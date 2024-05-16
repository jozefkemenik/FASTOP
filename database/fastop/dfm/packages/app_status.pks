/* Formatted on 12-05-2020 13:47:04 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DFM_APP_STATUS
AS
   /**************************************************************************
    * NAME:      DFM_APP_STATUS
    * PURPOSE:   DFM Application status setting functionality
    **************************************************************************/

   PROCEDURE setApplicationOpen(o_res OUT NUMBER);

   PROCEDURE setApplicationClosed(o_res OUT NUMBER);

   PROCEDURE setApplicationArchived(o_res OUT NUMBER);

   PROCEDURE setApplicationTROpen(o_res OUT NUMBER);

   PROCEDURE setApplicationTRPublish(p_round_sid     IN     NUMBER
                                   , p_storage_sid   IN     NUMBER
                                   , p_cust_text_sid IN     NUMBER
                                   , o_res              OUT NUMBER);

   PROCEDURE archiveMeasures(p_round_sid     IN     NUMBER
                           , p_storage_sid   IN     NUMBER
                           , p_cust_text_sid IN     NUMBER
                           , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                           , p_user          IN     VARCHAR2
                           , o_res              OUT NUMBER);

   PROCEDURE createCustomStorage(p_round_sid IN     NUMBER
                               , p_title     IN     VARCHAR2
                               , p_descr     IN     VARCHAR2
                               , o_res          OUT NUMBER);
END DFM_APP_STATUS;
/