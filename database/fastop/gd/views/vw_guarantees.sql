/* Formatted on 22/09/2021 17:32:22 (QP5 v5.313) */
CREATE OR REPLACE FORCE VIEW VW_GD_GUARANTEES
AS
   SELECT G.*, V.COUNTRY_ID, V.VERSION
     FROM GD_GUARANTEES G JOIN GD_CTY_VERSIONS V ON G.CTY_VERSION_SID = V.CTY_VERSION_SID;