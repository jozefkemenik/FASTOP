/* Formatted on 16-04-2021 11:46:47 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE ST_COUNTRY_STATUS
AS
   PROCEDURE getActions(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getCtyStatusChanges(o_cur            OUT SYS_REFCURSOR
                               , p_country_ids IN     CORE_COMMONS.VARCHARARRAY
                               , p_round_sid   IN     NUMBER);

   PROCEDURE getCountryStatuses(o_cur              OUT SYS_REFCURSOR
                              , p_app_id        IN     VARCHAR2
                              , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                              , p_round_sid     IN     NUMBER
                              , p_storage_sid   IN     NUMBER DEFAULT NULL
                              , p_cust_text_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE getCountryAcceptedDates(o_cur                  OUT SYS_REFCURSOR
                                   , p_app_id            IN     VARCHAR2
                                   , p_country_ids       IN     CORE_COMMONS.VARCHARARRAY
                                   , p_only_full_storage IN     NUMBER DEFAULT 0
                                   , p_only_full_round   IN     NUMBER DEFAULT 0);

   PROCEDURE setCountryStatus(o_res              OUT NUMBER
                            , o_cur              OUT SYS_REFCURSOR
                            , p_app_id        IN     VARCHAR2
                            , p_country_id    IN     VARCHAR2
                            , p_old_status_id IN     VARCHAR2
                            , p_new_status_id IN     VARCHAR2
                            , p_user          IN     VARCHAR2
                            , p_comment       IN     VARCHAR2
                            , p_send_mail     IN     NUMBER
                            , p_round_sid     IN     NUMBER
                            , p_storage_sid   IN     NUMBER DEFAULT NULL
                            , p_cust_text_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE setManyCountriesStatus(o_res              OUT NUMBER
                                  , p_app_id        IN     VARCHAR2
                                  , p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
                                  , p_new_status_id IN     VARCHAR2
                                  , p_user          IN     VARCHAR2
                                  , p_comment       IN     VARCHAR2
                                  , p_round_sid     IN     NUMBER
                                  , p_storage_sid   IN     NUMBER DEFAULT NULL
                                  , p_cust_text_sid IN     NUMBER DEFAULT NULL);
END ST_COUNTRY_STATUS;
/
