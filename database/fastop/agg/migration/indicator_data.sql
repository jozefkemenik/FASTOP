INSERT INTO AGG_INDICATOR_DATA ( ROUND_SID
,                                INDICATOR_SID
,                                COUNTRY_ID
,                                START_YEAR
,                                VECTOR
,                                LAST_CHANGE_USER
,                                LAST_CHANGE_DATE )
     SELECT D.ROUND_SID
,           I.INDICATOR_SID
,           D.COUNTRY_ID
,           D.START_YEAR
,           D.VECTOR
,           D.LAST_CHANGE_USER
,           D.LAST_CHANGE_DATE
       FROM AGG_INDICATOR_DATA@SCOPAX D
            JOIN ROUNDS R ON R.ROUND_SID = D.ROUND_SID
            JOIN GEO_AREAS G ON G.GEO_AREA_ID = D.COUNTRY_ID
            JOIN INDICATORS I ON I.INDICATOR_ID = D.INDICATOR_ID;

COMMIT;
