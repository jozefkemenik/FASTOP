/* Formatted on 30/03/2022 11:59:21 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE GD_GUARANTEE
AS
   PROCEDURE getGuarantee(p_guarantee_sid IN     NUMBER
                        , p_country_id    IN     VARCHAR2
                        , o_cur              OUT SYS_REFCURSOR);

   PROCEDURE getGuarantees(p_app_id     IN     VARCHAR2
                         , p_country_id IN     VARCHAR2
                         , o_cur           OUT SYS_REFCURSOR
                         , p_round_sid  IN     NUMBER DEFAULT NULL
                         , p_version    IN     NUMBER DEFAULT NULL);

   PROCEDURE getGuaranteeReasons(o_cur OUT SYS_REFCURSOR);

   PROCEDURE deleteGuarantee(p_app_id        IN     VARCHAR2
                           , p_guarantee_sid IN     NUMBER
                           , p_country_id    IN     VARCHAR2
                           , o_res              OUT NUMBER);

   PROCEDURE saveGuarantee(p_app_id IN VARCHAR2, p_guarantee IN GUARANTEEOBJECT, o_res OUT NUMBER);

   PROCEDURE saveGuarantees(p_app_id IN VARCHAR2, p_guarantees IN GUARANTEEARRAY, o_res OUT NUMBER);
END;