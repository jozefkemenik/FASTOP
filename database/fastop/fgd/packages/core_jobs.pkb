CREATE OR REPLACE PACKAGE BODY CORE_JOBS
AS
    PROCEDURE LOG_INFO_SUCC(pi_proc IN VARCHAR2, pi_msg IN VARCHAR2, pi_date IN DATE)
    IS
    BEGIN
        INSERT INTO LOG_INFO_SUCC(PROC_NAME, INFO_MSG, DATETIME)
        VALUES (pi_proc, pi_msg, pi_date);
        COMMIT;
    END; 

    PROCEDURE LOG_INFO_FAIL(pi_proc IN VARCHAR2, pi_msg IN VARCHAR2, pi_err_msg IN VARCHAR2, pi_date IN DATE)
    IS
    BEGIN
        INSERT INTO LOG_INFO_FAIL(PROC_NAME, INFO_MSG, ERROR_MSG, DATETIME)
        VALUES (pi_proc, pi_msg, pi_err_msg, pi_date);
        COMMIT;
    END;

    PROCEDURE INFO_MAIL(pi_proc IN VARCHAR2, pi_msg IN VARCHAR2, pi_status IN VARCHAR2, pi_recipient IN VARCHAR2)
    IS
        mailhost    VARCHAR2(30)   := 'smtpmail.cec.eu.int';
        l_sender    VARCHAR2(200)  := 'automated-notifications@nomail.ec.europa.eu';
        l_subject   VARCHAR2(200);
        l_message   VARCHAR2(2000);
        l_recipient VARCHAR2(200) := pi_recipient || '; Constantin-Mihai.stefan@ext.ec.europa.eu';

        mail_conn utl_smtp.connection;
        crlf VARCHAR2(2) := CHR(13)||CHR(10);
        msg VARCHAR2(4000);
    BEGIN
        l_subject := pi_proc || ' - Status:  '|| pi_status ;
        l_message := 'This email is an automated notification. Please do not not reply.

        ' || pi_msg || '

        Kind regards,
        ECFIN.R.3 - FGD team'; 
        mail_conn := utl_smtp.open_connection(mailhost,25);
        msg := 'Date: '||to_char(sysdate,'dd Mon yy hh24:mi:ss' )||crlf||
               'From: '||l_sender||'>'||crlf||'Subject: '||l_subject||crlf||
               'To: '||l_recipient||crlf||crlf||l_message;
        utl_smtp.helo(mail_conn,mailhost);
        utl_smtp.mail(mail_conn,l_sender);
        utl_smtp.rcpt(mail_conn,l_recipient);
        utl_smtp.data(mail_conn,msg);
        utl_smtp.quit(mail_conn);
        null;
        
    END;

    -- PROCEDURE ARCHIVE_ANSWERS(pi_app_id IN VARCHAR2, pi_round_sid IN VARCHAR2)
    -- IS
    --     l_year NUMBER;
    -- BEGIN
    --     SELECT YEAR INTO l_year FROM VW_ROUNDS WHERE ROUND_SID = pi_round_sid;
    --     --Create the vintage
    --     cfg_vintages.createVintageApp(pi_app_id, pi_round_sid, l_year, false);
    --     --insert all the answers in archive tables
    --     INSERT INTO ENTRY_CHOICES_ARCH(ROUND_SID, ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS, ASSESSMENT_PERIOD)
    --     SELECT pi_round_sid, ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS, ASSESSMENT_PERIOD FROM ENTRY_CHOICES WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = pi_app_id);
        
    --     INSERT INTO ENTRY_CHOICES_ADD_INFOS_ARCH(ROUND_SID, ENTRY_SID, QUESTION_VERSION_SID, DESCR, PERIOD_SID)
    --     SELECT pi_round_sid, ENTRY_SID, QUESTION_VERSION_SID, DESCR, PERIOD_SID FROM ENTRY_CHOICES_ADD_INFOS WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = pi_app_id);
        
    --     INSERT INTO TARGET_ENTRIES_ARCH(ROUND_SID, ENTRY_SID, QUESTION_VERSION_SID, RESPONSE_SID, VALUE, NOT_APPLICABLE, DESCR)
    --     SELECT pi_round_sid, ENTRY_SID, QUESTION_VERSION_SID, RESPONSE_SID, VALUE, NOT_APPLICABLE, DESCR FROM TARGET_ENTRIES WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = pi_app_id);
    -- END;

    -- PROCEDURE PREPARE_QSTNNR(pi_app_id IN VARCHAR2, pi_round_sid IN VARCHAR2)
    -- IS
    --     CURSOR c_entry_steps IS
    --     SELECT ENTRY_SID, EDIT_STEP_SID FROM ENTRY_EDIT_STEPS
    --     WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = pi_app_id)
    --     AND ROUND_SID = pi_round_sid;
    --     t_edit_steps CORE_TYPES.T_EDIT_STEPS;
        
    --     CURSOR c_qstnnr_status IS
    --     SELECT 7 AS STATUS_SID, COUNTRY_ID, QUESTIONNAIRE_SID FROM QSTNNR_CTY_STATUS
    --     WHERE QUESTIONNAIRE_SID IN (SELECT QUESTIONNAIRE_SID FROM CFG_QUESTIONNAIRES WHERE APP_ID = pi_app_id);

    --     l_current_round NUMBER;
    -- BEGIN
    --     l_current_round := CORE_GETTERS.getCurrentRoundSid(pi_app_id);
    --     FOR r_entry IN c_entry_steps LOOP
    --         INSERT INTO ENTRY_EDIT_STEPS(ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID)
    --         VALUES (r_entry.ENTRY_SID, t_edit_steps.UPD, l_current_round, 'AUT ROUND UPD', TRUNC(SYSDATE), t_edit_steps.CPL);
    --     END LOOP;
    --     FOR r_status IN c_qstnnr_status LOOP
    --         INSERT INTO QSTNNR_CTY_STATUS(STATUS_SID, COUNTRY_ID, QUESTIONNAIRE_SID, ROUND_SID, SUBMIT_LOGIN, SUBMIT_DATE)
    --         VALUES (r_status.STATUS_SID, r_status.COUNTRY_ID, r_status.QUESTIONNAIRE_SID, l_current_round, 'AUT ROUND UPD', TRUNC(SYSDATE));
    --     END LOOP;
    -- END;

    -- PROCEDURE ARCHIVE_INDICES(pi_app_id IN VARCHAR2)
    -- IS
    --     CURSOR c_data IS 
    --     SELECT S.INDEX_SID, S.COUNTRY_ID, S.ROUND_SID, S.STAGE_SID, S.LDAP_LOGIN, S.ORGANISATION, S.DATETIME, S.ITERATION
    --     FROM INDEX_CALC_STAGES S,
    --         CFG_INDEXES I,
    --         CFG_QUESTIONNAIRES Q
    --     WHERE S.INDEX_SID = I.INDEX_SID
    --     AND I.QUESTIONNAIRE_SID = Q.QUESTIONNAIRE_SID
    --     AND Q.APP_ID = pi_app_id;
            
    -- BEGIN
    --     FOR rec IN c_data LOOP
    --         INSERT INTO INDEX_CALC_STAGES_ARCH(INDEX_SID, COUNTRY_ID, ROUND_SID, STAGE_SID, LDAP_LOGIN, ORGANISATION, DATETIME, ITERATION)
    --         VALUES (rec.INDEX_SID, rec.COUNTRY_ID, rec.ROUND_SID, rec.STAGE_SID, rec.LDAP_LOGIN, rec.ORGANISATION, rec.DATETIME, rec.ITERATION);
    --         COMMIT;
    --         DELETE FROM INDEX_CALC_STAGES
    --         WHERE INDEX_SID = rec.INDEX_SID
    --         AND COUNTRY_ID = rec.COUNTRY_ID
    --         AND ROUND_SID = rec.ROUND_SID
    --         AND STAGE_SID = rec.STAGE_SID
    --         AND LDAP_LOGIN = rec.LDAP_LOGIN
    --         AND ORGANISATION = rec.ORGANISATION
    --         AND DATETIME = rec.DATETIME
    --         AND ITERATION = rec.ITERATION;
    --         COMMIT;
    --     END LOOP;
    -- END;  

    -- PROCEDURE ARCHIVE_SCORES(pi_app_id IN VARCHAR2, pi_round_sid IN NUMBER)
    -- IS
    --     CURSOR c_data IS 
    --     SELECT S.ENTRY_CRITERIA_SID, S.ENTRY_SID, S.CRITERION_SID, S.SCORE_VERSION_SID, S.SCORE, S.LDAP_LOGIN, S.DATETIME, S.ORGANISATION, S.ROUND_SID
    --     FROM ENTRY_CRITERIA S,
    --         ENTRIES I
    --     WHERE S.ENTRY_SID = I.ENTRY_SID
    --     AND I.APP_ID = pi_app_id
    --     AND S.ENTRY_CRITERIA_SID NOT IN (SELECT ENTRY_CRITERIA_SID FROM ENTRY_CRITERIA_ARCH);
            
    -- BEGIN
    --     FOR rec IN c_data LOOP
    --         INSERT INTO ENTRY_CRITERIA_ARCH(ENTRY_CRITERIA_SID, ENTRY_SID, CRITERION_SID, SCORE_VERSION_SID, SCORE, LDAP_LOGIN, DATETIME, ORGANISATION, ROUND_SID, ROUND_SID_ARCH)
    --         VALUES (rec.ENTRY_CRITERIA_SID, rec.ENTRY_SID, rec.CRITERION_SID, rec.SCORE_VERSION_SID, rec.SCORE, rec.LDAP_LOGIN, rec.DATETIME, rec.ORGANISATION, rec.ROUND_SID, pi_round_sid);
    --     END LOOP;
    --     COMMIT;
    -- END; 

    -- PROCEDURE roundCheckJob
    -- IS
    --     l_period_start_date DATE;
    --     l_app_sid           NUMBER;
    --     l_period_sid        NUMBER;
    --     l_curr_date         DATE;
    --     l_next_round        NUMBER;
    --     l_curr_round        NUMBER;
    --     l_proc              VARCHAR2(200 BYTE) := 'roundCheckJob';

    --     l_c4_recip          VARCHAR2(200 BYTE) := 'Martijn.HOOGELAND1@ec.europa.eu';
    --     l_r3_recip          VARCHAR2(200 BYTE) := 'Constantin-Mihai.Stefan@ext.ec.europa.eu';
        
    --     CURSOR c_qstnnrs IS
    --     SELECT QUESTIONNAIRE_SID, APP_ID FROM CFG_QUESTIONNAIRES;
    -- BEGIN
    --     l_curr_date := TO_DATE(TO_CHAR(TRUNC(SYSDATE), 'MM/DD'), 'MM/DD');
    --     LOG_INFO_SUCC(l_proc, 'Starting round check ', SYSDATE);
    --     FOR r_qstnnr IN c_qstnnrs LOOP
    --         --Get current round from the entry steps
    --         SELECT MAX(ROUND_SID) INTO l_curr_round FROM ENTRY_EDIT_STEPS WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = r_qstnnr.APP_ID);

    --         --Get application SID from FASTOP schema for each qstnnr
    --         BEGIN    
    --             SELECT APP_SID INTO l_app_sid FROM APPLICATIONS WHERE APP_ID = r_qstnnr.APP_ID;
    --         EXCEPTION
    --         WHEN OTHERS THEN
    --             --LOG MESSAGE AND SEND EMAIL
    --             LOG_INFO_FAIL(l_proc, 'APP_SID not found for qstnnr '||r_qstnnr.APP_ID, SQLERRM, SYSDATE);
    --             INFO_MAIL(l_proc, 'APP_SID not found for qstnnr '||r_qstnnr.APP_ID, 'ERROR', l_r3_recip);
    --         END;
            
    --         --Get the start date of the period defined for each application from the FASTOP schema
    --         BEGIN
    --             SELECT TO_DATE(P.START_DATE, 'MM/DD'), P.PERIOD_SID
    --             INTO l_period_start_date, l_period_sid
    --             FROM PERIODS P,
    --                 PERIOD_APPLICATIONS PA
    --             WHERE PA.PERIOD_SID = P.PERIOD_SID
    --             AND PA.APP_SID = l_app_sid;
    --         EXCEPTION
    --         WHEN OTHERS THEN
    --             --LOG MESSAGE AND SEND EMAIL
    --             LOG_INFO_FAIL(l_proc, 'PERIOD_SID not found for qstnnr '||r_qstnnr.APP_ID, SQLERRM, SYSDATE);
    --             INFO_MAIL(l_proc, 'PERIOD_SID not found for qstnnr '||r_qstnnr.APP_ID, 'ERROR', l_r3_recip);
    --         END;
            
    --         --Check current date against date set as startDate for the specific period
    --         --When there are 1 to 10 days left, send info email and check if the next round was activated
    --         --When the current date is the same as the startDate of specific period, prepare the next round for the specific qstnnr if the round was activated
    --         IF l_period_start_date - l_curr_date > 10 THEN
    --             --Nothing to do
    --             LOG_INFO_SUCC(l_proc, 'There are '|| to_char(l_period_start_date - l_curr_date) ||' days left until period starts for APP '||r_qstnnr.APP_ID, SYSDATE);
    --         ELSIF l_period_start_date - l_curr_date BETWEEN 1 AND 10 THEN
    --             LOG_INFO_SUCC(l_proc, TO_CHAR(l_period_start_date - l_curr_date)|| ' days left until period starts for APP '||r_qstnnr.APP_ID, SYSDATE);
                
    --             --Check if the round was activated
    --             BEGIN
    --                 SELECT ROUND_SID INTO l_next_round
    --                 FROM VW_ROUNDS
    --                 WHERE PERIOD_SID = l_period_sid
    --                 AND YEAR = TO_CHAR(TRUNC(SYSDATE), 'YYYY');
    --             EXCEPTION
    --                 WHEN OTHERS THEN
    --                 --LOG MESSAGE AND SEND EMAIL
    --                 NULL;
    --             END;
    --             --If there is a next_round defined, log info message
    --             IF l_next_round IS NOT NULL THEN
    --                 --Log info message
    --                 LOG_INFO_SUCC(l_proc, 'Next round is not yet defined', SYSDATE);
    --                 INFO_MAIL(l_proc, 'Next round is not yet defined for APP '||r_qstnnr.APP_ID ||'. There are '||TO_CHAR(l_curr_date - l_period_start_date)||
    --                      ' days left until period starts for APP '||r_qstnnr.APP_ID, 'WARN', l_c4_recip);
    --             ELSE
    --                 --email info and log
    --                 LOG_INFO_SUCC(l_proc, 'Next round is defined ', SYSDATE);
    --                 INFO_MAIL(l_proc, 'Next round is defined for APP '||r_qstnnr.APP_ID, 'INFO', l_c4_recip);
    --             END IF;
    --         ELSIF l_period_start_date - l_curr_date = 0 THEN
    --             --Check if the round was activated
    --             BEGIN
    --                 SELECT ROUND_SID INTO l_next_round
    --                 FROM VW_ROUNDS
    --                 WHERE PERIOD_SID = l_period_sid
    --                 AND YEAR = TO_CHAR(TRUNC(SYSDATE), 'YYYY');
    --             EXCEPTION
    --                 WHEN OTHERS THEN
    --                 --LOG MESSAGE AND SEND EMAIL
    --                 LOG_INFO_FAIL(l_proc, 'Next round is defined ', SQLERRM, SYSDATE);
    --                 INFO_MAIL(l_proc, 'Next round is defined for APP '||r_qstnnr.APP_ID, 'INFO', l_c4_recip);
    --             END;
    --             IF l_next_round IS NULL THEN
    --                 --email info and log
    --                 LOG_INFO_SUCC(l_proc, 'Next round is not yet defined', SYSDATE);
    --                 INFO_MAIL(l_proc, 'Next round is not yet defined for APP '||r_qstnnr.APP_ID ||'. There are '||TO_CHAR(l_curr_date - l_period_start_date)||
    --                      ' days left until period starts for APP '||r_qstnnr.APP_ID, 'WARN', l_c4_recip);
    --             ELSE
    --                 --Archive current answers
    --                 archive_answers(r_qstnnr.APP_ID, l_curr_round);
    --                 LOG_INFO_SUCC(l_proc, 'Answers for APP '|| r_qstnnr.APP_ID || ' archived succesfully', SYSDATE);
    --                 --Archive scores
    --                 archive_scores(r_qstnnr.APP_ID, l_curr_round);
    --                 LOG_INFO_SUCC(l_proc, 'Scores for APP '|| r_qstnnr.APP_ID || ' archived succesfully', SYSDATE);
    --                 --Archive indices
    --                 archive_indices(r_qstnnr.APP_ID);
    --                 LOG_INFO_SUCC(l_proc, 'Indices for APP '|| r_qstnnr.APP_ID || ' archived succesfully', SYSDATE);
    --                 --Run procedure for preparing qstnnr for next round
    --                 prepare_qstnnr(r_qstnnr.APP_ID, l_curr_round);
    --                 LOG_INFO_SUCC(l_proc, 'APP '|| r_qstnnr.APP_ID || ' is ready for next round', SYSDATE);
    --                 --prepare vintages
    --                 -- prepareVintages(r_qstnnr.APP_ID, l_curr_round);
    --                 -- LOG_INFO_SUCC(l_proc, 'Vintage for '|| r_qstnnr.APP_ID || ' is ready for next round', SYSDATE);
    --             END IF;
    --         END IF;
        
    --     END LOOP;
    --     LOG_INFO_SUCC(l_proc, 'Finished round check ', SYSDATE);
    -- END;
    
    -- PROCEDURE prepareVintages(pi_app_id IN VARCHAR2, pi_round_sid IN NUMBER)
    -- IS
    --     l_proc_name VARCHAR2(200 BYTE) := 'prepareVintages';
    --     l_year      NUMBER;
    --     l_tab_name  VARCHAR2(200 BYTE);
    --     l_upd_stat  VARCHAR2(2000 BYTE);
    --     l_debug     NUMBER;
    --     l_cust_msg  VARCHAR2(2000 BYTE) := 'There was an issue at code ';

    --     CURSOR c_cols IS
    --     SELECT VINTAGE_ATTR_SID FROM CFG_VINTAGE_ATTRIBUTES
    --      WHERE APP_ID = pi_app_id
    --        AND ADMIN_ONLY = 1; 
    -- BEGIN
    --     --GET THE YEAR BASED ON ROUND_SID
    --     SELECT YEAR INTO l_year FROM VW_ROUNDS WHERE ROUND_SID = pi_round_sid;

    --     --COMPOSE TABLE_NAME
    --     l_tab_name := 'VINTAGE_' || pi_app_id || '_' || l_year;

    --     --LOOP RECORDS
    --     FOR rec IN c_cols LOOP
    --         l_debug := 100;
    --         --SET COLUMN TO NULL
    --         l_upd_stat := 'UPDATE '||l_tab_name ||' SET COL'||rec.VINTAGE_ATTR_SID||' = NULL';
    --         BEGIN
    --             l_debug := 110;
    --             EXECUTE IMMEDIATE l_upd_stat;
    --         EXCEPTION
    --             WHEN OTHERS THEN
    --                 LOG_INFO_FAIL(l_proc_name, l_cust_msg|| l_debug, SQLERRM, sysdate);
    --         END;
    --         l_debug := 120;
    --         --DROP COLUMN
    --         l_upd_stat := 'ALTER TABLE '||l_tab_name|| ' DROP COLUMN COL'|| rec.VINTAGE_ATTR_SID;

    --         BEGIN
    --             l_debug := 130;
    --             EXECUTE IMMEDIATE l_upd_stat;
    --         EXCEPTION
    --             WHEN OTHERS THEN
    --                 LOG_INFO_FAIL(l_proc_name, l_cust_msg|| l_debug, SQLERRM, sysdate);
    --         END;
    --     END LOOP;
    -- EXCEPTION
    --     WHEN OTHERS THEN
    --         LOG_INFO_FAIL(l_proc_name, 'General issue', SQLERRM, sysdate);
    -- END;
END;