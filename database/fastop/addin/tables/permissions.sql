DROP TABLE ADDIN_PERMISSIONS;

CREATE TABLE ADDIN_PERMISSIONS
(
    DASHBOARD_SID        NUMBER (8)    NOT NULL
                            CONSTRAINT ADDIN_PERMISSIONS_DASHBOARD_FK
                                REFERENCES ADDIN_DASHBOARD (DASHBOARD_SID)
 ,  ROLE_SID             NUMBER (8)    NOT NULL
                            CONSTRAINT ADDIN_PERMISSIONS_ROLE_FK
                                 REFERENCES SECUNDA_ROLES (ROLE_SID)
);

