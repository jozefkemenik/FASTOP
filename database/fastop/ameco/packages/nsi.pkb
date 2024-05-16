CREATE OR REPLACE PACKAGE BODY AMECO_NSI
AS
    ----------------------------------------------------------------------------
    ------------------------------- Private methods ----------------------------
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- @name getNSIIndicatorSid
    ----------------------------------------------------------------------------
    FUNCTION getNSIIndicatorSid(p_nsi_indicator_id IN VARCHAR2, p_periodicity_id IN VARCHAR2)
       RETURN NUMBER
    IS
       l_nsi_indicator_sid AMECO_NSI_INDICATORS.NSI_INDICATOR_SID%TYPE;
    BEGIN
       BEGIN
          SELECT NSI_INDICATOR_SID
            INTO l_nsi_indicator_sid
            FROM AMECO_NSI_INDICATORS
           WHERE NSI_INDICATOR_ID = p_nsi_indicator_id
             AND PERIODICITY_ID = p_periodicity_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_nsi_indicator_sid := -1;
       END;

       RETURN l_nsi_indicator_sid;
    END getNSIIndicatorSid;

    ----------------------------------------------------------------------------
    -------------------------------- Public methods ----------------------------
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- @name getNSIData
    ----------------------------------------------------------------------------
    PROCEDURE getNSIData(o_cur               OUT SYS_REFCURSOR
                       , p_country_id     IN     VARCHAR2 DEFAULT NULL
                       , p_periodicity_id IN     VARCHAR2 DEFAULT 'A')
    IS
    BEGIN
       OPEN o_cur FOR
          SELECT N.NSI_INDICATOR_SID
               , N.NSI_INDICATOR_ID
               , N.COUNTRY_ID
               , N.TYPE
               , N.PERIODICITY_ID
               , N.START_YEAR
               , N.UPDATE_DATE
               , N.UPDATE_USER
               , D.TIMESERIE_DATA
               , D.ORDER_BY
            FROM AMECO_NSI_INDICATORS N
            JOIN AMECO_NSI_INDICATOR_DATA D
              ON N.NSI_INDICATOR_SID = D.NSI_INDICATOR_SID
           WHERE (p_country_id IS NULL OR N.COUNTRY_ID = p_country_id)
             AND N.PERIODICITY_ID = p_periodicity_id;
    END getNSIData;

    ----------------------------------------------------------------------------
    -- @name setNSIData
    ----------------------------------------------------------------------------
    PROCEDURE setNSIData(o_res                    OUT  NUMBER
                       ,  p_nsi_indicator_id   IN       VARCHAR2
                       ,  p_country_id         IN       VARCHAR2
                       ,  p_type               IN       VARCHAR2
                       ,  p_periodicity_id     IN       VARCHAR2
                       ,  p_start_year         IN       NUMBER
                       ,  p_time_series        IN       CORE_COMMONS.VARCHARARRAY
                       ,  p_orders             IN       CORE_COMMONS.SIDSARRAY
                       ,  p_user               IN       VARCHAR2)
    IS
       l_nsi_indicator_sid NUMBER := getNSIIndicatorSid(p_nsi_indicator_id, p_periodicity_id);
    BEGIN
       o_res := p_time_series.COUNT;

       IF l_nsi_indicator_sid > 0 THEN
         DELETE
           FROM AMECO_NSI_INDICATORS
          WHERE NSI_INDICATOR_SID = l_nsi_indicator_sid;

          l_nsi_indicator_sid := -1;
       END IF;

       INSERT INTO AMECO_NSI_INDICATORS( NSI_INDICATOR_ID
                                       , COUNTRY_ID
                                       , TYPE
                                       , PERIODICITY_ID
                                       , START_YEAR
                                       , UPDATE_USER)
            VALUES ( p_nsi_indicator_id
                   , p_country_id
                   , p_type
                   , p_periodicity_id
                   , p_start_year
                   , p_user)
         RETURNING NSI_INDICATOR_SID
              INTO l_nsi_indicator_sid;

       FOR i IN 1 .. p_time_series.COUNT LOOP
          INSERT INTO AMECO_NSI_INDICATOR_DATA( NSI_INDICATOR_SID
                                              , TIMESERIE_DATA
                                              , ORDER_BY)
               VALUES ( l_nsi_indicator_sid
                      , p_time_series(i)
                      , p_orders(i));
       END LOOP;
    END setNSIData;

END AMECO_NSI;
