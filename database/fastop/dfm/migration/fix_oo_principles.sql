/* Formatted on 23-03-2020 15:01:28 (QP5 v5.313) */
DECLARE
   l_principle_5 NUMBER(4);
   l_principle_0 NUMBER(4);
BEGIN
   SELECT P.OO_PRINCIPLE_SID
     INTO l_principle_5
     FROM dfm_oo_principles P
    WHERE P.OO_PRINCIPLE_ID = '5';

   SELECT P.OO_PRINCIPLE_SID
     INTO l_principle_0
     FROM dfm_oo_principles P
    WHERE P.OO_PRINCIPLE_ID = '0';

   UPDATE dfm_measures M
      SET M.OO_PRINCIPLE_SID = l_principle_0
        , M.ONE_OFF_COMMENTS = 'Please change to a correct principle or correct OO type.'
    WHERE M.OO_PRINCIPLE_SID = l_principle_5;

   UPDATE dfm_archived_measures M
      SET M.OO_PRINCIPLE_SID = l_principle_0
        , M.ONE_OFF_COMMENTS = 'Please change to a correct principle or correct OO type.'
    WHERE M.OO_PRINCIPLE_SID = l_principle_5;

   DELETE FROM dfm_oo_principles
         WHERE OO_PRINCIPLE_SID = l_principle_5;
   
   COMMIT;
END;
/