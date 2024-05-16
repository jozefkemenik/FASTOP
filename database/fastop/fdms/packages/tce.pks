CREATE OR REPLACE PACKAGE FDMS_TCE
AS
    /******************************************************************************
                                CONSTANTS
    ******************************************************************************/
    TCE_RESULTS_PROVIDER_ID CONSTANT VARCHAR2(10) := 'TCE_RSLTS';

    FUNCTION getTceReportIndicatorSid(p_indicator_id IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE setTceMatrix(p_round_sid   IN     NUMBER
,                          p_storage_sid IN     NUMBER
,                          p_provider_id IN     VARCHAR2
,                          o_res            OUT NUMBER);

    PROCEDURE setTceMatrixData(p_matrix_sid     IN      NUMBER
,                              p_exp_cty_id     IN      VARCHAR2
,                              p_exp_line_nr    IN      NUMBER
,                              p_prnt_cty_ids   IN      CORE_COMMONS.VARCHARARRAY
,                              p_prnt_col_nbrs  IN      CORE_COMMONS.SIDSARRAY
,                              p_values         IN      CORE_COMMONS.VARCHARARRAY
,                              o_res                OUT NUMBER);

    PROCEDURE getTceMatrixData(o_cur               OUT  SYS_REFCURSOR
,                              p_provider_id   IN       VARCHAR2
,                              p_round_sid     IN       NUMBER  DEFAULT NULL
,                              p_storage_sid   IN       NUMBER  DEFAULT NULL);

    PROCEDURE getTceResults(p_round_sid   IN       NUMBER
,                           p_storage_sid IN       NUMBER
,                           p_country_id  IN       VARCHAR2
,                           o_cur             OUT  SYS_REFCURSOR);

    PROCEDURE getTceReportDefinition(o_cur   OUT   SYS_REFCURSOR);

    PROCEDURE setTceResults(o_res                OUT  NUMBER
,                           p_country_id     IN       VARCHAR2
,                           p_indicator_ids  IN       CORE_COMMONS.VARCHARARRAY
,                           p_data_types     IN       CORE_COMMONS.VARCHARARRAY
,                           p_start_year     IN       NUMBER
,                           p_time_series    IN       CORE_COMMONS.VARCHARARRAY
,                           p_user           IN       VARCHAR2
,                           p_round_sid      IN       NUMBER DEFAULT NULL
,                           p_storage_sid    IN       NUMBER DEFAULT NULL);

    PROCEDURE getTceResultsCountries(p_round_sid   IN       NUMBER DEFAULT NULL
,                                    p_storage_sid IN       NUMBER DEFAULT NULL
,                                    o_cur             OUT  SYS_REFCURSOR);

    PROCEDURE getTCEIndicatorData(o_cur               OUT  SYS_REFCURSOR
,                                 p_country_ids    IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                          NULL AS CORE_COMMONS.VARCHARARRAY
                                                                        )
,                                 p_indicator_ids  IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                          NULL AS CORE_COMMONS.VARCHARARRAY
                                                                        )
,                                 p_partner_ids    IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                          NULL AS CORE_COMMONS.VARCHARARRAY
                                                                        )
,                                 p_periodicity_id IN      VARCHAR2
,                                 p_round_sid      IN      NUMBER DEFAULT NULL
,                                 p_storage_sid    IN      NUMBER DEFAULT NULL
    );


    PROCEDURE getTCETradeItemData(o_cur               OUT  SYS_REFCURSOR
,                                 p_country_ids    IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                          NULL AS CORE_COMMONS.VARCHARARRAY
                                                                        )
,                                 p_tradeItem_ids  IN      CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                          NULL AS CORE_COMMONS.VARCHARARRAY
                                                                        )
,                                 p_periodicity_id IN      VARCHAR2
,                                 p_round_sid      IN      NUMBER DEFAULT NULL
,                                 p_storage_sid    IN      NUMBER DEFAULT NULL
    );


    PROCEDURE getTcePartners(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getTceTradeItems(o_cur OUT SYS_REFCURSOR);

END FDMS_TCE;
