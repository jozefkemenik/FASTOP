INSERT INTO AGG_LINE_DATA ( ROUND_SID
,                                LINE_ID
,                                COUNTRY_ID
,                                START_YEAR
,                                VECTOR
,                                LAST_CHANGE_USER
,                                LAST_CHANGE_DATE )
     SELECT D.ROUND_SID
,           D.LINE_ID
,           D.COUNTRY_ID
,           D.START_YEAR
,           D.VECTOR
,           D.LAST_CHANGE_USER
,           D.LAST_CHANGE_DATE
       FROM AGG_LINE_DATA@SCOPAX D
            JOIN ROUNDS R ON R.ROUND_SID = D.ROUND_SID
            JOIN COUNTRIES C ON C.COUNTRY_ID = D.COUNTRY_ID
            JOIN VW_GD_ROUND_GRID_LINES L ON (L.LINE_ID = D.LINE_ID AND L.ROUND_SID = D.ROUND_SID);

COMMIT;
