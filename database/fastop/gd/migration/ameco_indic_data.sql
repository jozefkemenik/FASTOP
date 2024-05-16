/* Formatted on 12/12/2019 15:16:34 (QP5 v5.252.13127.32847) */
INSERT INTO AMECO_INDIC_DATA (ROUND_SID
,                             INDICATOR_SID
,                             COUNTRY_ID
,                             START_YEAR
,                             VECTOR
,                             LAST_CHANGE_USER
,                             LAST_CHANGE_DATE)
   SELECT R.ROUND_SID
,         I.INDICATOR_SID
,         A.COUNTRY_ID
,         A.START_YEAR
,         A.VECTOR
,         A.LAST_CHANGE_USER
,         A.LAST_CHANGE_DATE
     FROM AMECO_INDIC_DATA@SCOPAX A
          JOIN FORECAST_PERIODS@SCOPAX FP
             ON FP.FORECAST_PERIOD_SID = A.FORECAST_PERIOD_SID
          JOIN ROUNDS R
             ON R.YEAR = FP.FORECAST_YEAR AND R.PERIOD_SID = FP.PERIOD_SID
          JOIN INDICATORS@SCOPAX MI ON MI.INDICATOR_SID = A.INDICATOR_SID
          JOIN INDICATORS I ON I.INDICATOR_ID = MI.INDICATOR_ID;

COMMIT;
