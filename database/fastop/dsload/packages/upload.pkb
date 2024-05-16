CREATE OR REPLACE PACKAGE BODY DSLOAD_UPLOAD AS

    ----------------------------------------------------------------------------
    ------------------------------- Private methods ----------------------------
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- @name getInitialStatusSid
    ----------------------------------------------------------------------------
    FUNCTION getInitialStatusSid
       RETURN NUMBER
    IS
       l_status_sid DSLOAD_STATUSES.STATUS_SID%TYPE;
    BEGIN
      SELECT STATUS_SID
        INTO l_status_sid
        FROM DSLOAD_STATUSES
       WHERE STATUS_ID = 'DATASET';

       RETURN l_status_sid;
    END getInitialStatusSid;

    ----------------------------------------------------------------------------
    -------------------------------- Public methods ----------------------------
    ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- @name getUpload
   ----------------------------------------------------------------------------
   PROCEDURE getUpload(o_cur           OUT SYS_REFCURSOR
                     , p_user_id    IN     VARCHAR2
                     , p_upload_sid IN     NUMBER)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT
                   U.UPLOAD_SID
                ,  U.FOLDER
                ,  U.PROVIDER
                ,  U.DATASET
                ,  S.STATUS_ID AS STATUS
                ,  U.STATE
                ,  U.USER_ID
                ,  U.LATEST_DATE
              FROM DSLOAD_UPLOADS U
              JOIN DSLOAD_STATUSES S
                ON U.STATUS_SID = S.STATUS_SID
             WHERE IS_DSLOAD_UPLOAD_FINAL_STATUS(U.STATUS_SID) = 0
               AND (
                     ( p_upload_sid IS NOT NULL AND upload_sid = p_upload_sid )
                     OR
                     ( p_upload_sid IS NULL AND upper(user_id) = upper(p_user_id))
                   );
    END getUpload;

   ---------------------------------------------------------------------------
   -- @name createUpload
   ---------------------------------------------------------------------------
   PROCEDURE createUpload(p_user_id    IN      VARCHAR2
                        , p_provider   IN      VARCHAR2
                        , p_dataset    IN      VARCHAR2
                        , o_res           OUT  NUMBER)
   IS
       l_upload_sid     DSLOAD_UPLOADS.UPLOAD_SID%TYPE;
       l_status_sid DSLOAD_STATUSES.STATUS_SID%TYPE := getInitialStatusSid();
   BEGIN
       INSERT INTO DSLOAD_UPLOADS (
                       USER_ID
                     , PROVIDER
                     , DATASET
                     , STATUS_SID
          ) VALUES (
                       p_user_id
                     , p_provider
                     , p_dataset
                     , l_status_sid
         )
         RETURNING UPLOAD_SID INTO l_upload_sid;
   END createUpload;

   ---------------------------------------------------------------------------
   -- @name changeDataset
   ---------------------------------------------------------------------------
   PROCEDURE changeDataset(p_upload_sid IN      NUMBER
                         , p_provider   IN      VARCHAR2
                         , p_dataset    IN      VARCHAR2
                         , o_res           OUT  NUMBER)
   IS
       l_status_sid DSLOAD_STATUSES.STATUS_SID%TYPE := getInitialStatusSid();
   BEGIN
      UPDATE DSLOAD_UPLOADS
         SET LATEST_DATE = SYSTIMESTAMP
           , PROVIDER = p_provider
           , DATASET = p_dataset
           , STATUS_SID = l_status_sid
       WHERE UPLOAD_SID = p_upload_sid;

      o_res := SQL%ROWCOUNT;
   END changeDataset;

   ----------------------------------------------------------------------------
   -- @name setUploadFolder
   ----------------------------------------------------------------------------
   PROCEDURE setUploadFolder(p_upload_sid IN      NUMBER
                           , p_folder     IN      VARCHAR2
                           , o_res           OUT  NUMBER)
   IS
   BEGIN
      UPDATE DSLOAD_UPLOADS
         SET FOLDER = p_folder
           , LATEST_DATE = SYSTIMESTAMP
       WHERE UPLOAD_SID = p_upload_sid;

      o_res := SQL%ROWCOUNT;
   END setUploadFolder;

   ----------------------------------------------------------------------------
   -- @name updateUpload
   ----------------------------------------------------------------------------
   PROCEDURE updateUpload(p_upload_sid IN      NUMBER
                        , p_status     IN      VARCHAR2
                        , p_state      IN      CLOB
                        , o_res           OUT  NUMBER)
   IS
      l_status_sid  DSLOAD_STATUSES.STATUS_SID%TYPE;
   BEGIN
      IF p_status is NOT NULL
      THEN
        SELECT STATUS_SID
          INTO l_status_sid
          FROM DSLOAD_STATUSES
         WHERE STATUS_ID = p_status;
      END IF;

      UPDATE DSLOAD_UPLOADS
         SET STATUS_SID = CASE WHEN l_status_sid IS NOT NULL THEN l_status_sid ELSE STATUS_SID END
           , STATE = CASE WHEN p_state IS NOT NULL THEN p_state ELSE STATE END
           , LATEST_DATE = SYSTIMESTAMP
       WHERE UPLOAD_SID = p_upload_sid;

      o_res := SQL%ROWCOUNT;
   END updateUpload;

   ----------------------------------------------------------------------------
   -- @name getStatusTransition
   ----------------------------------------------------------------------------
   PROCEDURE getStatusTransition(p_status IN     VARCHAR2
                               , o_cur       OUT SYS_REFCURSOR)
   IS
   BEGIN
        OPEN o_cur FOR
            SELECT
                   S.STATUS_ID
                 , S.STATE_CHANGE
                 , (SELECT
                           LISTAGG(VVS.VALID_STATUS_ID, ',') WITHIN GROUP (ORDER BY VVS.STATUS_SID)
                      FROM VW_DSLOAD_VALID_STATUSES VVS
                     WHERE VVS.STATUS_SID = S.STATUS_SID
                   ) VALID_STATUSES
             FROM DSLOAD_STATUSES S
            WHERE S.STATUS_ID = p_status;
   END getStatusTransition;

END DSLOAD_UPLOAD;
