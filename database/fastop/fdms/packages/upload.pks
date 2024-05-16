/* Formatted on 19-01-2021 16:44:14 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE FDMS_UPLOAD
AS
   PROCEDURE getUploadInfo(o_user           OUT VARCHAR2
                         , o_date           OUT DATE
                         , p_round_sid   IN     NUMBER
                         , p_storage_sid IN     NUMBER
                         , p_provider_id IN     VARCHAR2
                         , p_country_id  IN     VARCHAR2 DEFAULT NULL);

   PROCEDURE getLatestUploadInfo(o_user           OUT VARCHAR2
                               , o_date           OUT DATE
                               , o_round_sid      OUT NUMBER
                               , o_storage_sid    OUT NUMBER
                               , p_provider_id IN     VARCHAR2
                               , p_country_id  IN     VARCHAR2 DEFAULT NULL);

   PROCEDURE getCountryUploadsInfo(
      o_cur            OUT SYS_REFCURSOR
    , p_app_id      IN     VARCHAR2 DEFAULT FDMS_GETTERS.APP_ID
    , p_country_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                NULL AS CORE_COMMONS.VARCHARARRAY
                                                             )
    , p_round_sid   IN     NUMBER DEFAULT NULL
    , p_storage_sid IN     NUMBER DEFAULT NULL
   );

   PROCEDURE getIndicatorDataUploads(p_round_sid   IN     NUMBER
                                   , p_storage_sid IN     NUMBER
                                   , o_cur            OUT SYS_REFCURSOR);

   PROCEDURE setIndicatorDataUpload(p_round_sid   IN     NUMBER
                                  , p_storage_sid IN     NUMBER
                                  , p_provider_id IN     VARCHAR2
                                  , p_user        IN     VARCHAR
                                  , o_res            OUT NUMBER
                                  , p_country_id  IN     VARCHAR2 DEFAULT NULL);

   PROCEDURE getDeskUpload(o_user             OUT VARCHAR2
                         , o_date             OUT DATE
                         , o_cur_annual       OUT SYS_REFCURSOR
                         , o_cur_quarterly    OUT SYS_REFCURSOR
                         , p_country_id    IN     VARCHAR2
                         , p_send_data     IN     NUMBER
                         , p_round_sid     IN     NUMBER DEFAULT NULL
                         , p_storage_sid   IN     NUMBER DEFAULT NULL);

   PROCEDURE getProviderUpload(o_user           OUT VARCHAR2
                             , o_date           OUT DATE
                             , o_cur            OUT SYS_REFCURSOR
                             , p_provider_id IN     VARCHAR2
                             , p_periodicity IN     VARCHAR2
                             , p_send_data   IN     NUMBER
                             , p_round_sid   IN     NUMBER DEFAULT NULL
                             , p_storage_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE uploadFile(o_res               OUT NUMBER
                      , p_app_id        IN      VARCHAR2
                      , p_round_sid     IN      NUMBER
                      , p_storage_sid   IN      NUMBER
                      , p_cust_text_sid IN      NUMBER
                      , p_country_id    IN      VARCHAR2
                      , p_provider_id   IN      VARCHAR2
                      , p_file_name     IN      VARCHAR2
                      , p_content_type  IN      VARCHAR2
                      , p_content       IN      BLOB
                      , p_user          IN      VARCHAR);

   PROCEDURE getFiles(o_cur               OUT SYS_REFCURSOR
                    , p_app_id        IN      VARCHAR2
                    , p_round_sid     IN      NUMBER
                    , p_storage_sid   IN      NUMBER
                    , p_cust_text_sid IN      NUMBER);

   PROCEDURE downloadFile(o_cur         OUT SYS_REFCURSOR
                        , p_file_sid IN     NUMBER);

   PROCEDURE removeOldFiles(p_round_sid   IN  NUMBER);


   PROCEDURE getEerData(o_cur OUT SYS_REFCURSOR);

END;
/
