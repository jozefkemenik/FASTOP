/* Formatted on 17-06-2021 12:15:03 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY MN_ACCESSORS
AS
   /******************************************************************************
      NAME:       MN_ACCESSORS
      PURPOSE:    Menu accessors: getters and setters

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       16/01/2019   rokosra          Created this package body.
   ******************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getAllAppMenus
   -- @return menus for app for superuser (no restrictions)
   ----------------------------------------------------------------------------
   PROCEDURE getAllAppMenus(p_application_name IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   AS
   BEGIN
      OPEN o_cur FOR
           SELECT MR.MENU_REPO_SID
                , MR.MENU_REPO_ID
                , MR.TITLE
                , MR.ICON
                , MR.LINK
                , MR.LINK_PARAMS
                , T.MENU_REPO_TYPE_ID
                , HM.MESS HELP_MESSAGE
             FROM MN_MENU_REPO MR
                  JOIN MN_APP_MENUS AM ON AM.MENU_REPO_SID = MR.MENU_REPO_SID
                  JOIN MN_MENU_REPO_TYPES T ON T.MENU_REPO_TYPE_SID = MR.MENU_REPO_TYPE_SID
                  JOIN APPLICATIONS A ON A.APP_SID = AM.APPLICATION_SID
                  LEFT JOIN HELP_MSGS HM ON HM.HELP_MSG_SID = MR.HELP_MSG_SID
            WHERE UPPER(A.APP_ID) = UPPER(p_application_name)
         ORDER BY AM.ORDER_BY;
   END;

   ----------------------------------------------------------------------------
   -- @name getAllMenuItems
   -- @return menu items for menu for superuser (no restrictions)
   ----------------------------------------------------------------------------
   PROCEDURE getAllMenuItems(p_menu_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   AS
   BEGIN
      OPEN o_cur FOR
           SELECT MR.MENU_REPO_SID
                , MR.MENU_REPO_ID
                , MR.TITLE
                , MR.ICON
                , MR.LINK
                , MR.LINK_PARAMS
                , T.MENU_REPO_TYPE_ID
                , HM.MESS HELP_MESSAGE
             FROM MN_MENU_REPO MR
                  JOIN MN_MENU_REPO_TYPES T ON T.MENU_REPO_TYPE_SID = MR.MENU_REPO_TYPE_SID
                  JOIN MN_MENU_MENU_ITEMS MMI ON MMI.MENU_ITEM_SID = MR.MENU_REPO_SID
                  LEFT JOIN HELP_MSGS HM ON HM.HELP_MSG_SID = MR.HELP_MSG_SID
            WHERE MMI.MENU_SID = p_menu_sid
         ORDER BY MMI.ORDER_BY;
   END;

   ----------------------------------------------------------------------------
   -- @name getAppMenus
   -- @return menus for app and user group
   ----------------------------------------------------------------------------
   PROCEDURE getAppMenus(p_application_name IN     VARCHAR2
                       , p_group_ids        IN     CORE_COMMONS.VARCHARARRAY
                       , o_cur                 OUT SYS_REFCURSOR)
   AS
      l_group_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_group_ids);
   BEGIN
      IF 'SU' MEMBER OF l_group_ids THEN
         getAllAppMenus(p_application_name, o_cur);
      ELSE
         OPEN o_cur FOR
              SELECT MR.MENU_REPO_SID
                   , MR.MENU_REPO_ID
                   , MR.TITLE
                   , MR.ICON
                   , MR.LINK
                   , MR.LINK_PARAMS
                   , T.MENU_REPO_TYPE_ID
                   , HM.MESS HELP_MESSAGE
                FROM MN_MENU_REPO MR
                     JOIN MN_APP_MENUS AM ON AM.MENU_REPO_SID = MR.MENU_REPO_SID
                     JOIN MN_MENU_REPO_TYPES T ON T.MENU_REPO_TYPE_SID = MR.MENU_REPO_TYPE_SID
                     JOIN APPLICATIONS A ON A.APP_SID = AM.APPLICATION_SID
                     JOIN
                     (
                        SELECT DISTINCT P.MENU_REPO_SID
                          FROM MN_PERMISSIONS P JOIN SECUNDA_ROLES R ON R.ROLE_SID = P.USER_GROUP_SID
                         WHERE R.ROLE_ID IN (SELECT * FROM TABLE(l_group_ids))
                     ) PG
                        ON PG.MENU_REPO_SID = MR.MENU_REPO_SID
                     LEFT JOIN HELP_MSGS HM ON HM.HELP_MSG_SID = MR.HELP_MSG_SID
               WHERE UPPER(A.APP_ID) = UPPER(p_application_name)
            ORDER BY AM.ORDER_BY;
      END IF;
   END;

   ----------------------------------------------------------------------------
   -- @name getMenuItems
   -- @return menu items for menu and user groups
   ----------------------------------------------------------------------------
   PROCEDURE getMenuItems(p_menu_sid  IN     NUMBER
                        , p_group_ids IN     CORE_COMMONS.VARCHARARRAY
                        , o_cur          OUT SYS_REFCURSOR)
   AS
      l_group_ids VARCHARLIST := CORE_COMMONS.arrayToList(p_group_ids);
   BEGIN
      IF 'SU' MEMBER OF l_group_ids THEN
         getAllMenuItems(p_menu_sid, o_cur);
      ELSE
         OPEN o_cur FOR
              SELECT MR.MENU_REPO_SID
                   , MR.MENU_REPO_ID
                   , MR.TITLE
                   , MR.ICON
                   , MR.LINK
                   , MR.LINK_PARAMS
                   , T.MENU_REPO_TYPE_ID
                   , HM.MESS HELP_MESSAGE
                FROM MN_MENU_REPO MR
                     JOIN MN_MENU_REPO_TYPES T ON T.MENU_REPO_TYPE_SID = MR.MENU_REPO_TYPE_SID
                     JOIN MN_MENU_MENU_ITEMS MMI ON MMI.MENU_ITEM_SID = MR.MENU_REPO_SID
                     JOIN
                     (
                        SELECT DISTINCT P.MENU_REPO_SID
                          FROM MN_PERMISSIONS P JOIN SECUNDA_ROLES R ON R.ROLE_SID = P.USER_GROUP_SID
                         WHERE R.ROLE_ID IN (SELECT * FROM TABLE(l_group_ids))
                     ) PG
                        ON PG.MENU_REPO_SID = MR.MENU_REPO_SID
                     LEFT JOIN HELP_MSGS HM ON HM.HELP_MSG_SID = MR.HELP_MSG_SID
               WHERE MMI.MENU_SID = p_menu_sid
            ORDER BY MMI.ORDER_BY;
      END IF;
   END;

   ----------------------------------------------------------------------------
   -- @name getFastopApps
   -- @return fastop apps
   ----------------------------------------------------------------------------
   PROCEDURE getFastopApps(p_only_external IN NUMBER DEFAULT 0, o_cur OUT SYS_REFCURSOR)
   AS
   BEGIN
      OPEN o_cur FOR
           SELECT AG.DESCR      APP_GROUP
                , AG.ORDER_BY   GROUP_ORDER
                , ASG.IS_PUBLIC PUBLIC_SUBGROUP
                , ASG.DESCR     SUBGROUP
                , ASG.ORDER_BY  SUBGROUP_ORDER
                , APP.APP_ID    APP_NAME
                , APP.DESCR     APP_DESCR
                , APP.LINK      APP_LINK
                , GD.DESCR      ROUTE_DESCR
                , MR.LINK       ROUTE
                , (SELECT LISTAGG(SR.ROLE_ID, ',') WITHIN GROUP (ORDER BY SR.ROLE_ID)
                     FROM MN_PERMISSIONS MP
                     JOIN SECUNDA_ROLES SR
                       ON MP.USER_GROUP_SID = SR.ROLE_SID
                    WHERE MR.MENU_REPO_SID = MP.MENU_REPO_SID
                  )             ROUTE_ROLES
             FROM APP_GROUPS AG
                  JOIN APP_GROUPS ASG       ON ASG.PARENT_GROUP_SID = AG.APP_GROUP_SID
                  JOIN APP_GROUP_DETAILS GD ON GD.APP_GROUP_SID = ASG.APP_GROUP_SID
                  JOIN APPLICATIONS APP     ON APP.APP_SID = GD.APP_SID
             LEFT JOIN MN_MENU_REPO MR      ON GD.MENU_REPO_ID = MR.MENU_REPO_ID
            WHERE (p_only_external = 0 OR APP.EXTERNAL_ACCESS = 1);
   END;

   ----------------------------------------------------------------------------
   -- @name canAccessRoute
   -- @return 1 if link can be access by given access groups otherwise 0
   ----------------------------------------------------------------------------
   PROCEDURE canAccessAppLink(p_link      IN     VARCHAR2
                            , p_app_id    IN     VARCHAR2
                            , p_group_ids IN     CORE_COMMONS.VARCHARARRAY
                            , o_res          OUT NUMBER)
   IS
      l_group_ids      VARCHARLIST := CORE_COMMONS.arrayToList(p_group_ids);
      l_menu_repo_sids SIDSLIST    := SIDSLIST();
      l_index          NUMBER      := 0;
   BEGIN
      o_res := 0;
      IF 'SU' MEMBER OF l_group_ids THEN
         o_res := 1;
      ELSE
         FOR c_menu IN (
             WITH M1(MENU_SID, MENU_ITEM_SID) AS (
                 SELECT MENU_SID
                      , MENU_ITEM_SID
                   FROM MN_MENU_MENU_ITEMS
                  WHERE MENU_SID IN (
                        SELECT MR.MENU_REPO_SID
                          FROM MN_MENU_REPO MR
                          JOIN MN_APP_MENUS AM ON AM.MENU_REPO_SID = MR.MENU_REPO_SID
                          JOIN APPLICATIONS A ON A.APP_SID = AM.APPLICATION_SID
                         WHERE UPPER(A.APP_ID) = UPPER(p_app_id)
                        )
              UNION ALL
               -- Recursive member
                 SELECT M2.MENU_SID
                      , M2.MENU_ITEM_SID
                   FROM MN_MENU_MENU_ITEMS M2, M1
                  WHERE M2.MENU_SID = M1.MENU_ITEM_SID
             )
             SELECT MENU_SID
                  , MENU_ITEM_SID
               FROM M1
         )
         LOOP
             l_index := l_index + 1;
             l_menu_repo_sids.extend();
             l_menu_repo_sids(l_index) := c_menu.MENU_SID;
             l_index := l_index + 1;
             l_menu_repo_sids.extend();
             l_menu_repo_sids(l_index) := c_menu.MENU_ITEM_SID;
         END LOOP;

         SELECT COUNT(MR.LINK)
           INTO o_res
           FROM MN_MENU_REPO MR
           JOIN
           (
              SELECT DISTINCT P.MENU_REPO_SID
                FROM MN_PERMISSIONS P JOIN SECUNDA_ROLES R ON R.ROLE_SID = P.USER_GROUP_SID
               WHERE R.ROLE_ID IN (SELECT * FROM TABLE(l_group_ids))
           ) PG
              ON PG.MENU_REPO_SID = MR.MENU_REPO_SID
          WHERE MR.LINK IS NOT NULL
            AND MR.MENU_REPO_SID IN (SELECT * FROM TABLE(l_menu_repo_sids))
            AND (LOWER(MR.LINK) = LOWER(p_link) OR LOWER(MR.LINK) LIKE (LOWER(p_link) || '/%'));
      END IF;
   END canAccessAppLink;

END;
/
