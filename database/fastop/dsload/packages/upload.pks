create or replace PACKAGE DSLOAD_UPLOAD
AS
   PROCEDURE getUpload(o_cur           OUT SYS_REFCURSOR
                     , p_user_id    IN     VARCHAR2
                     , p_upload_sid IN     NUMBER);

   PROCEDURE createUpload(p_user_id    IN      VARCHAR2
                        , p_provider   IN      VARCHAR2
                        , p_dataset    IN      VARCHAR2
                        , o_res           OUT  NUMBER);

   PROCEDURE changeDataset(p_upload_sid IN      NUMBER
                         , p_provider   IN      VARCHAR2
                         , p_dataset    IN      VARCHAR2
                         , o_res           OUT  NUMBER);

   PROCEDURE setUploadFolder(p_upload_sid IN      NUMBER
                           , p_folder     IN      VARCHAR2
                           , o_res           OUT  NUMBER);

   PROCEDURE updateUpload(p_upload_sid IN      NUMBER
                        , p_status     IN      VARCHAR2
                        , p_state      IN      CLOB
                        , o_res           OUT  NUMBER);

   PROCEDURE getStatusTransition(p_status IN     VARCHAR2
                               , o_cur       OUT SYS_REFCURSOR);


END DSLOAD_UPLOAD;
/
