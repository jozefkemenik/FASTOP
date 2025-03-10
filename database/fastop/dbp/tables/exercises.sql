/* Formatted on 12/4/2019 13:02:48 (QP5 v5.252.13127.32847) */
ALTER TABLE DBP_EXERCISES
   DROP PRIMARY KEY CASCADE;

DROP TABLE DBP_EXERCISES CASCADE CONSTRAINTS;
DROP SEQUENCE DBP_EXERCISES_SEQ;

CREATE TABLE DBP_EXERCISES
(
   EXERCISE_SID   NUMBER CONSTRAINT DBP_EXERCISES_PK PRIMARY KEY
,  EXERCISE_ID   VARCHAR2 (10 BYTE) NOT NULL
,  DESCR          VARCHAR2 (10 BYTE)
);

CREATE SEQUENCE DBP_EXERCISES_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER DBP_EXERCISES_TRG
   BEFORE INSERT
   ON DBP_EXERCISES
   FOR EACH ROW
BEGIN
   SELECT DBP_EXERCISES_SEQ.NEXTVAL INTO :NEW.EXERCISE_SID FROM DUAL;
END;