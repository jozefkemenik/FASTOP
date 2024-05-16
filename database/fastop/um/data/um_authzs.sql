SET DEFINE OFF;

-- FDMS-ADMIN
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.A.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'ADMIN')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-ALL'
    From Dual;

-- FDMS-AMECO
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.B.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'AMECO')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-ALL'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.B.3.002') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'AMECO')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-ALL'
    From Dual;

-- FDMS-CTY_DESK
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.E.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_E.1'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.E.2') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_E.2'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.E.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_E.3'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.F.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_F.1'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, COUNTRY_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.F.2') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'EL'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.F.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_F.3'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.F.4') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_F.4'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.G.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_G.1'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.G.2') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_G.2'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.G.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_G.3'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.D.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY_DESK_D.1'
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.B.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-CTY-EUCAM'
    From Dual;

-- FDMS-FORECAST
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.A.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.A.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.B.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.C.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.D.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.D.4') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.E') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.F') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.G') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
    From Dual;

-- FDMS-GBL_ECON
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.D.4') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'GBL_ECON')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-GBL-ECON'
    From Dual;

-- FDMS-SU
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.R.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'SU')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMS')
  ,     'FDMS-SU'
    From Dual;

-- FDMSIE-ADMIN
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.A.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'ADMIN')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMSIE')
    From Dual;

Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.D.4') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'ADMIN')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMSIE')
    From Dual;

-- FDMSIE-CTY_DESK
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.D.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'CTY_DESK')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMSIE')
  ,     'FDMSIE-CTY_DESK_D.1'
    From Dual;

-- FDMSIE-FORECAST
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.D.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'FORECAST')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMSIE')
    From Dual;

-- FDMSIE-GBL_ECON
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.D.1') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'GBL_ECON')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMSIE')
  ,     'FDMSIE-GBL-ECON'
    From Dual;

-- FDMSIE-SU
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.R.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'SU')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'FDMSIE')
  ,     'FDMS-SU'
    From Dual;


-- AUXTOOLS-SU
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.R.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'SU')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'AUXTOOLS')
  ,     'AUXTOOLS-SU'
    From Dual;

-- DBP-SU
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.R.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'SU')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'DBP')
  ,     'DBP-SU'
    From Dual;

-- SCP-SU
Insert into UM_AUTHZS(USER_SID, ROLE_SID, APP_SID, CTY_GRP_ID)
  Select
        (Select USER_SID From UM_USERS Where LDAP_LOGIN = 'ECFIN.R.3') USER_SID
  ,     (Select ROLE_SID From SECUNDA_ROLES Where ROLE_ID = 'SU')
  ,     (Select APP_SID From APPLICATIONS Where APP_ID = 'SCP')
  ,     'SCP-SU'
    From Dual;

COMMIT;
