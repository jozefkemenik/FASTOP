CREATE OR REPLACE PACKAGE BODY ADDIN_SETTERS
AS
----------------------------------------------------------------------------
-- @name setTreeApps
----------------------------------------------------------------------------
  PROCEDURE setTreeApps(           o_res   OUT  NUMBER
                                   , tree_sids IN       SIDSLIST
                                   , dashboard_sids   IN       SIDSLIST
                                   , parent_tree_sids IN       SIDSLIST
                                   , titles IN       VARCHARLIST
                                   , json_datas IN       VARCHARLIST )
   IS
     l_dashboard_sid ADDIN_TREE.DASHBOARD_SID%TYPE;
     l_parent_tree_sid ADDIN_TREE.PARENT_TREE_SID%TYPE;

   BEGIN
      o_res := tree_sids.COUNT;
      DELETE FROM ADDIN_TREE;
      FOR i IN 1 .. tree_sids.COUNT LOOP

         IF dashboard_sids(i) = -1 THEN
            l_dashboard_sid := NULL;
         ELSE   
            l_dashboard_sid := dashboard_sids(i);
         END IF; 

         IF parent_tree_sids(i) = -1 THEN
            l_parent_tree_sid := NULL;
         ELSE   
            l_parent_tree_sid := parent_tree_sids(i);
         END IF;       

         INSERT INTO ADDIN_TREE(TREE_SID,
                                PARENT_TREE_SID,
                                DASHBOARD_SID, 
                                TITLE,
                                JSON_DATA)
         VALUES (tree_sids(i), 
                 l_parent_tree_sid,
                 l_dashboard_sid,
                 titles(i),
                 json_datas(i)
                 );
      END LOOP;

  END setTreeApps;

END ADDIN_SETTERS;