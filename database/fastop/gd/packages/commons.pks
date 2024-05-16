/* Formatted on 14-05-2020 20:03:44 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE GD_COMMONS
AS
   /**************************************************************************
      NAME:       GD_COMMONS
      PURPOSE:
    **************************************************************************/

   PROCEDURE hasAnyGridData(p_app_id     IN     VARCHAR2
                          , p_country_id IN     VARCHAR2
                          , p_round_sid  IN     NUMBER DEFAULT NULL
                          , o_res           OUT NUMBER);

   PROCEDURE hasMissingData(p_country_id   IN       VARCHAR2
                          , p_round_sid    IN       NUMBER
                          , o_res              OUT  NUMBER);
END GD_COMMONS;
