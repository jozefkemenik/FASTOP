/* Formatted on 12/2/2019 17:29:46 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE IDR_SEMI_ELASTICITY
AS
   /******************************************************************************
      NAME:    IDR_SEMI_ELASTICITY
      PURPOSE: Semi elasticity functions
   ******************************************************************************/

   PROCEDURE storeSemiElasticity (
      o_res            OUT NUMBER
,     p_app_id      IN     VARCHAR2
,     p_round_sid   IN     NUMBER
,     p_countries   IN     CORE_COMMONS.VARCHARARRAY
,     p_values      IN     CORE_COMMONS.SIDSARRAY);

   FUNCTION getLastSemiElasticityRound RETURN NUMBER;

   PROCEDURE getLatestSemiElasticity (
      o_cur          OUT   SYS_REFCURSOR);

END IDR_SEMI_ELASTICITY;
/