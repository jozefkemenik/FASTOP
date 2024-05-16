/* Formatted on 17-08-2021 16:03:37 (QP5 v5.313) */
ALTER TABLE DRM_ARCHIVED_MEASURES
   DROP PRIMARY KEY CASCADE;

DROP TABLE DRM_ARCHIVED_MEASURES CASCADE CONSTRAINTS;
DROP SEQUENCE DRM_ARCHIVED_MEASURES_SEQ;

CREATE TABLE DRM_ARCHIVED_MEASURES(
   ARCHIVED_MEASURE_SID  NUMBER(12) CONSTRAINT DRM_ARCHIVED_MEASURES_PK PRIMARY KEY
 , ROUND_SID             NUMBER(8)
                         CONSTRAINT DRM_ARCHIVED_MEASURES_ROUND_FK REFERENCES ROUNDS(ROUND_SID)
 , MEASURE_SID NUMBER(12)
 , COUNTRY_ID            VARCHAR2(3 CHAR)
                         CONSTRAINT DRM_ARCHIVED_MEASURES_CTY_FK REFERENCES GEO_AREAS(GEO_AREA_ID)
 , TITLE VARCHAR2(100 CHAR)
 , DESCR VARCHAR2(4000 CHAR)
 , ESA_SID NUMBER(8)
 , ACC_PRINCIP_SID NUMBER(8)
 , ADOPT_STATUS_SID NUMBER(8)
 , DATA VARCHAR2(4000 CHAR)
 , START_YEAR NUMBER(4)
 , ONE_OFF_SID NUMBER(8)
 , ONE_OFF_TYPE_SID NUMBER(8)
 , YEAR NUMBER(4)
 , IS_EU_FUNDED_SID      NUMBER(8)
                         CONSTRAINT DRM_AR_MEASURES_IS_EU_FUND_FK
                         REFERENCES DFM_ONE_OFF(ONE_OFF_SID)
 , EU_FUND_SID           NUMBER(8)
                         CONSTRAINT DRM_AR_MEASURES_EU_FUND_FK REFERENCES DFM_EU_FUNDS(EU_FUND_SID)
 , LOG_DATE              DATE DEFAULT SYSDATE
);

CREATE SEQUENCE DRM_ARCHIVED_MEASURES_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER DRM_ARCHIVED_MEASURES_TRG
   BEFORE INSERT
   ON DRM_ARCHIVED_MEASURES
   FOR EACH ROW
BEGIN
   SELECT DRM_ARCHIVED_MEASURES_SEQ.NEXTVAL INTO :NEW.ARCHIVED_MEASURE_SID FROM DUAL;
END;