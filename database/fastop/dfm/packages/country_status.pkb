/* Formatted on 03/09/2021 16:41:22 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DFM_COUNTRY_STATUS
AS
   /**************************************************************************
    * NAME:      DFM_COUNTRY_STATUS
    * PURPOSE:   DFM Country submit and archive measures functionality
    **************************************************************************/

   /************* PUBLIC *****************************************************/

   ----------------------------------------------------------------------------
   -- @name archiveCountryMeasures
   -- @return number of measures archived
   ----------------------------------------------------------------------------
   PROCEDURE archiveCountryMeasures(p_round_sid     IN     NUMBER
                                  , p_storage_sid   IN     NUMBER
                                  , p_cust_text_sid IN     NUMBER
                                  , p_country_id    IN     VARCHAR2
                                  , p_user          IN     VARCHAR2
                                  , o_res              OUT NUMBER)
   IS
   BEGIN
      -- Delete previously archived measures to avoid duplicates
      DELETE FROM dfm_archived_measures
            WHERE 1 = 1
              AND country_id = p_country_id
              AND round_sid = p_round_sid
              AND storage_sid = p_storage_sid
              AND (p_cust_text_sid IS NULL OR cust_text_sid = p_cust_text_sid);

      -- Copy measures to the archive table
      INSERT INTO dfm_archived_measures(ROUND_SID
                                      , STORAGE_SID
                                      , CUST_TEXT_SID
                                      , MEASURE_SID
                                      , COUNTRY_ID
                                      , STATUS_SID
                                      , NEED_RESEARCH_SID
                                      , TITLE
                                      , SHORT_DESCR
                                      , INFO_SRC
                                      , ADOPT_DATE_YR
                                      , ADOPT_DATE_MH
                                      , COMMENTS
                                      , YEAR
                                      , REV_EXP_SID
                                      , ESA_SID
                                      , ESA_COMMENTS
                                      , ONE_OFF_SID
                                      , ONE_OFF_TYPE_SID
                                      , ONE_OFF_DISAGREE_SID
                                      , ONE_OFF_COMMENTS
                                      , DATA
                                      , START_YEAR
                                      , LOG_DATE
                                      , QUANT_COMMENTS
                                      , FIRST_ROUND_SID
                                      , OO_PRINCIPLE_SID
                                      , IS_EU_FUNDED_SID
                                      , EU_FUND_SID
                                      , IS_PUBLIC)
         SELECT p_ROUND_SID
              , p_STORAGE_SID
              , p_CUST_TEXT_SID
              , MEASURE_SID
              , COUNTRY_ID
              , STATUS_SID
              , NEED_RESEARCH_SID
              , TITLE
              , SHORT_DESCR
              , INFO_SRC
              , ADOPT_DATE_YR
              , ADOPT_DATE_MH
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
              , SYSDATE
              , QUANT_COMMENTS
              , FIRST_ROUND_SID
              , OO_PRINCIPLE_SID
              , IS_EU_FUNDED_SID
              , EU_FUND_SID
              , -1
           FROM DFM_MEASURES
          WHERE country_id = p_country_id;

      o_res := SQL%ROWCOUNT;
   END archiveCountryMeasures;

   PROCEDURE presubmit(p_round_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
        INTO o_res
        FROM DFM_MEASURES
       WHERE COUNTRY_ID = p_country_id;
   END presubmit;
END DFM_COUNTRY_STATUS;
/