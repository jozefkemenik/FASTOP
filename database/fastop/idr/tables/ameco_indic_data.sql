/* Formatted on 12/13/2019 14:57:58 (QP5 v5.252.13127.32847) */
DROP SEQUENCE AMECO_INDIC_DATA_SEQ;

ALTER TABLE AMECO_INDIC_DATA
   DROP PRIMARY KEY CASCADE;

DROP TABLE AMECO_INDIC_DATA CASCADE CONSTRAINTS;

CREATE TABLE AMECO_INDIC_DATA
(
   INDICATOR_DATA_SID   NUMBER (8) CONSTRAINT AMECO_INDIC_DATA_PK PRIMARY KEY
,  ROUND_SID            NUMBER (8)
                           NOT NULL
                           CONSTRAINT AMECO_INDIC_DATA_ROUND_FK
                               REFERENCES ROUNDS (ROUND_SID)
,  INDICATOR_SID        NUMBER (8)
                           NOT NULL
                           CONSTRAINT AMECO_INDIC_DATA_FK2
                               REFERENCES INDICATORS (INDICATOR_SID)
,  COUNTRY_ID           VARCHAR2 (8 BYTE)
                           NOT NULL
                           CONSTRAINT AMECO_INDIC_DATA_COUNTRY_FK
                               REFERENCES GEO_AREAS (GEO_AREA_ID)
,  START_YEAR           NUMBER (4) NOT NULL
,  VECTOR               VARCHAR2 (4000 BYTE) NOT NULL
,  LAST_CHANGE_USER     VARCHAR2 (20 BYTE) NOT NULL
,  LAST_CHANGE_DATE     DATE NOT NULL
,  CONSTRAINT AMECO_INDIC_DATA_UNQ UNIQUE
      (ROUND_SID, INDICATOR_SID, COUNTRY_ID)
);

CREATE SEQUENCE AMECO_INDIC_DATA_SEQ START WITH 1;
/
CREATE OR REPLACE TRIGGER AMECO_INDIC_DATA_TRG
   BEFORE INSERT
   ON AMECO_INDIC_DATA
   FOR EACH ROW
BEGIN
   SELECT AMECO_INDIC_DATA_SEQ.NEXTVAL INTO :NEW.INDICATOR_DATA_SID FROM DUAL;
END;
/
COMMENT ON TABLE AMECO_INDIC_DATA IS 'Ameco Indicators Data';
COMMENT ON COLUMN AMECO_INDIC_DATA.INDICATOR_DATA_SID IS 'Indicator Data SID';
COMMENT ON COLUMN AMECO_INDIC_DATA.INDICATOR_SID IS 'Indicator SID';
COMMENT ON COLUMN AMECO_INDIC_DATA.COUNTRY_ID IS 'Country ISO code';
COMMENT ON COLUMN AMECO_INDIC_DATA.START_YEAR IS 'Start Year of the Vector';
COMMENT ON COLUMN AMECO_INDIC_DATA.VECTOR IS
   'Vector containing the data of the indicator for the forecast year';
COMMENT ON COLUMN AMECO_INDIC_DATA.LAST_CHANGE_USER IS
   'User who has made the latest change';
COMMENT ON COLUMN AMECO_INDIC_DATA.LAST_CHANGE_DATE IS
   'Date of the latest change';
/