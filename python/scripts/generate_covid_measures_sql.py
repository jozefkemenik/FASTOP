import os
import pandas as pd
from typing import List

input_file = 'covid_measures.xlsx'
input_folder = 'data'
input_path = os.path.join(input_folder, input_file)

print(f'*** Reading input file: {input_path} ***')

df = pd.read_excel(input_path)
df[['Country', 'Indicator code']] = df['CODE'].str.split(pat='.', n=1, expand=True)
df = df.drop(columns=['CODE'])

# find timeserie columns and start year
years = [col for col in list(df.columns) if type(col) == int]
years.sort()
p_start_year = years[0]
p_app_id = 'FDMS'
p_provider_id = 'COVID'
p_periodicity_id = 'A'
p_scale_id='BILLION'
p_user = 'MANUAL'
p_add_missing = 1


output_folder = 'out'
output_file = 'insert_covid_measures.sql'
output_path = os.path.join(output_folder, output_file)

sql = """
  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => '{p_app_id}',
    p_country_id => '{p_country_id}',
    p_indicator_ids => {p_indicator_ids}, 
    p_provider_id => '{p_provider_id}', 
    p_periodicity_id => '{p_periodicity_id}', 
    p_scale_id => '{p_scale_id}', 
    p_start_year => {p_start_year}, 
    p_time_series => {p_time_series}, 
    p_user => '{p_user}', 
    p_add_missing => {p_add_missing},
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);
"""

sql_upload_info = """
  fdms_upload.setIndicatorDataUpload(
      p_round_sid => l_round_sid,
      p_storage_sid => l_storage_sid,
      p_provider_id => '{p_provider_id}',
      p_user => '{p_user}', 
      o_res => o_res);        
"""

def varchar_array(items: List) -> str:
    params = ",".join([f'{index+1}=>\'{val}\'' for (index, val) in enumerate(items)])
    return f'CORE_COMMONS.VARCHARARRAY({params})'


with open(file=output_path, mode='w', encoding='utf-8') as myFile:
    myFile.write('SET DEFINE OFF;\n\n')
    myFile.write('DECLARE\n')
    myFile.write('    o_res  NUMBER(8);\n')
    myFile.write(f"    l_round_sid ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid('{p_app_id}');\n")
    myFile.write(f"    l_storage_sid STORAGES.STORAGE_SID%TYPE := CORE_GETTERS.getCurrentStorageSid('{p_app_id}');\n")
    myFile.write('BEGIN\n')

    for country_id, group in df.groupby('Country'):
        p_indicator_ids = []
        p_time_series = []

        for idx in group.index:
            p_indicator_ids.append(group['Indicator code'][idx])
            ts = ','.join([str(group[year][idx]) for year in years])
            p_time_series.append(ts)

        myFile.write(
            sql.format(
                p_app_id=p_app_id,
                p_country_id=country_id,
                p_indicator_ids=varchar_array(p_indicator_ids),
                p_provider_id=p_provider_id,
                p_periodicity_id=p_periodicity_id,
                p_scale_id=p_scale_id,
                p_start_year=p_start_year,
                p_time_series=varchar_array(p_time_series),
                p_user=p_user,
                p_add_missing=p_add_missing
            )
        )

    myFile.write('\n')
    myFile.write(sql_upload_info.format(
        p_provider_id=p_provider_id,
        p_user=p_user
    ))

    myFile.write('END;\n')
    myFile.write('/')

print(f'*** All done, output: {output_path} ***')
