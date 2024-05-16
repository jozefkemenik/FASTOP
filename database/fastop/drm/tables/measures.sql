/* Formatted on 17-08-2021 16:00:25 (QP5 v5.313) */
ALTER TABLE DRM_MEASURES
   DROP PRIMARY KEY CASCADE;

DROP TABLE DRM_MEASURES CASCADE CONSTRAINTS;
DROP SEQUENCE DRM_MEASURES_SEQ;

CREATE TABLE DRM_MEASURES(
   MEASURE_SID       NUMBER(12) CONSTRAINT DRM_MEASURES_PK PRIMARY KEY
 , COUNTRY_ID        VARCHAR2(3 CHAR)
                     CONSTRAINT DRM_MEASURES_COUNTRY_FK REFERENCES GEO_AREAS(GEO_AREA_ID)
 , TITLE VARCHAR2(100 CHAR)
 , DESCR VARCHAR2(4000 CHAR)
 , ESA_SID           NUMBER(8) CONSTRAINT DRM_MEASURES_ESA_FK REFERENCES DBP_ESA(ESA_SID)
 , ACC_PRINCIP_SID   NUMBER(8)
                     CONSTRAINT DRM_MEASURES_ACC_PRINCIP_FK
                     REFERENCES DBP_ACC_PRINCIP(ACC_PRINCIP_SID)
 , ADOPT_STATUS_SID  NUMBER(8)
                     CONSTRAINT DRM_MEASURES_ADOPT_STATUS_FK
                     REFERENCES DBP_ADOPT_STATUS(ADOPT_STATUS_SID)
 , DATA VARCHAR2(4000 CHAR)
 , START_YEAR NUMBER(4)
 , ONE_OFF_SID       NUMBER(8)
                     CONSTRAINT DRM_MEASURES_ONE_OFF_FK REFERENCES DFM_ONE_OFF(ONE_OFF_SID)
 , ONE_OFF_TYPE_SID  NUMBER(8)
                     CONSTRAINT DRM_MEASURES_ONE_OFF_TYPE_FK
                     REFERENCES DFM_ONE_OFF_TYPES(ONE_OFF_TYPE_SID)
 , YEAR NUMBER(4)
 , IS_EU_FUNDED_SID  NUMBER(8)
                     CONSTRAINT DRM_MEASURES_IS_EU_FUND_FK REFERENCES DFM_ONE_OFF(ONE_OFF_SID)
 , EU_FUND_SID       NUMBER(8)
                     CONSTRAINT DRM_MEASURES_EU_FUND_FK REFERENCES DFM_EU_FUNDS(EU_FUND_SID)
);

CREATE SEQUENCE DRM_MEASURES_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER DRM_MEASURES_TRG
   BEFORE INSERT
   ON DRM_MEASURES
   FOR EACH ROW
BEGIN
   IF :NEW.MEASURE_SID IS NULL THEN
      SELECT DRM_MEASURES_SEQ.NEXTVAL INTO :NEW.MEASURE_SID FROM DUAL;
   END IF;
END;