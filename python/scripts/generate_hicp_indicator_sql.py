#-------------------------------------------------------------------------------------------------
# Generate HICP Indicator SQL 
# -----------------------------
# parametres : None
#-------------------------------------------------------------------------------------------------
import os
import logging
from datetime import datetime
import pandas as pd
import sdmx
from typing import Dict, List, Tuple

logging.basicConfig()
logging.root.setLevel(logging.NOTSET)

sql_file_name = 'hicp_indicators.sql'
file_path = '.'

sql_insert_template_code_rel = """
INSERT INTO HICP_INDICATOR_CODE_REL (PARENT_CODE_SID, CHILD_CODE_SID)
    SELECT INDICATOR_CODE_SID AS PARENT_CODE_SID,
    (SELECT INDICATOR_CODE_SID AS CHILD_CODE_SID FROM HICP_INDICATOR_CODES WHERE INDICATOR_ID = '{indicator_code}')
    FROM HICP_INDICATOR_CODES WHERE INDICATOR_ID = '{parent_indicator_code}';
"""

sql_insert_template = """
INSERT INTO HICP_INDICATOR_CODES (INDICATOR_ID, DESCR)
    VALUES ('{indicator_code}', '{indicator_descr}');
"""

sql_insert_template_index_datatype = """
INSERT INTO HICP_INDICATORS (INDICATOR_CODE_SID, PERIODICITY_ID, DATA_TYPE, EUROSTAT_CODE)
    SELECT HIC.INDICATOR_CODE_SID, 'M', 'I', '{eurostat_code}'
    FROM HICP_INDICATOR_CODES HIC WHERE HIC.INDICATOR_ID = '{indicator_code}';
"""

sql_insert_template_tax_rate_datatype = """
INSERT INTO HICP_INDICATORS (INDICATOR_CODE_SID, PERIODICITY_ID, DATA_TYPE, EUROSTAT_CODE)
    SELECT HIC.INDICATOR_CODE_SID, 'M', 'T', '{eurostat_code}'
    FROM HICP_INDICATOR_CODES HIC WHERE HIC.INDICATOR_ID = '{indicator_code}';
"""

sql_insert_template_weight_datatype = """
INSERT INTO HICP_INDICATORS (INDICATOR_CODE_SID, PERIODICITY_ID, DATA_TYPE, EUROSTAT_CODE)
    SELECT HIC.INDICATOR_CODE_SID, 'A', 'W', '{eurostat_code}'
    FROM HICP_INDICATOR_CODES HIC WHERE HIC.INDICATOR_ID = '{indicator_code}';
"""

root = None
current = None

#
# subroutines
#-------------------------------------------------------------
def getSQLInsertStatement( indicator_code, indicator_descr, parent_indicator_code, **kwargs ):

    global cps_midx_dict
    global cps_inw_dict
    global cps_tax_dict
    global cps_agg_midx_dict
    global cps_agg_inw_dict
    global cps_agg_tax_dict

    sql = sql_insert_template.format(indicator_code=indicator_code, indicator_descr=indicator_descr.replace("'", "''"))
    if parent_indicator_code != None:
        sql += sql_insert_template_code_rel.format(indicator_code=indicator_code, parent_indicator_code=parent_indicator_code)

    if indicator_code in cps_midx_dict or indicator_code in cps_agg_midx_dict:
        sql += sql_insert_template_index_datatype.format(indicator_code=indicator_code, eurostat_code='prc_hicp_midx|M.I15.{}.'.format(indicator_code))

    if indicator_code in cps_tax_dict or indicator_code in cps_agg_tax_dict:
        sql += sql_insert_template_tax_rate_datatype.format(indicator_code=indicator_code, eurostat_code='prc_hicp_cind|M.I15.{}.'.format(indicator_code))

    if indicator_code in cps_inw_dict or indicator_code in cps_agg_inw_dict:
        sql += sql_insert_template_weight_datatype.format(indicator_code=indicator_code, eurostat_code='prc_hicp_inw|A.{}.'.format(indicator_code))

    return sql

def addElement( code, descr, myFile, **kwargs ):

    global root
    global current
    global cps_agg_midx_dict
    global cps_agg_inw_dict

    if code in cps_agg_midx_dict or code in cps_agg_inw_dict:
        myFile.write(getSQLInsertStatement(indicator_code=code, indicator_descr=descr, parent_indicator_code=None))
    elif root is None and code == 'CP00':
        root = {
            'code': code,
            'descr': descr,
            'parent': None,
            'children': []
        }

        current = root
        myFile.write(getSQLInsertStatement(indicator_code=code, indicator_descr=descr, parent_indicator_code=None))
    else:
        if current.get('parent') is None or (len(code) >= len(current.get('code')) and code.startswith(current.get('code'))):
            tmp = {
                'code': code,
                'descr': descr,
                'parent': current,
                'children': []
            }
            current.get('children').append(tmp)
            myFile.write(getSQLInsertStatement(indicator_code=code, indicator_descr=descr, parent_indicator_code=current.get('code')))
            current = tmp
        else:
            current = current.get('parent')
            addElement(code, descr, myFile)

def addAggregatedRels(myFile):
    agg_indicator = '_AGG'
    sql = sql_insert_template.format(indicator_code=agg_indicator, indicator_descr='Aggregates')
    codes = [('FOOD_P', ['CP01111', 'CP01112', 'CP01113', 'CP01114', 'CP01115', 'CP01116', 'CP01117', 'CP01118', 'CP01127', 'CP01128', 'CP01132', 'CP01134', 'CP01135', 'CP01136', 'CP01141', 'CP01142', 'CP01143', 'CP01144', 'CP01145', 'CP01146', 'CP01151', 'CP01152', 'CP01153', 'CP01154', 'CP01155', 'CP01162', 'CP01163', 'CP01164', 'CP01172', 'CP01173', 'CP01174', 'CP01175', 'CP01176', 'CP01181', 'CP01182', 'CP01183', 'CP01184', 'CP01185', 'CP01186', 'CP01191', 'CP01192', 'CP01193', 'CP01194', 'CP01199', 'CP01211', 'CP01212', 'CP01213', 'CP01221', 'CP01222', 'CP01223', 'CP02111', 'CP02112', 'CP02121', 'CP02122', 'CP02123', 'CP02124', 'CP02131', 'CP02132', 'CP02133', 'CP02134', 'CP02201', 'CP02202', 'CP02203']),
             ('FOOD_NP', ['CP01121', 'CP01122', 'CP01123', 'CP01124', 'CP01125', 'CP01126', 'CP01131', 'CP01133', 'CP01147', 'CP01161', 'CP01171']),
             ('IGD_NNRG', ['IGD_NNRG_D', 'IGD_NNRG_SD', 'IGD_NNRG_ND']),
             ('IGD_NNRG_D', ['CP05111', 'CP05112', 'CP05113', 'CP05119', 'CP05121', 'CP05122', 'CP05311', 'CP05312', 'CP05313', 'CP05314', 'CP05315', 'CP05319', 'CP05321', 'CP05322', 'CP05323', 'CP05324', 'CP05329', 'CP05511', 'CP07111', 'CP07112', 'CP0712', 'CP0713', 'CP0714', 'CP08201', 'CP08202', 'CP08203', 'CP09111', 'CP09112', 'CP09113', 'CP09119', 'CP09121', 'CP09122', 'CP09123', 'CP09131', 'CP09132', 'CP09133', 'CP09134', 'CP09211', 'CP09212', 'CP09213', 'CP09214', 'CP09215', 'CP09221', 'CP09222', 'CP09322', 'CP12121', 'CP12311', 'CP12312']),
             ('IGD_NNRG_SD', ['CP0311', 'CP03121', 'CP03122', 'CP03123', 'CP03131', 'CP03132', 'CP03211', 'CP03212', 'CP03213', 'CP05201', 'CP05202', 'CP05203', 'CP05209', 'CP05401', 'CP05402', 'CP05403', 'CP05521', 'CP05522', 'CP06131', 'CP06132', 'CP06139', 'CP07211', 'CP07212', 'CP07213', 'CP09141', 'CP09142', 'CP09149', 'CP09311', 'CP09312', 'CP09321', 'CP09511', 'CP09512', 'CP09513', 'CP12131', 'CP12321', 'CP12322', 'CP12329']),
             ('IGD_NNRG_ND', ['CP0431', 'CP0441', 'CP05611', 'CP05612', 'CP0611', 'CP06121', 'CP06129', 'CP07224', 'CP09331', 'CP09332', 'CP09341', 'CP09342', 'CP09521', 'CP09522', 'CP0953', 'CP09541', 'CP09549', 'CP12132']),
             ('NRG', ['CP0451', 'CP04521', 'CP04522', 'CP0453', 'CP04541', 'CP04549', 'CP0455', 'CP07221', 'CP07222', 'CP07223']),
             ('SERV', ['SERV_COM', 'SERV_HOUS', 'SERV_REC', 'SERV_TRA', 'SERV_MSC']),
             ('SERV_COM', ['CP08101', 'CP08109', 'CP08204', 'CP08301', 'CP08302', 'CP08303', 'CP08304', 'CP08305']),
             ('SERV_HOUS', ['CP0411', 'CP04121', 'CP04122', 'CP04321', 'CP04322', 'CP04323', 'CP04324', 'CP04325', 'CP04329', 'CP0442', 'CP0443', 'CP04441', 'CP04442', 'CP04449', 'CP05123', 'CP0513', 'CP05204', 'CP0533', 'CP05404', 'CP05621', 'CP05622', 'CP05623', 'CP05629', 'CP1252']),
             ('SERV_REC', ['CP03141', 'CP03142', 'CP0322', 'CP0915', 'CP0923', 'CP09323', 'CP09411', 'CP09412', 'CP09421', 'CP09422', 'CP09423', 'CP09424', 'CP09425', 'CP09429', 'CP09514', 'CP09601', 'CP09602', 'CP11111', 'CP11112', 'CP1112', 'CP11201', 'CP11202', 'CP11203', 'CP12111', 'CP12112', 'CP12113']),
             ('SERV_TRA', ['CP0723', 'CP07241', 'CP07242', 'CP07243', 'CP07311', 'CP07312', 'CP07321', 'CP07322', 'CP07331', 'CP07332', 'CP07341', 'CP07342', 'CP0735', 'CP07361', 'CP07362', 'CP07369', 'CP12541', 'CP12542']),
             ('SERV_MSC', ['CP05512', 'CP05523', 'CP06133', 'CP06211', 'CP06212', 'CP0622', 'CP06231', 'CP06232', 'CP06239', 'CP63', 'CP0935', 'CP10101', 'CP10102', 'CP102', 'CP103', 'CP104', 'CP105', 'CP12122', 'CP12313', 'CP12323', 'CP12401', 'CP12402', 'CP12403', 'CP12404', 'CP12532', 'CP1255', 'CP12621', 'CP12622', 'CP12701', 'CP12702', 'CP12703', 'CP12704']),
             (agg_indicator, ['FOOD', 'FOOD_P', 'FOOD_NP', 'NRG', 'IGD_NNRG', 'SERV', 'TOT_X_NRG_FOOD', 'TOT_X_NRG_FOOD_NP'])]

    for (parent_code, child_codes) in codes:
        for code in child_codes:
            sql += sql_insert_template_code_rel.format(indicator_code=code, parent_indicator_code=parent_code)

    myFile.write(sql)


def getEurostatCOICOP(client: sdmx.Client, dataflow_id: str):

    df = client.dataflow(dataflow_id, params={'detail': 'referencepartial'})
    flow = next(iter(df.dataflow.items()))[1]

    coicop = None
    for dim in flow.structure.dimensions.components:
        if dim.id.upper() == 'COICOP':
            coicop = dim

    return coicop

def fetch_eurostat_dataflow(dataflow_id: str) -> Tuple[pd.DataFrame, pd.DataFrame]:
    print('*** Downloading {} from Eurostat ... ***'.format(dataflow_id))

    metadata = getEurostatCOICOP(estat, dataflow_id)
    codelist = sdmx.to_pandas(metadata.local_representation.enumerated).filter(like='CP')
    code_list_dict = codelist.to_dict()
    print('*** There are {} indicator codes in {}. ***'.format(len(code_list_dict), dataflow_id))

    # aggregated
    agg_codelist = sdmx.to_pandas(metadata.local_representation.enumerated).filter(items=aggregated_items)
    agg_codelist_dict = agg_codelist.to_dict()
    print('*** There are {} aggregated indicator codes in {}. ***'.format(len(agg_codelist_dict), dataflow_id))

    return codelist, agg_codelist

def generateSQLFile(file_path, sql_file_name, codes_dict):

    global root
    global current

    print('*** Generating SQL file {} ... ***'.format(file_path + sql_file_name))
    with open( file=os.path.join( file_path, sql_file_name), mode='w', encoding='utf-8' ) as myFile:

        theTimeNow = str(datetime.now().strftime('%d, %b %Y at %H:%M:%S'))
        myFile.write('--\n')
        myFile.write('-- This file contains both the EUROSTAT PRC_HICP_INW, PRC_HICP_MIDX and PRC_HICP_CIND list of indicators. It has been generated by generate_hicp_indicator_sql.py on the {}.\n'.format(theTimeNow))
        myFile.write('--\n')
        myFile.write('\n')
        myFile.write('SET DEFINE OFF;\n')
        myFile.write('DECLARE\n')
        myFile.write('BEGIN\n')
        myFile.write("   EXECUTE IMMEDIATE 'TRUNCATE TABLE HICP_INDICATOR_DATA';\n")
        myFile.write("   EXECUTE IMMEDIATE 'TRUNCATE TABLE HICP_INDICATORS';\n")
        myFile.write("   EXECUTE IMMEDIATE 'TRUNCATE TABLE HICP_INDICATOR_CODE_REL';\n")
        myFile.write("   EXECUTE IMMEDIATE 'TRUNCATE TABLE HICP_INDICATOR_CODES';\n")
        myFile.write('COMMIT;\n')

        root = None
        current = None

        for code, descr in codes_dict.items():
            if code not in ['TOT_X_CP041_042', 'CP00_X_042']:
                addElement(code, descr, myFile)

        addAggregatedRels(myFile)

        myFile.write('END;\n')
        myFile.write('/\n')
        myFile.write('--\n')
        myFile.write('-- This is the end of the file.\n')
        myFile.write('--\n')

        myFile.close()
        print('*** Generating SQL file {} successfully finished ***'.format(file_path + sql_file_name))

#
# Main routine
# --------------------------------------------------------------------

estat = sdmx.Client('ESTAT')
aggregated_items = ['TOT_X_NRG_FOOD', 'TOT_X_NRG_FOOD_NP', 'NRG', 'IGD_NNRG', 'IGD_NNRG_D', 'IGD_NNRG_SD', 'IGD_NNRG_ND', 'FOOD', 'FOOD_NP', 'FOOD_P', 'SERV', 'SERV_COM', 'SERV_HOUS', 'SERV_REC', 'SERV_TRA', 'SERV_MSC']

cps_midx, cps_agg_midx = fetch_eurostat_dataflow('prc_hicp_midx')
cps_inw, cps_agg_inw = fetch_eurostat_dataflow('prc_hicp_inw')
cps_tax, cps_agg_tax = fetch_eurostat_dataflow('prc_hicp_cind')

# check index and weights
cps = pd.concat([cps_midx, cps_inw, cps_tax, cps_agg_midx, cps_agg_inw, cps_agg_tax], axis=0).to_dict()
print('*** After merging both data sets, there are {} indicator unique codes. ***'.format(len(cps)))

cps_len = len(cps)
if (cps_len != (len(cps_midx) + len(cps_agg_midx)) or cps_len != (len(cps_inw) + len(cps_agg_inw))):
    print('!!! Warning, the expectation was for the lengths of index and weights to match. !!!')

# check constant tax rates
tax_len = len(cps_tax) + len(cps_agg_tax)
if (cps_len != tax_len):
    print(f' !!!Warning, Constant tax rates dataset has {tax_len} items, whereas index dataset has: {cps_len} items! !!!')


cps_midx_dict = cps_midx.to_dict()
cps_agg_midx_dict = cps_agg_midx.to_dict()
cps_inw_dict = cps_inw.to_dict()
cps_agg_inw_dict = cps_agg_inw.to_dict()
cps_tax_dict = cps_tax.to_dict()
cps_agg_tax_dict = cps_agg_tax.to_dict()

generateSQLFile(file_path, sql_file_name, cps)
