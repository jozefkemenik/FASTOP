-- check fastop for new round, old round, and year for old round
DECLARE
    l_year NUMBER := 2023;
    l_round_sid NUMBER := ;
    l_is_archive NUMBER := 0;
    
    t_edit_steps CORE_TYPES.T_EDIT_STEPS;
    l_current_round NUMBER := ;
    
    CURSOR c_apps IS
        SELECT APP_ID FROM CFG_QUESTIONNAIRES WHERE APP_SID IN (1,4);
    
    CURSOR c_entry_steps(pi_app_id IN VARCHAR2, pi_round_sid IN NUMBER) IS
         SELECT ENTRY_SID, EDIT_STEP_SID
           FROM ENTRY_EDIT_STEPS
          WHERE ENTRY_SID IN (SELECT ENTRY_SID 
                                FROM ENTRIES 
                               WHERE APP_ID = pi_app_id
                              )
            AND ROUND_SID = pi_round_sid;
         
        
    CURSOR c_qstnnr_status(pi_app_id IN VARCHAR2) IS
         SELECT 7 AS STATUS_SID, COUNTRY_ID, QUESTIONNAIRE_SID 
           FROM QSTNNR_CTY_STATUS
          WHERE QUESTIONNAIRE_SID IN (SELECT QUESTIONNAIRE_SID 
                                        FROM CFG_QUESTIONNAIRES 
                                       WHERE APP_ID = pi_app_id);

    CURSOR c_indices_data(pi_app_id IN VARCHAR2) IS 
         SELECT S.INDEX_SID, S.COUNTRY_ID, S.ROUND_SID, S.STAGE_SID, S.LDAP_LOGIN, S.ORGANISATION, S.DATETIME, S.ITERATION
         FROM INDEX_CALC_STAGES S,
             CFG_INDEXES I,
             CFG_QUESTIONNAIRES Q
         WHERE S.INDEX_SID = I.INDEX_SID
         AND I.QUESTIONNAIRE_SID = Q.QUESTIONNAIRE_SID
         AND Q.APP_ID = pi_app_id;    

    CURSOR c_scores_data(pi_app_id IN VARCHAR2) IS 
         SELECT S.ENTRY_CRITERIA_SID, S.ENTRY_SID, S.CRITERION_SID, S.SCORE_VERSION_SID, S.SCORE, S.LDAP_LOGIN, S.DATETIME, S.ORGANISATION, S.ROUND_SID
         FROM ENTRY_CRITERIA S,
             ENTRIES I
         WHERE S.ENTRY_SID = I.ENTRY_SID
         AND I.APP_ID = pi_app_id
         AND S.ENTRY_CRITERIA_SID NOT IN (SELECT ENTRY_CRITERIA_SID FROM ENTRY_CRITERIA_ARCH);    
BEGIN
    SAVEPOINT prepareNewRound;
    FOR app IN c_apps LOOP
        --Create the vintage
        SAVEPOINT createVintage;
        BEGIN
            cfg_vintages.createVintageApp(app.app_id, l_round_sid, l_year, l_is_archive);
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO createVintage;
                CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'createVintageApp error for '|| app.app_id, SQLERRM, SYSDATE);
        END;
         
         --insert entry choices in archive tables
         SAVEPOINT archiveEntryChoices;
         BEGIN
            INSERT INTO ENTRY_CHOICES_ARCH(ROUND_SID, ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS, ASSESSMENT_PERIOD)
            SELECT l_round_sid, ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS, ASSESSMENT_PERIOD FROM ENTRY_CHOICES WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = app.app_id);
         EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO archiveEntryChoices;
                CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'archiveEntryChoices error for '|| app.app_id, SQLERRM, SYSDATE);
        END;
        
        --insert choices additional infos in archive tables
        SAVEPOINT archiveEntryChoicesAddInfos;
        BEGIN
            INSERT INTO ENTRY_CHOICES_ADD_INFOS_ARCH(ROUND_SID, ENTRY_SID, QUESTION_VERSION_SID, DESCR, PERIOD_SID)
            SELECT l_round_sid, ENTRY_SID, QUESTION_VERSION_SID, DESCR, PERIOD_SID FROM ENTRY_CHOICES_ADD_INFOS WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = app.app_id);
        EXCEPTION
           WHEN OTHERS THEN
               ROLLBACK TO archiveEntryChoicesAddInfos;
               CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'archiveEntryChoicesAddInfos error for '|| app.app_id, SQLERRM, SYSDATE);
        END;
        
        --insert entry targets in archive tables
        SAVEPOINT archiveEntryTargets;
        BEGIN
            INSERT INTO TARGET_ENTRIES_ARCH(ROUND_SID, ENTRY_SID, QUESTION_VERSION_SID, RESPONSE_SID, VALUE, NOT_APPLICABLE, DESCR)
            SELECT l_round_sid, ENTRY_SID, QUESTION_VERSION_SID, RESPONSE_SID, VALUE, NOT_APPLICABLE, DESCR FROM TARGET_ENTRIES WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = app.app_id);
        EXCEPTION
           WHEN OTHERS THEN
               ROLLBACK TO archiveEntryTargets;
               CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'archiveEntryTargets error for '|| app.app_id, SQLERRM, SYSDATE);
        END;
        
        --prepare entries for update step for new round
        SAVEPOINT entryEditSteps;
        BEGIN
            FOR r_entry IN c_entry_steps(app.app_id, l_round_sid) LOOP
                INSERT INTO ENTRY_EDIT_STEPS(ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID)
                VALUES (r_entry.ENTRY_SID, t_edit_steps.UPD, l_current_round, 'AUT ROUND UPD', TRUNC(SYSDATE), t_edit_steps.CPL);
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK TO entryEditSteps;
               CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'entryEditSteps error for '|| app.app_id, SQLERRM, SYSDATE);
        END;
        
        --Prepare questionnaire status
        SAVEPOINT questionnaireStatus;
        BEGIN
            FOR r_status IN c_qstnnr_status(app.app_id) LOOP
                INSERT INTO QSTNNR_CTY_STATUS(STATUS_SID, COUNTRY_ID, QUESTIONNAIRE_SID, ROUND_SID, SUBMIT_LOGIN, SUBMIT_DATE)
                VALUES (r_status.STATUS_SID, r_status.COUNTRY_ID, r_status.QUESTIONNAIRE_SID, l_current_round, 'AUT ROUND UPD', TRUNC(SYSDATE));
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK TO questionnaireStatus;
               CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'questionnaireStatus error for '|| app.app_id, SQLERRM, SYSDATE);
        END;
        
        
        --Archive indices
        SAVEPOINT archiveIndices;
        BEGIN
            FOR rec IN c_indices_data(app.app_id) LOOP
                 INSERT INTO INDEX_CALC_STAGES_ARCH(INDEX_SID, COUNTRY_ID, ROUND_SID, STAGE_SID, LDAP_LOGIN, ORGANISATION, DATETIME, ITERATION)
                 VALUES (rec.INDEX_SID, rec.COUNTRY_ID, rec.ROUND_SID, rec.STAGE_SID, rec.LDAP_LOGIN, rec.ORGANISATION, rec.DATETIME, rec.ITERATION);

                 DELETE FROM INDEX_CALC_STAGES
                 WHERE INDEX_SID = rec.INDEX_SID
                 AND COUNTRY_ID = rec.COUNTRY_ID
                 AND ROUND_SID = rec.ROUND_SID
                 AND STAGE_SID = rec.STAGE_SID
                 AND LDAP_LOGIN = rec.LDAP_LOGIN
                 AND ORGANISATION = rec.ORGANISATION
                 AND DATETIME = rec.DATETIME
                 AND ITERATION = rec.ITERATION;
             END LOOP;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK TO archiveIndices;
               CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'archiveIndices error for '|| app.app_id, SQLERRM, SYSDATE);
         END;
         
         --Archive scores
        SAVEPOINT archiveScores;
        BEGIN
            FOR rec IN c_scores_data(app.app_id) LOOP
               INSERT INTO ENTRY_CRITERIA_ARCH(ENTRY_CRITERIA_SID, ENTRY_SID, CRITERION_SID, SCORE_VERSION_SID, SCORE, LDAP_LOGIN, DATETIME, ORGANISATION, ROUND_SID, ROUND_SID_ARCH)
               VALUES (rec.ENTRY_CRITERIA_SID, rec.ENTRY_SID, rec.CRITERION_SID, rec.SCORE_VERSION_SID, rec.SCORE, rec.LDAP_LOGIN, rec.DATETIME, rec.ORGANISATION, rec.ROUND_SID, l_current_round);
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO archiveScores;
                CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'archiveScores error for '|| app.app_id, SQLERRM, SYSDATE);
        END;
         
         
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO prepareNewRound;
        CORE_TYPES.LOG_INFO_FAIL('Prepare round script', 'prepareNewRound error for all', SQLERRM, SYSDATE);
END;