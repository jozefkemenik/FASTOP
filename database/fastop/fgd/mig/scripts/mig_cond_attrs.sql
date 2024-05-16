DECLARE
CURSOR c_old_conditions IS
    SELECT distinct A.COND_SID, 
           QVM.NEW_QUESTION_VERSION_SID AS QUESTION_VERSION_SID,
           QVM2.NEW_QUESTION_VERSION_SID AS COND_QUESTION_VERSION_SID,
           LMIG.NEW_LOV_SID as lov_sid,
           b.question_sid as old_question_sid,
           d.question_sid as old_cond_question_sid
                
    FROM FGD_CFG_CONDITIONAL_ATTRIBUTES A,
        FGD_CFG_ATTRIBUTES B,
        FGD_CFG_ATTRIBUTES D,
        LOVS_MIG LMIG,
        QUESTIONS_MIG QM,
        QUESTIONS_MIG QM2,
        QUESTION_VERSIONS_MIG QVM,
        QUESTION_VERSIONS_MIG QVM2
    WHERE A.ATTR_SID = B.ATTR_SID
      AND A.COND_ATTR_SID = D.ATTR_SID
 
      AND (A.COND_RESP_SID = LMIG.OLD_LOV_SID
            )
      AND QM.OLD_QUESTION_SID = B.QUESTION_SID
      AND QM2.OLD_QUESTION_SID = D.QUESTION_SID
      
      AND B.ATTR_SID = QVM.OLD_ATTR_SID
      AND D.ATTR_SID = QVM2.OLD_ATTR_SID
    
    UNION ALL
    SELECT DISTINCT A.COND_SID, 
           QVM.NEW_QUESTION_VERSION_SID AS QUESTION_VERSION_SID,
           QVM2.NEW_QUESTION_VERSION_SID AS COND_QUESTION_VERSION_SID,
           A.COND_RESP_SID  as lov_sid,
           b.question_sid as old_question_sid,
           d.question_sid as old_cond_question_sid
    FROM FGD_CFG_CONDITIONAL_ATTRIBUTES A,
        FGD_CFG_ATTRIBUTES B,
        FGD_CFG_ATTRIBUTES D,
        FGD_CFG_QUESTIONS Q,
        FGD_CFG_QUESTIONS V,
        QUESTIONS_MIG QM,
        QUESTIONS_MIG QM2,
        QUESTION_VERSIONS_MIG QVM,
        QUESTION_VERSIONS_MIG QVM2
    WHERE A.ATTR_SID = B.ATTR_SID
      AND B.QUESTION_SID = Q.QUESTION_SID
      AND A.COND_ATTR_SID = D.ATTR_SID
      AND D.QUESTION_SID = V.QUESTION_SID
      AND (A.COND_RESP_SID < 1)
      AND QM.OLD_QUESTION_SID = B.QUESTION_SID
      AND QM2.OLD_QUESTION_SID = Q.QUESTION_SID
      
      AND B.ATTR_SID = QVM.OLD_ATTR_SID
      AND D.ATTR_SID = QVM2.OLD_ATTR_SID;

l_key NUMBER;
BEGIN
    FOR r_condition IN c_old_conditions LOOP
        BEGIN
            INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
            VALUES (r_condition.QUESTION_VERSION_SID, r_condition.COND_QUESTION_VERSION_SID, r_condition.LOV_SID)
            RETURNING COND_SID INTO l_key;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_FAIL('CFG_QUESTION_CONDITIONS', sysdate, sqlerrm(), l_key);
        END;
            LOG_INFO('CFG_QUESTION_CONDITIONS', sysdate, 'Inserted succesfully new condition ', l_key);
            
            BEGIN
                INSERT INTO CONDITIONS_MIG(OLD_COND_SID, NEW_COND_SID, OLD_QUESTION_SID, OLD_COND_QUESTION_SID, NEW_QUESTION_VERSION_SID, NEW_COND_QUESTION_VERSION_SID)
                VALUES (r_condition.COND_SID, l_key, r_condition.OLD_QUESTION_SID, r_condition.OLD_COND_QUESTION_SID, r_condition.QUESTION_VERSION_SID, r_condition.COND_QUESTION_VERSION_SID);
            EXCEPTION
                WHEN OTHERS THEN
                    LOG_FAIL('CONDITIONS_MIG', sysdate, sqlerrm(), l_key);
            END;
        l_key := 0;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('Migrate question conditions', sysdate, sqlerrm(), l_key);
END;
/
DELETE CFG_QUESTION_CONDITIONS
WHERE QUESTION_VERSION_SID = 409;
COMMIT;
/