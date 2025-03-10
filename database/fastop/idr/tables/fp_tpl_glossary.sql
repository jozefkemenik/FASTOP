/* Formatted on 14-08-2020 13:00:46 (QP5 v5.313) */
ALTER TABLE FP_TPL_GLOSSARY
   DROP PRIMARY KEY CASCADE;

DROP TABLE FP_TPL_GLOSSARY CASCADE CONSTRAINTS;

DROP SEQUENCE FP_TPL_GLOSSARY_SEQ;

CREATE TABLE FP_TPL_GLOSSARY(
   GLOSSARY_SID  NUMBER(8) CONSTRAINT FP_TPL_GLOSSARY_PK PRIMARY KEY
 , DESCR         VARCHAR2(200 CHAR) NOT NULL
 , SECTION_NAME  VARCHAR2(100 CHAR) NOT NULL
 , EXPLANATION VARCHAR2(500 CHAR)
);

COMMENT ON TABLE FP_TPL_GLOSSARY IS 'Fiscal Params Template Glossary';
COMMENT ON COLUMN FP_TPL_GLOSSARY.GLOSSARY_SID IS 'Glossary SID';
COMMENT ON COLUMN FP_TPL_GLOSSARY.DESCR IS 'Description';
COMMENT ON COLUMN FP_TPL_GLOSSARY.SECTION_NAME IS 'Worksheet name';
COMMENT ON COLUMN FP_TPL_GLOSSARY.EXPLANATION IS 'Descriptive description of the indicator';

CREATE SEQUENCE FP_TPL_GLOSSARY_SEQ START WITH 1;
/
CREATE OR REPLACE TRIGGER SET_FP_TPL_GLOSSARY
   BEFORE INSERT
   ON FP_TPL_GLOSSARY
   FOR EACH ROW
BEGIN
   SELECT FP_TPL_GLOSSARY_SEQ.NEXTVAL INTO :NEW.GLOSSARY_SID FROM DUAL;
END;
/