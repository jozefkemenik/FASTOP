/* Formatted on 12/19/2019 14:34:27 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE BODY GD_LINE_PKG
AS
   /**************************************************************************
      NAME:       GD_LINE_PKG
      PURPOSE:
    **************************************************************************/

   PROCEDURE saveLine (P_ROUND_SID      IN     NUMBER
,                      P_LINE_SID       IN     NUMBER
,                      P_GRID_SID       IN     NUMBER
,                      P_DESCR          IN     VARCHAR2
,                      P_ESA_CODE       IN     VARCHAR2
,                      P_RATS_ID        IN     VARCHAR2
,                      P_IN_AGG         IN     VARCHAR2
,                      P_IN_LT          IN     VARCHAR2
,                      P_IS_MANDATORY   IN     NUMBER
,                      P_WEIGHT         IN     VARCHAR2
,                      P_WEIGHT_YEAR    IN     NUMBER
,                      P_IN_DD          IN     VARCHAR2
,                      P_AGG_DESCR      IN     VARCHAR2
,                      P_HELP_MSG_SID   IN     NUMBER
,                      O_RES               OUT NUMBER)
   IS
      l_round_sid   ROUNDS.ROUND_SID%TYPE
                       := CORE_GETTERS.GETCURRENTROUNDSID ();
      l_count       NUMBER (8);
      l_line        GD_LINES%ROWTYPE;
   BEGIN
      -- Round sid must be current round sid
      IF P_ROUND_SID != l_round_sid
      THEN
         o_res := -2;
      ELSE
         SELECT COUNT (LINE_SID)
           INTO l_count
           FROM VW_GD_ROUND_GRID_LINES L
          WHERE L.LINE_SID = p_line_sid AND L.ROUND_SID != l_round_sid;

         IF l_count = 0
         THEN
               UPDATE GD_LINES
                  SET DESCR = p_descr
,                     ESA_CODE = p_esa_code
,                     RATS_ID = p_rats_id
,                     IN_AGG = p_in_agg
,                     IN_LT = p_in_lt
,                     IS_MANDATORY = p_is_mandatory
,                     WEIGHT = p_weight
,                     WEIGHT_YEAR = p_weight_year
,                     IN_DD = p_in_dd
,                     AGG_DESCR = p_agg_descr
,                     HELP_MSG_SID = p_help_msg_sid
                WHERE LINE_SID = p_line_sid
            RETURNING LINE_SID
                 INTO o_res;
         ELSE
            SELECT *
              INTO l_line
              FROM GD_LINES
             WHERE LINE_SID = p_line_sid;

            INSERT INTO GD_LINES (LINE_TYPE_SID
,                                 DESCR
,                                 ESA_CODE
,                                 HELP_MSG_SID
,                                 RATS_ID
,                                 LINE_ID
,                                 EB_ID
,                                 IN_AGG
,                                 IN_LT
,                                 IS_MANDATORY
,                                 MANDATORY_CTY_GROUP_ID
,                                 WEIGHT
,                                 WEIGHT_YEAR
,                                 IN_DD
,                                 AGG_DESCR
,                                 CALC_RULE
,                                 COPY_LINE_RULE)
                 VALUES (l_line.LINE_TYPE_SID
,                        P_DESCR
,                        P_ESA_CODE
,                        P_HELP_MSG_SID
,                        P_RATS_ID
,                        l_line.LINE_ID
,                        l_line.EB_ID
,                        P_IN_AGG
,                        P_IN_LT
,                        P_IS_MANDATORY
,                        l_line.MANDATORY_CTY_GROUP_ID
,                        P_WEIGHT
,                        P_WEIGHT_YEAR
,                        P_IN_DD
,                        P_AGG_DESCR
,                        l_line.CALC_RULE
,                        l_line.COPY_LINE_RULE)
              RETURNING LINE_SID
                   INTO o_res;
 
            -- create new line indicators for new line_sid
            INSERT INTO GD_LINE_INDICATOR (LINE_SID, DATA_TYPE_SID, INDICATOR_SID)
            (SELECT o_res, DATA_TYPE_SID, INDICATOR_SID
               FROM GD_LINE_INDICATOR
               WHERE LINE_SID = p_line_sid); 

            INSERT INTO GD_ROUND_GRID_LINES (ROUND_GRID_SID
,                                            LINE_SID
,                                            ORDER_BY)
               SELECT ROUND_GRID_SID, o_res, ORDER_BY
                 FROM VW_GD_ROUND_GRID_LINES L
                WHERE     L.LINE_SID = p_line_sid
                      AND L.ROUND_SID = l_round_sid
                      AND L.GRID_SID = p_grid_sid;

            IF SQL%ROWCOUNT = 0
            THEN
               ROLLBACK;
               o_res := -1;
            ELSE
               DELETE FROM GD_ROUND_GRID_LINES
                     WHERE     LINE_SID = p_line_sid
                           AND ROUND_GRID_SID =
                                  (SELECT ROUND_GRID_SID
                                     FROM GD_ROUND_GRIDS
                                    WHERE     ROUND_SID = l_round_sid
                                          AND GRID_SID = p_grid_sid);

               -- update already existing cells for this line_sid and round_grid_sid to new line_sid
               UPDATE GD_CELLS
                  SET LINE_SID = o_res
                WHERE LINE_SID = p_line_sid
                  AND CTY_GRID_SID IN 
                        (SELECT CTY_GRID_SID
                           FROM GD_CTY_GRIDS cg
                           JOIN GD_ROUND_GRIDS rg ON cg.ROUND_GRID_SID = rg.ROUND_GRID_SID
                          WHERE rg.ROUND_SID = l_round_sid
                            AND rg.GRID_SID = p_grid_sid);            
            END IF;
         END IF;
      END IF;
   END saveLine;

   PROCEDURE getLineIndicators(p_line_sid  IN     NUMBER,
                               o_cur       OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT LI.INDICATOR_SID, LI.DATA_TYPE_SID
                         FROM GD_LINE_INDICATOR LI
                        WHERE LI.LINE_SID = p_line_sid
                     ORDER BY LI.DATA_TYPE_SID;
   END getLineIndicators;

   PROCEDURE saveLineIndicator(p_line_sid             IN NUMBER,
                               p_data_type_sid        IN NUMBER,
                               p_indicator_sid        IN NUMBER,
                               o_res                  OUT NUMBER)
   IS 
      l_count       NUMBER (8);
   BEGIN
      -- check if line_sid exist before!
      SELECT count(*) INTO l_count
         FROM GD_LINES l
      WHERE l.LINE_SID = p_line_sid;
      
      -- if line null or doesn't exist or other parameter null then error
      IF l_count = 0 OR p_data_type_sid IS NULL OR p_indicator_sid IS NULL THEN
         o_res := -1;
      ELSE
         -- UPDATE
         UPDATE GD_LINE_INDICATOR 
         SET INDICATOR_SID = p_indicator_sid
         WHERE LINE_SID = p_line_sid
         AND DATA_TYPE_SID = p_data_type_sid
         RETURNING LINE_SID INTO o_res;

         -- if no update, line_indicator doesn't exist => insert it!
         IF SQL%ROWCOUNT = 0 THEN
               -- INSERT
               INSERT INTO GD_LINE_INDICATOR (LINE_SID, DATA_TYPE_SID, INDICATOR_SID)
               VALUES (p_line_sid, p_data_type_sid, p_indicator_sid) 
               RETURNING LINE_SID INTO o_res;
         END IF;
      END IF;
   END saveLineIndicator;
   

   PROCEDURE deleteLineIndicator(p_line_sid        IN NUMBER,
                                 p_data_type_sid   IN NUMBER,
                                 o_res             OUT NUMBER)
   IS
   BEGIN
      -- DELETE
      DELETE FROM GD_LINE_INDICATOR WHERE LINE_SID = p_line_sid AND DATA_TYPE_SID = p_data_type_sid;
      o_res := SQL%ROWCOUNT;

   END deleteLineIndicator;

END GD_LINE_PKG;