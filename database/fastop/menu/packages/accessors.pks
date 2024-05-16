/* Formatted on 15-03-2021 13:15:31 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE MN_ACCESSORS
AS
   /******************************************************************************
      NAME:       MN_ACCESSORS
      PURPOSE:    Menu accessors: getters and setters

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       16/01/2019   rokosra          Created this package.
   ******************************************************************************/

   PROCEDURE getAppMenus(p_application_name IN     VARCHAR2
                       , p_group_ids        IN     CORE_COMMONS.VARCHARARRAY
                       , o_cur                 OUT SYS_REFCURSOR);

   PROCEDURE getMenuItems(p_menu_sid  IN     NUMBER
                        , p_group_ids IN     CORE_COMMONS.VARCHARARRAY
                        , o_cur          OUT SYS_REFCURSOR);

   PROCEDURE getFastopApps(p_only_external IN NUMBER DEFAULT 0, o_cur OUT SYS_REFCURSOR);

   PROCEDURE canAccessAppLink(p_link      IN     VARCHAR2
                            , p_app_id    IN     VARCHAR2
                            , p_group_ids IN     CORE_COMMONS.VARCHARARRAY
                            , o_res          OUT NUMBER);
END;
