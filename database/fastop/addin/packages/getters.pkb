CREATE OR REPLACE PACKAGE BODY ADDIN_GETTERS
AS
    ----------------------------------------------------------------------------
    -- @name getActiveApps
    ----------------------------------------------------------------------------
    PROCEDURE getActiveApps(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
       OPEN o_cur FOR
          SELECT A.DASHBOARD_SID
               , A.TITLE
               , A.LINK
               , A.OWNER_APP_ID
               , A.ROLES
            FROM VW_ADDIN_ACTIVE_APPS A
        ORDER BY A.ORDER_BY ASC;
    END getActiveApps;


     ----------------------------------------------------------------------------
    -- @name getTreeActiveApps
    ----------------------------------------------------------------------------
    PROCEDURE getTreeActiveApps(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
       OPEN o_cur FOR
           SELECT  
                t.tree_sid,
                t.parent_tree_sid,
                t.dashboard_sid,
                t.title, 
                 A.LINK
               , A.OWNER_APP_ID
               , A.ROLES
               , t.json_data
               FROM addin_tree T 
               LEFT JOIN  VW_ADDIN_ACTIVE_APPS A ON t.dashboard_sid=a.dashboard_sid;
    END getTreeActiveApps;

END ADDIN_GETTERS;
