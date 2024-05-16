/* Formatted on 12/12/2019 15:39:10 (QP5 v5.252.13127.32847) */
INSERT INTO CALCULATED_INDIC_DATA (ROUND_SID
,                                  INDICATOR_SID
,                                  COUNTRY_ID
,                                  START_YEAR
,                                  VECTOR
,                                  SOURCE
,                                  LAST_CHANGE_USER
,                                  LAST_CHANGE_DATE)
   SELECT D.ROUND_SID
,         I.INDICATOR_SID
,         D.COUNTRY_ID
,         D.START_YEAR
,         D.VECTOR
,         D.SOURCE
,         D.LAST_CHANGE_USER
,         D.LAST_CHANGE_DATE
     FROM CALCULATED_INDIC_DATA@SCOPAX D
          JOIN ROUNDS R ON R.ROUND_SID = D.ROUND_SID
          JOIN COUNTRIES C ON C.COUNTRY_ID = D.COUNTRY_ID
          JOIN INDICATORS@SCOPAX MI ON MI.INDICATOR_SID = D.INDICATOR_SID
          JOIN INDICATORS I ON I.INDICATOR_ID = MI.INDICATOR_ID;

COMMIT;
