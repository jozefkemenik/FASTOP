/* Formatted on 17-08-2020 13:04:43 (QP5 v5.313) */
ALTER TABLE ST_ACTIONS
   DROP PRIMARY KEY CASCADE;

DROP TABLE ST_ACTIONS CASCADE CONSTRAINTS;
DROP SEQUENCE ST_ACTIONS_SEQ;

CREATE TABLE ST_ACTIONS(
   ACTION_SID         NUMBER(8) CONSTRAINT ST_ACTIONS_PK PRIMARY KEY
 , ACTION_ID          VARCHAR2(16) NOT NULL CONSTRAINT ST_ACTIONS_ID_UNQ UNIQUE
 , DESCR              VARCHAR2(64) NOT NULL
 , RESULT_STATUS_SID  NUMBER(8)
                      NOT NULL
                      CONSTRAINT ST_ACTIONS_STATUS_FK REFERENCES ST_STATUS_REPO(STATUS_SID)
);

CREATE SEQUENCE ST_ACTIONS_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER ST_ACTIONS_TRG
   BEFORE INSERT
   ON ST_ACTIONS
   FOR EACH ROW
BEGIN
   SELECT ST_ACTIONS_SEQ.NEXTVAL INTO :NEW.ACTION_SID FROM DUAL;
END;