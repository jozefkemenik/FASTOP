DECLARE

    CURSOR c_data IS
    SELECT QUESTIONNAIRE_SID, QUESTIONNAIRE_ID, DESCR, ORDER_BY FROM FGD_CFG_QUESTIONNAIRES ORDER BY 4;
    
    l_eu VARCHAR2(20 BYTE) := 'EU';
    l_cc VARCHAR2(20 BYTE) := 'EUCC';
    
l_key NUMBER;
l_version_key NUMBER;
BEGIN
    FOR r_rec IN c_data LOOP
        BEGIN
            INSERT INTO CFG_QUESTIONNAIRES(APP_ID, DESCR)
            VALUES (r_rec.QUESTIONNAIRE_ID, r_rec.DESCR)
            RETURNING QUESTIONNAIRE_SID INTO l_key;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_FAIL('CFG_QUESTIONNAIRES', sysdate, sqlerrm(), 0);
        END;
        
        BEGIN
            INSERT INTO CFG_QSTNNR_VERSIONS(QUESTIONNAIRE_SID, COUNTRY_GROUP_ID)
            VALUES (l_key, l_eu)
            RETURNING QSTNNR_VERSION_SID INTO l_version_key;
        EXCEPTION 
            WHEN OTHERS THEN
                LOG_FAIL('CFG_QSTNNR_VERSIONS', sysdate, sqlerrm(), l_key);
        END;
            INSERT INTO QUESTIONNAIRES_MIG(OLD_QUESTIONNAIRE_SID, QSTNNR_VERSION_SID, COUNTRY_GROUP_ID)
            VALUES (r_rec.QUESTIONNAIRE_SID, l_version_key, l_eu);
        -- BEGIN
        --     INSERT INTO CFG_QSTNNR_VERSIONS(QUESTIONNAIRE_SID, COUNTRY_GROUP_ID)
        --     VALUES (l_key, l_cc)
        --     RETURNING QSTNNR_VERSION_SID INTO l_version_key;
        -- EXCEPTION 
        --     WHEN OTHERS THEN
        --         LOG_FAIL('CFG_QSTNNR_VERSIONS', sysdate, sqlerrm(), l_key);
        -- END;
        --     INSERT INTO QUESTIONNAIRES_MIG(OLD_QUESTIONNAIRE_SID, QSTNNR_VERSION_SID, COUNTRY_GROUP_ID)
        --     VALUES (r_rec.QUESTIONNAIRE_SID, l_version_key, l_cc);
        
    END LOOP;
 EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('MIG QUESTIONNAIRES FAIL', sysdate, sqlerrm(), 0);
END;
    