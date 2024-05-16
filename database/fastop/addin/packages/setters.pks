CREATE OR REPLACE PACKAGE ADDIN_SETTERS
AS
    PROCEDURE setTreeApps(           o_res   OUT  NUMBER
                                   , tree_sids IN       SIDSLIST
                                   , dashboard_sids   IN       SIDSLIST
                                   , parent_tree_sids IN       SIDSLIST
                                   , titles IN       VARCHARLIST
                                   , json_datas IN       VARCHARLIST );
END ADDIN_SETTERS;
