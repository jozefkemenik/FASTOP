/* Formatted on 25/08/2021 16:39:39 (QP5 v5.313) */
DECLARE
   l_app                    NUMBER;
   l_app2                   NUMBER;
   l_menu_sid               NUMBER;
   l_menu2_sid              NUMBER;
   l_menu_item_sid          NUMBER;
   l_submenu_item_sid       NUMBER;
   l_menu_order             NUMBER;
   l_item_order             NUMBER;
   l_subitem_order          NUMBER;

   l_mail_notifications_sid NUMBER;

   rt_main_menu             NUMBER;
   rt_submenu               NUMBER;
   rt_page                  NUMBER;
   rt_url                   NUMBER;
   rt_grid                  NUMBER;
   rt_questionnaire         NUMBER;
   rt_index                 NUMBER;
   rt_vintage               NUMBER;

   p_full                   NUMBER;
   p_read_only              NUMBER;

   g_admin                  NUMBER;
   g_cty_desk               NUMBER;
   g_c1                     NUMBER;
   g_ms                     NUMBER;
   g_read_only              NUMBER;
   g_gbl_econ               NUMBER;
   g_ameco                  NUMBER;
   g_forecast               NUMBER;
   g_public                 NUMBER;
BEGIN
   SELECT R.ROLE_SID
     INTO g_admin
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'ADMIN';

   SELECT R.ROLE_SID
     INTO g_ms
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'MS';

   SELECT R.ROLE_SID
     INTO g_cty_desk
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'CTY_DESK';

   SELECT R.ROLE_SID
     INTO g_c1
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'C1';

   SELECT R.ROLE_SID
     INTO g_read_only
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'READ_ONLY';

   SELECT R.ROLE_SID
     INTO g_gbl_econ
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'GBL_ECON';

   SELECT R.ROLE_SID
     INTO g_ameco
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'AMECO';

   SELECT R.ROLE_SID
     INTO g_forecast
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'FORECAST';

   SELECT R.ROLE_SID
     INTO g_public
     FROM SECUNDA_ROLES R
    WHERE R.ROLE_ID = 'PUBLIC';

   -- Menu Repo Types
   INSERT INTO MN_MENU_REPO_TYPES(MENU_REPO_TYPE_ID, DESCR)
        VALUES ('main_menu', 'Main Menu')
     RETURNING MENU_REPO_TYPE_SID
          INTO rt_main_menu;

   INSERT INTO MN_MENU_REPO_TYPES(MENU_REPO_TYPE_ID, DESCR)
        VALUES ('submenu', 'Submenu')
     RETURNING MENU_REPO_TYPE_SID
          INTO rt_submenu;

   INSERT INTO MN_MENU_REPO_TYPES(MENU_REPO_TYPE_ID, DESCR)
        VALUES ('page', 'Page')
     RETURNING MENU_REPO_TYPE_SID
          INTO rt_page;

   INSERT INTO MN_MENU_REPO_TYPES(MENU_REPO_TYPE_ID, DESCR)
        VALUES ('url', 'Url')
     RETURNING MENU_REPO_TYPE_SID
          INTO rt_url;

   INSERT INTO MN_MENU_REPO_TYPES(MENU_REPO_TYPE_ID, DESCR)
        VALUES ('grid', 'Grid')
     RETURNING MENU_REPO_TYPE_SID
          INTO rt_grid;

   INSERT INTO MN_MENU_REPO_TYPES(MENU_REPO_TYPE_ID, DESCR)
        VALUES ('fgd_quest', 'Fgd questionnaire')
     RETURNING MENU_REPO_TYPE_SID
          INTO rt_questionnaire;

   INSERT INTO MN_MENU_REPO_TYPES(MENU_REPO_TYPE_ID, DESCR)
        VALUES ('fgd_index', 'Fgd index')
     RETURNING MENU_REPO_TYPE_SID
          INTO rt_index;

   INSERT INTO MN_MENU_REPO_TYPES(MENU_REPO_TYPE_ID, DESCR)
        VALUES ('fgd_vintage', 'Fgd vintage')
     RETURNING MENU_REPO_TYPE_SID
          INTO rt_vintage;

   -- Permission Types
   INSERT INTO MN_PERMISSION_TYPES(PERMISSION_TYPE_ID, DESCR)
        VALUES ('full', 'Full Access')
     RETURNING PERMISSION_TYPE_SID
          INTO p_full;

   INSERT INTO MN_PERMISSION_TYPES(PERMISSION_TYPE_ID, DESCR)
        VALUES ('read_only', 'Read Only')
     RETURNING PERMISSION_TYPE_SID
          INTO p_read_only;

   -- Menu Repo

   --------------------------------- DFM --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'DFM';

   -- Measures menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('dfm_measures', 'Active Measures', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_read_only);

   -- page Enter measures
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_enter_measures', 'View/edit measures', 'measures/enter', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Country measures
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_country_measures', 'View/edit aggregated impact', 'measures/country', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Archive to custom storage
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_archive_custom', 'Archive to custom storage', 'customStorage', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- Archived Measures menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('dfm_measures_arch', 'Archived Measures', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_read_only);

   -- page Enter measures archived
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , LINK_PARAMS
                          , MENU_REPO_TYPE_SID)
        VALUES ('dfm_enter_measures_arch'
              , 'View measures'
              , 'measures/enter'
              , '{"archived":"true"}'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Country measures archived
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , LINK_PARAMS
                          , MENU_REPO_TYPE_SID)
        VALUES ('dfm_country_measures_arch'
              , 'View aggregated impact'
              , 'measures/country'
              , '{"archived":"true"}'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- Active Overview reports menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('dfm_actv_overview_reports', 'Active Overview Reports', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_read_only);

   -- page Additional impact
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_add_impact', 'Additional impact', 'reports/additionalImpact', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Total impact
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_total_impact', 'Total impact', 'reports/totalImpact', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Total impact (detailed)
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_total_impact_detailed'
              , 'Total impact (detailed)'
              , 'reports/totalImpactDetailed'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Transparency report
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_transparency_rep', 'Transparency report', 'measures/transparency', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Transfer matrix report
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_transfer_matrix_rep', 'Transfer matrix', 'reports/transferMatrix', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Additional impact (horizontal view)
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_add_impact_horiz'
              , 'Additional impact (horizontal view)'
              , 'reports/additionalImpactHoriz'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Total impact (horizontal view)
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_total_impact_horiz'
              , 'Total impact (horizontal view)'
              , 'reports/totalImpactHoriz'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- Archived Overview reports menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('dfm_arch_overview_reports', 'Archived Overview Reports', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_read_only);

   -- page Additional impact, archived
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_add_impact_arch'
              , 'Additional impact, archived'
              , 'reports/additionalImpactArchive'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Total impact, archived
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_total_impact_arch'
              , 'Total impact, archived'
              , 'reports/totalImpactArchive'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Transparency report, archived
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , LINK_PARAMS
                          , MENU_REPO_TYPE_SID)
        VALUES ('dfm_transparency_rep_arch'
              , 'Transparency report, archived'
              , 'measures/transparency'
              , '{"archived":"true"}'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Additional impact, archived (horizontal view)
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_add_impact_horiz_arch'
              , 'Additional impact, archived (horizontal view)'
              , 'reports/additionalImpactHorizArchive'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Total impact, archived (horizontal view)
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('dfm_total_impact_horiz_arch'
              , 'Total impact, archived (horizontal view)'
              , 'reports/totalImpactHorizArchive'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('dfm_admin', 'Admin', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   -- page Mail notifications
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('mail_notifications', 'Mail Notifications', 'admin/mailNotifications', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_mail_notifications_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_mail_notifications_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_mail_notifications_sid, g_admin, p_full);

   ---------------------------------------- DRM -------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'DRM';

   -- Input data menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('drm_measures', 'Active Measures', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_c1, p_full);

   -- page Manage measures online
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('drm_enter_measures', 'View/edit measures', 'measures/enter', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_c1, p_read_only);

   -- page wizard to upload measures
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('drm_wizard', 'Upload wizard', 'measures/wizard', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_ms, p_full);

   -- Visualize data menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('drm_visualize_data', 'Visualize data', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   -- page Download MS transparency Report
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , LINK_PARAMS
                          , MENU_REPO_TYPE_SID)
        VALUES ('drm_ms_transparency_report'
              , 'Download MS transparency Report'
              , 'reports/transparencyReport'
              , '{"archived":"true"}'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_ms, p_full);

   -- page search other DRM reports
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('drm_other_reports', 'Search other DRM reports', 'measures/otherReports', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_ms, p_full);

   -- Archived Measures menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('drm_measures_arch', 'Archived Measures', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_c1, p_full);

   -- page View/Edit measures archived
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , LINK_PARAMS
                          , MENU_REPO_TYPE_SID)
        VALUES ('drm_enter_measures_arch'
              , 'View measures'
              , 'measures/enter'
              , '{"archived":"true"}'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_c1, p_read_only);

   -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('drm_admin', 'Admin', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   -- page Mail notifications
   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_mail_notifications_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   --------------------------------- DBP, SCP ---------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'DBP';

   SELECT A.APP_SID
     INTO l_app2
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'SCP';

   -- Grids menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('gd_grids', 'Grids', rt_grid)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app2, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_read_only);

   -- page Manage Data
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , ICON
                          , MENU_REPO_TYPE_SID)
        VALUES ('gd_grids_country_data'
              , 'Manage Data'
              , 'grids/countryData'
              , 'pi pi-bars'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- Tools menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('gd_tools', 'Tools', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app2, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_read_only);

   -- page Output Gap
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_output_gap', 'Output gap', 'tools/outputGap', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_submenu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_c1, p_read_only);

   -- page Download Linked Tables
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_linked_tables_download'
              , 'Download Linked Tables'
              , 'tools/linkedTables'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_submenu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_read_only, p_read_only);

   -- Archive menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('gd_archive', 'Archive', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app2, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_read_only);

   -- page Read-only grids
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_archived_grids', 'Read-only Grids', 'grids/archive/grids/n', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- page Download data
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_archived_download'
              , 'Download data to csv format'
              , 'grids/archive/download'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_read_only, p_read_only);

   -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('gd_admin', 'Admin', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app2, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_read_only);

   -- submenu Grids Management
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('gd_grids_management', 'Grids Management', rt_submenu)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;
   l_subitem_order := 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page New Version of DBP/SCP
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_new_cty_version', 'New version of {appName}', 'admin/newVersion', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- submenu Load Parameters
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('gd_load_params', 'Load Parameters', rt_submenu)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;
   l_subitem_order := 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Load Semi-Elasticity
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_load_semi_elasticity', 'Load Semi-Elasticity', 'admin/semiElasticity', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- page Load fiscal parameters
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_load_fiscal_params', 'Load fiscal parameters ', 'admin/fiscalParams', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- page Load Output Gap parameters
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_load_og_params', 'Load Output Gap parameters ', 'admin/ogParams', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- submenu Grids Administration
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('gd_grids_admin', 'Grids Administration', rt_submenu)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;
   l_subitem_order := 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Line management
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_line_management', 'Line management', 'admin/lineManagement', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- page Upload Linked Tables Template
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_linked_tables_templates'
              , 'Upload Linked Tables Template'
              , 'admin/uploadLinkedTables'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_submenu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- page Export Aggregates
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('gd_aggregates', 'Aggregates', 'admin/aggregates', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_submenu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_c1, p_read_only);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_read_only, p_read_only);

   -- page Mail notifications
   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_mail_notifications_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   --------------------------------- FDMS --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'FDMS';

   SELECT A.APP_SID
     INTO l_app2
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'FDMSIE';

   -- Tools menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fdms_tools', 'Tools', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fdmsie_tools', 'Tools', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu2_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app2, l_menu2_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ameco, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu2_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu2_sid, g_cty_desk, p_full);

   -- page Data Explorer
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_data_explorer', 'Data explorer', 'tools/dataExplorer', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu2_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_ameco, p_full);

   -- page Input Data validation
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_input_data_test', 'Input Data validation', 'indicatorData/test', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_ameco, p_full);

   -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fdms_admin', 'Admin', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fdmsie_admin', 'Admin', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu2_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app2, l_menu2_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu2_sid, g_admin, p_full);

   -- page Initiate a round
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_init_round', '1.Initiate round', 'admin/initiateRound', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Indicator Data
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_input_data', '2.Input data upload', 'indicatorData', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Commodities Upload
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_commodities', '3.Commodities: Oil Price', 'task/commodities', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Forecast aggregates FDMS
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_forecast_agg', '4.Forecast aggregates', 'task/forecast_agg', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page TCE
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_tce', '5.TCE', 'task/forecast_tce', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Output Gap Upload
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_output_gap', '6.Output Gap', 'task/output_gap', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- submenu Reports FDMS
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fdms_reports', 'Reports', rt_submenu)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;
   l_subitem_order := 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Budget report
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_budg_report', 'Budget report', 'admin/budgetReport', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order    := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- page Transfer files
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_xfer_ameco', 'Transfer files', 'admin/xferAmeco', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order    := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- submenu Utils FDMS
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fdms_utils', 'Utils', rt_submenu)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;
   l_subitem_order := 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Uploads
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdms_uploads', 'Uploads archive', 'admin/uploads', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order    := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- page Mail notifications
   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_mail_notifications_sid, l_subitem_order);

   l_subitem_order    := l_subitem_order + 1;

   -- FSMSIE
   l_item_order    := 1;

   -- page Forecast aggregates FDMSIE
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdmsie_forecast_agg', 'Forecast aggregates', 'task/forecast_agg', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu2_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- submenu Utils FDMSIE
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fdmsie_utils', 'Utils', rt_submenu)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu2_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;
   l_subitem_order := 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Uploads
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fdmsie_uploads', 'Uploads archive', 'admin/uploads', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order    := l_subitem_order + 1;

   --------------------------------- FGD --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'FGD';

   -- Questionnaires menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('fgd_questionnaires'
              , 'Questionnaires'
              , rt_questionnaire
              , 'pi pi-home'
              , 'questionnaire')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   -- Scores menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('fgd_scores'
              , 'Scores'
              , rt_index
              , ''
              , 'scores')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   -- Indices menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('fgd_indices'
              , 'Current Indices'
              , rt_index
              , ''
              , 'indices')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   -- Horizontal view menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('fgd_horizontal'
              , 'Horizontal view'
              , rt_index
              , ''
              , 'horizontal/indexes')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   -- Vintages menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('fgd_vintages'
              , 'Database vintages'
              , rt_questionnaire
              , ''
              , 'vintages')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   --------------------------------- AUXTOOLS --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'AUXTOOLS';

   -- Tools menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('auxtools_tools', 'Tools', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_forecast, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_public, p_full);

   -- page Bloomberg
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('auxtools_bloom_converter', 'Bloomberg File Converter', 'tools/bloombergConverter', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_forecast, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_public, p_full);

   -- HICP menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('auxtools_hicp', 'Hicp', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_public, p_full);

   -- page Calculation
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('auxtools_hicp_calculation', 'Calculation', 'hicp/base', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_public, p_full);

   -- submenu HICP analytics
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('auxtools_hicp_analytics', 'Analytics', rt_submenu)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;
   l_subitem_order := 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_public, p_full);

   -- page Base effect
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('hicp_base_effect', 'Base effect', 'hicp/base_effect', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_public, p_full);

   -- page Contributions
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('hicp_contrib', 'Contributions', 'hicp/contrib', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_public, p_full);

   -- page Anomalies
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('hicp_anomalies', 'Anomalies', 'hicp/anomalies', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_submenu_item_sid, g_public, p_full);

   -- page Simple Statistics
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
   VALUES ('hicp_simple_stats', 'Simple statistics', 'hicp/base_stats', rt_page)
   RETURNING MENU_REPO_SID
   INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
   VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_public, p_full);

   -- page Tramo-Seats
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
   VALUES ('hicp_tramo_seats', 'Seasonal Adjustments', 'hicp/tramo_seats', rt_page)
   RETURNING MENU_REPO_SID
   INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
   VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_public, p_full);

   -- page Qlick dashboard
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
   VALUES ('hicp_qlick', 'Analytics dashboard', 'https://webgate.ec.testa.eu/qs_ecfin_dashboard/eu-login/sense/app/d35e4964-117d-449e-a321-77c124bbd9fe', rt_url)
   RETURNING MENU_REPO_SID
   INTO l_submenu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
   VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);

   l_subitem_order := l_subitem_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
   VALUES (l_submenu_item_sid, g_public, p_full);

--   -- page Data import
--   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
--        VALUES ('auxtools_hicp_data', 'Data import', 'hicp/data_import', rt_page)
--     RETURNING MENU_REPO_SID
--          INTO l_menu_item_sid;
--
--   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
--        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);
--
--   l_item_order    := l_item_order + 1;
--
--   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Categories
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('auxtools_hicp_categories', 'Categories', 'hicp/categories', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_public, p_full);

   -- EER menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('auxtools_eer', 'EER', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;


   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_forecast, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_public, p_full);

   -- page EER Calculation
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('auxtools_eer_task_exr', 'Calculation', 'eer/task/exchangeRate', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_forecast, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_public, p_full);

   ---------------------------------- AMECO ----------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'AMECO';

   -- Tools menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('ameco_tools', 'Tools', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   -- page Unemployment
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('ameco_unemployment', 'Unemployment', 'task/unemployment', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   -- page NSI
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('ameco_nsi', 'NSI', 'task/nsi', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_cty_desk, p_full);

   -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('ameco_admin', 'Admin', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   -- page AIRFLOW link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('ameco_airflow', 'Airflow', 'http://fp-etl-p.cc.cec.eu.int:8080/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);


--   -- submenu Load initial raw data
--   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
--        VALUES ('ameco_load_raw_data', 'Load initial raw data', rt_submenu)
--     RETURNING MENU_REPO_SID
--          INTO l_menu_item_sid;
--
--   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
--        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);
--
--   l_item_order    := l_item_order + 1;
--   l_subitem_order := 1;
--
--   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--        VALUES (l_menu_item_sid, g_admin, p_full);
--
--   -- page Unemployment indicators
--   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
--        VALUES ('ameco_unemployment_indicators', 'Unemployment indicators', 'tools/unemployment_input', rt_page)
--     RETURNING MENU_REPO_SID
--          INTO l_submenu_item_sid;
--
--   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
--        VALUES (l_menu_item_sid, l_submenu_item_sid, l_subitem_order);
--
--   l_subitem_order := l_subitem_order + 1;
--
--   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--        VALUES (l_submenu_item_sid, g_admin, p_full);

   -- Ameco-internal menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('ameco_internal', 'Ameco internal', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_forecast, p_full);

   -- page Ameco internal current
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('ameco_internal_current', 'Current', 'tools/ameco_internal/current', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

    l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_forecast, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Ameco internal annex
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('ameco_internal_annex', 'Annex', 'tools/ameco_internal/annex', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

    l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_forecast, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page Ameco internal restricted
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('ameco_internal_restricted', 'Restricted', 'tools/ameco_internal/restricted', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

    l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_forecast, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   ---------------------------------- AMECO --> OUTPUT GAP ----------------------------------------
   l_menu_order    := 4;
   l_item_order    := 1;
 
   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'AMECO';

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('output_gap', 'Output Gap', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   -- page T10
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('output_gap_t10_upload', 'T+10 upload', 'output_gap/t10_upload', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);


   ---------------------------------- FPADMIN ----------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'FPADMIN';

   -- Logs menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_logs', 'Logs', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   -- page Access log
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_access_log', 'Access log', 'logs/access', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- Notification menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_notification', 'Notification', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   -- page CNS notification
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_cns', 'CNS', 'notification/cns', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- Tools menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_tools', 'Tools', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   -- page AIRFLOW link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_aiflow', 'Airflow', 'http://fp-etl-p.cc.cec.eu.int:8080/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   -- page FMR link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_fmr', 'FMR', 'http://halmost.cc.cec.eu.int:8090/FusionRegistry/overview.html', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

------------------------------
   -- Api-docs menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_api_docs', 'Api-docs', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   --  Api-docs ameco link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_ameco', 'Ameco', '{HOST}/api-docs/ameco/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --  Api-docs dfm link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_dfm', 'Dfm', '{HOST}/api-docs/dfm/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --  Api-docs drm link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_drm', 'Drm', '{HOST}/api-docs/drm/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --  Api-docs fdms link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_fdms', 'Fdms', '{HOST}/api-docs/fdms/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --  Api-docs Fpapi ameco link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_fpapi_ameco', 'Fpapi ameco', '{HOST}/api-docs/fpapi/1.0/json/ameco/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --  Api-docs Fpapi sdmx link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_fpapi_sdmx', 'Fpapi sdmx', '{HOST}/api-docs/fpapi/1.0/data/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --  Api-docs imf link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_imf', 'Imf', '{HOST}/api-docs/imf/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --  Api-docs sdmx link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_sdmx', 'Sdmx', '{HOST}/api-docs/sdmx/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --  Api-docs spi link
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_apidocs_spi', 'Spi', '{HOST}/api-docs/spi/', rt_url)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);


   -- Addin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_addin', 'Addin', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   --  Addin Groups
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_addin_groups', 'Groups', 'addin/groups', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);


   -- Tasks menu -----------------------------------------------------------------------------
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_tasks', 'Tasks', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   --  executed
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_tasks_executed', 'Executed', 'tasks/executed', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);    

 -- Indicators menu -----------------------------------------------------------------------------
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_indicators', 'Indicators', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   --  all
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('fpadmin_indicators_all', 'All', 'indicators/all', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);      

   --------------------------------- BCS --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'BCS';

   -- Manage menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, MENU_REPO_TYPE_SID)
        VALUES ('bcs_manage', 'Manage', rt_main_menu)
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   -- page Manage country groups
   INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('bcs_manage_aggregates', 'Aggregate groups', 'manage/aggregates', rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

    -- page Manage parameters
    INSERT INTO MN_MENU_REPO(MENU_REPO_ID, TITLE, LINK, MENU_REPO_TYPE_SID)
        VALUES ('bcs_manage_parameters', 'Parameters', 'manage/parameters', rt_page)
        RETURNING MENU_REPO_SID
            INTO l_menu_item_sid;

    INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

    l_item_order    := l_item_order + 1;

    INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);


   --------------------------------- NFR --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'NFR';

   -- Scores menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('nfr_scores'
              , 'Scores'
              , rt_index
              , ''
              , 'scores')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);
   
   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_full);

   -- Indices menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('nfr_indices'
              , 'Current Indices'
              , rt_index
              , ''
              , 'indices')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   -- Horizontal view menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('nfr_horizontal'
              , 'Horizontal view'
              , rt_index
              , ''
              , 'horizontal/indexes')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

    -- Vintages menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('nfr_vintages'
              , 'Database vintages'
              , rt_vintage
              , 'vintages')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_full);

     -- Graphs menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('nfr_graphs'
              , 'Graphs'
              , rt_url
              , 'https://webgate.ec.testa.eu/qs_ecfin_dashboard/eu-login/sense/app/63d7797e-b134-49df-b3e2-bde378912fa3/sheet/ffd025a4-8746-44ef-96f1-642e23e21433/state/analysis')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

--    INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--         VALUES (l_menu_sid, g_cty_desk, p_full);

--    INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--         VALUES (l_menu_sid, g_ms, p_full);

--    INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--         VALUES (l_menu_sid, g_read_only, p_full);

--    INSERT INTO MN_MENU_REPO(MENU_REPO_ID
--                           , TITLE
--                           , LINK
--                           , MENU_REPO_TYPE_SID)
--         VALUES ('nfr_graphs_current_vintage'
--               , 'Fiscal Rules by year'
--               , 'graphs/year'
--               , rt_url)
--      RETURNING MENU_REPO_SID
--           INTO l_menu_item_sid;

--    INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
--         VALUES (l_menu_sid, l_menu_item_sid, l_item_order);
   
--    l_item_order    := l_item_order + 1;

--    INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--         VALUES (l_menu_item_sid, g_admin, p_full);

--    INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--         VALUES (l_menu_item_sid, g_cty_desk, p_full);

--    INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--         VALUES (l_menu_item_sid, g_ms, p_full);
   
--    INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
--         VALUES (l_menu_item_sid, g_read_only, p_full);
     
     -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('nfr_admin'
              , 'Admin'
              , rt_main_menu
              , 'admin')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , MENU_REPO_TYPE_SID)
        VALUES ('nfr_admin_current_vintage'
              , 'Current Vintage'
              , 'admin/vintage'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);
   --------------------------------- IFI --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'IFI';

   -- Scores menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('ifi_scores'
              , 'Scores'
              , rt_index
              , ''
              , 'scores')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_full);

   -- Indices menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('ifi_indices'
              , 'Current Indices'
              , rt_index
              , ''
              , 'indices')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   -- Horizontal view menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('ifi_horizontal'
              , 'Horizontal view'
              , rt_index
              , ''
              , 'horizontal/indexes')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

    -- Vintages menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('ifi_vintages'
              , 'Database vintages'
              , rt_vintage
              , 'vintages')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_full);

     -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('ifi_admin'
              , 'Admin'
              , rt_main_menu
              , 'admin')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , MENU_REPO_TYPE_SID)
        VALUES ('ifi_admin_current_vintage'
              , 'Current Vintage'
              , 'admin/vintage'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   --------------------------------- MTBF --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'MTBF';

   -- Scores menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('mtbf_scores'
              , 'Scores'
              , rt_index
              , ''
              , 'scores')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_full);

   -- Indices menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('mtbf_indices'
              , 'Current Indices'
              , rt_index
              , ''
              , 'indices')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   -- Horizontal view menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('mtbf_horizontal'
              , 'Horizontal view'
              , rt_index
              , ''
              , 'horizontal/indexes')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

    -- Vintages menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('mtbf_vintages'
              , 'Database vintages'
              , rt_vintage
              , 'vintages')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_full);


     -- Graphs menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('mtbf_graphs'
              , 'Graphs'
              , rt_url
              , 'https://webgate.ec.testa.eu/qs_ecfin_dashboard/eu-login/sense/app/0b2665d7-7085-4680-aa3a-3fc5d4d0b815/sheet/1fe95904-77a8-459e-851b-f0f02b53e6e6/state/analysis')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);   
     -- Admin menu  
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('mtbf_admin'
              , 'Admin'
              , rt_main_menu
              , 'admin')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , MENU_REPO_TYPE_SID)
        VALUES ('mtbf_admin_current_vintage'
              , 'Current Vintage'
              , 'admin/vintage'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);


   --------------------------------- GBD --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'GBD';

   -- Horizontal view menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , ICON
                          , LINK)
        VALUES ('gbd_horizontal'
              , 'Horizontal view'
              , rt_index
              , ''
              , 'horizontal/indexes')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   -- Vintages menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('gbd_vintages'
              , 'Database vintages'
              , rt_vintage
              , 'vintages')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_full);
     -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('gbd_admin'
              , 'Admin'
              , rt_main_menu
              , 'admin')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , MENU_REPO_TYPE_SID)
        VALUES ('gbd_admin_current_vintage'
              , 'Current Vintage'
              , 'admin/vintage'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);


   --------------------------------- PMI --------------------------------------
   l_menu_order    := 1;

   SELECT A.APP_SID
     INTO l_app
     FROM APPLICATIONS A
    WHERE A.APP_ID = 'PIM';

   -- Vintages menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('pim_vintages'
              , 'Database vintages'
              , rt_vintage
              , 'vintages')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_cty_desk, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_ms, p_full);

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_read_only, p_full);
   -- Admin menu
   l_item_order    := 1;

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , MENU_REPO_TYPE_SID
                          , LINK)
        VALUES ('pim_admin'
              , 'Admin'
              , rt_main_menu
              , 'admin')
     RETURNING MENU_REPO_SID
          INTO l_menu_sid;

   INSERT INTO MN_APP_MENUS(APPLICATION_SID, MENU_REPO_SID, ORDER_BY)
        VALUES (l_app, l_menu_sid, l_menu_order);

   l_menu_order    := l_menu_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_sid, g_admin, p_full);

   INSERT INTO MN_MENU_REPO(MENU_REPO_ID
                          , TITLE
                          , LINK
                          , MENU_REPO_TYPE_SID)
        VALUES ('pim_admin_current_vintage'
              , 'Current Vintage'
              , 'admin/vintage'
              , rt_page)
     RETURNING MENU_REPO_SID
          INTO l_menu_item_sid;

   INSERT INTO MN_MENU_MENU_ITEMS(MENU_SID, MENU_ITEM_SID, ORDER_BY)
        VALUES (l_menu_sid, l_menu_item_sid, l_item_order);

   l_item_order    := l_item_order + 1;

   INSERT INTO MN_PERMISSIONS(MENU_REPO_SID, USER_GROUP_SID, PERMISSION_TYPE_SID)
        VALUES (l_menu_item_sid, g_admin, p_full);

   COMMIT;
END;
/
