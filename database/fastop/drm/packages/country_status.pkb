/* Formatted on 17-08-2021 17:26:04 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DRM_COUNTRY_STATUS
AS
   /************* PRIVATE ****************************************************/

   ----------------------------------------------------------------------------
   -- @name copyScaleToArchive
   -- @return number of scales archived
   ----------------------------------------------------------------------------
   PROCEDURE copyScaleToArchive(p_round_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      -- Delete previously archived scales to avoid duplicates
      DELETE FROM DRM_ARCHIVED_CTY_SCALES
            WHERE COUNTRY_ID = p_country_id AND ROUND_SID = p_round_sid;

      -- Copy scales to the archive table
      INSERT INTO DRM_ARCHIVED_CTY_SCALES(ROUND_SID, COUNTRY_ID, SCALE_SID)
         SELECT p_round_sid, COUNTRY_ID, SCALE_SID
           FROM DRM_CTY_SCALES
          WHERE COUNTRY_ID = p_country_id;

      o_res := SQL%ROWCOUNT;
   END copyScaleToArchive;

   /************* PUBLIC *****************************************************/

   ----------------------------------------------------------------------------
   -- @name archiveCountryMeasures
   -- @return number of measures archived
   ----------------------------------------------------------------------------
   PROCEDURE archiveCountryMeasures(p_round_sid  IN     NUMBER
                                  , p_country_id IN     VARCHAR2
                                  , o_res           OUT NUMBER)
   IS
      l_res NUMBER;
   BEGIN
      -- Archive scale
      copyScaleToArchive(p_round_sid, p_country_id, l_res);

      -- Delete previously archived measures to avoid duplicates
      DELETE FROM drm_archived_measures
            WHERE country_id = p_country_id AND round_sid = p_round_sid;

      -- Copy measures to the archive table

      INSERT INTO drm_archived_measures(ROUND_SID
                                      , MEASURE_SID
                                      , COUNTRY_ID
                                      , TITLE
                                      , DESCR
                                      , ESA_SID
                                      , ACC_PRINCIP_SID
                                      , ADOPT_STATUS_SID
                                      , DATA
                                      , START_YEAR
                                      , ONE_OFF_SID
                                      , ONE_OFF_TYPE_SID
                                      , IS_EU_FUNDED_SID
                                      , EU_FUND_SID
                                      , YEAR)
         SELECT p_round_sid
              , MEASURE_SID
              , COUNTRY_ID
              , TITLE
              , DESCR
              , ESA_SID
              , ACC_PRINCIP_SID
              , ADOPT_STATUS_SID
              , DATA
              , START_YEAR
              , ONE_OFF_SID
              , ONE_OFF_TYPE_SID
              , IS_EU_FUNDED_SID
              , EU_FUND_SID
              , YEAR
           FROM DRM_MEASURES
          WHERE country_id = p_country_id;

      o_res := SQL%ROWCOUNT;
   END archiveCountryMeasures;

   ----------------------------------------------------------------------------
   -- @name presubmit
   ----------------------------------------------------------------------------
   PROCEDURE presubmit(p_round_sid IN NUMBER, p_country_id IN VARCHAR2, o_res OUT NUMBER)
   IS
   BEGIN
      SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
        INTO o_res
        FROM DRM_MEASURES
       WHERE COUNTRY_ID = p_country_id;
   END presubmit;
END DRM_COUNTRY_STATUS;
/