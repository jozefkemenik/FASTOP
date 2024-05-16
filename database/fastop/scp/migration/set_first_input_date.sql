/* Formatted on 08/05/2020 15:58:09 (QP5 v5.313) */
/

DECLARE
   TYPE T_ROUND_CTY IS RECORD(ROUND_SID VW_GD_CTY_GRIDS.ROUND_SID%TYPE
                            , COUNTRY_ID VW_GD_CTY_GRIDS.COUNTRY_ID%TYPE);

   CURSOR gridRoundCountries(p_round_sid NUMBER)
   IS
      SELECT DISTINCT ROUND_SID, COUNTRY_ID
        FROM VW_GD_CTY_GRIDS
       WHERE ROUND_SID = p_round_sid;

   PROCEDURE setFirstInputDate(p_app_id IN VARCHAR2, p_roundCty IN T_ROUND_CTY)
   IS
      l_res NUMBER;
      l_cur SYS_REFCURSOR;
   BEGIN
      ST_COUNTRY_STATUS.setCountryStatus(l_res
                                       , l_cur
                                       , p_app_id
                                       , p_roundCty.COUNTRY_ID
                                       , 'ACTIVE'
                                       , 'ACTIVE'
                                       , 'MIGR'
                                       , NULL
                                       , 0
                                       , p_roundCty.ROUND_SID);
      l_res := 0;
      GD_COMMONS.hasAnyGridData(p_app_id
                              , p_roundCty.COUNTRY_ID
                              , p_roundCty.ROUND_SID
                              , l_res);

      IF l_res > 0 THEN
         ST_STATUS_CHANGES.setFirstInputDate(p_roundCty.ROUND_SID, p_roundCty.COUNTRY_ID);
      END IF;
   END;

   PROCEDURE process(p_app_id IN VARCHAR2)
   IS
      l_round_sid NUMBER;
   BEGIN
      l_round_sid := CORE_GETTERS.getCurrentRoundSid(p_app_id);

      FOR roundCty IN gridRoundCountries(l_round_sid) LOOP
         setFirstInputDate(p_app_id, roundCty);
      END LOOP;
   END;
BEGIN
   process(DBP_GETTERS.APP_ID);
   process(SCP_GETTERS.APP_ID);

   COMMIT;
END;
/