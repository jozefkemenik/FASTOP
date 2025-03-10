/* Formatted on 12/3/2019 15:54:14 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW VW_GD_CTY_GRIDS
AS
   SELECT CG.*
,         CV.COUNTRY_ID
,         CV.VERSION
,         G.DESCR
,         G.GRID_ID
,         G.GRID_SID
,         G.YEAR
,         G.ROUND_SID
,         G.GRID_TYPE_ID
,         G.ORDER_BY
,         CS1.DESCR CD_STATUS
,         CS2.DESCR MS_STATUS
     FROM GD_CTY_GRIDS CG
          JOIN GD_CTY_VERSIONS CV ON CV.CTY_VERSION_SID = CG.CTY_VERSION_SID
          JOIN VW_GD_GRIDS G ON G.ROUND_GRID_SID = CG.ROUND_GRID_SID
          LEFT JOIN GD_CONSISTENCY_STATUSES CS1
             ON CS1.CONSISTENCY_STATUS_SID = CG.CONSISTENCY_STATUS_CD_SID
          LEFT JOIN GD_CONSISTENCY_STATUSES CS2
             ON CS2.CONSISTENCY_STATUS_SID = CG.CONSISTENCY_STATUS_MS_SID;