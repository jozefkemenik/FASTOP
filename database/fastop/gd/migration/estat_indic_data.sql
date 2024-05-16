/* Formatted on 12/13/2019 15:09:18 (QP5 v5.252.13127.32847) */
INSERT INTO ESTAT_INDIC_DATA (ROUND_SID
,                             INDICATOR_SID
,                             COUNTRY_ID
,                             YEAR
,                             NA_ITEM
,                             SECTOR
,                             UNIT
,                             VALUE
,                             LAST_CHANGE_USER
,                             LAST_CHANGE_DATE)
   SELECT R.ROUND_SID
,         I.INDICATOR_SID
,         D.COUNTRY_ID
,         D.YEAR
,         D.NA_ITEM
,         D.SECTOR
,         D.UNIT
,         D.VALUE
,         D.LAST_UPDATE_USER
,         D.LAST_UPDATE
     FROM ESTAT_INDIC_DATA@SCOPAX D
          JOIN FORECAST_PERIODS@SCOPAX FP
             ON FP.FORECAST_PERIOD_SID = D.FORECAST_PERIOD_SID
          JOIN ROUNDS R
             ON R.YEAR = FP.FORECAST_YEAR AND R.PERIOD_SID = FP.PERIOD_SID
          JOIN INDICATORS@SCOPAX MI ON MI.INDICATOR_SID = D.INDICATOR_SID
          JOIN INDICATORS I ON I.INDICATOR_ID = MI.INDICATOR_ID;

COMMIT;
