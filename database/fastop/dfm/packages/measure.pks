/* Formatted on 27-08-2021 15:42:17 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DFM_MEASURE
AS
   /******************************************************************************
      NAME:      DFM_MEASURE
      PURPOSE:   Measure accessors
   ******************************************************************************/
   TYPE NUMBERSTABLE IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   PROCEDURE deleteMeasure(p_measure_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER);

   PROCEDURE getAllMeasures(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getAllMeasuresArchived(p_round_sid     IN OUT NUMBER
                                  , p_storage_sid   IN OUT NUMBER
                                  , p_cust_text_sid IN     NUMBER
                                  , p_storage_id    IN     VARCHAR2
                                  , o_cur              OUT SYS_REFCURSOR);

   PROCEDURE getCountryMeasures(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getCountryMeasuresArchived(p_round_sid     IN OUT NUMBER
                                      , p_storage_sid   IN OUT NUMBER
                                      , p_cust_text_sid IN     NUMBER
                                      , p_storage_id    IN     VARCHAR2
                                      , p_country_id    IN     VARCHAR2
                                      , o_cur              OUT SYS_REFCURSOR);

   PROCEDURE getMeasureDetails(p_measure_sid IN     NUMBER
                             , p_country_id  IN     VARCHAR2
                             , o_cur            OUT SYS_REFCURSOR);

   PROCEDURE getMeasureDetailsArchived(p_round_sid     IN OUT NUMBER
                                     , p_storage_sid   IN OUT NUMBER
                                     , p_cust_text_sid IN     NUMBER
                                     , p_storage_id    IN     VARCHAR2
                                     , p_measure_sid   IN     NUMBER
                                     , p_country_id    IN     VARCHAR2
                                     , o_cur              OUT SYS_REFCURSOR);

   PROCEDURE getMeasures(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getMeasuresArchived(p_round_sid     IN OUT NUMBER
                               , p_storage_sid   IN OUT NUMBER
                               , p_cust_text_sid IN     NUMBER
                               , p_storage_id    IN     VARCHAR2
                               , p_country_id    IN     VARCHAR2
                               , o_cur              OUT SYS_REFCURSOR);

   PROCEDURE getTransparencyReportMeasures(o_cur           OUT SYS_REFCURSOR
                                         , p_country_id IN     VARCHAR2
                                         , p_round_sid  IN     NUMBER DEFAULT NULL);

   PROCEDURE saveMeasureDetails(p_measure_sid          IN     NUMBER
                              , p_country_id           IN     VARCHAR2
                              , p_status_sid           IN     NUMBER
                              , p_need_research_sid    IN     NUMBER
                              , p_title                IN     VARCHAR2
                              , p_descr                IN     VARCHAR2
                              , p_info_src             IN     VARCHAR2
                              , p_adopt_date_yr        IN     NUMBER
                              , p_adopt_date_mh        IN     NUMBER
                              , p_comments             IN     VARCHAR2
                              , p_rev_exp_sid          IN     NUMBER
                              , p_esa_sid              IN     NUMBER
                              , p_esa_comments         IN     VARCHAR2
                              , p_one_off_sid          IN     NUMBER
                              , p_one_off_type_sid     IN     NUMBER
                              , p_one_off_disagree_sid IN     NUMBER
                              , p_one_off_comments     IN     VARCHAR2
                              , p_quant_comments       IN     VARCHAR2
                              , p_oo_principle_sid     IN     NUMBER
                              , p_label_sids           IN     SIDSLIST
                              , p_is_eu_funded_sid     IN     NUMBER
                              , p_eu_fund_sid          IN     NUMBER
                              , p_is_uploaded          IN     VARCHAR2 DEFAULT NULL
                              , o_res                     OUT NUMBER);

   PROCEDURE setMeasureValues(p_measure_sid IN     NUMBER
                            , p_country_id  IN     VARCHAR2
                            , p_year        IN     NUMBER
                            , p_start_year  IN     NUMBER
                            , p_values      IN     VARCHAR2
                            , o_res            OUT NUMBER);

   PROCEDURE saveTransparencyReport(p_country_id   IN     VARCHAR2
                                  , p_measure_sids IN     NUMBERSTABLE
                                  , o_res             OUT NUMBER);

   PROCEDURE uploadWizardMeasures(p_country_id IN     VARCHAR2
                                , p_scale_sid  IN     NUMBER
                                , p_measures   IN     MEASUREARRAY
                                , o_res           OUT NUMBER);
END;
/