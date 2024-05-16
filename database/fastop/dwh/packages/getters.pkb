CREATE OR REPLACE PACKAGE BODY DWH_GETTERS
AS
    ----------------------------------------------------------------------------
    -- @name getIndicators
    ----------------------------------------------------------------------------
    PROCEDURE getIndicators(p_provider_ids  IN    CORE_COMMONS.VARCHARARRAY
                          , o_cur           OUT   SYS_REFCURSOR)
    IS
      l_provider_ids  VARCHARLIST := CORE_COMMONS.arrayToList(p_provider_ids);
    BEGIN
       OPEN o_cur FOR
          SELECT DISTINCT INDICATOR_ID   AS "indicatorId"
               , PERIODICITY_ID          AS "periodicityId"
               , TO_CHAR(DESCR)          AS "descr"
            FROM VW_DWH_INDICATORS
           WHERE PROVIDER_ID IN (SELECT * FROM TABLE(l_provider_ids))
        ORDER BY INDICATOR_ID ASC;
    END getIndicators;

    ----------------------------------------------------------------------------
    -- @name getIndicatorData
    ----------------------------------------------------------------------------
    PROCEDURE getIndicatorData(p_provider_ids    IN       CORE_COMMONS.VARCHARARRAY
                             , p_periodicity_id  IN       VARCHAR2
                             , p_indicator_ids   IN       CORE_COMMONS.VARCHARARRAY
                             , o_cur                 OUT  SYS_REFCURSOR)
    IS
      l_provider_ids  VARCHARLIST := CORE_COMMONS.arrayToList(p_provider_ids);
      l_indicator_ids  VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
    BEGIN
       OPEN o_cur FOR
          SELECT INDICATOR_ID    AS "indicatorId"
               , PERIODICITY_ID  AS "periodicityId"
               , START_YEAR      AS "startYear"
               , TIMESERIE_DATA  AS "timeserie"
               , UPDATE_DATE     AS "updateDate"
               , UPDATE_USER     AS "updateUser"
            FROM VW_DWH_INDICATOR_DATA
           WHERE PERIODICITY_ID = p_periodicity_id
             AND PROVIDER_ID IN (SELECT * FROM TABLE(l_provider_ids))
             AND INDICATOR_ID IN (SELECT * FROM TABLE(l_indicator_ids));
    END getIndicatorData;

END DWH_GETTERS;
