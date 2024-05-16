CREATE OR REPLACE PACKAGE DBP_GRID_DATA
AS
    /******************************************************************************
       NAME:       DBP_GRID_DATA
       PURPOSE:

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        12/07/2019  lubiesz          1. Created this package.
    ******************************************************************************/

    PROCEDURE calculateTable5AMeasures(p_country_id   IN     VARCHAR2
,                                      p_round_sid    IN     NUMBER
,                                      p_version      IN     NUMBER
,                                      o_res          OUT    NUMBER);

END DBP_GRID_DATA;
