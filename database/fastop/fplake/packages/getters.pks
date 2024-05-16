CREATE OR REPLACE PACKAGE FPLAKE_GETTERS
AS
   PROCEDURE getLakes(o_cur         OUT SYS_REFCURSOR
                    , p_provider IN     VARCHAR2 DEFAULT NULL
                    , p_dataflow IN     VARCHAR2 DEFAULT NULL
   );

END FPLAKE_GETTERS;
/
