/* Formatted on 11/29/2019 15:51:41 (QP5 v5.252.13127.32847) */
ALTER TABLE ST_CTY_STATUS_CURR_AUD
   DROP PRIMARY KEY CASCADE;

DROP TABLE ST_CTY_STATUS_CURR_AUD CASCADE CONSTRAINTS;
DROP SEQUENCE ST_CTY_STATUS_CURR_AUD_SEQ;

CREATE TABLE ST_CTY_STATUS_CURR_AUD
(
   CTY_STATUS_CURR_AUD_SID   NUMBER (12)
                                CONSTRAINT ST_CTY_STATUS_CURR_AUD_PK PRIMARY KEY
,  CTY_STATUS_CURR_SID       NUMBER (12)
                                CONSTRAINT ST_CTY_STATUS_CURR_AUD_SC_FK

                                   REFERENCES ST_CTY_STATUS_CURR (CTY_STATUS_CURR_SID)
,  ROUND_SID                 NUMBER (8)
                                CONSTRAINT ST_CTY_STATUS_CURR_AUD_R_FK
                                    REFERENCES ROUNDS (ROUND_SID)
,  APP_SID                   NUMBER (8)
                                CONSTRAINT ST_CTY_STATUS_CURR_AUD_A_FK
                                    REFERENCES APPLICATIONS (APP_SID)
,  COUNTRY_ID                VARCHAR2 (8)
                                CONSTRAINT ST_CTY_STATUS_CURR_AUD_C_FK
                                    REFERENCES GEO_AREAS (GEO_AREA_ID)
,  STATUS_SID                NUMBER (8)
                                CONSTRAINT ST_CTY_STATUS_CURR_AUD_S_FK
                                    REFERENCES ST_STATUS_REPO (STATUS_SID)
,  STORAGE_SID               NUMBER (8)
                                CONSTRAINT ST_CTY_STATUS_CURR_AUD_ST_FK
                                    REFERENCES STORAGES (STORAGE_SID)
,  CUST_TEXT_SID             NUMBER (8)
                                CONSTRAINT ST_CTY_STATUS_CURR_AUD_TEXT_FK
                                   REFERENCES CUST_STORAGE_TEXTS (CUST_STORAGE_TEXT_SID)
,  LAST_CHANGE_DATE          DATE
,  UPDATE_USER               VARCHAR2(16 BYTE)
,  AUDIT_ACTION              VARCHAR2 (20)
,  AUDIT_CREATE_DATE         TIMESTAMP (6) DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE ST_CTY_STATUS_CURR_AUD_SEQ START WITH 1;
/
CREATE OR REPLACE TRIGGER ST_CTY_STATUS_CURR_AUD_TRG
   BEFORE INSERT
   ON ST_CTY_STATUS_CURR_AUD
   FOR EACH ROW
BEGIN
   SELECT ST_CTY_STATUS_CURR_AUD_SEQ.NEXTVAL
     INTO :NEW.CTY_STATUS_CURR_AUD_SID
     FROM DUAL;
END;
/
CREATE OR REPLACE TRIGGER ST_CTY_STATUS_CURR_UPD_TRG
   AFTER UPDATE
   ON ST_CTY_STATUS_CURR
   FOR EACH ROW
   WHEN (   OLD.ROUND_SID != NEW.ROUND_SID
         OR OLD.APP_SID != NEW.APP_SID
         OR OLD.COUNTRY_ID != NEW.COUNTRY_ID
         OR OLD.STATUS_SID != NEW.STATUS_SID
         OR OLD.STORAGE_SID != NEW.STORAGE_SID
         OR OLD.CUST_TEXT_SID != NEW.CUST_TEXT_SID)
BEGIN
   INSERT INTO ST_CTY_STATUS_CURR_AUD (CTY_STATUS_CURR_SID
,                                      ROUND_SID
,                                      APP_SID
,                                      COUNTRY_ID
,                                      STATUS_SID
,                                      STORAGE_SID
,                                      CUST_TEXT_SID
,                                      LAST_CHANGE_DATE
,                                      UPDATE_USER
,                                      AUDIT_ACTION)
        VALUES (:OLD.CTY_STATUS_CURR_SID
,               :OLD.ROUND_SID
,               :OLD.APP_SID
,               :OLD.COUNTRY_ID
,               :OLD.STATUS_SID
,               :OLD.STORAGE_SID
,               :OLD.CUST_TEXT_SID
,               :OLD.LAST_CHANGE_DATE
,               :OLD.UPDATE_USER
,               'UPDATE');
END;
/
