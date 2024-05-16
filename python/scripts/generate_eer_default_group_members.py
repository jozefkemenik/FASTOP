import os
from typing import List


sql_insert_group_member = """
INSERT INTO EER_GEO_GROUP_MEMBER(GEO_GROUP_SID, GEO_AREA_ID, ORDER_BY)
  SELECT GEO_GROUP_SID, '{geo_area_id}', {order_by} FROM EER_GEO_GROUP WHERE GEO_GROUP_ID = '{group_id}';
"""


def get_insert_sql(geo_group_id: str, members: List[str]) -> str:
    sql = f'\n-- {geo_group_id}'
    for index, member in enumerate(members):
        sql += sql_insert_group_member.format(geo_area_id=member, group_id=geo_group_id, order_by=index + 1)

    sql += '\n'
    return sql


file_path = '.'
sql_file_name = 'eer_geo_group_member.sql'

print('Generating eer default group members')

with open( file=os.path.join( file_path, sql_file_name), mode='w', encoding='utf-8' ) as myFile:
    sql = 'SET DEFINE OFF;\n'
    sql += 'TRUNCATE TABLE EER_GEO_GROUP_MEMBER;\n'

    # EA19
    sql += get_insert_sql(
        'EA19',
        ['BE', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'IT', 'CY', 'LU', 'MT', 'NL', 'AT', 'PT', 'SI', 'SK', 'FI', 'LV', 'LT']
    )

    # EA20
    sql += get_insert_sql(
        'EA20',
        ['BE', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'IT', 'CY', 'LU', 'MT', 'NL', 'AT', 'PT', 'SI', 'SK', 'FI', 'LV', 'LT', 'HR']
    )

    # EU27
    sql += get_insert_sql(
        'EU27',
        ['BE', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'IT', 'CY', 'LU', 'MT', 'NL', 'AT', 'PT', 'SI', 'SK', 'FI', 'BG', 'CZ', 'DK', 'LV', 'LT', 'HU', 'PL', 'RO', 'SE', 'HR']
    )

    # IC37
    sql += get_insert_sql(
        'IC37',
        ['BE', 'BG', 'CZ', 'DK', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'HU', 'MT', 'NL',
         'AT', 'PL', 'PT', 'RO', 'SI', 'SK', 'SE', 'FI', 'UK', 'NO', 'CH', 'TR', 'US', 'CA', 'MX', 'AU', 'NZ', 'JP']
    )

    # GR42
    sql += get_insert_sql(
        'GR42',
        ['BE', 'BG', 'CZ', 'DK', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'HU', 'MT', 'NL', 'AT', 'PL',
         'PT', 'RO', 'SI', 'SK', 'SE', 'FI', 'UK', 'NO', 'CH', 'TR', 'US', 'CA', 'MX', 'AU', 'NZ', 'JP', 'RU', 'BR', 'CN', 'HK', 'KR']
    )

    myFile.write(sql)
    myFile.write('/\n')
    myFile.write('COMMIT;\n')
    myFile.close()

print('Generating eer default group members - finished')
