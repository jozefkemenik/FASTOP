DECLARE
    l_qstnnr_version_sid NUMBER;
    l_question_sid NUMBER;

BEGIN
    SELECT APP_ID INTO l_qstnnr_version_sid FROM CFG_QUESTIONNAIRES WHERE APP_ID = 'PIM';
    
    INSERT INTO CFG_CUSTOM_HEADERS(CUSTOM_HEADER_ID, QSTNNR_VERSION_SID, WIDTH, ORDER_BY, IN_QUESTIONNAIRE)
    VALUES ('AVAILABILITY', l_qstnnr_version_sid, 100, 1, 'Status');
    INSERT INTO CFG_CUSTOM_HEADERS(CUSTOM_HEADER_ID, QSTNNR_VERSION_SID, WIDTH, ORDER_BY, IN_QUESTIONNAIRE)
    VALUES ('ENTRY_VERSION', l_qstnnr_version_sid, 75, 2, 'Version');

    SELECT QUESTION_VERSION_SID INTO l_question_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Types of strategic investment plans?');
    
    INSERT INTO CFG_HEADERS(QSTNNR_VERSION_SID, QUESTION_VERSION_SID, SHORT, WIDTH, MAPPING_TYPE, ORDER_BY, IN_QUESTIONNAIRE)
    VALUES (l_qstnnr_version_sid, l_question_sid, 'Types of strategic investment plans', 170, 'id', 1, 1);

EXCEPTION
    WHEN OTHERS THEN
        CORE_JOBS.LOG_INFO_FAIL('Insert in cfg_custom_headers script', 'Smth went wrong', SQLERRM, trunc(SYSDATE));
        ROLLBACK;
END;
/