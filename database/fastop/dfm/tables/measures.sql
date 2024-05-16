/* Formatted on 17-08-2021 15:36:20 (QP5 v5.313) */
ALTER TABLE DFM_MEASURES
   DROP PRIMARY KEY CASCADE;

DROP TABLE DFM_MEASURES CASCADE CONSTRAINTS;
DROP SEQUENCE DFM_MEASURES_SEQ;

CREATE TABLE DFM_MEASURES(
   MEASURE_SID       NUMBER(8) CONSTRAINT DFM_MEASURES_PK PRIMARY KEY
 , COUNTRY_ID        VARCHAR2(3 CHAR)
                     CONSTRAINT DFM_MEASURES_COUNTRY_FK REFERENCES GEO_AREAS(GEO_AREA_ID)
 , STATUS_SID        NUMBER(8) CONSTRAINT DFM_MEASURES_STATUS_FK REFERENCES DFM_STATUS(STATUS_SID)
 , NEED_RESEARCH_SID NUMBER(4)
 , TITLE VARCHAR2(100 CHAR)
 , SHORT_DESCR VARCHAR2(4000 CHAR)
 , INFO_SRC VARCHAR2(400 CHAR)
 , ADOPT_DATE_YR NUMBER(4)
 , ADOPT_DATE_MH NUMBER(2)
 , COMMENTS VARCHAR2(4000 CHAR)
 , YEAR NUMBER(8)
 , REV_EXP_SID       NUMBER(4) CONSTRAINT DFM_MEASURES_R01 REFERENCES DFM_REV_EXP(REV_EXP_SID)
 , ESA95_SID NUMBER(8)
 , ESA95_COMMENTS VARCHAR2(4000 CHAR)
 , ONE_OFF_SID       NUMBER(8) CONSTRAINT DFM_MEASURES_ONE_OFF_FK REFERENCES DFM_ONE_OFF(ONE_OFF_SID)
 , ONE_OFF_TYPE_SID  NUMBER(8)
                     CONSTRAINT DFM_MEASURES_OO_TYPE_FK
                     REFERENCES DFM_ONE_OFF_TYPES(ONE_OFF_TYPE_SID)
 , ONE_OFF_DISAGREE_SID NUMBER(4)
 , ONE_OFF_COMMENTS VARCHAR2(4000 CHAR)
 , DATA VARCHAR2(4000 CHAR)
 , START_YEAR NUMBER(4)
 , IS_UPLOADED VARCHAR2(1 BYTE)
 , QUANT_COMMENTS VARCHAR2(4000 BYTE)
 , FIRST_ROUND_SID   NUMBER(8) CONSTRAINT DFM_MEASURES_FIRST_ROUND_FK REFERENCES ROUNDS(ROUND_SID)
 , OO_PRINCIPLE_SID  NUMBER(8)
                     CONSTRAINT DFM_MEASURES_OO_PRINC_FK
                     REFERENCES DFM_OO_PRINCIPLES(OO_PRINCIPLE_SID)
 , IS_PUBLIC         NUMBER(4) DEFAULT -1
 , IS_EU_FUNDED_SID  NUMBER(8)
                     CONSTRAINT DFM_MEASURES_IS_EU_FUND_FK REFERENCES DFM_ONE_OFF(ONE_OFF_SID)
 , EU_FUND_SID       NUMBER(8)
                     CONSTRAINT DFM_MEASURES_EU_FUND_FK REFERENCES DFM_EU_FUNDS(EU_FOUND_SID)
);

CREATE SEQUENCE DFM_MEASURES_SEQ START WITH 20000;
/

CREATE OR REPLACE TRIGGER DFM_MEASURES_TRG
   BEFORE INSERT
   ON DFM_MEASURES
   FOR EACH ROW
BEGIN
   SELECT DFM_MEASURES_SEQ.NEXTVAL INTO :NEW.MEASURE_SID FROM DUAL;

   SELECT VALUE
     INTO :NEW.FIRST_ROUND_SID
     FROM PARAMS
    WHERE param_id = 'CURRENT_ROUND';
END;
/

COMMENT ON TABLE DFM_MEASURES IS 'Discretionary Fiscal Measures Database';
COMMENT ON COLUMN DFM_MEASURES.MEASURE_SID IS 'Id';
COMMENT ON COLUMN DFM_MEASURES.STATUS_SID IS 'Status';
COMMENT ON COLUMN DFM_MEASURES.NEED_RESEARCH_SID IS 'Needs Additional Research';
COMMENT ON COLUMN DFM_MEASURES.TITLE IS 'Measure Title *';
COMMENT ON COLUMN DFM_MEASURES.SHORT_DESCR IS 'Short Description';
COMMENT ON COLUMN DFM_MEASURES.INFO_SRC IS 'Source';
COMMENT ON COLUMN DFM_MEASURES.ADOPT_DATE_YR IS 'Year of Adoption';
COMMENT ON COLUMN DFM_MEASURES.ADOPT_DATE_MH IS 'Month of Adoption';
COMMENT ON COLUMN DFM_MEASURES.COMMENTS IS 'General Comments';
COMMENT ON COLUMN DFM_MEASURES.YEAR IS 'Year of First budgetary impact';
COMMENT ON COLUMN DFM_MEASURES.REV_EXP_SID IS 'Rev/Exp *';
COMMENT ON COLUMN DFM_MEASURES.ESA95_SID IS 'ESA Code *';
COMMENT ON COLUMN DFM_MEASURES.ESA95_COMMENTS IS 'Comments ESA Classification';
COMMENT ON COLUMN DFM_MEASURES.ONE_OFF_SID IS 'One-off *';
COMMENT ON COLUMN DFM_MEASURES.ONE_OFF_TYPE_SID IS 'One-off type';
COMMENT ON COLUMN DFM_MEASURES.ONE_OFF_DISAGREE_SID IS 'MS disagrees on one-off treatment';
COMMENT ON COLUMN DFM_MEASURES.ONE_OFF_COMMENTS IS 'Comments on one-off measure';
COMMENT ON COLUMN DFM_MEASURES.DATA IS 'Budgetary Impact';
/