/* Formatted on 17-09-2021 14:47:51 (QP5 v5.313) */
DROP TABLE GD_GUARANTEE_REASONS CASCADE CONSTRAINTS;

CREATE TABLE GD_GUARANTEE_REASONS(
   REASON_SID  NUMBER(8) CONSTRAINT GD_GUARANTEE_REASONS_PK PRIMARY KEY
 , REASON_ID   VARCHAR2(32) NOT NULL CONSTRAINT GD_GUARANTEE_REASONS_UNQ UNIQUE
 , DESCR VARCHAR2(100 CHAR)
 , ORDER_BY NUMBER(8)
);
/