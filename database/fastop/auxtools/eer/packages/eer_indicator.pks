CREATE OR REPLACE PACKAGE AUXTOOLS_EER_INDICATOR
AS
   PROCEDURE getIndicatorData(o_cur                  OUT SYS_REFCURSOR
                            , p_provider_id       IN     VARCHAR2
                            , p_group_id          IN     VARCHAR2 DEFAULT NULL
                            , p_periodicity_id    IN     VARCHAR2 DEFAULT NULL);

END;
