# Incicator utils module

from functools import reduce
from math import ceil, nan
from typing import List
from pandas import DataFrame
import numpy as np

###################################################################################################
##################################### Public section ##############################################
###################################################################################################
def fix_NA(dataFrame: DataFrame):
    return dataFrame.replace({'#N/A': nan, '#n/a': nan, 'NA': nan, 'na': nan, 'N.A.': nan, 'n.a.': nan, '': nan})

###################################################################################################
def format_indicators_data(data_db, periodicity = 'A'):
    # find the lowest start year and normalize all vectors to the same start year
    start = reduce(lambda acc, row: row[3] if row[3] < acc else acc, data_db, 3000)
    data_db = map(__normalize_vector(start, periodicity), data_db)

    columns = ['Country AMECO', 'Variable Code', 'Scale Name', 'Start Year', 'Time Serie']
    df = DataFrame(data_db, columns=columns)
    values = df['Time Serie'].str.split(',', expand = True)
    values_length = len(values.columns)
    if periodicity == 'Q':
        years = range(start, start + ceil(values_length / 4))
        values.columns = [str(y) + 'Q' + str(q) for y in years for q in range(1,5)][:values_length]
    elif periodicity == 'M':
        years = range(start, start + ceil(values_length / 12))
        values.columns = [str(y) + 'M' + str(m) for y in years for m in range(1,13)][:values_length]
    else:
        values.columns = list(range(start, start + values_length))
    df = df.join(values)
    df = df.replace({'na': nan, '': nan})
    df = df.set_index(
        ['Country AMECO', 'Variable Code', 'Scale Name']
    ).drop(
        columns=['Start Year', 'Time Serie']
    )
    return df

###############################################################################################
def normalize_vector(
    start_year: int, vector: List[float], new_start_year: int, new_length: int, periodicity: str = 'A'
) -> List[float]:
    multiplier = 12 if periodicity == 'M' else (4 if periodicity == 'Q' else 1)
    result = np.array(vector)
    if new_start_year < start_year:
        empty = np.empty(multiplier * (start_year - new_start_year))
        empty[:] = np.nan
        result = np.concatenate((empty, result))

    if len(result) < new_length:
        empty = np.empty(new_length - len(result))
        empty[:] = np.nan
        result = np.concatenate((result, empty))
    elif len(result) > new_length:
        result = result[0:new_length]

    return result.tolist()

###############################################################################################
def str_to_float(value: str) -> float:
    try:
        return float(value)
    except:
        return np.nan

###################################################################################################
##################################### Private Section #############################################
###################################################################################################
def __normalize_vector(start: int, periodicity = 'A'):
    def process_row(row):
        prefix = ',' * (row[3] - start)
        if periodicity == 'Q':
            prefix = 4 * prefix
        elif periodicity == 'M':
            prefix = 12 * prefix
        return list(row[:3]) + [start, prefix + row[4]]
    return process_row
