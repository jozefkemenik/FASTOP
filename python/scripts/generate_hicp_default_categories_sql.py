#-------------------------------------------------------------------------------------------------
# Generate HICP categories SQLs
# -----------------------------
# parameters : None
#-------------------------------------------------------------------------------------------------
import logging
import os
import yaml

logging.basicConfig()
logging.root.setLevel(logging.NOTSET)

sql_category_file_name = 'hicp_category.sql'
sql_category_rel_file_name = 'hicp_category_rel.sql'
sql_indicator_category_file_name = 'hicp_indicator_code_category.sql'

input_file_path = './data/hicp_categories_config.yaml'
output_file_path = './out'

try:
    os.mkdir(output_file_path)
except:
    print(f'{output_file_path} already exists')


generated_categories = set()
assigned_indicators = set()

sql_level_1_2 = """
INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ORDER_BY)
    VALUES ('{category_id}', '{descr}', {order_by});
"""

sql_level_3 = """
INSERT INTO HICP_CATEGORY (CATEGORY_ID, DESCR, ROOT_INDICATOR_ID, BASE_INDICATOR_ID, ORDER_BY)
    VALUES ('{category_id}', '{descr}', '{root_id}', '{base_indicator_id}', {order_by});
"""

sql_indicator_code_category = """
INSERT INTO HICP_INDICATOR_CODE_CATEGORY(INDICATOR_ID, CATEGORY_SID)
    SELECT '{indicator_id}', CATEGORY_SID FROM HICP_CATEGORY WHERE CATEGORY_ID = '{category_id}';
"""

sql_category_rel = """
INSERT INTO HICP_CATEGORY_REL(PARENT_CATEGORY_SID, CHILD_CATEGORY_SID)
   SELECT
     (select category_sid from HICP_CATEGORY where category_id = '{parent_category_id}') as parent_category_sid,
     (select category_sid from HICP_CATEGORY where category_id = '{child_category_id}') as child_category_sid
   FROM dual;     
"""

def level_1_2(file_handler, category_id, descr, order_by):
    if category_id not in generated_categories:
        file_handler.write(
            sql_level_1_2.format(category_id=category_id, descr=descr, order_by=order_by)
        )
        generated_categories.add(category_id)

def level_3(file_handler, category_id, descr, root_id, base_indicator_id, order_by):
    if category_id not in generated_categories:
        file_handler.write(
            sql_level_3.format(
                category_id=category_id, descr=descr, root_id=root_id, base_indicator_id=base_indicator_id, order_by=order_by
            )
        )
        generated_categories.add(category_id)

def category_rel(file_handler, parent_category_id, child_category_id):
    file_handler.write(
        sql_category_rel.format(
            parent_category_id=parent_category_id, child_category_id=child_category_id
        )
    )

def assign_indicators_to_category(file_handler, category_id, indicators):
    file_handler.write(f'\n-- category: {category_id}')

    for indicator_id in indicators:
        key = f'{category_id}_{indicator_id}'
        if key not in assigned_indicators:
            file_handler.write(
                sql_indicator_code_category.format(category_id=category_id, indicator_id=indicator_id)
            )
            assigned_indicators.add(key)

def get_config():
    input_path = os.path.join(input_file_path)

    with open( file=input_path, mode='r', encoding='utf-8' ) as f:
        yaml_config = yaml.load(f, Loader=yaml.FullLoader)

        # remove dictionary
        del yaml_config['dictionary']
    return yaml_config


# --------------------------------------------------------------------
# Main routine
# --------------------------------------------------------------------

config = get_config()

path_category_sql = os.path.join( output_file_path, sql_category_file_name)
path_category_rel_sql = os.path.join( output_file_path, sql_category_rel_file_name)
path_indicator_category_sql = os.path.join( output_file_path, sql_indicator_category_file_name)

print(
    '*** Generating hicp categories file {}, category relation file {} and hicp indicator code category file  {} ***'.format(
        path_category_sql, path_category_rel_sql, path_indicator_category_sql
    )
)

with (open( file=path_category_sql, mode='w', encoding='utf-8' ) as category_file,
      open( file=path_category_rel_sql, mode='w', encoding='utf-8' ) as category_rel_file,
      open( file=path_indicator_category_sql, mode='w', encoding='utf-8' ) as indicator_file) :

    category_file.write('SET DEFINE OFF;\n\n')
    category_file.write('-- Delete "default" categories, keep user defined categories\n')
    category_file.write("DELETE FROM HICP_INDICATOR_CODE_CATEGORY WHERE CATEGORY_SID IN (SELECT CATEGORY_SID FROM HICP_CATEGORY WHERE OWNER = 'DEFAULT');\n")
    category_file.write('TRUNCATE TABLE HICP_CATEGORY_REL;\n')
    category_file.write("DELETE FROM HICP_CATEGORY WHERE OWNER = 'DEFAULT';\n\n")

    category_rel_file.write('SET DEFINE OFF;\n\n')
    indicator_file.write('SET DEFINE OFF;\n\n')


    order1 = 1
    order2 = 100
    order3 = 1000


    for key1, item1 in config.items():
        # generate level1
        level_1_2(category_file, key1, item1["label"], order1)
        order1 = order1 + 1

        for key2, item2 in item1["children"].items():
            # generate level2
            level_1_2(category_file, key2, item2["label"], order2)
            order2 = order2 + 1

            category_rel(category_rel_file, key1, key2)

            for key3, item3 in item2["children"].items():
                # generate level3
                level_3(category_file, key3, item3["label"], item3["root"], item3["base"], order3)

                order3 = order3 + 1
                category_rel(category_rel_file, key2, key3)

                # generate indicator to category assignment
                assign_indicators_to_category(indicator_file, key3, item3["indicators"])


    category_file.write('\nCOMMIT;\n')
    category_rel_file.write('\nCOMMIT;\n')
    indicator_file.write('\nCOMMIT;\n')

    category_file.close()
    indicator_file.close()

print('*** All done ***')

