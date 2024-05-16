DECLARE
    
    l_qstnnr_sid NUMBER;
    l_qstnnr_version_sid NUMBER; 
    l_elem_type_sid NUMBER;
    l_default_step VARCHAR2(40 BYTE) := 'DEFAULT';
    l_app_id VARCHAR2(40 BYTE) := 'PIM';
    l_cpl_step_sid NUMBER;
    l_new_step_sid NUMBER;
    l_entry_sid NUMBER;
    
    l_round_sid NUMBER;
    CURSOR c_ctys IS
    SELECT DISTINCT COUNTRY_ID FROM qstnnr_cty_status WHERE QUESTIONNAIRE_SID = 2 AND COUNTRY_ID != 'UK' ORDER BY 1;
BEGIN
    --Insert new questionnaire
    INSERT INTO CFG_QUESTIONNAIRES(APP_ID, DESCR) VALUES (l_app_id, 'Public Investment Management')
    RETURNING QUESTIONNAIRE_SID INTO l_qstnnr_sid;
    --Insert new version
    INSERT INTO CFG_QSTNNR_VERSIONS(QUESTIONNAIRE_SID, COUNTRY_GROUP_ID) VALUES (l_qstnnr_sid, 'EU')
    RETURNING QSTNNR_VERSION_SID INTO l_qstnnr_version_sid;
    
    --Get specific qstnnr element types and add the corresponding data
    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = 'QSTNNR_MAIN_HEADER';
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'Public Investment Management questionnaire', l_qstnnr_version_sid, l_default_step);
    
    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = 'NO_CHANGE_BTN';
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'No Change since {YEAR2}', l_qstnnr_version_sid, l_default_step);
    
    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = 'NO_CHANGE_TIP';
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'In case all the elements of the PIM framework have remained the same since last survey update', l_qstnnr_version_sid, l_default_step);
    
    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = 'REFORM_BTN';
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'Reformed/modified since {YEAR2}', l_qstnnr_version_sid, l_default_step);
    
    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = 'REFORM_TIP';
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'In case any element of the PIM framework was changed', l_qstnnr_version_sid, l_default_step);
    
    --Add cfg for Details Btn
    INSERT INTO CFG_UI_ELEMENT_TYPES(ELEMENT_TYPE_ID, DESCR)
    VALUES ('DETAILS_BTN', 'Label for Details Btn on questionnaire')
    RETURNING ELEMENT_TYPE_SID INTO l_elem_type_sid;
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'Details', l_qstnnr_version_sid, l_default_step);
    --for other questionnaires the same
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (l_elem_type_sid, 'Details', 1, l_default_step);
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (l_elem_type_sid, 'Details', 2, l_default_step);
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (l_elem_type_sid, 'Details', 3, l_default_step);
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (l_elem_type_sid, 'Details', 4, l_default_step);
    
    INSERT INTO CFG_UI_ELEMENT_TYPES(ELEMENT_TYPE_ID, DESCR)
    VALUES ('DETAILS_TIP', 'Help text for Details Btn on questionnaire')
    RETURNING ELEMENT_TYPE_SID INTO l_elem_type_sid;
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'Please click here to review the answers from the previous survey', l_qstnnr_version_sid, l_default_step);
    --for other questionnaires leave it empty
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (l_elem_type_sid, '', 1, l_default_step);
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (l_elem_type_sid, '', 2, l_default_step);
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (l_elem_type_sid, '', 3, l_default_step);
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (l_elem_type_sid, '', 4, l_default_step);
    --Help Legends
    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = 'FAB_TEXT_OVERVIEW';
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'To start 	Press ' || chr(39) || 'details' || chr(39) || ' to review the answers (excluding annually updated questions) from the previous survey. ;
Press ' || chr(39) || 'no change since {YEAR2}' || chr(39) || ' if there was not any practical or legal change for your institution during the year. In this case, no changes can be made to the answers apart from the annually updated questions. ;
Press ' || chr(39) || 'reformed/modified since {YEAR2}' || chr(39) || ' in case there was a legal reform or change in practice with regard to your institution. Please indicate the nature of the reform or change in practice in the pop-up screen. ;
Please, note that no further changes can be made after completion. In case you spot a mistake after completion or submission, please send an email to:  PIM@ec.europa.eu 
', l_qstnnr_version_sid, l_default_step);

    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = 'FAB_TEXT_ENTRY';
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, '*  		Questions with a ' || chr(39) || '*' || chr(39) || ' at the end are mandatory questions. ;
Help text	An explanation is shown, when hovering the mouse over the name of a question. ;
Save as PDF	Press ' || chr(39) || 'Save as PDF' || chr(39) || ' (top right) to download your answers to this questionnaire. ;
Saving 		Please, note that after answering a question your answer is automatically saved. ;
Complete	Press ' || chr(39) || 'Complete' || chr(39) || ' (top right) to finalize the questionnaire.;
Red text    The name of a question turns red if the answer is changed vis-à-vis last survey.;
Please, note that no further changes can be made after completion. In case you spot a mistake after completion or submission, please send an email to:  PIM@ec.europa.eu ', l_qstnnr_version_sid, l_default_step);

    UPDATE CFG_UI_QSTNNR_ELEMENTS
      SET ELEMENT_TEXT = ELEMENT_TEXT || ';
Red text    The name of a question turns red if the answer is changed vis-à-vis last survey.
' WHERE ELEMENT_TYPE_SID = l_elem_type_sid AND QSTNNR_VERSION_SID != l_qstnnr_version_sid;

    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = 'VINTAGE_HEADER_INFO_MSG';
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'Do not use this data in public/external communication (incl. visualisations, presentations, working documents, etc.) without an EXPLICIT prior check and permission by ECFIN. Please email to [ecfin-fiscalframework@ec.europa.eu] or to [ECFIN-PIM@ec.europa.eu] for any questions, data requests or permission to use data.', 
    l_qstnnr_version_sid, l_default_step);

    --get the round
    SELECT ROUND_SID INTO l_round_sid FROM VW_ROUNDS WHERE YEAR = 2022 AND PERIOD_ID = 'SPR';
    --get edit steps
    SELECT EDIT_STEP_SID INTO l_new_step_sid FROM CFG_EDIT_STEPS WHERE EDIT_STEP_ID = 'NEW';
    SELECT EDIT_STEP_SID INTO l_cpl_step_sid FROM CFG_EDIT_STEPS WHERE EDIT_STEP_ID = 'CPL';
    --Add the list of entries
    FOR rec IN c_ctys LOOP
        --Entries  
        INSERT INTO ENTRIES(ENTRY_NO, ENTRY_VERSION, COUNTRY_ID, APP_ID, APPRV_DATE, IMPL_DATE)
        VALUES (1, 1, rec.COUNTRY_ID, l_app_id, TO_DATE('2021/01/01', 'yyyy/mm/dd'), TO_DATE('2021/02/01', 'yyyy/mm/dd'))
        RETURNING ENTRY_SID INTO l_entry_sid;
        --Edit steps
        INSERT INTO ENTRY_EDIT_STEPS(ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE, PREV_STEP_SID)
        VALUES (l_entry_sid, l_cpl_step_sid, l_round_sid, 'INITIAL UPLOAD', TRUNC(SYSDATE),  l_new_step_sid);
        --Qstnnr cty status
        INSERT INTO QSTNNR_CTY_STATUS(STATUS_SID, COUNTRY_ID, QUESTIONNAIRE_SID, ROUND_SID, SUBMIT_LOGIN, SUBMIT_DATE)
        VALUES (3, rec.COUNTRY_ID, l_qstnnr_sid, l_round_sid, 'INITIAL UPLOAD', TRUNC(SYSDATE));
    END LOOP;

    COMMIT;   
EXCEPTION
    WHEN OTHERS THEN
        CORE_JOBS.LOG_INFO_FAIL('Add cfg script', 'Smth went wrong', SQLERRM, trunc(SYSDATE));
        ROLLBACK;
END;
/