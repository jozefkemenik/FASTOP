CREATE OR REPLACE PACKAGE AGG_GETTERS
AS
   /******************************************************************************
      NAME:       AGG_GETTERS
   /****************************************************************************/

   PROCEDURE getVariables ( p_round_sid      IN     NUMBER
,                           p_area_id        IN     VARCHAR2
,                           p_variable_ids   IN     CORE_COMMONS.VARCHARARRAY
,                           o_cur            OUT    SYS_REFCURSOR);

   PROCEDURE getGridCells ( p_round_sid    IN     NUMBER
,                           p_line_ids     IN     CORE_COMMONS.VARCHARARRAY
,                           o_cur          OUT    SYS_REFCURSOR);

   PROCEDURE getIndicatorVectors ( p_round_sid         IN     NUMBER
,                                  p_area              IN     VARCHAR2
,                                  p_indicator_ids     IN     CORE_COMMONS.VARCHARARRAY
,                                  o_cur               OUT    SYS_REFCURSOR);

   PROCEDURE getAggregatedVectors ( p_round_sid      IN     NUMBER
,                                   p_variable_ids   IN     CORE_COMMONS.VARCHARARRAY
,                                   o_cur            OUT    SYS_REFCURSOR);

   PROCEDURE getLevels ( p_round_sid   IN     NUMBER
,                        p_line_id     IN     VARCHAR2
,                        o_cur         OUT    SYS_REFCURSOR);

END AGG_GETTERS;
