CREATE OR REPLACE PACKAGE BODY DFM_REPORTS
AS
   /******************************************************************************
      NAME:      DFM_REPORTS
      PURPOSE:   Procedures used for generating DFM reports

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/11/2017  rokosra          1. Created this package body.
   ******************************************************************************/
   PROCEDURE getAdditionalImpactAll(
      o_cur                  OUT SYS_REFCURSOR
    , p_adopt_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_adopt_months      IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_label_sids        IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_is_eu_funded_sids IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_country_id        IN     VARCHAR2 DEFAULT NULL
    , p_one_off_sid       IN     NUMBER DEFAULT NULL
   )
   IS
      l_adopt_years             SIDSLIST := CORE_COMMONS.arrayToSidsList(p_adopt_years);
      l_adopt_years_count       NUMBER(8) := p_adopt_years.COUNT;
      l_adopt_months            SIDSLIST := CORE_COMMONS.arrayToSidsList(p_adopt_months);
      l_adopt_months_count      NUMBER(8) := p_adopt_months.COUNT;
      l_label_sids              SIDSLIST := CORE_COMMONS.arrayToSidsList(p_label_sids);
      l_label_sids_count        NUMBER(8) := p_label_sids.COUNT;
      l_is_eu_funded_sids       SIDSLIST := CORE_COMMONS.arrayToSidsList(p_is_eu_funded_sids);
      l_is_eu_funded_sids_count NUMBER(8) := p_is_eu_funded_sids.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT  cty.COUNTRY_ID
               , cty.DESCR as country
               , cty.CODEISO3 || '.' || e.ameco_code_id as series
               , e.ESA95_SID as type_sid
               , e.REV_EXP_SID
               , e.ORDER_BY
               , e.DESCR
               , m.START_YEAR
               , dfm_commons.tabagg(CAST(COLLECT(m.DATA) AS VARCHARLIST)) AS data
          FROM COUNTRIES cty 
          JOIN COUNTRY_GROUPS cg ON cg.COUNTRY_ID = cty.COUNTRY_ID 
               AND cg.COUNTRY_GROUP_ID = 'EU' AND cg.IS_ACTIVE = 1
          FULL JOIN VW_DFM_ALL_ESA e on 1=1
          LEFT JOIN (
             SELECT  dm.COUNTRY_ID
                   , dm.START_YEAR
                   , dm.ESA95_SID
                   , dm.DATA
              FROM DFM_MEASURES dm
             WHERE dm.STATUS_SID IN (4, 5, 6) 
               AND (l_adopt_years_count = 0
                     OR COALESCE(dm.ADOPT_DATE_YR, -1) IN (SELECT * FROM TABLE(l_adopt_years)))
               AND (l_adopt_months_count = 0
                     OR COALESCE(dm.ADOPT_DATE_MH, -1) IN (SELECT * FROM TABLE(l_adopt_months)))
               AND (l_label_sids_count = 0
                     OR EXISTS
                     (SELECT 1
                        FROM DFM_MEASURE_LABELS ml
                        WHERE ml.MEASURE_SID = dm.MEASURE_SID
                           AND ml.LABEL_SID IN (SELECT * FROM TABLE(l_label_sids)))
                     OR (-1 IN (SELECT * FROM TABLE(l_label_sids))
                     AND NOT EXISTS
                        (SELECT 1
                           FROM DFM_MEASURE_LABELS ml
                        WHERE ml.MEASURE_SID = dm.MEASURE_SID)))
               AND (l_is_eu_funded_sids_count = 0
                     OR COALESCE(dm.IS_EU_FUNDED_SID, -1) IN (SELECT * FROM TABLE(l_is_eu_funded_sids)))
               AND (p_one_off_sid IS NULL OR dm.ONE_OFF_SID = p_one_off_sid)
         ) m ON e.ESA95_SID = m.ESA95_SID AND cty.COUNTRY_ID = m.COUNTRY_ID
         WHERE e.ESA_PERIOD = dfm_getters.getRoundEsaInfoByRoundSid()  
           AND (p_country_id IS NULL OR cty.COUNTRY_ID = p_country_id)
         GROUP BY cty.COUNTRY_ID
               , cty.DESCR
               , cty.CODEISO3
               , e.AMECO_CODE_ID
               , e.ESA95_SID
               , e.REV_EXP_SID
               , e.ORDER_BY
               , e.DESCR
               , m.START_YEAR
         ORDER BY e.REV_EXP_SID DESC, e.ORDER_BY, cty.COUNTRY_ID;        
   END;

   PROCEDURE getAdditionalImpactAllArchived(
      p_round_sid         IN OUT NUMBER
    , p_storage_sid       IN OUT NUMBER
    , p_cust_text_sid     IN     NUMBER
    , p_storage_id        IN     VARCHAR2
    , o_cur                  OUT SYS_REFCURSOR
    , p_adopt_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_adopt_months      IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_label_sids        IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_is_eu_funded_sids IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_country_id        IN     VARCHAR2 DEFAULT NULL
   )
   IS
      l_adopt_years             SIDSLIST := CORE_COMMONS.arrayToSidsList(p_adopt_years);
      l_adopt_years_count       NUMBER(8) := p_adopt_years.COUNT;
      l_adopt_months            SIDSLIST := CORE_COMMONS.arrayToSidsList(p_adopt_months);
      l_adopt_months_count      NUMBER(8) := p_adopt_months.COUNT;
      l_label_sids              SIDSLIST := CORE_COMMONS.arrayToSidsList(p_label_sids);
      l_label_sids_count        NUMBER(8) := p_label_sids.COUNT;
      l_is_eu_funded_sids       SIDSLIST := CORE_COMMONS.arrayToSidsList(p_is_eu_funded_sids);
      l_is_eu_funded_sids_count NUMBER(8) := p_is_eu_funded_sids.COUNT;
   BEGIN
      IF p_storage_id IS NOT NULL THEN
         dfm_getters.getRoundStorage(p_storage_id, p_round_sid, p_storage_sid);
      END IF;

      OPEN o_cur FOR
           SELECT cty.country_id
                , cty.descr                                              country
                , cty.codeiso3 || '.' || e.ameco_code_id                 series
                , e.esa95_sid                                            type_sid
                , e.rev_exp_sid
                , e.order_by
                , e.descr
                , m.start_year
                , dfm_commons.tabagg(CAST(COLLECT(m.data) AS VARCHARLIST)) AS data
             FROM countries cty
                  INNER JOIN country_groups cg ON cg.country_id = cty.country_id
                  FULL JOIN VW_DFM_ALL_ESA e ON 1 = 1
                  LEFT JOIN dfm_archived_measures m
                     ON e.esa95_sid = m.esa_sid
                    AND cty.country_id = m.country_id
                    AND m.status_sid IN (4, 5, 6)
            WHERE cg.country_group_id = 'EU'
              AND (p_country_id IS NULL OR cty.country_id = p_country_id)
              AND e.esa_period = dfm_getters.getRoundEsaInfoByRoundSid(p_round_sid)
              AND m.round_sid = p_round_sid
              AND M.STORAGE_SID = p_storage_sid
              AND (M.CUST_TEXT_SID IS NULL OR M.CUST_TEXT_SID = p_cust_text_sid)
              AND (l_adopt_years_count = 0
                OR COALESCE(m.adopt_date_yr, -1) IN (SELECT * FROM TABLE(l_adopt_years)))
              AND (l_adopt_months_count = 0
                OR COALESCE(m.adopt_date_mh, -1) IN (SELECT * FROM TABLE(l_adopt_months)))
              AND (l_label_sids_count = 0
                OR EXISTS
                      (SELECT 1
                         FROM dfm_measure_labels ml
                        WHERE ml.MEASURE_SID = m.MEASURE_SID
                          AND ml.LABEL_SID IN (SELECT * FROM TABLE(l_label_sids)))
                OR (-1 IN ((SELECT * FROM TABLE(l_label_sids)))
                AND NOT EXISTS
                       (SELECT 1
                          FROM dfm_measure_labels ml
                         WHERE ml.MEASURE_SID = m.MEASURE_SID)))
              AND (l_is_eu_funded_sids_count = 0
                OR COALESCE(m.is_eu_funded_sid, -1) IN (SELECT * FROM TABLE(l_is_eu_funded_sids)))
         GROUP BY cty.country_id
                , cty.descr
                , cty.codeiso3 || '.' || e.ameco_code_id
                , e.esa95_sid
                , e.rev_exp_sid
                , e.order_by
                , e.descr
                , m.start_year
         ORDER BY e.rev_exp_sid DESC, e.order_by, cty.country_id;
   END;

   PROCEDURE getAdditionalImpactOO(
      o_cur                  OUT SYS_REFCURSOR
    , p_adopt_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_adopt_months      IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_label_sids        IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_is_eu_funded_sids IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_country_id        IN     VARCHAR2 DEFAULT NULL
   )
   IS
      l_version                 NUMBER := dfm_getters.getRoundOOTypesInfoByRoundSid();
      l_adopt_years             SIDSLIST := CORE_COMMONS.arrayToSidsList(p_adopt_years);
      l_adopt_years_count       NUMBER(8) := p_adopt_years.COUNT;
      l_adopt_months            SIDSLIST := CORE_COMMONS.arrayToSidsList(p_adopt_months);
      l_adopt_months_count      NUMBER(8) := p_adopt_months.COUNT;
      l_label_sids              SIDSLIST := CORE_COMMONS.arrayToSidsList(p_label_sids);
      l_label_sids_count        NUMBER(8) := p_label_sids.COUNT;
      l_is_eu_funded_sids       SIDSLIST := CORE_COMMONS.arrayToSidsList(p_is_eu_funded_sids);
      l_is_eu_funded_sids_count NUMBER(8) := p_is_eu_funded_sids.COUNT;
   BEGIN
      OPEN o_cur FOR
           SELECT country_id
                , country
                , ''                                                   series
                , type_sid
                , rev_exp_sid
                , order_by
                , descr
                , start_year
                , dfm_commons.tabagg(CAST(COLLECT(data) AS VARCHARLIST)) AS data
             FROM (SELECT cty.country_id
                        , cty.descr        country
                        , o.one_off_type_sid AS type_sid
                        , 1                AS rev_exp_sid
                        , o.order_by
                        , o.descr
                        , m.start_year
                        , m.measure_sid
                        , m.data
                     FROM countries cty
                          INNER JOIN country_groups cg ON cg.country_id = cty.country_id
                          FULL JOIN dfm_one_off_types o ON o.one_off_type_sid > 1
                          LEFT JOIN dfm_measures m
                             ON o.one_off_type_sid = m.one_off_type_sid
                            AND cty.country_id = m.country_id
                            AND m.one_off_sid = 1
                            AND m.rev_exp_sid = 1
                            AND m.status_sid IN (4, 5, 6)
                    WHERE cg.country_group_id = 'EU'
                      AND cg.IS_ACTIVE = 1
                      AND (p_country_id IS NULL OR cty.country_id = p_country_id)
                      AND o.version = l_version
                      AND (l_adopt_years_count = 0
                        OR COALESCE(m.adopt_date_yr, -1) IN (SELECT * FROM TABLE(l_adopt_years)))
                      AND (l_adopt_months_count = 0
                        OR COALESCE(m.adopt_date_mh, -1) IN (SELECT * FROM TABLE(l_adopt_months)))
                      AND (l_label_sids_count = 0
                        OR EXISTS
                              (SELECT 1
                                 FROM dfm_measure_labels ml
                                WHERE ml.MEASURE_SID = m.MEASURE_SID
                                  AND ml.LABEL_SID IN (SELECT * FROM TABLE(l_label_sids)))
                        OR (-1 IN ((SELECT * FROM TABLE(l_label_sids)))
                        AND NOT EXISTS
                               (SELECT 1
                                  FROM dfm_measure_labels ml
                                 WHERE ml.MEASURE_SID = m.MEASURE_SID)))
                      AND (l_is_eu_funded_sids_count = 0
                        OR COALESCE(m.is_eu_funded_sid, -1) IN
                              (SELECT * FROM TABLE(l_is_eu_funded_sids)))
                   UNION ALL
                   SELECT cty.country_id
                        , cty.descr            country
                        , 0 - o.one_off_type_sid AS type_sid
                        , 2                    AS rev_exp_sid
                        , o.order_by
                        , o.descr
                        , m.start_year
                        , m.measure_sid
                        , m.data
                     FROM countries cty
                          INNER JOIN country_groups cg ON cg.country_id = cty.country_id
                          FULL JOIN dfm_one_off_types o ON o.one_off_type_sid > 1
                          LEFT JOIN dfm_measures m
                             ON o.one_off_type_sid = m.one_off_type_sid
                            AND cty.country_id = m.country_id
                            AND m.one_off_sid = 1
                            AND m.rev_exp_sid = 2
                            AND m.status_sid IN (4, 5, 6)
                    WHERE cg.country_group_id = 'EU'
                      AND cg.IS_ACTIVE = 1
                      AND (p_country_id IS NULL OR cty.country_id = p_country_id)
                      AND o.version = l_version
                      AND (l_adopt_years_count = 0
                        OR COALESCE(m.adopt_date_yr, -1) IN (SELECT * FROM TABLE(l_adopt_years)))
                      AND (l_adopt_months_count = 0
                        OR COALESCE(m.adopt_date_mh, -1) IN (SELECT * FROM TABLE(l_adopt_months)))
                      AND (l_label_sids_count = 0
                        OR EXISTS
                              (SELECT 1
                                 FROM dfm_measure_labels ml
                                WHERE ml.MEASURE_SID = m.MEASURE_SID
                                  AND ml.LABEL_SID IN (SELECT * FROM TABLE(l_label_sids)))
                        OR (-1 IN ((SELECT * FROM TABLE(l_label_sids)))
                        AND NOT EXISTS
                               (SELECT 1
                                  FROM dfm_measure_labels ml
                                 WHERE ml.MEASURE_SID = m.MEASURE_SID)))
                      AND (l_is_eu_funded_sids_count = 0
                        OR COALESCE(m.is_eu_funded_sid, -1) IN
                              (SELECT * FROM TABLE(l_is_eu_funded_sids))))
         GROUP BY country_id
                , country
                , type_sid
                , rev_exp_sid
                , order_by
                , descr
                , start_year
         ORDER BY rev_exp_sid DESC, order_by, country_id;
   END;

   PROCEDURE getAdditionalImpactOOArchived(
      p_round_sid         IN OUT NUMBER
    , p_storage_sid       IN OUT NUMBER
    , p_cust_text_sid     IN     NUMBER
    , p_storage_id        IN     VARCHAR2
    , o_cur                  OUT SYS_REFCURSOR
    , p_adopt_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_adopt_months      IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_label_sids        IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_is_eu_funded_sids IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY)
    , p_country_id        IN     VARCHAR2 DEFAULT NULL
   )
   IS
      l_version                 NUMBER;
      l_adopt_years             SIDSLIST := CORE_COMMONS.arrayToSidsList(p_adopt_years);
      l_adopt_years_count       NUMBER(8) := p_adopt_years.COUNT;
      l_adopt_months            SIDSLIST := CORE_COMMONS.arrayToSidsList(p_adopt_months);
      l_adopt_months_count      NUMBER(8) := p_adopt_months.COUNT;
      l_label_sids              SIDSLIST := CORE_COMMONS.arrayToSidsList(p_label_sids);
      l_label_sids_count        NUMBER(8) := p_label_sids.COUNT;
      l_is_eu_funded_sids       SIDSLIST := CORE_COMMONS.arrayToSidsList(p_is_eu_funded_sids);
      l_is_eu_funded_sids_count NUMBER(8) := p_is_eu_funded_sids.COUNT;
   BEGIN
      IF p_storage_id IS NOT NULL THEN
         dfm_getters.getRoundStorage(p_storage_id, p_round_sid, p_storage_sid);
      END IF;

      l_version := dfm_getters.getRoundOOTypesInfoByRoundSid(p_round_sid);

      OPEN o_cur FOR
           SELECT country_id
                , country
                , ''                                                   series
                , type_sid
                , rev_exp_sid
                , order_by
                , descr
                , start_year
                , dfm_commons.tabagg(CAST(COLLECT(data) AS VARCHARLIST)) AS data
             FROM (SELECT cty.country_id
                        , cty.descr        country
                        , o.one_off_type_sid AS type_sid
                        , 1                AS rev_exp_sid
                        , o.order_by
                        , o.descr
                        , m.start_year
                        , m.measure_sid
                        , m.data
                     FROM countries cty
                          INNER JOIN country_groups cg ON cg.country_id = cty.country_id
                          FULL JOIN dfm_one_off_types o ON o.one_off_type_sid > 1
                          LEFT JOIN dfm_archived_measures m
                             ON o.one_off_type_sid = m.one_off_type_sid
                            AND cty.country_id = m.country_id
                            AND m.one_off_sid = 1
                            AND m.rev_exp_sid = 1
                            AND m.status_sid IN (4, 5, 6)
                    WHERE cg.country_group_id = 'EU'
                      AND (p_country_id IS NULL OR cty.country_id = p_country_id)
                      AND o.version = l_version
                      AND m.round_sid = p_round_sid
                      AND M.STORAGE_SID = p_storage_sid
                      AND (M.CUST_TEXT_SID IS NULL OR M.CUST_TEXT_SID = p_cust_text_sid)
                      AND (l_adopt_years_count = 0
                        OR COALESCE(m.adopt_date_yr, -1) IN (SELECT * FROM TABLE(l_adopt_years)))
                      AND (l_adopt_months_count = 0
                        OR COALESCE(m.adopt_date_mh, -1) IN (SELECT * FROM TABLE(l_adopt_months)))
                      AND (l_label_sids_count = 0
                        OR EXISTS
                              (SELECT 1
                                 FROM dfm_measure_labels ml
                                WHERE ml.MEASURE_SID = m.MEASURE_SID
                                  AND ml.LABEL_SID IN (SELECT * FROM TABLE(l_label_sids)))
                        OR (-1 IN ((SELECT * FROM TABLE(l_label_sids)))
                        AND NOT EXISTS
                               (SELECT 1
                                  FROM dfm_measure_labels ml
                                 WHERE ml.MEASURE_SID = m.MEASURE_SID)))
                      AND (l_is_eu_funded_sids_count = 0
                        OR COALESCE(m.is_eu_funded_sid, -1) IN
                              (SELECT * FROM TABLE(l_is_eu_funded_sids)))
                   UNION ALL
                   SELECT cty.country_id
                        , cty.descr            country
                        , 0 - o.one_off_type_sid AS type_sid
                        , 2                    AS rev_exp_sid
                        , o.order_by
                        , o.descr
                        , m.start_year
                        , m.measure_sid
                        , m.data
                     FROM countries cty
                          INNER JOIN country_groups cg ON cg.country_id = cty.country_id
                          FULL JOIN dfm_one_off_types o ON o.one_off_type_sid > 1
                          LEFT JOIN dfm_archived_measures m
                             ON o.one_off_type_sid = m.one_off_type_sid
                            AND cty.country_id = m.country_id
                            AND m.one_off_sid = 1
                            AND m.rev_exp_sid = 2
                            AND m.status_sid IN (4, 5, 6)
                    WHERE cg.country_group_id = 'EU'
                      AND (p_country_id IS NULL OR cty.country_id = p_country_id)
                      AND o.version = l_version
                      AND m.round_sid = p_round_sid
                      AND M.STORAGE_SID = p_storage_sid
                      AND (M.CUST_TEXT_SID IS NULL OR M.CUST_TEXT_SID = p_cust_text_sid)
                      AND (l_adopt_years_count = 0
                        OR COALESCE(m.adopt_date_yr, -1) IN (SELECT * FROM TABLE(l_adopt_years)))
                      AND (l_adopt_months_count = 0
                        OR COALESCE(m.adopt_date_mh, -1) IN (SELECT * FROM TABLE(l_adopt_months)))
                      AND (l_label_sids_count = 0
                        OR EXISTS
                              (SELECT 1
                                 FROM dfm_measure_labels ml
                                WHERE ml.MEASURE_SID = m.MEASURE_SID
                                  AND ml.LABEL_SID IN (SELECT * FROM TABLE(l_label_sids)))
                        OR (-1 IN ((SELECT * FROM TABLE(l_label_sids)))
                        AND NOT EXISTS
                               (SELECT 1
                                  FROM dfm_measure_labels ml
                                 WHERE ml.MEASURE_SID = m.MEASURE_SID)))
                      AND (l_is_eu_funded_sids_count = 0
                        OR COALESCE(m.is_eu_funded_sid, -1) IN
                              (SELECT * FROM TABLE(l_is_eu_funded_sids))))
         GROUP BY country_id
                , country
                , type_sid
                , rev_exp_sid
                , order_by
                , descr
                , start_year
         ORDER BY rev_exp_sid DESC, order_by, country_id;
   END;

   PROCEDURE getReportMeasures(o_cur OUT SYS_REFCURSOR, p_country_id IN VARCHAR2)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT M.MEASURE_SID
                , M.TITLE
                , M.SHORT_DESCR
                , M.COUNTRY_ID
                , M.ONE_OFF_SID
                , M.IS_EU_FUNDED_SID
                , M.REV_EXP_SID
                , CASE WHEN M.ADOPT_DATE_YR > 0 THEN M.ADOPT_DATE_YR END      ADOPT_DATE_YR
                , COALESCE(M.ADOPT_DATE_MH, -1)                               ADOPT_DATE_MH
                , COALESCE(m.esa95_sid, -1)                                   ESA_SID
                , M.START_YEAR
                , M.DATA
                , LISTAGG(l.label_sid, ',') WITHIN GROUP (ORDER BY l.label_sid) label_sids
             FROM DFM_MEASURES M LEFT JOIN dfm_measure_labels l ON l.MEASURE_SID = m.MEASURE_SID
            WHERE M.COUNTRY_ID = p_country_id AND M.STATUS_SID IN (4, 5, 6)
         GROUP BY M.MEASURE_SID
                , M.TITLE
                , M.SHORT_DESCR
                , M.COUNTRY_ID
                , M.ONE_OFF_SID
                , M.IS_EU_FUNDED_SID
                , M.REV_EXP_SID
                , M.ADOPT_DATE_YR
                , M.ADOPT_DATE_MH
                , m.esa95_sid
                , M.START_YEAR
                , M.DATA
         ORDER BY M.MEASURE_SID;
   END;

   PROCEDURE getCountryMultiplier(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT country_id, multi, scale FROM dfm_countries_info;
   END;
END DFM_REPORTS;