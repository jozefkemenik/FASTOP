/* Formatted on 20-04-2020 23:02:06 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DRM_COUNTRY_STATUS
AS
   /**************************************************************************
    * NAME:      DRM_COUNTRY_STATUS
    * PURPOSE:   DRM Country submit and archive measures functionality
    **************************************************************************/

   PROCEDURE archiveCountryMeasures(p_round_sid  IN     NUMBER
                                  , p_country_id IN     VARCHAR2
                                  , o_res           OUT NUMBER);

   PROCEDURE presubmit(p_round_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER);
END DRM_COUNTRY_STATUS;