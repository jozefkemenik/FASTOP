CREATE OR REPLACE PACKAGE DWH_GETTERS
AS
    PROCEDURE getIndicators(p_provider_ids  IN    CORE_COMMONS.VARCHARARRAY
                          , o_cur           OUT   SYS_REFCURSOR);

    PROCEDURE getIndicatorData(p_provider_ids    IN       CORE_COMMONS.VARCHARARRAY
                             , p_periodicity_id  IN       VARCHAR2
                             , p_indicator_ids   IN       CORE_COMMONS.VARCHARARRAY
                             , o_cur                 OUT  SYS_REFCURSOR);
END DWH_GETTERS;
