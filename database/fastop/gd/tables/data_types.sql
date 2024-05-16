/* Formatted on 12/3/2019 12:54:41 (QP5 v5.252.13127.32847) */
ALTER TABLE GD_DATA_TYPES
   DROP PRIMARY KEY CASCADE;

DROP TABLE GD_DATA_TYPES CASCADE CONSTRAINTS;

CREATE TABLE GD_DATA_TYPES
(
   DATA_TYPE_SID   NUMBER (8) CONSTRAINT GD_DATA_TYPES_PK PRIMARY KEY
,  DATA_TYPE_ID    VARCHAR2 (15 BYTE)
                      NOT NULL
                      CONSTRAINT GD_DATA_TYPES_ID_UNQ UNIQUE
,  DESCR           VARCHAR2 (50 BYTE)
,  LINE_INDICATOR_DISPLAY   NUMBER(1) DEFAULT 0
);