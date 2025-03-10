/* Formatted on 11/29/2019 10:26:15 (QP5 v5.252.13127.32847) */
ALTER TABLE TEMPLATE_FILES
   DROP PRIMARY KEY CASCADE;

DROP TABLE TEMPLATE_FILES CASCADE CONSTRAINTS;
DROP SEQUENCE TEMPLATE_FILES_SEQ;

CREATE TABLE TEMPLATE_FILES
(
   TEMPLATE_SID        NUMBER CONSTRAINT TEMPLATE_FILES_PK PRIMARY KEY
,  TEMPLATE_TYPE_SID   NUMBER
                          NOT NULL
                          CONSTRAINT TEMPLATE_FILES_TYPE_FK
                              REFERENCES TEMPLATE_TYPES (TEMPLATE_TYPE_SID)
,  APP_SID             NUMBER
                          NOT NULL
                          CONSTRAINT TEMPLATE_FILES_APP_FK
                              REFERENCES APPLICATIONS (APP_SID)
,  TITLE               VARCHAR2 (200 CHAR) NOT NULL
,  CONTENT_TYPE        VARCHAR2 (150 CHAR) NOT NULL
,  CONTENT             BLOB NOT NULL
,  DESCR               VARCHAR2 (500 CHAR)
,  IS_ACTIVE           NUMBER (1)
                          DEFAULT 0
                          NOT NULL
                          CONSTRAINT TEMPLATE_FILES_ACTIVE_CHECK CHECK
                             (IS_ACTIVE IN (0, 1))
,  LAST_CHANGE_DATE    DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
,  LAST_CHANGE_USER    VARCHAR2 (20 CHAR)
);

CREATE UNIQUE INDEX TPL_FILES_ACTIVE_IDX
    ON TEMPLATE_FILES( CASE WHEN IS_ACTIVE = 1
                            THEN APP_SID
                            ELSE NULL
                        END,
                        CASE WHEN IS_ACTIVE = 1
                            THEN TEMPLATE_TYPE_SID
                            ELSE NULL
                        END );

CREATE SEQUENCE TEMPLATE_FILES_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER TEMPLATE_FILES_TRG
   BEFORE INSERT
   ON TEMPLATE_FILES
   FOR EACH ROW
BEGIN
   SELECT TEMPLATE_FILES_SEQ.NEXTVAL INTO :NEW.TEMPLATE_SID FROM DUAL;
END;
