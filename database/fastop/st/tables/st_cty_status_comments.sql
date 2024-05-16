/* Formatted on 15-06-2020 20:01:10 (QP5 v5.313) */
ALTER TABLE ST_CTY_STATUS_COMMENTS
   DROP PRIMARY KEY CASCADE;

DROP TABLE ST_CTY_STATUS_COMMENTS CASCADE CONSTRAINTS;
DROP SEQUENCE ST_CTY_STATUS_COMMENTS_SEQ;

CREATE TABLE ST_CTY_STATUS_COMMENTS(
   CTY_STATUS_COMMENT_SID  NUMBER(8) CONSTRAINT ST_CTY_STATUS_COMMENT_PK PRIMARY KEY
 , CTY_STATUS_CURR_SID     NUMBER(8)
                           NOT NULL
                           CONSTRAINT ST_CTY_STATUS_COMMENTS_CURR_FK
                           REFERENCES ST_CTY_STATUS_CURR(CTY_STATUS_CURR_SID)
 , STATUS_SID              NUMBER(8)
                           NOT NULL
                           CONSTRAINT ST_CTY_STATUS_COMMENTS_ST_FK
                           REFERENCES ST_STATUS_REPO(STATUS_SID)
 , COMMENT_TEXT            VARCHAR2(4000)
 , COMMENT_DATE            DATE NOT NULL
 , COMMENT_USER            VARCHAR2(16) NOT NULL
);

CREATE SEQUENCE ST_CTY_STATUS_COMMENTS_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER ST_CTY_STATUS_COMMENTS_TRG
   BEFORE INSERT
   ON ST_CTY_STATUS_COMMENTS
   FOR EACH ROW
BEGIN
   SELECT ST_CTY_STATUS_COMMENTS_SEQ.NEXTVAL INTO :NEW.CTY_STATUS_COMMENT_SID FROM DUAL;
END;