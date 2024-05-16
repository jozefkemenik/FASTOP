DECLARE
    CURSOR c_old_resp_groups IS
        SELECT A.COND_SID AS OLD_COND_SID, 
               A.QUESTION_SID AS OLD_QUESTION_SID,
               A.RESPONSE_GROUP_SID AS OLD_LOV_TYPE_SID,
               b.attr_sid as old_attr_sid
        FROM FGD_CFG_QUEST_RESP_GROUPS A,
             fgd_cfg_attributes b
        WHERE A.QUESTION_SID = B.QUESTION_SID
        AND B.ATTR_SID IN (SELECT OLD_ATTR_SID FROM QUESTION_VERSIONS_MIG)
        AND A.RESPONSE_GROUP_SID != 0
        ORDER BY 1;
        
l_err_key NUMBER;
l_key NUMBER;
l_cond NUMBER;
l_question NUMBER;
l_lov_type NUMBER;
BEGIN
    FOR r_rec IN c_old_resp_groups LOOP
        l_err_key := r_rec.old_attr_sid;
        IF r_rec.OLD_COND_SID IS NOT NULL THEN
            l_key := 1;
            l_cond := get_new_cond_sid(r_rec.OLD_COND_SID);
        ELSE
            l_cond := null;
        END IF;
        l_key := 2;
        l_question := get_question_version_sid(r_rec.old_attr_sid);
        l_key := 3;
        l_lov_type := get_new_lov_type(r_rec.OLD_LOV_TYPE_SID);
        l_key := 4;
        BEGIN
            INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID)
            VALUES (l_question, l_cond, l_lov_type);
        EXCEPTION 
            WHEN OTHERS THEN
                LOG_FAIL('CFG_QUESTION_LOV_TYPES', sysdate, sqlerrm(), l_question);
        END;
            LOG_info('CFG_QUESTION_LOV_TYPES', sysdate, 'Migrated with SUCC', l_question);
            
            INSERT INTO QUESTION_LOV_TYPES_MIG(OLD_COND_SID, OLD_QUESTION_SID, OLD_LOV_TYPE_SID, NEW_COND_SID, NEW_QUESTION_VERSION_SID, NEW_LOV_TYPE_SID)
            VALUES (r_rec.OLD_COND_SID, r_rec.OLD_QUESTION_SID, r_rec.OLD_LOV_TYPE_SID, l_cond, l_question, l_lov_type);
            
            LOG_info('QUESTION_LOV_TYPES_MIG', sysdate, 'Migrated with SUCC', l_question);
        
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('Migrate question lov types', sysdate, sqlerrm() || l_key , l_err_key);
END;
/


