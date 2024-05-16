/* Formatted on 05/03/2019 17:07:14 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW VW_DFM_ALL_ESA
(
   ESA95_SID,
   ESA95_ID,
   DESCR,
   REV_EXP_SID,
   ORDER_BY,
   OVERVIEW_SID,
   AMECO_CODE_ID,
   RELATED_ESA95_SID,
   RELATED_ESA2010_SID,
   ESA_PERIOD
)
AS
   SELECT "ESA95_SID",
          "ESA95_ID",
          "DESCR",
          "REV_EXP_SID",
          "ORDER_BY",
          "OVERVIEW_SID",
          "AMECO_CODE_ID",
          NULL AS RELATED_ESA95_SID,
          "RELATED_ESA2010_SID",
          'esa95' AS esa_period
     FROM dfm_esa95
   UNION ALL
   SELECT "ESA2010_SID",
          "ESA2010_ID",
          "DESCR",
          "REV_EXP_SID",
          "ORDER_BY",
          "OVERVIEW_SID",
          "AMECO_CODE_ID",
          "RELATED_ESA95_SID",
          NULL AS RELATED_ESA2010_SID,
          'esa2010' AS esa_period
     FROM dfm_esa2010;
