ALTER TABLE FDMS_TCE_PARTNERS
    DROP PRIMARY KEY CASCADE;

DROP TABLE FDMS_TCE_PARTNERS CASCADE CONSTRAINTS;

CREATE TABLE FDMS_TCE_PARTNERS (
    PARTNER_ID  VARCHAR2(10 BYTE) CONSTRAINT FDMS_TCE_PARTNERS_PK PRIMARY KEY
  , DESCR       VARCHAR2(38)
                NOT NULL
);
