/* Formatted on 22-10-2021 16:43:55 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DRM_APP_STATUS
AS
   /**************************************************************************
    * NAME:      DRM_APP_STATUS
    * PURPOSE:   DRM Application status setting functionality
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name archiveMeasures - archive measures for all countries and clear the measures table
   -- @return number of measures archived
   ----------------------------------------------------------------------------
   PROCEDURE archiveMeasures(p_round_sid IN NUMBER, o_res OUT NUMBER)
   IS
      l_res       NUMBER;
      l_countries VARCHARLIST;
   BEGIN
      SELECT DISTINCT COUNTRY_ID
        BULK COLLECT INTO l_countries
        FROM DRM_MEASURES;

      o_res := 0;

      FOR i IN 1 .. l_countries.COUNT LOOP
         DRM_COUNTRY_STATUS.archiveCountryMeasures(p_round_sid, l_countries(i), l_res);
         o_res := o_res + l_res;
      END LOOP;

      DELETE FROM DRM_MEASURES;
   END archiveMeasures;

   ----------------------------------------------------------------------------
   -- @name setApplicationOpen
   -- @return number of applications updated
   ----------------------------------------------------------------------------
   PROCEDURE setApplicationOpen(o_res OUT NUMBER)
   IS
      l_app_sid           NUMBER := DRM_GETTERS.getCurrentAppSid();
      l_open_status_sid   NUMBER := CORE_GETTERS.getStatusSid('OPEN');
      l_closed_status_sid NUMBER := CORE_GETTERS.getStatusSid('CLOSED');
   BEGIN
      o_res := -1;

      IF l_open_status_sid IS NOT NULL AND l_closed_status_sid IS NOT NULL THEN
         UPDATE applications
            SET status_sid = l_open_status_sid, status_date = SYSTIMESTAMP
          WHERE app_sid = l_app_sid AND status_sid = l_closed_status_sid;

         o_res := SQL%ROWCOUNT;
      END IF;
   END setApplicationOpen;

   ----------------------------------------------------------------------------
   -- @name setApplicationClosed
   -- @return number of applications updated
   ----------------------------------------------------------------------------
   PROCEDURE setApplicationClosed(o_res OUT NUMBER)
   IS
      l_app_sid           NUMBER := DRM_GETTERS.getCurrentAppSid();
      l_open_status_sid   NUMBER := CORE_GETTERS.getStatusSid('OPEN');
      l_closed_status_sid NUMBER := CORE_GETTERS.getStatusSid('CLOSED');
   BEGIN
      o_res := -1;

      IF l_open_status_sid IS NOT NULL AND l_closed_status_sid IS NOT NULL THEN
         UPDATE applications
            SET status_sid = l_closed_status_sid, status_date = SYSTIMESTAMP
          WHERE app_sid = l_app_sid AND status_sid = l_open_status_sid;

         o_res := SQL%ROWCOUNT;
      END IF;
   END setApplicationClosed;
END DRM_APP_STATUS;