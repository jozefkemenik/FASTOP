/* Formatted on 21-01-2020 17:33:10 (QP5 v5.313) */
ALTER TABLE FDMS_INDICATOR_CODES
    DROP PRIMARY KEY CASCADE;

DROP TABLE FDMS_INDICATOR_CODES CASCADE CONSTRAINTS;
DROP SEQUENCE FDMS_INDICATOR_CODES_SEQ;

CREATE TABLE FDMS_INDICATOR_CODES(
    INDICATOR_CODE_SID  NUMBER(8) CONSTRAINT FDMS_INDICATOR_CODES_PK PRIMARY KEY
  , INDICATOR_ID        VARCHAR2(35 BYTE)
                        NOT NULL
                        CONSTRAINT FDMS_INDICATOR_CODES_ID_UNQ UNIQUE
  , DESCR               VARCHAR2(1000 BYTE)
  , EUROSTAT_CODE       VARCHAR2(100 BYTE)
  , ESA_CODE            VARCHAR2(40 BYTE)
  , AMECO_CODE          VARCHAR2(15 BYTE)
                        NOT NULL
  , AMECO_TRN           VARCHAR2(3 BYTE)
  , AMECO_AGG           VARCHAR2(3 BYTE)
  , AMECO_UNIT          VARCHAR2(3 BYTE)
  , AMECO_REF           VARCHAR2(3 BYTE)
  , FORECAST  NUMBER(1) DEFAULT 0
  , CONSTRAINT INDICATOR_ID_CHECK CHECK (
    (AMECO_TRN IS NULL AND INDICATOR_ID = AMECO_CODE) OR
    (AMECO_TRN IS NOT NULL AND INDICATOR_ID = (AMECO_CODE || '.' || AMECO_TRN || '.' || AMECO_AGG || '.' || AMECO_UNIT || '.' || AMECO_REF))
  )
);

CREATE SEQUENCE FDMS_INDICATOR_CODES_SEQ;

CREATE OR REPLACE TRIGGER FDMS_INDICATOR_CODES_TRG
    BEFORE INSERT
    ON FDMS_INDICATOR_CODES
    FOR EACH ROW
BEGIN
    SELECT FDMS_INDICATOR_CODES_SEQ.NEXTVAL INTO :NEW.INDICATOR_CODE_SID FROM DUAL;
END;
