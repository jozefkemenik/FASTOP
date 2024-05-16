/* Formatted on 12/16/2019 15:30:47 (QP5 v5.252.13127.32847) */
INSERT INTO DFM_ARCHIVED_MEASURES (ROUND_SID
,                                  STORAGE_SID
,                                  CUST_TEXT_SID
,                                  MEASURE_SID
,                                  COUNTRY_ID
,                                  STATUS_SID
,                                  NEED_RESEARCH_SID
,                                  TITLE
,                                  SHORT_DESCR
,                                  INFO_SRC
,                                  ADOPT_DATE_YR
,                                  COMMENTS
,                                  YEAR
,                                  REV_EXP_SID
,                                  ESA_SID
,                                  ESA_COMMENTS
,                                  ONE_OFF_SID
,                                  ONE_OFF_TYPE_SID
,                                  ONE_OFF_DISAGREE_SID
,                                  ONE_OFF_COMMENTS
,                                  DATA
,                                  START_YEAR
,                                  LOG_DATE
,                                  QUANT_COMMENTS
,                                  FIRST_ROUND_SID
,                                  OO_PRINCIPLE_SID
,                                  IS_PUBLIC)
   SELECT MR1.NEW_ROUND_SID
,         S1.STORAGE_SID
,         MR1.NEW_CUST_TEXT_SID
,         AM.MEASURE_SID
,         AM.COUNTRY_ID
,         AM.STATUS_SID
,         AM.NEED_RESEARCH_SID
,         AM.TITLE
,         AM.SHORT_DESCR
,         AM.INFO_SRC
,         AM.ADOPT_DATE_YR
,         AM.COMMENTS
,         AM.YEAR
,         AM.REV_EXP_SID
,         AM.ESA95_SID
,         AM.ESA95_COMMENTS
,         AM.ONE_OFF_SID
,         AM.ONE_OFF_TYPE_SID
,         AM.ONE_OFF_DISAGREE_SID
,         AM.ONE_OFF_COMMENTS
,         AM.DATA
,         AM.START_YEAR
,         AM.LOG_DATE
,         AM.QUANT_COMMENTS
,         MR2.NEW_ROUND_SID
,         AM.OO_PRINCIPLE_SID
,         AM.IS_PUBLIC
     FROM DFM_ARCHIVED_MEASURES@SCOPAX AM
          JOIN MIGR_ROUNDS MR1 ON MR1.ROUND_SID = AM.ROUND_SID
          JOIN STORAGES S1 ON S1.STORAGE_ID = MR1.NEW_STORAGE_ID
          LEFT JOIN MIGR_ROUNDS MR2 ON MR2.ROUND_SID = AM.FIRST_ROUND_SID;
          
COMMIT;