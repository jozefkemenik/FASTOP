/* Formatted on 12/3/2019 16:00:07 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW VW_GD_CELLS
AS
   SELECT VG.GRID_ID
,         VG.COUNTRY_ID
,         VG.CTY_GRID_SID
,         VG.VERSION
,         VG.YEAR
,         VG.ROUND_SID
,         VG.GRID_TYPE_ID
,         VL.LINE_ID
,         VL.LINE_TYPE_ID
,         VL.LINE_SID
,         VL.IN_LT
,         VL.IN_AGG
,         VC.YEAR_VALUE
,         VC.COL_SID
,         VC.DATA_TYPE_ID
,         VC.IS_ABSOLUTE
,         VC.COL_TYPE_ID
,         FC.VALUE_P
,         FC.VALUE_N
,         FC.VALUE_CD
,         F.N_FOOTNOTE
,         F.P_FOOTNOTE
,         F.CD_FOOTNOTE
,         F.N_FTN_SID
,         F.P_FTN_SID
,         F.CD_FTN_SID
     FROM GD_CELLS FC
          JOIN VW_GD_COLS VC ON FC.COL_SID = VC.COL_SID
          JOIN VW_GD_LINES VL ON FC.LINE_SID = VL.LINE_SID
          JOIN VW_GD_CTY_GRIDS VG ON FC.CTY_GRID_SID = VG.CTY_GRID_SID
          LEFT JOIN VW_GD_FOOTNOTES F
             ON F.CELL_SID = FC.CELL_SID AND F.CTY_GRID_SID = FC.CTY_GRID_SID
    WHERE     VC.COL_TYPE_ID = 'YEAR'
          AND VL.LINE_TYPE_ID IN ('LINE', 'CALCULATION');