/* Formatted on 17-05-2021 17:44:22 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE TASK_COMMANDS
AS
   PROCEDURE prepareTask(p_app_id      IN     VARCHAR2
                       , p_task_id     IN     VARCHAR2
                       , p_country_ids IN     CORE_COMMONS.VARCHARARRAY
                       , p_prep_steps  IN     NUMBER
                       , p_user        IN     VARCHAR2
                       , o_res            OUT NUMBER
                       , p_concurrency IN     NUMBER DEFAULT 1);

   PROCEDURE addTaskRunPrepStep(p_task_run_sid IN NUMBER, o_res OUT NUMBER);

   PROCEDURE addConcurrentSteps(p_task_run_sid IN NUMBER, p_steps IN CORE_COMMONS.SIDSARRAY);

   PROCEDURE setTaskRunAllSteps(p_task_run_sid IN NUMBER, p_num_steps IN NUMBER, o_res OUT NUMBER);

   PROCEDURE finishTask(p_task_run_sid   IN     NUMBER
                      , p_task_status_id IN     VARCHAR2
                      , p_num_steps      IN     NUMBER
                      , o_res               OUT NUMBER);

   PROCEDURE logStep(p_task_run_sid    IN     NUMBER
                   , p_step_number     IN     NUMBER
                   , p_step_descr      IN     VARCHAR2
                   , p_step_status_id  IN     VARCHAR2
                   , p_step_exceptions IN     NUMBER
                   , p_step_message    IN     VARCHAR2
                   , p_step_type_id    IN     VARCHAR2
                   , o_res                OUT NUMBER);

   PROCEDURE logStepValidations(p_task_log_sid    IN     NUMBER
                              , p_labels          IN     VARCHAR2
                              , p_indicator_codes IN     CORE_COMMONS.VARCHARARRAY
                              , p_actual          IN     CORE_COMMONS.VARCHARARRAY
                              , p_validation1     IN     CORE_COMMONS.VARCHARARRAY
                              , p_validation2     IN     CORE_COMMONS.VARCHARARRAY
                              , p_failed          IN     CORE_COMMONS.VARCHARARRAY
                              , o_res                OUT NUMBER);
END TASK_COMMANDS;