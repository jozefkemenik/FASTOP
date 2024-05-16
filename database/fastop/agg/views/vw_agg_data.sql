CREATE OR REPLACE FORCE VIEW VW_AGG_DATA ( "AGG_DATA_SID"
,                                          "ROUND_SID"
,                                          "AGG_TYPE_ID"
,                                          "COUNTRY_ID"
,                                          "START_YEAR"
,                                          "VECTOR"
,                                          "LAST_CHANGE_USER"
,                                          "LAST_CHANGE_DATE"
,                                          "AGG_TYPE"
,                                          "DESCR"
,                                          "GR_DESCR"
,                                          "COMPARABLE_VARIABLE_ID" )
AS
   SELECT ALD.AGG_LINE_DATA_SID
,         ALD.ROUND_SID
,         ALD.LINE_ID
,         ALD.COUNTRY_ID
,         ALD.START_YEAR
,         ALD.VECTOR
,         ALD.LAST_CHANGE_USER
,         ALD.LAST_CHANGE_DATE
,         'LINE' AS AGG_TYPE
,         L.DESCR
,         GR.DESCR AS GR_DESCR
,         L.INDICATOR_ID AS COMPARABLE_VARIABLE_ID
     FROM AGG_LINE_DATA ALD
     JOIN VW_GD_ROUND_GRID_LINES L
       ON (ALD.ROUND_SID = L.ROUND_SID AND ALD.LINE_ID = L.LINE_ID)
     JOIN GD_GRIDS GR
       ON L.GRID_SID = GR.GRID_SID
    UNION ALL
   SELECT AID.AGG_INDICATOR_DATA_SID
,         AID.ROUND_SID
,         I.INDICATOR_ID
,         AID.COUNTRY_ID
,         AID.START_YEAR
,         AID.VECTOR
,         AID.LAST_CHANGE_USER
,         AID.LAST_CHANGE_DATE
,         'INDICATOR' AS AGG_TYPE
,         I.DESCR
,         'Calculated variables' AS GR_DESCR
,         '' AS COMPARABLE_VARIABLE_ID
     FROM AGG_INDICATOR_DATA AID
     JOIN INDICATORS I
       ON AID.INDICATOR_SID = I.INDICATOR_SID;
