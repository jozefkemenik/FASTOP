CREATE OR REPLACE FORCE VIEW VW_NOMENCLATURES
(
   CODE
,  LABEL
,  NOMENCLATURE_TYPE
)
AS
SELECT CODE
     , LABEL
     , 'BPM6' AS NOMENCLATURE_TYPE
FROM BPM6
UNION ALL
SELECT CODE
     , LABEL
     , 'NACE1' AS NOMENCLATURE_TYPE
FROM NACE1
UNION ALL
SELECT CODE
     , LABEL
     , 'NACE2' AS NOMENCLATURE_TYPE
FROM NACE2
UNION ALL
SELECT CODE
     , LABEL
     , 'CPA2002' AS NOMENCLATURE_TYPE
FROM CPA2002
UNION ALL
SELECT CODE
     , LABEL
     , 'CPA2008' AS NOMENCLATURE_TYPE
FROM CPA2008
UNION ALL
SELECT CODE
     , LABEL
     , 'BEC' AS NOMENCLATURE_TYPE
FROM BEC
UNION ALL
SELECT CODE
     , LABEL
     , 'BPM5' AS NOMENCLATURE_TYPE
FROM BPM5;





