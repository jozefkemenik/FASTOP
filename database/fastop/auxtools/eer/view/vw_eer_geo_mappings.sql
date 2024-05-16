CREATE OR REPLACE FORCE VIEW VW_EER_GEO_MAPPINGS
AS
   SELECT G.GEO_AREA_ID AS GEO_AREA_ID
        , (CASE
             WHEN M.SOURCE_DESCR IS NOT NULL THEN M.SOURCE_DESCR
             ELSE G.DESCR
           END) AS DESCR
        , G.NEER_ORDER AS ORDER_BY
     FROM GEO_AREAS G
LEFT JOIN GEO_AREA_MAPPINGS M
       ON G.GEO_AREA_ID = M.GEO_AREA_ID AND M.MAPPING_ID = 'EER';
