/* Formatted on 12/13/2019 15:01:28 (QP5 v5.252.13127.32847) */
ALTER TABLE ESTAT_INDIC_DATA
   DROP PRIMARY KEY CASCADE;

DROP TABLE ESTAT_INDIC_DATA CASCADE CONSTRAINTS;
DROP SEQUENCE ESTAT_INDIC_DATA_SEQ;

CREATE TABLE ESTAT_INDIC_DATA
(
   INDICATOR_DATA_SID   NUMBER (8) CONSTRAINT ESTAT_INDIC_DATA_PK PRIMARY KEY
,  ROUND_SID            NUMBER (8)
                           NOT NULL
                           CONSTRAINT ESTAT_INDIC_DATA_ROUND_FK
                               REFERENCES ROUNDS (ROUND_SID)
,  INDICATOR_SID        NUMBER (8)
                           NOT NULL
                           CONSTRAINT ESTAT_INDIC_DATA_FK2
                               REFERENCES INDICATORS (INDICATOR_SID)
,  COUNTRY_ID           VARCHAR2 (12 BYTE)
                           NOT NULL
                           CONSTRAINT ESTAT_INDIC_DATA_COUNTRY_FK
                               REFERENCES GEO_AREAS (GEO_AREA_ID)
,  YEAR                 NUMBER (4) NOT NULL
,  NA_ITEM              VARCHAR2 (10 BYTE)
,  SECTOR               VARCHAR2 (6 BYTE)
,  UNIT                 VARCHAR2 (20 BYTE)
,  VALUE                NUMBER
,  LAST_CHANGE_USER     VARCHAR2 (20 BYTE) NOT NULL
,  LAST_CHANGE_DATE     DATE NOT NULL
,  CONSTRAINT ESTAT_INDIC_DATA_UNQ UNIQUE
      (ROUND_SID, INDICATOR_SID, COUNTRY_ID)
);

CREATE SEQUENCE ESTAT_INDIC_DATA_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER ESTAT_INDIC_DATA_TRG
   BEFORE INSERT
   ON ESTAT_INDIC_DATA
   FOR EACH ROW
BEGIN
   SELECT ESTAT_INDIC_DATA_SEQ.NEXTVAL INTO :NEW.INDICATOR_DATA_SID FROM DUAL;
END;