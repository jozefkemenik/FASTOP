/* Formatted on 16/06/2020 23:13:13 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY ST_STATUS_COMMENTS
AS
   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getCountryRoundComments
   ----------------------------------------------------------------------------
   PROCEDURE getCountryRoundComments(o_cur           OUT SYS_REFCURSOR
                                   , p_app_id     IN     VARCHAR2
                                   , p_round_sid  IN     NUMBER
                                   , p_country_id IN     VARCHAR2)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT S.DESCR         "storage"
                , S.STORAGE_ID    "storageId"
                , R.DESCR         "status"
                , R.STATUS_ID     "statusId"
                , COMM.COMMENT_USER "user"
                , COMM.COMMENT_DATE "date"
                , COMM.COMMENT_TEXT "comment"
             FROM st_cty_status_curr CURR
                  JOIN applications A ON A.APP_SID = CURR.APP_SID
                  JOIN storages S ON S.STORAGE_SID = CURR.STORAGE_SID
                  JOIN st_cty_status_comments COMM
                     ON COMM.CTY_STATUS_CURR_SID = CURR.CTY_STATUS_CURR_SID
                  JOIN st_status_repo R ON R.STATUS_SID = COMM.STATUS_SID
            WHERE A.APP_ID = p_app_id
              AND CURR.ROUND_SID = p_round_sid
              AND CURR.COUNTRY_ID = p_country_id
         ORDER BY CURR.STORAGE_SID DESC, COMM.COMMENT_DATE DESC;
   END getCountryRoundComments;

   ----------------------------------------------------------------------------
   -- @name setStatusComment
   ----------------------------------------------------------------------------
   PROCEDURE setStatusComment(o_res                    OUT NUMBER
                            , p_cty_status_curr_sid IN     NUMBER
                            , p_status_sid          IN     NUMBER
                            , p_user                IN     VARCHAR2
                            , p_comment             IN     VARCHAR2)
   IS
   BEGIN
      INSERT INTO ST_CTY_STATUS_COMMENTS(CTY_STATUS_CURR_SID
                                       , STATUS_SID
                                       , COMMENT_USER
                                       , COMMENT_TEXT
                                       , COMMENT_DATE)
           VALUES (p_cty_status_curr_sid
                 , p_status_sid
                 , p_user
                 , p_comment
                 , SYSDATE)
        RETURNING CTY_STATUS_COMMENT_SID
             INTO o_res;
   END setStatusComment;
END ST_STATUS_COMMENTS;
/