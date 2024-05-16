/* Formatted on 06-05-2021 12:24:23 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE IDR_FISCAL_PARAMS
AS
   /******************************************************************************
      NAME:    IDR_FISCAL_PARAMS
      PURPOSE: Fiscal params functions
   ******************************************************************************/

   PROCEDURE getTemplateDefinitions(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getWorksheets(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getWorksheetIndicatorData(o_cur              OUT SYS_REFCURSOR
                                     , p_worksheet_sid IN     NUMBER
                                     , p_round_sid     IN     NUMBER DEFAULT NULL
                                     , p_app_id        IN     VARCHAR2 DEFAULT NULL);

   PROCEDURE storeIndicators(o_res                 OUT NUMBER
                           , p_round_sid        IN     NUMBER
                           , p_last_change_user IN     VARCHAR2
                           , p_indicator_sids   IN     CORE_COMMONS.SIDSARRAY
                           , p_country_ids      IN     CORE_COMMONS.VARCHARARRAY
                           , p_start_years      IN     CORE_COMMONS.SIDSARRAY
                           , p_vectors          IN     CORE_COMMONS.VARCHARARRAY);
END IDR_FISCAL_PARAMS;
/