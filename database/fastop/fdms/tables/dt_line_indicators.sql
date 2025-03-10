/* Formatted on 02-09-2020 17:10:10 (QP5 v5.313) */
DROP TABLE FDMS_DT_LINE_INDICATORS CASCADE CONSTRAINTS;

CREATE TABLE FDMS_DT_LINE_INDICATORS(
   TABLE_LINE_SID  NUMBER(8)
                   CONSTRAINT FDMS_DT_LI_TABLE_LINE_FK
                   REFERENCES FDMS_DT_TABLE_LINES(TABLE_LINE_SID)
 , COL_TYPE_SID    NUMBER(8)
                   CONSTRAINT FDMS_DT_LI_COL_TYPE_FK REFERENCES FDMS_DT_COL_TYPES(COL_TYPE_SID)
 , INDICATOR_SID   NUMBER(8)
                   NOT NULL
                   CONSTRAINT FDMS_DT_LI_INDICATOR_FK REFERENCES FDMS_INDICATORS(INDICATOR_SID)
 , CONSTRAINT FDMS_DT_LINE_INDICATORS_PK PRIMARY KEY(TABLE_LINE_SID, COL_TYPE_SID)
);