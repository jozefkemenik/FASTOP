CREATE OR REPLACE VIEW RESPONSE_CHOICES_VW
AS
SELECT L.LOV_SID        AS RESPONSE_SID
                  ,L.LOV_ID         AS RESPONSE_ID
                  ,L.LOV_TYPE_SID   AS RESPONSE_GROUP_SID
                  ,L.DESCR
                  ,L.NEED_DET       AS PROVIDE_DETAILS
                  ,L.ORDER_BY
                  ,L.CFG_TYPE       AS RESPONSE_TYPE_SID
                  ,L.HELP_TEXT
                  ,L.CHOICE_LIMIT
                  ,L.DETS_TXT
                  ,L.INFO_ICON
                  ,L.INFO_TXT
              FROM CFG_LOVS L
                  ,CFG_LOV_TYPES LT
             WHERE L.LOV_TYPE_SID = LT.LOV_TYPE_SID
               AND LT.DYN_SID = 0
               AND L.LOV_ID IS NULL
               AND LT.LOV_TYPE_ID != 'COUNTRY'
            UNION
            SELECT L.LOV_SID        AS RESPONSE_SID
                  ,L.LOV_ID         AS RESPONSE_ID
                  ,DL.LOV_TYPE_SID  AS RESPONSE_GROUP_SID
                  ,L.DESCR
                  ,L.NEED_DET       AS PROVIDE_DETAILS
                  ,L.ORDER_BY
                  ,L.CFG_TYPE       AS RESPONSE_TYPE_SID
                  ,L.HELP_TEXT
                  ,L.CHOICE_LIMIT
                  ,L.DETS_TXT
                  ,L.INFO_ICON
                  ,L.INFO_TXT
              FROM CFG_LOVS L
                  ,CFG_LOV_TYPES LT
                  ,CFG_DYNAMIC_LOVS DL
             WHERE DL.USED_LOV_TYPE_SID = L.LOV_TYPE_SID
               AND LT.LOV_TYPE_SID = DL.LOV_TYPE_SID
               AND LT.DYN_SID = DL.DYN_SID
               AND L.LOV_SID = DL.USED_LOV_SID
               AND LT.LOV_TYPE_ID != 'COUNTRY'
               AND LT.DYN_SID = 1
            UNION
            SELECT L.LOV_SID        AS RESPONSE_SID
                  ,L.LOV_ID         AS RESPONSE_ID
                  ,L.LOV_TYPE_SID   AS RESPONSE_GROUP_SID
                  ,L.DESCR
                  ,L.NEED_DET       AS PROVIDE_DETAILS
                  ,L.ORDER_BY
                  ,L.CFG_TYPE       AS RESPONSE_TYPE_SID
                  ,L.HELP_TEXT
                  ,L.CHOICE_LIMIT
                  ,L.DETS_TXT
                  ,L.INFO_ICON
                  ,L.INFO_TXT
              FROM CFG_LOVS L
                  ,CFG_LOV_TYPES LT
             WHERE L.LOV_TYPE_SID = LT.LOV_TYPE_SID
               AND LT.DYN_SID = 0
               AND L.LOV_ID IS NOT NULL
               AND LT.LOV_TYPE_ID != 'COUNTRY'
            UNION
            SELECT L.LOV_SID        AS RESPONSE_SID
                  ,L.LOV_ID         AS RESPONSE_ID
                  ,L.LOV_TYPE_SID   AS RESPONSE_GROUP_SID
                  ,L.DESCR
                  ,L.NEED_DET       AS PROVIDE_DETAILS
                  ,L.ORDER_BY
                  ,L.CFG_TYPE       AS RESPONSE_TYPE_SID
                  ,L.HELP_TEXT
                  ,L.CHOICE_LIMIT
                  ,L.DETS_TXT
                  ,L.INFO_ICON
                  ,L.INFO_TXT
              FROM CFG_SPECIAL_LOVS L
                  ,CFG_LOV_TYPES LT
             WHERE L.LOV_TYPE_SID = LT.LOV_TYPE_SID
               AND LT.LOV_TYPE_ID != 'COUNTRY'
            ORDER BY 3, 6;
