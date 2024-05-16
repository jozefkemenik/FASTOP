CREATE OR REPLACE PACKAGE AGG_DATA
AS
   /******************************************************************************
      NAME:       AGG_DATA
   /****************************************************************************/

    PROCEDURE saveAggLines ( p_round_sid   IN     NUMBER
,                            p_area        IN     VARCHAR2
,                            p_variables   IN     VECTORARRAY
,                            p_user        IN     VARCHAR2
,                            o_res         OUT    NUMBER);

    PROCEDURE saveAggIndicators ( p_round_sid   IN     NUMBER
,                                 p_area        IN     VARCHAR2
,                                 p_variables   IN     VECTORARRAY
,                                 p_user        IN     VARCHAR2
,                                 o_res         OUT    NUMBER);

END AGG_DATA;
