/* Formatted on 22-10-2021 16:40:43 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DRM_APP_STATUS
AS
   /**************************************************************************
    * NAME:      DRM_APP_STATUS
    * PURPOSE:   DRM Application status setting functionality
    **************************************************************************/

   PROCEDURE archiveMeasures(p_round_sid IN NUMBER, o_res OUT NUMBER);

   PROCEDURE setApplicationOpen(o_res OUT NUMBER);

   PROCEDURE setApplicationClosed(o_res OUT NUMBER);
END DRM_APP_STATUS;