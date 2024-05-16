/* Formatted on 17-05-2021 17:43:49 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE TASK_GETTERS
AS
   PROCEDURE getCountryTask(o_cur            OUT SYS_REFCURSOR
                          , p_app_id      IN     VARCHAR2
                          , p_task_id     IN     VARCHAR2
                          , p_country_id  IN     VARCHAR2
                          , p_round_sid   IN     NUMBER DEFAULT NULL
                          , p_storage_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE getCtyTaskExceptions(p_task_id     IN     VARCHAR2
                                , p_country_id  IN     VARCHAR2
                                , p_round_sid   IN     NUMBER
                                , p_storage_sid IN     NUMBER
                                , o_cur            OUT SYS_REFCURSOR);

   PROCEDURE getTaskLogs(p_task_run_sid   IN     NUMBER
                       , o_task_status_id    OUT VARCHAR2
                       , o_cur               OUT SYS_REFCURSOR);

   PROCEDURE getTaskLogValidations(p_country_id  IN     VARCHAR2
                                 , p_step        IN     NUMBER
                                 , p_round_sid   IN     NUMBER
                                 , p_storage_sid IN     NUMBER
                                 , o_cur            OUT SYS_REFCURSOR);

   FUNCTION getTaskRunStatusId(p_task_run_sid IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE getCountriesTasks(o_cur            OUT SYS_REFCURSOR
                             , p_app_id      IN     VARCHAR2
                             , p_task_id     IN     VARCHAR2
                             , p_round_sid   IN     NUMBER DEFAULT NULL
                             , p_storage_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE getTasks(o_cur            OUT SYS_REFCURSOR
                    , p_country_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)
                    , p_storage_sids IN    CORE_COMMONS.SIDSARRAY    DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
                    , p_round_sids   IN    CORE_COMMONS.SIDSARRAY    DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
                    , p_status_ids  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY)
                    , p_task_sids   IN     CORE_COMMONS.SIDSARRAY    DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY));

   PROCEDURE getTaskCountriesDict(o_cur           OUT SYS_REFCURSOR
                                , p_status_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY));

   PROCEDURE getTaskRoundsDict(o_cur           OUT SYS_REFCURSOR
                             , p_status_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY));

   PROCEDURE getTaskStoragesDict(o_cur           OUT SYS_REFCURSOR
                               , p_status_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY));

   PROCEDURE getTaskNamesDict(o_cur           OUT SYS_REFCURSOR
                            , p_status_ids IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(NULL AS CORE_COMMONS.VARCHARARRAY));

END TASK_GETTERS;
