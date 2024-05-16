CREATE OR REPLACE PACKAGE AUXTOOLS_EER_MATRIX
AS
   PROCEDURE getMatrixData(o_cur            OUT SYS_REFCURSOR
                         , p_provider_id IN     VARCHAR2
                         , p_group_id    IN     VARCHAR2               DEFAULT NULL
                         , p_years       IN     CORE_COMMONS.SIDSARRAY DEFAULT CAST(NULL AS CORE_COMMONS.SIDSARRAY));

   PROCEDURE getMatrixYears(p_provider_id IN     VARCHAR2
                          , o_cur            OUT SYS_REFCURSOR);

END;
