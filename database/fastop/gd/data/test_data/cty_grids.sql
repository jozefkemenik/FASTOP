/* Formatted on 6/7/2019 14:15:38 (QP5 v5.252.13127.32847) */
SET DEFINE OFF;

INSERT INTO GD_CTY_GRIDS (CTY_VERSION_SID, ROUND_GRID_SID)
   SELECT CV.CTY_VERSION_SID, RG.ROUND_GRID_SID
   FROM GD_CTY_VERSIONS CV
   FULL JOIN GD_ROUND_GRIDS RG ON 1=1;

COMMIT;
/
