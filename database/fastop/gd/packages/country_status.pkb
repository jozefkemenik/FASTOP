/* Formatted on 11/22/2019 12:49:38 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE BODY GD_COUNTRY_STATUS
AS
   ----------------------------------------------------------------------------
   -- @name getDashboardGlobalDates
   ----------------------------------------------------------------------------
   PROCEDURE getDashboardGlobalDates (p_app_id              IN     VARCHAR2
,                                     o_ameco                  OUT DATE
,                                     o_linked_tables          OUT DATE
,                                     o_fiscal_parameters      OUT DATE)
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE
                       := CORE_GETTERS.GETCURRENTROUNDSID (p_app_id);
   BEGIN
      o_ameco := IDR_GETTERS.GETLASTAMECOUPLOAD (l_round_sid);
      o_linked_tables := GD_LINK_TABLES.GETACTIVETEMPLATEDATE (p_app_id);
      o_fiscal_parameters :=
         IDR_GETTERS.GETLASTFISCALPARAMSUPLOAD (l_round_sid);
   END getDashboardGlobalDates;

END GD_COUNTRY_STATUS;
