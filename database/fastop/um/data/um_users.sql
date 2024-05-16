SET DEFINE OFF;
Insert into UM_USERS(LDAP_LOGIN, USER_TYPE_SID)
  Select COLUMN_VALUE LDAP_LOGIN
       , (Select USER_TYPE_SID From UM_USER_TYPES Where USER_TYPE_ID = 'UNIT') USER_TYPE_SID
    From sys.odcivarchar2list('ECFIN.A.1', 'ECFIN.A.3', 'ECFIN.B.3', 'ECFIN.B.3.002', 'ECFIN.C.1', 'ECFIN.D.1', 'ECFIN.D.4', 'ECFIN.E', 'ECFIN.E.1', 'ECFIN.E.2', 'ECFIN.E.3', 'ECFIN.F', 'ECFIN.F.1', 'ECFIN.F.2', 'ECFIN.F.3', 'ECFIN.F.4', 'ECFIN.G', 'ECFIN.G.1', 'ECFIN.G.2', 'ECFIN.G.3', 'ECFIN.R.3');

COMMIT;
