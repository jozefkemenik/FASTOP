/* Formatted on 12/3/2019 13:16:26 (QP5 v5.252.13127.32847) */
ALTER TABLE GD_GRID_VERSION_TYPES
   DROP PRIMARY KEY CASCADE;

DROP TABLE GD_GRID_VERSION_TYPES CASCADE CONSTRAINTS;

CREATE TABLE GD_GRID_VERSION_TYPES
(
   VERSION_TYPE_ID   VARCHAR2 (2 BYTE)
                        CONSTRAINT GD_GRID_VERSION_TYPES_PK PRIMARY KEY
,  DESCR             VARCHAR2 (50 BYTE) NOT NULL
);