/* Formatted on 11/21/2019 15:22:24 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE GD_COUNTRY_STATUS
AS
   /***************************************************************************
      NAME:    GD_COUNTRY_STATUS
      PURPOSE: Grid country status changes accessors
    ***************************************************************************/

   PROCEDURE getDashboardGlobalDates (p_app_id              IN     VARCHAR2
,                                     o_ameco                  OUT DATE
,                                     o_linked_tables          OUT DATE
,                                     o_fiscal_parameters      OUT DATE);
END GD_COUNTRY_STATUS;