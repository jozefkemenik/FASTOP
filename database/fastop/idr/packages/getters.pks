/* Formatted on 23/03/2021 11:18:52 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE IDR_GETTERS
AS
   /******************************************************************************
      NAME:    IDR_GETTERS
      PURPOSE: Indicator getters
   ******************************************************************************/

   PROCEDURE getIndicatorById(o_cur             OUT SYS_REFCURSOR
                            , p_indicator_id IN     indicators.indicator_id%TYPE);

   PROCEDURE getIndicatorListBySource(o_cur       OUT SYS_REFCURSOR
                                    , p_source IN     indicators.source%TYPE DEFAULT NULL);

   PROCEDURE getAmecoIndForLinkedTables(o_cur OUT SYS_REFCURSOR, p_workbook_id IN VARCHAR2);

   FUNCTION getLastAmecoUpload(p_round_sid IN NUMBER)
      RETURN DATE;

   FUNCTION getLastFiscalParamsUpload(p_round_sid IN NUMBER)
      RETURN DATE;

   PROCEDURE getCurrentGDP(p_country_id    IN     VARCHAR2
                         , o_cur              OUT SYS_REFCURSOR
                         , p_with_forecast IN     NUMBER DEFAULT NULL);

   PROCEDURE getHelpMessages(p_help_msg_type_id IN VARCHAR2 DEFAULT NULL, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getCyclicalAdjustments(
      o_cur            OUT SYS_REFCURSOR
    , p_country_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                NULL AS CORE_COMMONS.VARCHARARRAY
                                                             )
    , p_round_sid   IN     NUMBER DEFAULT NULL
   );
END;