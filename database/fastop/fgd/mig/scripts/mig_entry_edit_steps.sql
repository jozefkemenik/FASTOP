DECLARE

    CURSOR c_entry_edit_steps IS
        SELECT T.ENTRY_SID AS OLD_ENTRY_SID,
       E.NEW_SID AS NEW_ENTRY_SID,
       T.EDIT_STEP_SID,
       T.ROUND_SID,
       T.LAST_LOGIN,
       T.LAST_MODIF_DATE,
       T.PREV_STEP_SID,
       T.TAB,
       E.OLD_TABLE
  FROM   
    (SELECT RULE_SID AS ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID, 'NFR' AS TAB FROM FGD_NFR_RULE_EDIT_STEPS
    UNION
    SELECT INSTITUTION_SID AS ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID, 'IFI' AS TAB FROM FGD_IFI_INST_EDIT_STEPS
    UNION
    SELECT FRAME_SID AS ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID, 'MTBF' AS TAB FROM FGD_MTBF_FRAME_EDIT_STEPS
    UNION 
    SELECT ENTRY_SID AS ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID, 'GBD' AS TAB FROM fgd_gbd_entry_edit_steps) T,
    ENTRIES_MIG E
 WHERE E.OLD_SID = T.ENTRY_SID
   AND E.OLD_TABLE LIKE '%' || T.TAB || '%';
     
    
l_key NUMBER;
BEGIN
    FOR r_rec IN c_entry_edit_steps LOOP
        BEGIN
            INSERT INTO ENTRY_EDIT_STEPS(ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID)
            VALUES (r_rec.NEW_ENTRY_SID, r_rec.EDIT_STEP_SID, r_rec.ROUND_SID, r_rec.LAST_LOGIN, r_rec.LAST_MODIF_DATE, r_rec.PREV_STEP_SID)
            RETURNING ENTRY_EDIT_STEP_SID INTO l_key;
            
        EXCEPTION
            WHEN OTHERS THEN
                LOG_FAIL('ENTRY_EDIT_STEPS', sysdate, sqlerrm(),r_rec.OLD_ENTRY_SID);
        END;
            INSERT INTO ENTRY_EDIT_STEPS_MIG(NEW_EDIT_STEP_SID, OLD_SID,  NEW_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID, OLD_TABLE)
            VALUES ( l_key,r_rec.OLD_ENTRY_SID, r_rec.NEW_ENTRY_SID, r_rec.EDIT_STEP_SID, r_rec.ROUND_SID, r_rec.LAST_LOGIN, r_rec.LAST_MODIF_DATE, r_rec.PREV_STEP_SID, r_rec.TAB);
    END LOOP;
    
    
    
 EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('MIG ENTRIES FAIL', sysdate, sqlerrm(), 0);
END;
    