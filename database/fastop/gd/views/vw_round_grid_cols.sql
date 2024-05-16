/* Formatted on 12/3/2019 15:58:00 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW VW_GD_ROUND_GRID_COLS
AS
   SELECT RGC.ROUND_GRID_SID, RGC.ORDER_BY, C.*
     FROM GD_ROUND_GRID_COLS RGC JOIN VW_GD_COLS C ON C.COL_SID = RGC.COL_SID;