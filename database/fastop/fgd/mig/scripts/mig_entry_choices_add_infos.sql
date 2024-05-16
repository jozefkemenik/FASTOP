DECLARE
    CURSOR c_data IS
        WITH t AS (SELECT  RULE_SID AS OLD_ENTRY_SID, DESCR, ATTR_SID AS OLD_ATTR_SID, 'FGD_NFR_RULES' AS TAB from fgd_nfr_rule_ADD_INFOS
        UNION
        SELECT  INSTITUTION_SID AS OLD_ENTRY_SID, DESCR, ATTR_SID AS OLD_ATTR_SID, 'FGD_IFI_INSTITUTIONS' AS TAB from fgd_IFI_INSTITUTION_ADD_INFOS
        UNION
        SELECT  FRAME_SID AS OLD_ENTRY_SID, DESCR, ATTR_SID AS OLD_ATTR_SID, 'FGD_MTBF_FRAMES' AS TAB from fgd_MTBF_FRAME_ADD_INFOS
        UNION
        SELECT  ENTRY_SID AS OLD_ENTRY_SID, DESCR, ATTR_SID AS OLD_ATTR_SID, 'FGD_GBD_ENTRIES' AS TAB from fgd_GBD_ENTRY_ADD_INFOS)
        SELECT t.* 
          FROM t,
               ENTRIES_MIG e,
               QUESTION_VERSIONS_MIG q
         WHERE t.OLD_ENTRY_SID = e.OLD_SID
           AND t.TAB = e.OLD_TABLE
           AND t.OLD_ATTR_SID = q.OLD_ATTR_SID;

    l_question_version NUMBER;
    l_entry_sid NUMBER;
    

    l_old_attr_sid number;
    l_old_entry_sid number;
    

BEGIN
    FOR rec IN c_data LOOP
        l_old_entry_sid := rec.OLD_ENTRY_SID;
        l_old_attr_sid := rec.OLD_ATTR_SID;
        
        l_question_version := get_question_version_sid(rec.OLD_ATTR_SID);
        l_entry_sid := get_new_entry_sid(rec.OLD_ENTRY_SID, rec.TAB);
        
        BEGIN
            INSERT INTO ENTRY_CHOICES_ADD_INFOS(ENTRY_SID, QUESTION_VERSION_SID, DESCR)
            VALUES (l_entry_sid, l_question_version, rec.DESCR);
        EXCEPTION
            WHEN OTHERS THEN
                LOG_FAIL('ENTRY_CHOICES_ADD_INFOS', sysdate, sqlerrm(), -11);
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('ENTRY_CHOICES_ADD_INFOS', sysdate, sqlerrm()|| ' ENTRY_SID = ' || l_old_entry_sid || ' QUESTION_VERSION_SID = ' || l_old_attr_sid , -22);
END;
