/* Formatted on 12/4/2019 13:20:50 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW VW_DBP_MEASURES
AS
   SELECT M.*, V.COUNTRY_ID, V.VERSION
     FROM DBP_MEASURES M
          JOIN GD_CTY_VERSIONS V ON M.CTY_VERSION_SID = V.CTY_VERSION_SID;