ALTER TABLE AMECO_NSI_INDICATORS
DROP PRIMARY KEY CASCADE;

DROP TABLE AMECO_NSI_INDICATORS CASCADE CONSTRAINTS;
DROP SEQUENCE AMECO_NSI_INDICATORS_SEQ;

CREATE TABLE AMECO_NSI_INDICATORS(
      NSI_INDICATOR_SID   NUMBER(12)     CONSTRAINT AMECO_NSI_INDICATORS_PK PRIMARY KEY
    , NSI_INDICATOR_ID    VARCHAR2(10)   NOT NULL
    , COUNTRY_ID          VARCHAR2(12)
                                         NOT NULL
                                         CONSTRAINT AMECO_NSI_INDICATORS_CTY_FK REFERENCES GEO_AREAS(GEO_AREA_ID)
    , TYPE                VARCHAR(2)     NOT NULL
                                         CONSTRAINT AMECO_NSI_INDICATORS_TYPE_CHECK CHECK (TYPE IN ('UH', 'UC', 'TE'))
    , PERIODICITY_ID      VARCHAR2(1)
                                         NOT NULL
                                         CONSTRAINT AMECO_NSI_INDICATORS_PERIOD_CHECK CHECK (PERIODICITY_ID IN ('A', 'M', 'Q'))
    , START_YEAR          NUMBER(4)      NOT NULL
    , UPDATE_DATE         DATE
                                         DEFAULT SYSDATE
    , UPDATE_USER         VARCHAR2(16)
    , CONSTRAINT AMECO_NSI_INDICATORS_UNQ UNIQUE(NSI_INDICATOR_ID, PERIODICITY_ID)
);

CREATE SEQUENCE AMECO_NSI_INDICATORS_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER AMECO_NSI_INDICATORS_TRG
   BEFORE INSERT
   ON AMECO_NSI_INDICATORS
   FOR EACH ROW
BEGIN
SELECT AMECO_NSI_INDICATORS_SEQ.NEXTVAL INTO :NEW.NSI_INDICATOR_SID FROM DUAL;
END;
/
COMMENT ON COLUMN AMECO_NSI_INDICATORS.TYPE IS 'UH = Households, UC = Corporations, TE = Total Economy';
/
