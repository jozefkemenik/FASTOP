/* Formatted on 12/4/2019 13:18:58 (QP5 v5.252.13127.32847) */
ALTER TABLE DBP_MEASURES
   DROP PRIMARY KEY CASCADE;

DROP TABLE DBP_MEASURES CASCADE CONSTRAINTS;
DROP SEQUENCE DBP_MEASURES_SEQ;

CREATE TABLE DBP_MEASURES
(
   MEASURE_SID        NUMBER (12) CONSTRAINT DBP_MEASURES_PK PRIMARY KEY
,  ROUND_SID          NUMBER (8)
                         NOT NULL
                         CONSTRAINT DBP_MEASURES_ROUND_FK
                             REFERENCES ROUNDS (ROUND_SID)
,  TITLE              VARCHAR2 (100 CHAR)
,  DESCR              VARCHAR2 (4000 CHAR)
,  SOURCE_SID         NUMBER (8)
                         CONSTRAINT DBP_MEASURES_SOURCE_FK
                             REFERENCES DBP_SOURCES (SOURCE_SID)
,  ESA_SID            NUMBER (8)
                         CONSTRAINT DBP_MEASURES_ESA_FK
                             REFERENCES DBP_ESA (ESA_SID)
,  ACC_PRINCIP_SID    NUMBER (8)
                         CONSTRAINT DBP_MEASURES_ACC_PRINCIP_FK
                             REFERENCES DBP_ACC_PRINCIP (ACC_PRINCIP_SID)
,  ADOPT_STATUS_SID   NUMBER (8)
                         CONSTRAINT DBP_MEASURES_ADOPT_STATUS_FK
                             REFERENCES DBP_ADOPT_STATUS (ADOPT_STATUS_SID)
,  DATA               VARCHAR2 (4000 CHAR)
,  START_YEAR         NUMBER (4)
,  CTY_VERSION_SID    NUMBER (8)
                         CONSTRAINT DBP_MEASURES_CTY_VER_FK
                             REFERENCES GD_CTY_VERSIONS (CTY_VERSION_SID)
);

CREATE SEQUENCE DBP_MEASURES_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER DBP_MEASURES_TRG
   BEFORE INSERT
   ON DBP_MEASURES
   FOR EACH ROW
BEGIN
   SELECT DBP_MEASURES_SEQ.NEXTVAL INTO :NEW.MEASURE_SID FROM DUAL;
END;