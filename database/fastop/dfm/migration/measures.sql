/* Formatted on 19-02-2020 19:15:13 (QP5 v5.313) */
ALTER TABLE DFM_MEASURES
    DISABLE ALL TRIGGERS;

INSERT INTO DFM_MEASURES(MEASURE_SID
                       , COUNTRY_ID
                       , STATUS_SID
                       , NEED_RESEARCH_SID
                       , TITLE
                       , SHORT_DESCR
                       , INFO_SRC
                       , ADOPT_DATE_YR
                       , COMMENTS
                       , YEAR
                       , REV_EXP_SID
                       , ESA95_SID
                       , ESA95_COMMENTS
                       , ONE_OFF_SID
                       , ONE_OFF_TYPE_SID
                       , ONE_OFF_DISAGREE_SID
                       , ONE_OFF_COMMENTS
                       , DATA
                       , START_YEAR
                       , IS_UPLOADED
                       , QUANT_COMMENTS
                       , FIRST_ROUND_SID
                       , OO_PRINCIPLE_SID
                       , IS_PUBLIC)
    SELECT M.MEASURE_SID
         , M.COUNTRY_ID
         , CASE WHEN M.STATUS_SID > 4 THEN 4 ELSE M.STATUS_SID END
         , M.NEED_RESEARCH_SID
         , M.TITLE
         , M.SHORT_DESCR
         , M.INFO_SRC
         , M.ADOPT_DATE_YR
         , M.COMMENTS
         , M.YEAR
         , M.REV_EXP_SID
         , M.ESA95_SID
         , M.ESA95_COMMENTS
         , M.ONE_OFF_SID
         , M.ONE_OFF_TYPE_SID
         , M.ONE_OFF_DISAGREE_SID
         , M.ONE_OFF_COMMENTS
         , M.DATA
         , M.START_YEAR
         , M.IS_UPLOADED
         , M.QUANT_COMMENTS
         , R.NEW_ROUND_SID
         , M.OO_PRINCIPLE_SID
         , M.IS_PUBLIC
      FROM DFM_MEASURES@SCOPAX M JOIN MIGR_ROUNDS R ON R.ROUND_SID = M.FIRST_ROUND_SID;

ALTER TABLE DFM_MEASURES
    ENABLE ALL TRIGGERS;