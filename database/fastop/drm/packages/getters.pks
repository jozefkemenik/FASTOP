/* Formatted on 14-05-2020 20:43:51 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DRM_GETTERS
AS
   /******************************************************************************
      NAME:       DRM_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       01/04/2019    lubiesz        1. Created this package body.
   ******************************************************************************/

   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   APP_ID CONSTANT VARCHAR2(3) := 'DRM';

   /****************************************************************************/

   PROCEDURE getScale(p_country_id  IN     VARCHAR2
                    , o_scale_sid      OUT NUMBER
                    , o_scale_descr    OUT VARCHAR2);

   FUNCTION getCurrentAppSid
      RETURN NUMBER;

   PROCEDURE getCountryCurrency(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR);
END DRM_GETTERS;