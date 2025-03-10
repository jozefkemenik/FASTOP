/* Formatted on 14-08-2020 13:10:51 (QP5 v5.313) */
ALTER TABLE FP_TPL_WORKSHEET
   DROP PRIMARY KEY CASCADE;

DROP TABLE FP_TPL_WORKSHEET CASCADE CONSTRAINTS;
DROP SEQUENCE FP_TPL_WORKSHEET_SEQ;

CREATE TABLE FP_TPL_WORKSHEET(
   WORKSHEET_SID  NUMBER(8) CONSTRAINT FP_TPL_WORKSHEET_PK PRIMARY KEY
 , NAME           VARCHAR2(40 CHAR) NOT NULL
 , TITLE VARCHAR2(50 CHAR)
 , START_YEAR     NUMBER(4) NOT NULL
 , END_YEAR       NUMBER(4) NOT NULL
 , ORDER_BY NUMBER(8)
);

COMMENT ON TABLE FP_TPL_WORKSHEET IS 'Fiscal Params Template Worksheet';
COMMENT ON COLUMN FP_TPL_WORKSHEET.WORKSHEET_SID IS 'Worksheet SID';
COMMENT ON COLUMN FP_TPL_WORKSHEET.NAME IS 'Worksheet name';
COMMENT ON COLUMN FP_TPL_WORKSHEET.TITLE IS 'Worksheet first column title';
COMMENT ON COLUMN FP_TPL_WORKSHEET.START_YEAR IS 'Vector start year';
COMMENT ON COLUMN FP_TPL_WORKSHEET.END_YEAR IS 'Vector end year';
COMMENT ON COLUMN FP_TPL_WORKSHEET.ORDER_BY IS 'Ordering';

CREATE SEQUENCE FP_TPL_WORKSHEET_SEQ START WITH 1;
/
CREATE OR REPLACE TRIGGER SET_FP_TPL_WORKSHEET
   BEFORE INSERT
   ON FP_TPL_WORKSHEET
   FOR EACH ROW
BEGIN
   SELECT FP_TPL_WORKSHEET_SEQ.NEXTVAL INTO :NEW.WORKSHEET_SID FROM DUAL;
END;
/