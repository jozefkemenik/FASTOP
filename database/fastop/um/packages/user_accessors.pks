/* Formatted on 20-11-2020 11:38:45 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE UM_USER_ACCESSORS
AS
   /******************************************************************************
      NAME:       UM_USER_ACCESSORS
      PURPOSE:    UM users data accessors: getters and setters
   ******************************************************************************/

   PROCEDURE getUserAuthzs(p_user_id       IN     VARCHAR2
                         , p_unit_id       IN     VARCHAR2
                         , o_cur              OUT SYS_REFCURSOR);
END;
