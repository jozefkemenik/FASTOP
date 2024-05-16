/* Formatted on 06-09-2021 18:40:09 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DRM_MEASURE
AS
   /******************************************************************************
      NAME:      DRM_MEASURE
      PURPOSE:   Measure accessors
   ******************************************************************************/

   PROCEDURE copyPreviousRoundMeasures(p_country_id IN     VARCHAR2
                                     , p_round_sid  IN     NUMBER
                                     , o_res           OUT NUMBER);

   PROCEDURE deleteMeasure(p_measure_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER);

   PROCEDURE getWizardMeasures(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getWizardArchivedMeasures(p_country_id     IN     VARCHAR2
                                     , o_cur               OUT SYS_REFCURSOR
                                     , p_round_sid      IN     NUMBER
                                     , p_history_offset IN     NUMBER);

   PROCEDURE getMeasureDetails(p_measure_sid IN     NUMBER
                             , p_country_id  IN     VARCHAR2
                             , o_cur            OUT SYS_REFCURSOR);

   PROCEDURE getMeasureDetailsArchived(p_round_sid     IN     NUMBER
                                     , p_storage_sid   IN     NUMBER
                                     , p_cust_text_sid IN     NUMBER
                                     , p_storage_id    IN     VARCHAR2
                                     , p_measure_sid   IN     NUMBER
                                     , p_country_id    IN     VARCHAR2
                                     , o_cur              OUT SYS_REFCURSOR);

   PROCEDURE getMeasures(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getMeasuresArchived(p_round_sid     IN     NUMBER
                               , p_storage_sid   IN     NUMBER
                               , p_cust_text_sid IN     NUMBER
                               , p_storage_id    IN     VARCHAR2
                               , p_country_id    IN     VARCHAR2
                               , o_cur              OUT SYS_REFCURSOR);

   PROCEDURE saveMeasureDetails(p_measure_sid      IN     NUMBER
                              , p_country_id       IN     VARCHAR2
                              , p_title            IN     VARCHAR2
                              , p_descr            IN     VARCHAR2
                              , p_esa_sid          IN     NUMBER
                              , p_one_off_sid      IN     NUMBER
                              , p_one_off_type_sid IN     NUMBER
                              , p_acc_princip_sid  IN     NUMBER
                              , p_adopt_status_sid IN     NUMBER
                              , p_label_sids       IN     SIDSLIST
                              , p_is_eu_funded_sid IN     NUMBER
                              , p_eu_fund_sid      IN     NUMBER
                              , o_res                 OUT NUMBER
                              , p_force_insert     IN     NUMBER DEFAULT 0);

   PROCEDURE setMeasureValues(p_measure_sid IN     NUMBER
                            , p_country_id  IN     VARCHAR2
                            , p_year        IN     NUMBER
                            , p_start_year  IN     NUMBER
                            , p_values      IN     VARCHAR2
                            , o_res            OUT NUMBER);

   PROCEDURE saveMeasureScale(p_country_id IN VARCHAR2, p_scale_sid IN NUMBER, o_res OUT NUMBER);

   PROCEDURE uploadWizardMeasures(p_country_id IN     VARCHAR2
                                , p_scale_sid  IN     NUMBER
                                , p_measures   IN     MEASUREARRAY
                                , o_res           OUT NUMBER);
END;