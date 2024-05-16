/* Formatted on 12/2/2019 19:19:36 (QP5 v5.252.13127.32847) */
ALTER TABLE GD_LINE_TYPES
   DROP PRIMARY KEY CASCADE;

DROP TABLE GD_LINE_TYPES CASCADE CONSTRAINTS;

CREATE TABLE GD_LINE_TYPES
(
   LINE_TYPE_SID   NUMBER (8) CONSTRAINT GD_LINE_TYPES_PK PRIMARY KEY
,  LINE_TYPE_ID    VARCHAR2 (15 BYTE)
                      NOT NULL
                      CONSTRAINT GD_LINE_TYPES_ID_UNQ UNIQUE
,  DESCR           VARCHAR2 (500 BYTE)
);