/* Formatted on 12/3/2019 17:10:03 (QP5 v5.252.13127.32847) */
ALTER TABLE DFM_PARAMS
   DROP PRIMARY KEY CASCADE;

DROP TABLE DFM_PARAMS CASCADE CONSTRAINTS;
DROP SEQUENCE DFM_PARAMS_SEQ;

CREATE TABLE DFM_PARAMS
(
   PARAM_SID    NUMBER (8) CONSTRAINT DFM_PARAMS_PK PRIMARY KEY
,  PARAM_ID     VARCHAR2 (30 CHAR)
                   NOT NULL
                   CONSTRAINT DFM_PARAMS_ID_UNQ UNIQUE
,  DESCR        VARCHAR2 (100 CHAR)
,  VALUE        VARCHAR2 (100 CHAR)
,  LONG_DESCR   VARCHAR2 (4000 CHAR)
);

CREATE SEQUENCE DFM_PARAMS_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER DFM_PARAMS_TRG
   BEFORE INSERT
   ON DFM_PARAMS
   FOR EACH ROW
BEGIN
   SELECT DFM_PARAMS_SEQ.NEXTVAL INTO :NEW.PARAM_SID FROM DUAL;
END;