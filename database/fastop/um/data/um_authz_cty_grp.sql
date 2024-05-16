SET DEFINE OFF;
Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-ALL', COLUMN_VALUE
    From sys.odcivarchar2list('AL','BA','ME','MK','NO','RS','TR','XK','AT','BE','BG','CY','CZ','DE','DK','EE','EL','ES','FI','FR','HR','HU','IE','IT','LT','LU','LV','MT','NL','PL','PT','RO','SE','SI','SK','UK','AR','AU','BR','CA','CH','CN','HK','ID','IN','JP','KR','LATAM','MENA','MX','NZ','OASIA','OCIS','OLATAM','RU','SA','SG','SSA','TW','US','ZA');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_E.1', COLUMN_VALUE
    From sys.odcivarchar2list('BE', 'FR', 'LU');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_E.2', COLUMN_VALUE
    From sys.odcivarchar2list('EE', 'LV', 'LT', 'NL');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_E.3', COLUMN_VALUE
    From sys.odcivarchar2list('BG', 'RO', 'SE');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_F.1', COLUMN_VALUE
    From sys.odcivarchar2list('AT', 'CY', 'DE');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_F.3', COLUMN_VALUE
    From sys.odcivarchar2list('HR', 'ES');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_F.4', COLUMN_VALUE
    From sys.odcivarchar2list('FI', 'HU', 'SI');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_G.1', COLUMN_VALUE
    From sys.odcivarchar2list('CZ', 'PL', 'SK');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_G.2', COLUMN_VALUE
    From sys.odcivarchar2list('DK', 'IE', 'PT');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_G.3', COLUMN_VALUE
    From sys.odcivarchar2list('IT', 'MT');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY_DESK_D.1', COLUMN_VALUE
    From sys.odcivarchar2list('MK', 'ME', 'AL', 'CH', 'RS', 'TR', 'IS', 'NO');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-CTY-EUCAM', COLUMN_VALUE
    From sys.odcivarchar2list('AT', 'BE', 'BG', 'CY', 'CZ', 'DE', 'DK', 'EE', 'EL', 'ES', 'FI', 'FR', 'HR', 'HU', 'IE', 'IT', 'LT', 'LU', 'LV', 'MT', 'NL', 'PL', 'PT', 'RO', 'SE', 'SI', 'SK', 'UK', 'AR', 'AU', 'BR', 'CA', 'CH', 'CN', 'HK', 'ID', 'IN', 'IS', 'JP', 'KR', 'LATAM', 'MENA', 'MX', 'NZ', 'OASIA', 'OCIS', 'OLATAM', 'RU', 'SA', 'SG', 'SSA', 'TW', 'US', 'ZA');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-GBL-ECON', COLUMN_VALUE
    From sys.odcivarchar2list('AR', 'AU', 'BR', 'CA', 'CN', 'HK', 'ID', 'IN', 'JP', 'KR', 'LATAM', 'MENA', 'MX', 'NZ', 'OASIA', 'OCIS', 'OLATAM', 'RU', 'SA', 'SG', 'SSA', 'TW', 'UK', 'US', 'ZA');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMS-SU', COLUMN_VALUE
    From sys.odcivarchar2list('AL', 'BA', 'ME', 'MK', 'NO', 'RS', 'TR', 'XK', 'AT', 'BE', 'BG', 'CY', 'CZ', 'DE', 'DK', 'EE', 'EL', 'ES', 'FI', 'FR', 'HR', 'HU', 'IE', 'IT', 'LT', 'LU', 'LV', 'MT', 'NL', 'PL', 'PT', 'RO', 'SE', 'SI', 'SK', 'UK', 'AR', 'AU', 'BR', 'CA', 'CH', 'CN', 'HK', 'ID', 'IN', 'JP', 'KR', 'LATAM', 'MENA', 'MX', 'NZ', 'OASIA', 'OCIS', 'OLATAM', 'RU', 'SA', 'SG', 'SSA', 'TW', 'US', 'ZA');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMSIE-CTY_DESK_D.1', COLUMN_VALUE
    From sys.odcivarchar2list('BA', 'ME', 'TR', 'XK', 'NO', 'AL', 'RS', 'MK');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'FDMSIE-GBL-ECON', COLUMN_VALUE
    From sys.odcivarchar2list('NO', 'AR', 'AU', 'BR', 'CA', 'CH', 'CN', 'HK', 'ID', 'IN', 'IS', 'JP', 'KR', 'LATAM', 'MENA', 'MX', 'NZ', 'OASIA', 'OCIS', 'OLATAM', 'RU', 'SA', 'SG', 'SSA', 'TW', 'UK', 'US', 'ZA');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'AUXTOOLS-SU', COLUMN_VALUE
    From sys.odcivarchar2list('AL', 'BA', 'ME', 'MK', 'NO', 'RS', 'TR', 'XK', 'AT', 'BE', 'BG', 'CY', 'CZ', 'DE', 'DK', 'EE', 'EL', 'ES', 'FI', 'FR', 'HR', 'HU', 'IE', 'IT', 'LT', 'LU', 'LV', 'MT', 'NL', 'PL', 'PT', 'RO', 'SE', 'SI', 'SK', 'UK', 'AR', 'AU', 'BR', 'CA', 'CH', 'CN', 'HK', 'ID', 'IN', 'JP', 'KR', 'LATAM', 'MENA', 'MX', 'NZ', 'OASIA', 'OCIS', 'OLATAM', 'RU', 'SA', 'SG', 'SSA', 'TW', 'US', 'ZA');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'DBP-SU', COLUMN_VALUE
    From sys.odcivarchar2list('AT', 'BE', 'DE', 'EE', 'ES', 'FI', 'FR', 'IT', 'LU', 'MT', 'NL', 'SI', 'SK', 'LV', 'PT', 'IE', 'LT', 'EL', 'CY', 'HR');

Insert into UM_AUTHZ_CTY_GRP(CTY_GRP_ID, COUNTRY_ID)
  Select 'SCP-SU', COLUMN_VALUE
    From sys.odcivarchar2list('AT', 'BE', 'DE', 'EE', 'ES', 'FI', 'FR', 'IT', 'LU', 'MT', 'NL', 'SI', 'SK', 'LV', 'PT', 'IE', 'LT', 'EL', 'CY', 'HR');


COMMIT;
