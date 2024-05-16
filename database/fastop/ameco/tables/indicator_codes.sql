ALTER TABLE AMECO_INDICATOR_CODES
    DROP PRIMARY KEY CASCADE;

DROP TABLE AMECO_INDICATOR_CODES CASCADE CONSTRAINTS;
DROP SEQUENCE AMECO_INDICATOR_CODES_SEQ;

CREATE TABLE AMECO_INDICATOR_CODES(
    INDICATOR_CODE_SID  NUMBER(8) CONSTRAINT AMECO_INDICATOR_CODES_PK PRIMARY KEY
  , INDICATOR_ID        VARCHAR2(35 BYTE)
                        NOT NULL
                        CONSTRAINT AMECO_INDICATOR_CODES_ID_UNQ UNIQUE
  , DESCR VARCHAR2(1000 BYTE)
);

CREATE SEQUENCE AMECO_INDICATOR_CODES_SEQ;

CREATE OR REPLACE TRIGGER AMECO_INDICATOR_CODES_TRG
    BEFORE INSERT
    ON AMECO_INDICATOR_CODES
    FOR EACH ROW
BEGIN
    SELECT AMECO_INDICATOR_CODES_SEQ.NEXTVAL INTO :NEW.INDICATOR_CODE_SID FROM DUAL;
END;
