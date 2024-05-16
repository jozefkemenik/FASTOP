/* Formatted on 24/01/2020 11:26:48 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE FDMS_ROUND
AS

    PROCEDURE getNextRoundInfo(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getRounds(o_cur OUT SYS_REFCURSOR);

    PROCEDURE checkNewRoundPreconditions(p_year                   IN     NUMBER
,                                        p_period_sid             IN     NUMBER
,                                        o_input_year_ok          OUT    NUMBER
,                                        o_input_period_sid_ok    OUT    NUMBER
,                                        o_storage_ok             OUT    NUMBER);

    PROCEDURE createNewRound(p_year                   IN     NUMBER
,                            p_period_sid             IN     NUMBER
,                            p_desc                   IN     VARCHAR2
,                            o_input_year_ok          OUT    NUMBER
,                            o_input_period_sid_ok    OUT    NUMBER
,                            o_grid_round_app_id      OUT    VARCHAR2
,                            o_grids_ok               OUT    NUMBER);

    PROCEDURE createCustomRound(p_year                   IN     NUMBER
,                               p_period_sid             IN     NUMBER
,                               p_version                IN     NUMBER
,                               p_desc                   IN     VARCHAR2
,                               o_input_year_ok          OUT    NUMBER
,                               o_input_period_sid_ok    OUT    NUMBER
,                               o_input_version_ok       OUT    NUMBER);


    PROCEDURE checkActivateRound(p_round_sid        IN    NUMBER
,                                o_round_ok        OUT    NUMBER
,                                o_storage_ok      OUT    NUMBER
,                                o_app_status_cur  OUT    SYS_REFCURSOR);

    PROCEDURE activateRound(p_round_sid  IN   NUMBER
,                           p_user       IN   VARCHAR2
,                           o_res        OUT  NUMBER);

    PROCEDURE moveToNextStorage (p_round_sid   IN  NUMBER
,                                p_storage_sid IN  NUMBER
,                                o_res         OUT NUMBER);

    PROCEDURE getPeriods(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getLatestVersion(p_year        IN  NUMBER
,                              p_period_sid  IN  NUMBER
,                              o_res         OUT NUMBER);

END FDMS_ROUND;
