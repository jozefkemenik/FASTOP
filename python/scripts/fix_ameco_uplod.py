#-------------------------------------------------------------------------------------------------
# Fix Ameco input data scales
# -----------------------------
# parametres : argv[]
# sys.argv[1] = path to the input data file
# sys.argv[2] = path to the output data file
# sys.argv[3] = path to the scale conversion file, default: ./data/ameco_scale_mapping.csv
#-------------------------------------------------------------------------------------------------
import sys
from typing import Dict, List

if len(sys.argv) < 3 or len(sys.argv) > 4:
    print ('usage:', __file__, '[input data file] [output data file] [ameco scale mapping file]' )
    sys.exit()
else:
    scale_mapping_file = sys.argv[3] if len(sys.argv) == 4 else './data/ameco_scale_mapping.csv'

input_file = sys.argv[1]
output_file = sys.argv[2]
print(f'Fixing missing scales:\n  {input_file}   =>   {output_file}')


def is_valid_row(row: List[str]) -> bool:
    # Ignore Western Germany and duplicated header rows
    return row[0].upper() != 'CODE' and not row[0].upper().startswith('D_W.')


def fix_row_data(row: List[str]) -> List[str]:
    # Fix Romania country code ROM => ROU
    if row[0].upper().startswith('ROM.'):
        row[0] = row[0].upper().replace('ROM.', 'RUE.', 1)

    return row


def read_input() -> List[List[str]]:
    with open(input_file, 'r') as fh:
        lines = fh.readlines()

    result = []
    for idx, line in enumerate(lines):
        row = line.strip().split(',')
        if idx == 0 or is_valid_row(row):
            result.append(fix_row_data(row))

    return result


def read_scales() -> Dict[str, str]:
    with open(scale_mapping_file, 'r') as fh:
        lines = fh.readlines()

    scales = dict()
    # Skip first line (header)
    for line in lines[1:]:
        code, scale = line.rstrip().split(',')
        scales[code] = scale

    return scales


def get_ameco_code(code: str) -> str:
    tmp = code.split('.')
    return '.'.join(tmp[1:]).upper()


def ameco_key(code: str):
    tmp = code.split('.')[1:]
    tmp.insert(0, tmp.pop())
    return '.'.join(tmp)


def find_new_scale(code: str, file_scales: Dict, mapping: Dict) -> str:
    if code in mapping:
        return mapping[code]

    scale_set = file_scales[code]
    if not scale_set:
        return
    elif len(scale_set) > 1:
        print(f'Cannot determine valid scale for: {code}\n  - possible scales: {scale_set}')
        return
    else:
        return next(iter(scale_set))


def fix_scales(rows: List[List[str]], mapping: Dict[str, str]):
    scales = dict()
    for row in rows[1:]:
        code = get_ameco_code(row[0])
        scale = row[2]
        if scale:
            if code not in scales:
                scales[code] = set()
            scales[code].add(scale.upper())

    codes_no_scales = set()
    for row in rows[1:]:
        code = get_ameco_code(row[0])
        scale = row[2]
        if not scale:
            new_scale = find_new_scale(code, scales, mapping)
            if not new_scale:
                codes_no_scales.add(code)
                print(f'No scale found for: {code}')
            else:
                new_scale_cc = new_scale.lower()[0].upper() + new_scale.lower()[1:]
                print(f'Fixed scale for row {row[0]}\n  - new scale: {new_scale_cc}')
                row[2] = new_scale_cc

    print('\nCodes without scales: ')
    codes_list = list(codes_no_scales)
    codes_list.sort(key=ameco_key)
    [print(code) for code in codes_list]


def save_output(rows: List[List[str]]):
    with open(output_file, 'w') as fh:
        for row in rows:
            fh.write(','.join(row) + '\n')


rows = read_input()
scales_mapping = read_scales()
fix_scales(rows, scales_mapping)
save_output(rows)

print(f'\nConversion done. Output saved to: {output_file}')
