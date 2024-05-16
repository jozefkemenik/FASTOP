/* Formatted on 07-07-2020 17:21:14 (QP5 v5.313) */
ALTER TABLE TASK_RUNS
   DROP PRIMARY KEY CASCADE;

DROP TABLE TASK_RUNS CASCADE CONSTRAINTS;
DROP SEQUENCE TASK_RUNS_SEQ;

CREATE TABLE TASK_RUNS(
   TASK_RUN_SID     NUMBER(12) CONSTRAINT TASK_RUNS_PK PRIMARY KEY
 , TASK_STATUS_SID  NUMBER(8)
                    NOT NULL
                    CONSTRAINT TASK_RUNS_STATUS_FK
                    REFERENCES TASK_STATUSES(TASK_STATUS_SID)
 , START_RUN        TIMESTAMP
 , END_RUN          TIMESTAMP
 , ALL_STEPS        NUMBER(4) DEFAULT 999
 , STEPS            NUMBER(4) DEFAULT 0
 , ALL_PREP_STEPS   NUMBER(4) DEFAULT 999
 , PREP_STEPS       NUMBER(4) DEFAULT 0
 , CONCURRENCY      NUMBER(4) DEFAULT 1
 , WORKERS_DONE     NUMBER(4) DEFAULT 0
 , USER_RUN         VARCHAR2(20)
);

CREATE SEQUENCE TASK_RUNS_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER TASK_RUNS_TRG
   BEFORE INSERT
   ON TASK_RUNS
   FOR EACH ROW
BEGIN
   SELECT TASK_RUNS_SEQ.NEXTVAL INTO :NEW.TASK_RUN_SID FROM DUAL;
END;