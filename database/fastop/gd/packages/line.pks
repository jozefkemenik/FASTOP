/* Formatted on 12/16/2019 19:22:47 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE GD_LINE_PKG
AS
   /**************************************************************************
      NAME:       GD_LINE_PKG
      PURPOSE:
    **************************************************************************/

   PROCEDURE saveLine (P_ROUND_SID      IN     NUMBER
,                      P_LINE_SID       IN     NUMBER
,                      P_GRID_SID       IN     NUMBER
,                      P_DESCR          IN     VARCHAR2
,                      P_ESA_CODE       IN     VARCHAR2
,                      P_RATS_ID        IN     VARCHAR2
,                      P_IN_AGG         IN     VARCHAR2
,                      P_IN_LT          IN     VARCHAR2
,                      P_IS_MANDATORY   IN     NUMBER
,                      P_WEIGHT         IN     VARCHAR2
,                      P_WEIGHT_YEAR    IN     NUMBER
,                      P_IN_DD          IN     VARCHAR2
,                      P_AGG_DESCR      IN     VARCHAR2
,                      P_HELP_MSG_SID   IN     NUMBER
,                      O_RES               OUT NUMBER);

   PROCEDURE getLineIndicators (p_line_sid  IN     NUMBER,
                                o_cur       OUT SYS_REFCURSOR);

   PROCEDURE saveLineIndicator (p_line_sid             IN NUMBER,
                                p_data_type_sid        IN NUMBER,
                                p_indicator_sid        IN NUMBER,
                                o_res                  OUT NUMBER);

   PROCEDURE deleteLineIndicator (p_line_sid     IN NUMBER,
                                  p_data_type_sid          IN NUMBER,
                                  o_res                    OUT NUMBER);
                              
END GD_LINE_PKG;