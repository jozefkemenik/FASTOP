-- deprecated: hicp data is stored in MongoDb

ALTER TABLE HICP_INDICATOR_DATA
   DROP PRIMARY KEY CASCADE;

DROP TABLE HICP_INDICATOR_DATA CASCADE CONSTRAINTS;
DROP SEQUENCE HICP_INDICATOR_DATA_SEQ;

CREATE TABLE HICP_INDICATOR_DATA(
   INDICATOR_DATA_SID  NUMBER(12) CONSTRAINT HICP_INDICATOR_DATA_PK PRIMARY KEY
 , INDICATOR_SID       NUMBER(8)
                       NOT NULL
                       CONSTRAINT HICP_INDICATOR_DATA_IND_FK
                       REFERENCES HICP_INDICATORS(INDICATOR_SID)
 , COUNTRY_ID          VARCHAR2(12)
                       NOT NULL
                       CONSTRAINT HICP_INDICATOR_DATA_CTY_FK REFERENCES GEO_AREAS(GEO_AREA_ID)
 , START_YEAR          NUMBER(4) NOT NULL
 , TIMESERIE_DATA      VARCHAR2(4000)
 , UPDATE_DATE         DATE
 , UPDATE_USER         VARCHAR2(16)
 , CONSTRAINT HICP_INDICATOR_DATA_UNQ UNIQUE(INDICATOR_SID, COUNTRY_ID)
);

CREATE SEQUENCE HICP_INDICATOR_DATA_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER HICP_INDICATOR_DATA_TRG
   BEFORE INSERT
   ON HICP_INDICATOR_DATA
   FOR EACH ROW
BEGIN
   SELECT HICP_INDICATOR_DATA_SEQ.NEXTVAL INTO :NEW.INDICATOR_DATA_SID FROM DUAL;
END;
