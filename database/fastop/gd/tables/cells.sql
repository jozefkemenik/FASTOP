/* Formatted on 12/3/2019 13:12:49 (QP5 v5.252.13127.32847) */
ALTER TABLE GD_CELLS
   DROP PRIMARY KEY CASCADE;

DROP TABLE GD_CELLS;
DROP SEQUENCE GD_CELLS_SID_SEQ;

CREATE TABLE GD_CELLS
(
   CELL_SID       NUMBER (8) CONSTRAINT GD_CELLS_PK PRIMARY KEY
,  CTY_GRID_SID   NUMBER (8)
                     NOT NULL
                     CONSTRAINT GD_CELLS_CTY_GRID_FK

                        REFERENCES GD_CTY_GRIDS (CTY_GRID_SID) ON DELETE CASCADE
,  LINE_SID       NUMBER (8)
                     NOT NULL
                     CONSTRAINT GD_CELLS_LINE_FK
                         REFERENCES GD_LINES (LINE_SID)
,  COL_SID        NUMBER (8)
                     NOT NULL
                     CONSTRAINT GD_CELLS_COL_FK REFERENCES GD_COLS (COL_SID)
,  VALUE_P        VARCHAR2 (100 BYTE)
,  VALUE_N        VARCHAR2 (100 BYTE)
,  VALUE_CD       VARCHAR2 (100 BYTE)
,  CONSTRAINT GD_CELLS_UNQ UNIQUE (CTY_GRID_SID, LINE_SID, COL_SID)
);

CREATE SEQUENCE GD_CELLS_SID_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER GD_CELLS_TRG
   BEFORE INSERT
   ON GD_CELLS
   FOR EACH ROW
BEGIN
   SELECT GD_CELLS_SID_SEQ.NEXTVAL INTO :NEW.CELL_SID FROM DUAL;
END;