CREATE OR REPLACE PACKAGE BODY AMECO_UPLOAD
AS
   ----------------------------------------------------------------------------
   -- @name uploadIndicatorData
   ----------------------------------------------------------------------------
   PROCEDURE uploadIndicatorData(o_res                    OUT  NUMBER
                              ,  p_country_id         IN       VARCHAR2
                              ,  p_start_year         IN       NUMBER
                              ,  p_indicator_sids     IN       CORE_COMMONS.SIDSARRAY
                              ,  p_time_series        IN       CORE_COMMONS.VARCHARARRAY
                              ,  p_user               IN       VARCHAR2)
   IS

   BEGIN
      o_res := p_indicator_sids.COUNT;
      FOR i IN 1 .. p_indicator_sids.COUNT LOOP
         DELETE
           FROM AMECO_INDICATOR_DATA
          WHERE INDICATOR_SID =  p_indicator_sids(i)
            AND COUNTRY_ID = p_country_id;

            INSERT INTO AMECO_INDICATOR_DATA( INDICATOR_SID
                                            , COUNTRY_ID
                                            , START_YEAR
                                            , TIMESERIE_DATA
                                            , UPDATE_USER)
                 VALUES (p_indicator_sids(i)
                       , p_country_id
                       , p_start_year
                       , p_time_series(i)
                       , p_user);
      END LOOP;
   END uploadIndicatorData;

END AMECO_UPLOAD;
/
