DECLARE
    CURSOR C_ELEMS
    IS
    SELECT * FROM FGD_CFG_UI_ELEMENTS;
BEGIN
    FOR rec IN C_ELEMS
    LOOP
        INSERT INTO CFG_UI_ELEMENT_TYPES(ELEMENT_TYPE_ID, DESCR)
        VALUES (rec.ELEMENT_ID, rec.DESCR);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('MIG CFG_UI_ELEMENT_TYPES FAIL', sysdate, sqlerrm(), 0);
END;
/
DECLARE
    
    CURSOR c_qst_elems
    IS
    SELECT A.ELEMENT_SID, A.ELEMENT_TEXT, B.QSTNNR_VERSION_SID, A.EDIT_STEP_ID
    FROM FGD_CFG_UI_QST_ELEMENTS A, CFG_QSTNNR_VERSIONS B
    WHERE A.QUESTIONNAIRE_SID = B.QUESTIONNAIRE_SID;

BEGIN
    FOR rec IN c_qst_elems
    LOOP
        INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
        VALUES (rec.ELEMENT_SID, rec.ELEMENT_TEXT, rec.QSTNNR_VERSION_SID, rec.EDIT_STEP_ID);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('MIG CFG_UI_QSTNNR_ELEMENTS FAIL', sysdate, sqlerrm(), 0);
END;
/
INSERT INTO CFG_UI_ELEMENT_TYPES (ELEMENT_TYPE_ID, DESCR) VALUES ('FAB_HELP_TEXT', 'Label for FAB'); --11
INSERT INTO CFG_UI_ELEMENT_TYPES (ELEMENT_TYPE_ID, DESCR) VALUES ('FAB_TEXT_OVERVIEW', 'Help text for Overview page');
INSERT INTO CFG_UI_ELEMENT_TYPES (ELEMENT_TYPE_ID, DESCR) VALUES ('FAB_TEXT_ENTRY', 'Help text for Entry page');
INSERT INTO CFG_UI_ELEMENT_TYPES (ELEMENT_TYPE_ID, DESCR) VALUES ('FAB_TEXT_SCORES', 'Help text for Scores page');
COMMIT;
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (11, 'HELP', 1, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (11, 'HELP', 2, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (11, 'HELP', 3, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (11, 'HELP', 4, 'DEFAULT');

INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (12, 'To start 	Press ' || chr(39) || 'details' || chr(39) || ' to review the answers (excluding compliance) from the previous year. ;
Press ' || chr(39) || 'no change in {YEAR1}' || chr(39) || ' if there was not any practical or legal change to the rule during the year. In this case, no changes can be made to the answers apart from annual compliance. ;
Press ' || chr(39) || 'reformed/modified in {YEAR1}' || chr(39) || ' in case there was a legal reform or change in practice with regard to the framework. Please indicate the nature of the reform or change in practice in the pop-up screen. ;
Submit	After completing all questionnaires, remember to press ' || chr(39) || 'submit' || chr(39) || ' in the overview screen. ;
Please, note that no further changes can be made after completion. In case you spot a mistake after completion or submission, please send an email to: ;
For Member States	 	ECFIN-FiscalFramework@ec.europa.eu ;
For candidate countries: 	ECFIN-FGDB-ENLARGEMENT-D1@ec.europa.eu
', 1, 'DEFAULT');

INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (12, 'To start 	Press ' || chr(39) || 'details' || chr(39) || ' to review the answers (excluding compliance) from the previous year. ;
Press ' || chr(39) || 'no change in {YEAR1}' || chr(39) || ' if there was not any practical or legal change for your institution during the year. In this case, no changes can be made to the answers apart from the annual developments and ad-hoc questions. ;
Press ' || chr(39) || 'reformed/modified in {YEAR1}' || chr(39) || ' in case there was a legal reform or change in practice with regard to your institution. Please indicate the nature of the reform or change in practice in the pop-up screen. ;
Please, note that no further changes can be made after completion. In case you spot a mistake after completion or submission, please send an email to:  ECFIN-FiscalFramework@ec.europa.eu 
', 2, 'DEFAULT');

INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (12, 'To start 	Press ' || chr(39) || 'details' || chr(39) || ' to review the answers (excluding compliance) from the previous year. ;
Press ' || chr(39) || 'no change in {YEAR1}' || chr(39) || ' if there was not any practical or legal change during the year. In this case, no changes can be made to the answers apart from annual compliance. ;
Press ' || chr(39) || 'reformed/modified in {YEAR1}' || chr(39) || ' in case there was a legal reform or change in practice with regard to the framework. ;
Submit	After completing the questionnaire, remember to press ' || chr(39) || 'submit' || chr(39) || ' in the overview screen. ;
Please, note that no further changes can be made after completion. In case you spot a mistake after completion or submission, please send an email to:  ECFIN-FiscalFramework@ec.europa.eu 
', 3, 'DEFAULT');

INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (12, 'To start 	Press ' || chr(39) || 'details' || chr(39) || ' to review the answers from the previous year. ;
Press ' || chr(39) || 'no change in {YEAR1}' || chr(39) || ' if there was not any practical or legal change during the year. In this case, no changes can be made to the answers. ;
Press ' || chr(39) || 'reformed/modified in {YEAR1}' || chr(39) || ' in case there was a legal reform or change in practice with regard to your green budgeting practices. Please indicate the nature of the reform or change in practice in the pop-up screen. ;
Submit	After completing your questionnaire, remember to also press ' || chr(39) || 'submit' || chr(39) || ' in the overview screen to finalise your submission. ;
Please, note that no further changes can be made after completion. In case you spot a mistake after completion or submission, please send an email to:   ECFIN-GREEN-BUDGETING-SURVEY@ec.europa
', 4, 'DEFAULT');

INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (13, '*  		Questions with a ' || chr(39) || '*' || chr(39) || ' at the end are mandatory questions. ;
Pink 		Any questions with a pink colour are used directly for the score calculation. ;
Help text	An explanation is shown, when hovering the mouse over the name of a question. ;
Save as PDF	Press ' || chr(39) || 'Save as PDF' || chr(39) || ' (top right) to download your answers to this questionnaire. ;
Saving 		Please, note that after answering a question your answer is automatically saved. ;
Complete	Press ' || chr(39) || 'Complete' || chr(39) || ' (top right) to finalize the questionnaire. 
', 1, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (13, '*  		Questions with a ' || chr(39) || '*' || chr(39) || ' at the end are mandatory questions. ;
Pink 		Any questions with a pink colour are used directly for the score calculation. ;
Help text	An explanation is shown, when hovering the mouse over the name of a question. ;
Save as PDF	Press ' || chr(39) || 'Save as PDF' || chr(39) || ' (top right) to download your answers to this questionnaire. ;
Saving 		Please, note that after answering a question your answer is automatically saved. ;
Complete	Press ' || chr(39) || 'Complete' || chr(39) || ' (top right) to finalize the questionnaire.
', 2, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (13, '*  		Questions with a ' || chr(39) || '*' || chr(39) || ' at the end are mandatory questions. ;
Pink 		Any questions with a pink colour are used directly for the score calculation. ;
Help text	An explanation is shown, when hovering the mouse over the name of a question. ;
Save as PDF	Press ' || chr(39) || 'Save as PDF' || chr(39) || ' (top right) to download your answers to this questionnaire. ;
Saving 		Please, note that after answering a question your answer is automatically saved. ;
Complete	Press ' || chr(39) || 'Complete' || chr(39) || ' (top right) to finalize the questionnaire. 
', 3, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (13, '*  		Questions with a ' || chr(39) || '*' || chr(39) || ' at the end are mandatory questions. ;
Help text	An explanation is shown, when hovering the mouse over the name of a question. ;
Save as PDF	Press ' || chr(39) || 'Save as PDF' || chr(39) || ' (top right) to download your answers to this questionnaire. ;
Saving 		Please, note that after answering a question your answer is automatically saved. ;
Complete	Press ' || chr(39) || 'Complete' || chr(39) || ' (top right) to finalize the questionnaire.
', 4, 'DEFAULT');

INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (14, 'By placing the mouse on the names of the index dimensions, explanations on the scoring will appear. ;
By placing the mouse on the entry number, the entry description will appear. ;
Bold entry numbers indicate the entry has been <strong>created</strong> or <strong>reformed</strong> in this exercise year. ;
Blue score numbers indicate that the score has been changed at the <strong>present scoring step</strong>. ;
Red score numbers indicate that the score is different between <strong>final version of last exercise year</strong> and <strong>present scoring step</strong>.  ;
Bold score numbers indicate that the score has been changed at <strong>any point during this year' || chr(39) || 's scoring</strong>. ;
Yellow cells indicate that a score has been entered at the <strong>present scoring step</strong>. ;
In order to complete a scoring step, please click “Complete” when all cells are ready.
', 1, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (14, '<ul [style.margin-top]="0">
By placing the mouse on the names of the index dimensions, explanations on the scoring will appear. ;
By placing the mouse on the entry number, the entry description will appear. ;
Bold entry numbers indicate the entry has been <strong>created</strong> or <strong>reformed</strong> in this exercise year. ;
Blue score numbers indicate that the score has been changed at the <strong>present scoring step</strong>. ;
Red score numbers indicate that the score is different between <strong>final version of last exercise year</strong> and <strong>present scoring step</strong>.  ;
Bold score numbers indicate that the score has been changed at <strong>any point during this year' || chr(39) || 's scoring</strong>. ;
Yellow cells indicate that a score has been entered at the <strong>present scoring step</strong>. ;
In order to complete a scoring step, please click “Complete” when all cells are ready.
', 2, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (14, '<ul [style.margin-top]="0">
By placing the mouse on the names of the index dimensions, explanations on the scoring will appear. ;
By placing the mouse on the entry number, the entry description will appear. ;
Bold entry numbers indicate the entry has been <strong>created</strong> or <strong>reformed</strong> in this exercise year. ;
Blue score numbers indicate that the score has been changed at the <strong>present scoring step</strong>. ;
Red score numbers indicate that the score is different between <strong>final version of last exercise year</strong> and <strong>present scoring step</strong>.  ;
Bold score numbers indicate that the score has been changed at <strong>any point during this year' || chr(39) || 's scoring</strong>. ;
Yellow cells indicate that a score has been entered at the <strong>present scoring step</strong>. ;
In order to complete a scoring step, please click “Complete” when all cells are ready.
', 3, 'DEFAULT');
INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID) VALUES (14, '<ul [style.margin-top]="0">
By placing the mouse on the names of the index dimensions, explanations on the scoring will appear. ;
By placing the mouse on the entry number, the entry description will appear. ;
Bold entry numbers indicate the entry has been <strong>created</strong> or <strong>reformed</strong> in this exercise year. ;
Blue score numbers indicate that the score has been changed at the <strong>present scoring step</strong>. ;
Red score numbers indicate that the score is different between <strong>final version of last exercise year</strong> and <strong>present scoring step</strong>.  ;
Bold score numbers indicate that the score has been changed at <strong>any point during this year' || chr(39) || 's scoring</strong>. ;
Yellow cells indicate that a score has been entered at the <strong>present scoring step</strong>. ;
In order to complete a scoring step, please click “Complete” when all cells are ready.
', 4, 'DEFAULT');
COMMIT;