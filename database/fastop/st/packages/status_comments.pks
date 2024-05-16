/* Formatted on 15-06-2020 21:06:25 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE ST_STATUS_COMMENTS
AS
   PROCEDURE getCountryRoundComments(o_cur           OUT SYS_REFCURSOR
                                   , p_app_id     IN     VARCHAR2
                                   , p_round_sid  IN     NUMBER
                                   , p_country_id IN     VARCHAR2);

   PROCEDURE setStatusComment(o_res                    OUT NUMBER
                            , p_cty_status_curr_sid IN     NUMBER
                            , p_status_sid          IN     NUMBER
                            , p_user                IN     VARCHAR2
                            , p_comment             IN     VARCHAR2);
END ST_STATUS_COMMENTS;
/