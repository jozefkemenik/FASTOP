/* Formatted on 29-03-2021 19:47:21 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE IDR_CALCULATED
AS
   /******************************************************************************
      NAME:    IDR_CALCULATED
      PURPOSE: Calculated indicators data accessors
   ******************************************************************************/

   PROCEDURE getAmecoIndicators(o_cur           OUT SYS_REFCURSOR
                              , p_country_id IN     VARCHAR2
                              , p_indicators IN     CORE_COMMONS.VARCHARARRAY
                              , p_round_sid  IN     NUMBER);

   PROCEDURE getAmecoIndicatorsForCSV(o_cur              OUT SYS_REFCURSOR
                                    , p_round_sids    IN     CORE_COMMONS.SIDSARRAY
                                    , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                                    , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY);

   PROCEDURE getCalculatedIndicators(o_cur           OUT SYS_REFCURSOR
                                   , p_country_id IN     VARCHAR2
                                   , p_sources    IN     CORE_COMMONS.VARCHARARRAY
                                   , p_indicators IN     CORE_COMMONS.VARCHARARRAY
                                   , p_round_sid  IN     NUMBER);

   PROCEDURE getCalculatedIndicatorsForCSV(o_cur              OUT SYS_REFCURSOR
                                         , p_round_sids    IN     CORE_COMMONS.SIDSARRAY
                                         , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                                         , p_indicator_ids IN     CORE_COMMONS.VARCHARARRAY);

   PROCEDURE getSemiElasticityInfo(o_cur OUT SYS_REFCURSOR, p_country_id IN VARCHAR2, p_round_sid IN NUMBER);

   PROCEDURE getAmecoLastChangeDate(o_res           OUT DATE
                                  , p_country_id IN     VARCHAR2
                                  , p_round_sid  IN     NUMBER);


   PROCEDURE getCalculatedLastChangeDate(o_res             OUT DATE
                                       , p_indicator_id IN     VARCHAR2
                                       , p_country_id   IN     VARCHAR2
                                       , p_round_sid    IN     NUMBER);

   FUNCTION scaleTimeSerie(p_time_serie IN VARCHAR2, p_scale_id IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE uploadCalculatedIndicatorData(
      p_round_sid        IN     calculated_indic_data.round_sid%TYPE
    , p_indicator_sid    IN     calculated_indic_data.indicator_sid%TYPE
    , p_country_id       IN     calculated_indic_data.country_id%TYPE
    , p_start_year       IN     calculated_indic_data.start_year%TYPE
    , p_vector           IN     calculated_indic_data.vector%TYPE
    , p_last_change_user IN     calculated_indic_data.last_change_user%TYPE
    , p_source           IN     calculated_indic_data.source%TYPE
    , o_res                 OUT NUMBER
   );
END IDR_CALCULATED;