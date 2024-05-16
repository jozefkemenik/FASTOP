/* Formatted on 28-05-2020 19:05:46 (QP5 v5.313) */
CREATE OR REPLACE FORCE VIEW VW_AMECO_INDIC_DATA
AS
   SELECT a.INDICATOR_DATA_SID
        , a.ROUND_SID
        , r.PERIOD_SID
        , p.PERIOD_ID
        , p.ORDER_PERIOD
        , P.ROUND_TYPE
        , r.YEAR
        , a.INDICATOR_SID
        , a.COUNTRY_ID
        , a.START_YEAR
        , a.VECTOR
        , a.start_year + LENGTH(REGEXP_REPLACE(a.vector, '[^,]')) AS END_YEAR
        , a.LAST_CHANGE_DATE
        , i.indicator_id || ': ' || i.descr                       AS descr
        , i.indicator_id
     FROM ameco_indic_data a, indicators i, rounds r, periods p
    WHERE a.indicator_sid = i.indicator_sid
      AND a.round_sid = r.round_sid
      AND r.period_sid = p.period_sid;