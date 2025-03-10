/* Formatted on 17-05-2021 18:09:12 (QP5 v5.313) */
DROP TABLE TASK_LOG_VALIDATIONS CASCADE CONSTRAINTS;

CREATE TABLE TASK_LOG_VALIDATIONS(
   TASK_LOG_SID  NUMBER(14)
                 NOT NULL
                 CONSTRAINT TASK_LOG_VALS_LOG_FK
                 REFERENCES TASK_LOGS(TASK_LOG_SID) ON DELETE CASCADE
 , INDICATOR_ID  VARCHAR2(50 BYTE) NOT NULL
 , LABELS        VARCHAR2(4000 BYTE)
 , ACTUAL        VARCHAR2(4000 BYTE)
 , VALIDATION1   VARCHAR2(4000 BYTE)
 , VALIDATION2   VARCHAR2(4000 BYTE)
 , FAILED        VARCHAR2(400 BYTE)

 , CONSTRAINT TASK_LOG_VALIDATIONS_UNQ UNIQUE(TASK_LOG_SID, INDICATOR_ID)
);