/* Formatted on 12/5/2019 16:56:51 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW VW_GD_ROUND_GRID_LINES
AS
   SELECT RGL.ROUND_GRID_SID
,         RGL.ORDER_BY
,         RG.ROUND_SID
,         RG.GRID_SID
,         L.*
     FROM GD_ROUND_GRID_LINES RGL
          JOIN GD_ROUND_GRIDS RG ON RG.ROUND_GRID_SID = RGL.ROUND_GRID_SID
          JOIN VW_GD_LINES L ON L.LINE_SID = RGL.LINE_SID;