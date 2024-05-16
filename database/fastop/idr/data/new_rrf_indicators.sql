/* Formatted on 03/Nov/22 14:23:14 (QP5 v5.313) */
DECLARE
   PROCEDURE addIndicator(p_indicator IN VARCHAR2, p_ameco_prefix IN VARCHAR2)
   IS
      sid  NUMBER(12);
   BEGIN
      BEGIN
         SELECT INDICATOR_SID
           INTO sid
           FROM INDICATORS
          WHERE INDICATOR_ID = '1.0.319.0.' || p_indicator AND SOURCE = 'AMECO';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            INSERT INTO INDICATORS(INDICATOR_ID, SOURCE, AMECO_CODE, IN_LT)
                 VALUES ('1.0.319.0.' || p_indicator
                       , 'AMECO'
                       , '1.0.319.0.' || p_indicator
                       , p_ameco_prefix || p_indicator)
              RETURNING INDICATOR_SID
                   INTO sid;
      END;

      INSERT INTO INDICATOR_LISTS(INDICATOR_SID, WORKBOOK_GROUP_SID)
           VALUES (sid
                 , (SELECT WG.WORKBOOK_GROUP_SID
                      FROM WORKBOOK_GROUPS WG
                     WHERE WG.WORKBOOK_GROUP_ID = 'linked_tables'));
   END;
BEGIN
   addIndicator('UUCGR', '319');
   addIndicator('UIGG0R', '319');
   addIndicator('UKTGR', '319');
   addIndicator('UTGCR', '319');
   addIndicator('UROGR', '319');

   addIndicator('URCGR', '1319');
   addIndicator('UKTTR', '1319');
   addIndicator('UUTGI', '1319');
END;