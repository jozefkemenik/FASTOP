/* Formatted on 14-05-2020 16:25:30 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DFM_COMMONS
AS
   /******************************************************************************
      NAME:       DFM_COMMONS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       06/03/2019    lubiesz        1. Created this package body.
   ******************************************************************************/

   FUNCTION tabagg(p_varchar2_tab IN VARCHARLIST, p_delimiter IN VARCHAR2 DEFAULT ',')
      RETURN VARCHAR2;
END DFM_COMMONS;
/