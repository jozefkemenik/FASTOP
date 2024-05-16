/* Formatted on 14-05-2020 20:44:01 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DRM_GETTERS
AS
   /******************************************************************************
      NAME:       DRM_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       01/04/2019    lubiesz        1. Created this package body.
   ******************************************************************************/
   PROCEDURE getScale(p_country_id  IN     VARCHAR2
                    , o_scale_sid      OUT NUMBER
                    , o_scale_descr    OUT VARCHAR2)
   IS
   BEGIN
      SELECT S.scale_sid, S.descr
        INTO o_scale_sid, o_scale_descr
        FROM drm_cty_scales D LEFT JOIN scales S ON D.scale_sid = S.scale_sid
       WHERE D.country_id = p_country_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_scale_sid   := NULL;
         o_scale_descr := NULL;
   END getScale;

   ----------------------------------------------------------------------------
   -- @name getCurrentAppSid
   ----------------------------------------------------------------------------
   FUNCTION getCurrentAppSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getApplicationSid(DRM_GETTERS.APP_ID);
   END getCurrentAppSid;

   ----------------------------------------------------------------------------
   -- @name getCountryCurrency
   ----------------------------------------------------------------------------
   PROCEDURE getCountryCurrency(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT D.SCALE_SID AS "sid", S.DESCR AS "descr", S.SCALE_ID AS "id"
                       FROM DRM_CTY_SCALES D JOIN SCALES S ON D.SCALE_SID = S.SCALE_SID
                      WHERE D.COUNTRY_ID = p_country_id;
   END getCountryCurrency;
END DRM_GETTERS;