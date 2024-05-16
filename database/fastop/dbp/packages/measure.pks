/* Formatted on 7/30/2019 17:03:32 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE DBP_MEASURE
AS
   /******************************************************************************
      NAME:      DBP_MEASURE
      PURPOSE:   Measure accessors
   ******************************************************************************/

   PROCEDURE getMeasures (p_country_id   IN     VARCHAR2
,                         o_cur          OUT    SYS_REFCURSOR
,                         p_round_sid    IN     NUMBER DEFAULT NULL
,                         p_version      IN     NUMBER DEFAULT NULL);

   PROCEDURE getMeasureDetails (p_measure_sid   IN     NUMBER
,                               p_country_id    IN     VARCHAR2
,                               o_cur           OUT    SYS_REFCURSOR);

   PROCEDURE setMeasureValues (p_measure_sid   IN     NUMBER
,                              p_country_id    IN     VARCHAR2
,                              p_year          IN     NUMBER
,                              p_start_year    IN     NUMBER
,                              p_values        IN     VARCHAR2
,                              o_res           OUT    NUMBER);

   PROCEDURE saveMeasureDetails (p_measure_sid        IN     NUMBER
,                                p_country_id         IN     VARCHAR2
,                                p_title              IN     VARCHAR2
,                                p_descr              IN     VARCHAR2
,                                p_esa_sid            IN     NUMBER
,                                p_source_sid         IN     NUMBER
,                                p_acc_princip_sid    IN     NUMBER
,                                p_adopt_status_sid   IN     NUMBER
,                                o_res                OUT    NUMBER);

   PROCEDURE deleteMeasure (p_measure_sid   IN     NUMBER
,                           p_country_id    IN     VARCHAR2
,                           o_res           OUT    NUMBER);

   PROCEDURE deleteMeasures (p_country_id    IN     VARCHAR2
,                            p_round_sid     IN     NUMBER
,                            o_res           OUT    NUMBER);

   PROCEDURE saveMeasureScale (p_country_id    IN     VARCHAR2
,                              p_scale_sid     IN     NUMBER
,                              o_res           OUT    NUMBER);

   PROCEDURE getWizardMeasures (p_country_id   IN     VARCHAR2
,                               p_round_sid    IN     NUMBER
,                               o_cur          OUT    SYS_REFCURSOR);

   PROCEDURE saveMeasure( p_country_id             IN     VARCHAR2
,                         p_title                  IN     VARCHAR2
,                         p_descr                  IN     VARCHAR2
,                         p_source_sid             IN     NUMBER
,                         p_esa_sid                IN     NUMBER
,                         p_acc_princip_sid        IN     NUMBER
,                         p_adopt_status_sid       IN     NUMBER
,                         p_data                   IN     VARCHAR2
,                         p_start_year             IN     NUMBER
,                         p_year                   IN     NUMBER
,                         p_uploaded_measure_sid   IN     NUMBER
,                         o_res                    OUT    NUMBER );

   PROCEDURE uploadWizardMeasures( p_country_id     IN     VARCHAR2
,                                  p_scale_sid      IN     NUMBER
,                                  p_measures       IN     MEASUREARRAY
,                                  o_res            OUT    NUMBER);

END;
