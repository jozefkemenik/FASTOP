#-------------------------------------------------------------------------------------------------
# Generate sql to populate FDMS_INDICATOR_TREE table
# ---------------------------------------------------
# Source: csv dump from ameco internal db:
# sql:
#     SELECT
#            id as SID,
#            code_serie as CODE,
#            nom_serie as DESCR,
#            niv_serie as LEVEL,
#            node_type as NODE_TYPE,
#            num_ordre as ORDER_BY,
#            code_chap as PARENT_CODE
#       FROM ameco_internal.arbre
#   ORDER BY niv_serie, num_ordre;
#-------------------------------------------------------------------------------------------------

import csv
import math

from collections import namedtuple
from pathlib import Path
from pydantic import BaseModel
from typing import Any, Dict, List, Optional


class TreeData(BaseModel):
    code: str
    descr: Optional[str]
    order_by: Optional[int]
    parent_code: Optional[str]
    level: str
    new_code: str

class TreeNode(BaseModel):
    data: TreeData
    children: Optional[List[Any]]

UNIQUE_CODES = set()
INDICATOR_IDS = set()

def get_ameco_tree(input_filepath):
    result = []
    with open(input_filepath) as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        Data = namedtuple('Data', next(reader))  # get names from column headers
        for data in map(Data._make, reader):
            result.append(data)

    return result

def get_abbreviation(tokens: List[str]) -> str:
    buff = []
    for token in tokens:
        if len(token) > 0:
            alfa = ''.join([c for c in token if c.isalnum()])
            if len(alfa) > 0:
                buff.append(alfa[0])

    return ''.join(buff)


def generate_code(code: str, descr: str, level: str) -> str:
    tokens = descr.upper().split(' ')
    try:
        new_code = (tokens[0] if len(tokens) == 1 else get_abbreviation(tokens))[0:5]
        if new_code in UNIQUE_CODES:
            new_code = f'{new_code}{code}{level}'
            if new_code in UNIQUE_CODES:
                new_code = f'{new_code}'
                if new_code in UNIQUE_CODES:
                    raise Exception(f'New code not unique: {new_code}, desc: {descr}')
        UNIQUE_CODES.add(new_code)
        if level == '3':
            INDICATOR_IDS.add(code)

        return new_code
    except IndexError as ex:
        print(f'Exception: {ex}, descr: {descr}')
        raise ex

def tree_data(data) -> TreeData:
    # Data(SID='1', CODE='1', DESCR='POPULATION AND EMPLOYMENT', LEVEL='1', NODE_TYPE='N', ORDER_BY='100000', PARENT_CODE='1')
    code = data.CODE
    parent_code = data.PARENT_CODE
    new_code = generate_code(code, data.DESCR, data.LEVEL)
    return TreeData(code=code, descr=data.DESCR, order_by=data.ORDER_BY, parent_code=parent_code, level=data.LEVEL, new_code=new_code)


def level_key(level: str, code: str, parent_code: str = None) -> str:
    key = f'{level}_{code}'
    return key if parent_code is None else f'{key}_{parent_code}'


def add_child(parent: TreeNode, child: TreeNode):
    if parent.children is None:
        parent.children = []
    parent.children.append(child)

def build_tree(ameco) -> List[TreeNode]:

    nodes = dict()
    for item in ameco:
        data = tree_data(item)
        node = TreeNode(data=data)

        if data.level == '1':
            nodes[level_key(data.level, data.code)] = node
        elif data.level == '2':
            nodes[level_key(data.level, data.code, data.parent_code)] = node
            add_child(nodes[level_key('1', data.parent_code)], node)
        elif data.level == '3':
            code = math.floor((data.order_by - (float(data.parent_code) * 100000)) / 1000.0)
            add_child(nodes[level_key('2', code, data.parent_code)], node)

    return [i for i in list(nodes.values()) if i.data.level == '1']

def to_sql(data: TreeData, parent: Optional[TreeData]) -> str:
    insert_root_sql = "Insert into FDMS_INDICATOR_TREE\n   (CODE, DESCR, ORDER_BY)\n Values ('{code}', '{desc}', {order_by});\n"
    insert_sql = "Insert into FDMS_INDICATOR_TREE\n   (CODE, DESCR, ORDER_BY, PARENT_CODE)\n Values ('{code}', '{desc}', {order_by}, '{parent_code}');\n"
    insert_sql_leaf = "Insert into FDMS_INDICATOR_TREE\n   (CODE, DESCR, ORDER_BY, INDICATOR_ID, PARENT_CODE)\n Values ('{code}', '{desc}', {order_by}, '{ind_id}', '{parent_code}');\n"

    sql = insert_root_sql if parent is None else (insert_sql_leaf if data.level == '3' else insert_sql)

    return sql.format(
        code=data.new_code, desc=data.descr, order_by=data.order_by,
        parent_code=(parent.new_code if parent is not None else None),
        ind_id=(data.code if data.level == '3' else None)
    )

def process_node(node: TreeNode, buff: List[str], parent: TreeNode = None):
    data = node.data
    buff.append(to_sql(data, None if parent is None else parent.data))
    if node.children is not None:
        for child in node.children:
            process_node(child, buff, node)


def tree_to_sql(tree):
    buff = ['SET DEFINE OFF;\nTRUNCATE TABLE FDMS_INDICATOR_TREE;\n']

    for i in tree:
        process_node(i, buff)

    buff.append('\nCOMMIT;\n')
    return '\n'.join(buff)


def save_to_file(text, filePath):
    output_file = Path(filePath)
    output_file.parent.mkdir(exist_ok=True, parents=True)
    output_file.write_text(text)


def main():

    input_filepath = './data/ameco_internal_prod_tree.csv'
    output_filepath = './out/indicator_tree.sql'

    ameco = get_ameco_tree(input_filepath)
    tree = build_tree(ameco)
    sql = tree_to_sql(tree)
    save_to_file(sql, output_filepath)

    print(f'Sql generated')

main()
