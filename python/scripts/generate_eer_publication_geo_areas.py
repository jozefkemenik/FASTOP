import os
from typing import List


sql_insert_group_member = """
INSERT INTO EER_PUBLICATION_GEO_AREAS(GEO_GROUP_SID, GEO_AREA_ID, ORDER_BY)
  SELECT GEO_GROUP_SID, '{geo_area_id}', {order_by} FROM EER_GEO_GROUP WHERE GEO_GROUP_ID = '{group_id}';
"""


def get_insert_sql(geo_group_id: str, members: List[str]) -> str:
    sql = f'\n-- {geo_group_id}'
    for index, member in enumerate(members):
        sql += sql_insert_group_member.format(geo_area_id=member, group_id=geo_group_id, order_by=index + 1)

    sql += '\n'
    return sql


file_path = '.'
sql_file_name = 'eer_publication_geo_areas.sql'

print('Generating eer publication geo areas')

with open( file=os.path.join( file_path, sql_file_name), mode='w', encoding='utf-8' ) as myFile:
    sql = 'SET DEFINE OFF;\n'
    sql += 'TRUNCATE TABLE EER_PUBLICATION_GEO_AREAS;\n'

    # EA19
    sql += get_insert_sql(
        'EA19',
        ['BE', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'IT', 'CY', 'LV', 'LT', 'LU', 'MT', 'NL', 'AT', 'PT', 'SI', 'SK', 'FI', 'BG', 'CZ', 'DK', 'HR', 'HU', 'PL', 'RO', 'SE', 'UK', 'NO', 'CH', 'TR', 'RU', 'US', 'CA', 'MX', 'BR', 'AU', 'NZ', 'JP', 'CN', 'HK', 'KR']
    )

    # EA20
    sql += get_insert_sql(
        'EA20',
        ['BE', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'MT', 'NL', 'AT', 'PT', 'SI', 'SK', 'FI', 'BG', 'CZ', 'DK', 'HU', 'PL', 'RO', 'SE', 'UK', 'NO', 'CH', 'TR', 'RU', 'US', 'CA', 'MX', 'BR', 'AU', 'NZ', 'JP', 'CN', 'HK', 'KR', 'EA19']
    )

    # EU27
    sql += get_insert_sql(
        'EU27',
        ['BE', 'BG', 'CZ', 'DK', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'HU', 'MT', 'NL', 'AT', 'PL', 'PT', 'RO', 'SI', 'SK', 'FI', 'SE', 'UK', 'NO', 'CH', 'TR', 'RU', 'US', 'CA', 'MX', 'BR', 'AU', 'NZ', 'JP', 'CN', 'HK', 'KR', 'EA19', 'EA20']
    )

    # IC37
    sql += get_insert_sql(
        'IC37',
        ['BE', 'BG', 'CZ', 'DK', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'HU', 'MT', 'NL', 'AT', 'PL', 'PT', 'RO', 'SI', 'SK', 'FI', 'SE', 'UK', 'NO', 'CH', 'TR', 'US', 'CA', 'MX', 'AU', 'NZ', 'JP', 'RU', 'BR', 'CN', 'HK', 'KR', 'EU27', 'EA19', 'EA20']
    )

    # GR42
    sql += get_insert_sql(
        'GR42',
        ['BE', 'BG', 'CZ', 'DK', 'DE', 'EE', 'IE', 'EL', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'HU', 'MT', 'NL', 'AT', 'PL', 'PT', 'RO', 'SI', 'SK', 'FI', 'SE', 'UK', 'NO', 'CH', 'TR', 'RU', 'US', 'CA', 'MX', 'BR', 'AU', 'NZ', 'JP', 'CN', 'HK', 'KR', 'EU27', 'EA19', 'EA20']
    )

    myFile.write(sql)
    myFile.write('/\n')
    myFile.write('COMMIT;\n')
    myFile.close()

print('Generating eer publication geo areas - finished')
