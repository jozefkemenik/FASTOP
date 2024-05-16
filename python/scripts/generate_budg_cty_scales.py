import os

budg_indicators = {
    'DMGE.1.0.99.0': 'BILLION_E',
    'HVGDP.1.0.0.0': 'THOUSAND_NC',
    'HVGDP.1.0.212.0': 'THOUSAND_PPS',
    'HVGDP.1.0.99.0': 'THOUSAND_E',
    'HVGNP.1.0.0.0': 'THOUSAND_NC',
    'HVGNP.1.0.212.0': 'THOUSAND_PPS',
    'HVGNP.1.0.99.0': 'THOUSAND_E',
    'NPTD.1.0.0.0': 'THOUSAND',
    'OVGN.1.0.0.0': 'BILLION',
    'OVGN.1.0.99.0': 'BILLION_E',
    'PCPH.3.1.0.0': 'UNIT',
    'PCPH.3.1.99.0': 'UNIT',
    'PVGD.3.1.0.0': 'UNIT',
    'PVGD.3.1.99.0': 'UNIT',
    'PVGD.6.1.0.0': 'UNIT',
    'PVGD.6.1.99.0': 'UNIT',
    'UCPH.1.0.0.0': 'BILLION',
    'UCPH.1.0.99.0': 'BILLION_E',
    'UCTG0.1.0.0.0': 'BILLION',
    'UCTG0.1.0.99.0': 'BILLION_E',
    'UGSG.1.0.0.0': 'BILLION',
    'UGSG.1.0.99.0': 'BILLION_E',
    'UIGG0.1.0.0.0': 'BILLION',
    'UIGG0.1.0.99.0': 'BILLION_E',
    'UKCG0.1.0.0.0': 'BILLION',
    'UKCG0.1.0.99.0': 'BILLION_E',
    'UUTG.1.0.99.0': 'BILLION_E',
    'UUTGI.1.0.99.0': 'BILLION_E',
    'UVGD.1.0.0.0': 'BILLION',
    'UVGD.1.0.99.0': 'BILLION_E',
    'UVGN.1.0.0.0': 'BILLION',
    'UVGN.1.0.99.0': 'BILLION_E',
    'UWCG.1.0.0.0': 'BILLION',
    'UWCG.1.0.99.0': 'BILLION_E',
    'XNE.1.0.99.0': 'UNIT',
    'ZCPIH.6.0.0.0': 'UNIT'
}


sql_insert_cty_indicator_scales = """
INSERT INTO FDMS_CTY_INDICATOR_SCALES(COUNTRY_ID, INDICATOR_SID, SCALE_SID)  
SELECT G.GEO_AREA_ID
     , (SELECT INDICATOR_SID FROM VW_FDMS_INDICATORS WHERE PROVIDER_ID = 'BUDG' AND PERIODICITY_ID = 'A' AND INDICATOR_ID = '{indicator_id}') AS INDICATOR_SID
     , (SELECT SCALE_SID FROM FDMS_SCALES WHERE SCALE_ID = '{scale_id}') AS SCALE_SID
  FROM GEO_AREAS G 
  JOIN COUNTRY_GROUPS CG 
    ON CG.COUNTRY_ID = G.GEO_AREA_ID 
 WHERE UPPER(CG.COUNTRY_GROUP_ID) = UPPER('BUDG');
"""


def get_insert_sql(indicator_id: str, scale_id: str) -> str:
    sql = sql_insert_cty_indicator_scales.format(indicator_id=indicator_id, scale_id=scale_id)
    sql += '\n'

    return sql


file_path = '.'
sql_file_name = 'cty_indicator_scales.sql'

print('Generating budg cty indicator scales')

with open( file=os.path.join( file_path, sql_file_name), mode='w', encoding='utf-8' ) as myFile:
    sql = 'SET DEFINE OFF;\n'
    sql += '\n-- BUDG indicators\n'

    for indicator_id, scale_id in budg_indicators.items():
        sql += get_insert_sql(indicator_id, scale_id)

    myFile.write(sql)
    myFile.write('/\n')
    myFile.write('COMMIT;\n')
    myFile.close()

print('Generating budg cty indicator scales - finished')
