/* Formatted on 12/03/2020 11:21:40 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DFM_COUNTRY_STATUS
AS
   /**************************************************************************
    * NAME:      DFM_COUNTRY_STATUS
    * PURPOSE:   DFM Country submit and archive measures functionality
    **************************************************************************/

   PROCEDURE archiveCountryMeasures(p_round_sid     IN     NUMBER
                                  , p_storage_sid   IN     NUMBER
                                  , p_cust_text_sid IN     NUMBER
                                  , p_country_id    IN     VARCHAR2
                                  , p_user         IN     VARCHAR2
                                  , o_res              OUT NUMBER);

   PROCEDURE presubmit(p_round_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER);
END DFM_COUNTRY_STATUS;
/