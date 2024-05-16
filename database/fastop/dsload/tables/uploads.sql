ALTER TABLE DSLOAD_UPLOADS
DROP PRIMARY KEY CASCADE;

DROP TABLE DSLOAD_UPLOADS;
DROP SEQUENCE DSLOAD_UPLOADS_SID_SEQ;

CREATE TABLE DSLOAD_UPLOADS
(
        UPLOAD_SID          NUMBER (12) CONSTRAINT DSLOAD_UPLOADS_PK PRIMARY KEY
      , USER_ID             VARCHAR2 (30 BYTE) NOT NULL
      , LATEST_DATE         DATE DEFAULT SYSDATE NOT NULL
      , FOLDER              VARCHAR2(500)
      , DATASET             VARCHAR2(100)
      , PROVIDER            VARCHAR2(30)
      , STATUS_SID          NUMBER(8)
                            NOT NULL
                            CONSTRAINT DSLOAD_UPLOADS_STATUS_FK
                            REFERENCES DSLOAD_STATUSES(STATUS_SID)
      , STATE               CLOB
);
/
CREATE SEQUENCE DSLOAD_UPLOADS_SID_SEQ START WITH 1;
/
CREATE OR REPLACE TRIGGER DSLOAD_UPLOADS_TRG
   BEFORE INSERT
   ON DSLOAD_UPLOADS
   FOR EACH ROW
BEGIN
    SELECT DSLOAD_UPLOADS_SID_SEQ.NEXTVAL INTO :NEW.UPLOAD_SID FROM DUAL;
END;
/
CREATE OR REPLACE FUNCTION IS_DSLOAD_UPLOAD_FINAL_STATUS(P_STATUS_SID IN NUMBER)
    RETURN NUMBER
DETERMINISTIC
IS
    l_res NUMBER(1);
BEGIN

    SELECT COUNT(*)
      INTO l_res
      FROM DSLOAD_STATUSES
     WHERE STATUS_SID = p_status_sid
       AND STATUS_ID IN ('FINISHED', 'CANCELLED');

    RETURN l_res;
END;
/
CREATE UNIQUE INDEX DSLOAD_UPLOADS_UNIQUE
ON DSLOAD_UPLOADS (CASE WHEN IS_DSLOAD_UPLOAD_FINAL_STATUS(STATUS_SID) > 0 THEN UPLOAD_SID ELSE 0 END, USER_ID);
/
