ALTER TABLE OG_BASELINE_DATA
   DROP PRIMARY KEY CASCADE;

DROP TABLE OG_BASELINE_DATA CASCADE CONSTRAINTS;
DROP SEQUENCE OG_BASELINE_DATA_SEQ;

CREATE TABLE OG_BASELINE_DATA
(
   DATA_SID             NUMBER (8) CONSTRAINT OG_BASELINE_DATA_PK PRIMARY KEY
,  ROUND_SID            NUMBER (8)
                          NOT NULL
                          CONSTRAINT OG_BASELINE_DATA_ROUND_FK
                              REFERENCES ROUNDS (ROUND_SID)
,  VARIABLE_SID         NUMBER (8)
                          NOT NULL
                          CONSTRAINT OG_BASELINE_DATA_VAR_FK
                              REFERENCES OG_BASELINE_VARIABLES (VARIABLE_SID)
,  COUNTRY_ID           VARCHAR2 (5 BYTE)
                           NOT NULL
                           CONSTRAINT OG_BLNE_DATA_COUNTRY_FK
                               REFERENCES GEO_AREAS (GEO_AREA_ID)
,  YEAR                 NUMBER (4) NOT NULL
,  VALUE                VARCHAR2(100 BYTE)
,  CONSTRAINT OG_BASELINE_DATA_UNQ UNIQUE (ROUND_SID, VARIABLE_SID, COUNTRY_ID, YEAR)
);
/
CREATE SEQUENCE OG_BASELINE_DATA_SEQ START WITH 1;
/
CREATE OR REPLACE TRIGGER OG_BASELINE_DATA_TRG
   BEFORE INSERT
   ON OG_BASELINE_DATA
   FOR EACH ROW
BEGIN
   SELECT OG_BASELINE_DATA_SEQ.NEXTVAL
     INTO :NEW.DATA_SID
     FROM DUAL;
END;
/
