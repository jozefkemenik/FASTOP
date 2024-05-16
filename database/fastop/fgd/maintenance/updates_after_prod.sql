--Ad-hoc improvements, line 4
UPDATE CFG_INDEX_STAGE_VERSIONS
   SET DESCR = 'C4/D1 proposal to MS'
   WHERE INDEX_SID = 1 AND SCORE_VERSION_SID = 3;
UPDATE CFG_INDEX_STAGE_VERSIONS
   SET DESCR = 'C4/D1 first version'
   WHERE INDEX_SID = 1 AND SCORE_VERSION_SID = 7;   
   
UPDATE CFG_INDEX_STAGE_VERSIONS
   SET DESCR = 'C4 proposal to IFI'
   WHERE INDEX_SID = 3 AND SCORE_VERSION_SID = 3;   
UPDATE CFG_INDEX_STAGE_VERSIONS
   SET DESCR = 'COMM - IFI cross-check'
   WHERE INDEX_SID = 3 AND SCORE_VERSION_SID = 4;
DELETE CFG_INDEX_STAGE_VERSIONS
WHERE SCORE_VERSION_SID = 6 AND INDEX_SID IN (3,4);
COMMIT;
update cfg_ui_qstnnr_elements
set element_text = 'By placing the mouse on the names of the index dimensions, explanations on the scoring will appear. ;
By placing the mouse on the entry number, the entry description will appear. ;
Bold entry numbers indicate the entry has been created or reformed in this exercise year. ;
Blue score numbers indicate that the score has been changed at the present scoring step. ;
Red score numbers indicate that the score is different between final version of last exercise year and present scoring step.  ;
Bold score numbers indicate that the score has been changed at any point during this year`s scoring. ;
Yellow cells indicate that a score has been entered at the present scoring step. ;
In order to complete a scoring step, please click Complete when all cells are ready.
'
where element_type_sid = 14;
COMMIT;
update cfg_lovs
set need_det = 2 where lov_sid in (528, 545);
update cfg_lovs
set need_det = 3 where lov_sid in (254);
commit;

update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(DETAILS) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) > {TARGET}'
where score_cond_sid = 9;

update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(DETAILS) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) >= {TARGET}'
where score_cond_sid = 12;
commit;

update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) <= {TARGET}'
where score_cond_sid = 3;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) >= {TARGET}'
where score_cond_sid = 4;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) <= {TARGET}'
where score_cond_sid = 5;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) <= {TARGET}'
where score_cond_sid = 6;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) > {TARGET}'
where score_cond_sid = 7;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) < {TARGET}'
where score_cond_sid = 8;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) > {TARGET}'
where score_cond_sid = 9;

update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) > {TARGET}'
where score_cond_sid = 10;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) <= {TARGET}'
where score_cond_sid = 11;

update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) >= {TARGET}'
where score_cond_sid = 12;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) <= {TARGET}'
where score_cond_sid = 13;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) <= {TARGET}'
where score_cond_sid = 14;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) > {TARGET}'
where score_cond_sid = 15;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) < {TARGET}'
where score_cond_sid = 16;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) > {TARGET}'
where score_cond_sid = 17;
update cfg_score_conditions
set custom_condition = '(SELECT TO_NUMBER(NVL(DETAILS,0)) FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = {QUESTION_VERSION_SID} AND ENTRY_SID = {ENTRY_SID}) > {TARGET}'
where score_cond_sid = 18;
commit;
delete cfg_score_conditions where choice_score_sid in (170, 171, 172, 173, 178, 179, 180, 181);
delete CFG_INDEX_CHOICES_SCORES where choice_score_sid in (170, 171, 172, 173, 178, 179, 180, 181);
commit;
DECLARE
    CURSOR c_miss_vin IS
        SELECT QS.QUESTION_VERSION_SID, Q.DESCR, QS.ORDER_BY
        FROM CFG_QUESTIONS Q,
            CFG_QUESTION_VERSIONS QV,
            cfg_qstnnr_section_questions QS
        WHERE QS.SECTION_VERSION_SID = 72
          AND QS.QUESTION_VERSION_SID = QV.QUESTION_VERSION_SID
          AND QV.QUESTION_SID = Q.QUESTION_SID
          ORDER BY QS.ORDER_BY;
        l_prefix varchar2(500 byte) := 'Ad-hoc questions';
        l_order number;
begin
    select max(order_by)+1 into l_order FROM cfg_vintage_attributes where app_id = 'IFI';
    
    FOR rec IN c_miss_vin LOOP
        INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DISPLAY_PREFIX, DEFAULT_SELECTED, ORDER_BY)
        VALUES ('IFI', 6, TO_CHAR(rec.QUESTION_VERSION_SID), rec.DESCR, l_prefix, 0, l_order);
        l_order := l_order + 1;
    END LOOP;
COMMIT;
END; 
/
DECLARE
 CURSOR c_data IS SELECT * FROM CFG_INDEX_cRITERIA;
BEGIN
    FOR rec IN c_data LOOP
        IF rec.INDEX_SID = 1 THEN
            UPDATE cfg_horizontal_elements SET DISPLAY_NAME = rec.DESCR WHERE DISPLAY_NAME = 'CR'||rec.CRITERION_ID||upper(rec.SUB_CRITERION_ID) AND INDEX_SID = 1;
        ELSIF rec.INDEX_SID = 2 THEN
            UPDATE cfg_horizontal_elements SET DISPLAY_NAME = rec.DESCR WHERE DISPLAY_NAME = 'CR'||rec.CRITERION_ID||upper(rec.SUB_CRITERION_ID) AND INDEX_SID = 2;
        ELSIF rec.INDEX_SID = 3 THEN
            UPDATE cfg_horizontal_elements SET DISPLAY_NAME = rec.DESCR WHERE UPPER(DISPLAY_NAME) = upper(rec.CRITERION_ID)||upper(rec.SUB_CRITERION_ID) AND INDEX_SID = 3;
        ELSIF rec.INDEX_SID = 4 THEN
            UPDATE cfg_horizontal_elements SET DISPLAY_NAME = rec.DESCR WHERE UPPER(DISPLAY_NAME) = upper(rec.CRITERION_ID)||upper(rec.SUB_CRITERION_ID) AND INDEX_SID = 4;
        END IF;
    END LOOP;
COMMIT;    
END;
/
UPDATE cfg_question_versions SET ACCESSOR = 'REFORM_REASON' WHERE QUESTION_VERSION_SID = 44;

UPDATE cfg_indice_criteria
   SET ACCESSOR = 'FUNCTION_BASED', CRITERION_VALUE = 'getRanking', INDICE_TYPE_SID = 3
 WHERE IND_CRITERION_SID = 17;
UPDATE cfg_indice_criteria
   SET ACCESSOR = 'RANKING' WHERE ACCESSOR = 'RANKING1';

DROP SEQUENCE CFG_INDICE_CRIT_COND_SEQ;
DROP TABLE CFG_INDICE_CRIT_COND CASCADE CONSTRAINTS;
CREATE SEQUENCE CFG_INDICE_CRIT_COND_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE TABLE CFG_INDICE_CRIT_COND (
    IND_CONDITION_SID       NUMBER,
    IND_CRITERION_SID       NUMBER,
    DEP_IND_CRITERION_SID   NUMBER,
    EQUALITY_OPERATION      NUMBER,
    DEP_CRITERION_VALUE     NUMBER,
    COND_GROUP              NUMBER,
        CONSTRAINT "CFG_INDICE_CRIT_COND_PK" PRIMARY KEY ("IND_CONDITION_SID"),
        CONSTRAINT "CFG_INDICE_CRIT_COND_FK1" FOREIGN KEY ("IND_CRITERION_SID")
            REFERENCES "CFG_INDICE_CRITERIA" ("IND_CRITERION_SID"),
        CONSTRAINT "CFG_INDICE_CRIT_COND_FK2" FOREIGN KEY ("DEP_IND_CRITERION_SID")
            REFERENCES "CFG_INDICE_CRITERIA" ("IND_CRITERION_SID")
);

CREATE OR REPLACE TRIGGER CFG_INDICE_CRIT_COND_TRG
    BEFORE INSERT
    ON CFG_INDICE_CRIT_COND
    FOR EACH ROW
    DECLARE
    BEGIN
       SELECT CFG_INDICE_CRIT_COND_SEQ.NEXTVAL INTO :NEW.IND_CONDITION_SID FROM dual;
END CFG_INDICE_CRIT_COND_TRG;
/
ALTER TRIGGER "CFG_INDICE_CRIT_COND_TRG" ENABLE;
/
COMMIT;
--DONE
update cfg_sections
set section_id = chr(39)||'Green'||chr(39)||' budget tagging'
where section_sid = 62;
update cfg_sections
set section_id = 'Ex-ante environmental impact assesment' where section_sid = 63;
update cfg_sections
set section_id = 'Ex-post environmental evaluation analyses' where section_sid = 64;
update cfg_sections
set section_id = 'Governance for '||chr(39)||'green'||chr(39)||' budget tagging' where section_sid = 68;
update cfg_sections
set section_id = 'Governance for ex-ante environmental impact assessment' where section_sid = 69;
insert into cfg_sections(section_id) values ('Governance for ex-post environmental evaluation analyses');

update cfg_section_versions
set descr = chr(39)||'Green'||chr(39)||' budget tagging' where section_version_sid = 62;
update cfg_section_versions
set descr = 'Ex-ante environmental impact assesment' where section_version_sid = 63;
update cfg_section_versions
set descr = 'Ex-post environmental evaluation analyses' where section_version_sid = 63;
update cfg_section_versions
set descr = chr(39)||'Green'||chr(39)||' budget tagging', section_sid = 62 where section_version_sid = 65;
update cfg_section_versions
set descr = 'Ex-ante environmental impact assesment', section_sid = 63 where section_version_sid = 66;
update cfg_section_versions
set descr = 'Governance for '||chr(39)||'green'||chr(39)||' budget tagging' where section_version_sid = 68;
update cfg_section_versions
set descr = 'Governance for ex-ante environmental impact assessment' where section_version_sid = 69;
insert into cfg_section_versions(section_sid, descr, assessment_period, no_help)
values (64, 'Ex-post environmental evaluation analyses', 0, NULL);
insert into cfg_section_versions(section_sid, descr, assessment_period, no_help)
values (73, 'Governance for ex-post environmental evaluation analyses', 0, NULL);

UPDATE CFG_SECTION_VERSIONS SET DESCR = 'Please indicate the coverage of ex-ante environmental impact assessments analyses performed in your country, with respect to environmental objectives, budgetary elements and public sector.' WHERE SECTION_VERSION_SID = 63;
UPDATE CFG_SECTION_VERSIONS SET DESCR = 'Please indicate the coverage of ex-post environmental evaluations performed in your country, with respect to environmental objectives, budgetary elements and public sector. ' WHERE SECTION_VERSION_SID = 64;
UPDATE CFG_SECTION_VERSIONS SET  DESCR = 'Please indicate the coverage of green budgeting practices implemented in your country, with respect to environmental objectives, budgetary elements and public sector. ' WHERE SECTION_VERSION_SID = 62;

INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD) VALUES (72, 'Ad-hoc questions', 0) ;
Insert into CFG_SECTION_VERSIONS (SECTION_VERSION_SID,SECTION_SID,DESCR,ASSESSMENT_PERIOD,NO_HELP) values (76,73,'Governance for ex-post environmental evaluation analyses',0,null);

Insert into CFG_SECTION_VERSIONS (SECTION_VERSION_SID,SECTION_SID,DESCR,ASSESSMENT_PERIOD,NO_HELP) values (77,72,'Ad-hoc questions',0,null);

--
INSERT INTO CFG_QSTNNR_VER_SECTIONS(QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY) VALUES (4, 77, 9);

insert into cfg_qstnnr_ver_subsections(qstnnr_version_sid, parent_section_version_sid, sub_section_version_sid, order_by)
values (4, 56, 74, 3);
insert into cfg_qstnnr_ver_subsections(qstnnr_version_sid, parent_section_version_sid, sub_section_version_sid, order_by)
values (4, 57, 76, 4);
--

INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Transparency and accountability of the environmental evaluation analyses'); --417
INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(417, 2, 'Is the methodology used for impact assessment analyses: Please select all that apply.', 1, 0);

INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(375, 5, 'Please provide link to relevant report or publication when available.', 1, 0);

INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(366, 5, 'Please specify who conducts the evaluation.', 1, 0);

INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Other remarks on the chosen methodology for the environmental evaluation analysis'); --418
INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(418, 5, 'Please provide any additional relevant information to the chosen methodology for environmental impact assessment analyses.', 1, 0);

UPDATE CFG_QUESTIONS SET DESCR = 'Other remarks on the chosen tagging methodology' WHERE QUESTION_SID = 337;
UPDATE CFG_QUESTIONS SET DESCR = 'Other remarks on the chosen methodology for impact assessment ' WHERE QUESTION_SID = 339;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please provide any additional relevant information to the chosen methodology for environmental impact assessment analyses.' WHERE QUESTION_VERSION_SID = 339;

UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Who is leading the green budget tagging process? Please select all that apply.' WHERE QUESTION_VERSION_SID = 344;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Who is involved in the green budget tagging process? Please select all that apply.' WHERE QUESTION_VERSION_SID = 343;

INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Impact assessments linked to budgetary process'); --419
INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(419, 1, 'Are the impact assessment analyses linked to the regular budgetary process (i.e., conducted systematically as part of the budgetary cycle and/or formalised within the budgetary process)?', 1, 0);

INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Weblink to document formalising process'); --420
INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(420, 5, 'Please specify and provide link to the document formalising the environmental assessment process, if applicable', 1, 0);

INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(344, 2, 'Who is leading the impact assessment process? Please select all that apply.', 1, 0);

INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Evaluations analyses linked to budgetary process'); --421
INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(421, 1, 'Are the environmental evaluation analyses linked to the regular budgetary process (i.e., conducted systematically as part of the budgetary cycle and/or formalised within the budgetary process)?', 1, 0);

INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(343, 1, 'Who conducts the impact assessment analyses?', 1, 0);
INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(345, 5, 'Please add a description of a how the process works, including how responsibilities are allocated and calendar of actions.', 1, 0);

UPDATE CFG_QUESTIONS SET DESCR = 'Covid-19 response measures related to green budgeting processes' WHERE QUESTION_SID = 361;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'What specific actions have been taken to promote green budgeting processes as part of the Covid-19 response measures. Please select all that apply.' WHERE QUESTION_VERSION_SID = 361;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Do the recovery and resilience plans include any measures/reforms to promote the implementation or further development of regular green budgeting processes at the national level?' WHERE QUESTION_VERSION_SID = 362;

INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Helpfulness COM training'); --422
INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(422, 1, ' To what extent has the technical support training, provided by the European Commission, helped with implementing or further developing green budgeting at the national level?', 1, 0);

INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Further support'); --423
INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(423, 1, ' Would you like to receive further technical support from the European Commission for implementing green budgeting?', 1, 0);

UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please specify which sectors (e.g. transport, agriculture).' WHERE QUESTION_VERSION_SID = 386;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please provide additional comments that are relevant to the impacts of conducting green budgeting, but have not been addressed in this section. ' WHERE QUESTION_VERSION_SID = 360;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Are there any plans, publicly available, to introduce green budgeting in the future? Please select all that apply.' WHERE QUESTION_VERSION_SID = 307;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'When is the introduction of green budgeting foreseen? Please specify the budget year of first application (e.g. 2030), or “not yet defined”.' WHERE QUESTION_VERSION_SID = 308;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please indicate any other points you may want to make on the coverage of the green budget tagging exercise.' WHERE QUESTION_VERSION_SID = 320;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Do the impact assessment analyses examine impacts on: Please select all that apply.' WHERE QUESTION_VERSION_SID = 321;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Do the evaluation analyses examine impacts on: Please select all that apply.' WHERE QUESTION_VERSION_SID = 328;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Do the impact assessment analyses cover: Please select all that apply' WHERE QUESTION_VERSION_SID = 322;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Do the evaluation analyses cover? Please select all that apply.' WHERE QUESTION_VERSION_SID = 329;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Are the impact assessments done for measures at the level of: Please select all that apply.' WHERE QUESTION_VERSION_SID = 324;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Are the evaluation analyses done for measures at the level of: Please select all that apply.' WHERE QUESTION_VERSION_SID = 331;

UPDATE CFG_QUESTIONS SET DESCR = 'Other remarks on the coverage of environmental evaluation analyses' WHERE QUESTION_SID = 334;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please indicate any other points you may want to make on the coverage of environmental evaluation analyses.' WHERE QUESTION_VERSION_SID = 334;

UPDATE CFG_QUESTIONS SET DESCR = 'Other remarks on the chosen methodology for green budget tagging' WHERE QUESTION_SID = 337;
UPDATE CFG_QUESTIONS SET DESCR = 'Other remarks on the chosen methodology for impact assessment' WHERE QUESTION_SID = 339;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please provide any additional relevant information to the chosen methodology for environmental impact assessment analyses.' WHERE QUESTION_VERSION_SID = 339;

UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Are any tools or processes in place to measure the impact of conducting green budgeting?' WHERE QUESTION_VERSION_SID = 356;

INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(420, 5, 'Please specify and provide link to the document formalising the environmental assessment process, if applicable', 1, 0);

INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY) VALUES
(344, 2, 'Who is leading the impact assessment process? Please select all that apply.', 1, 0);
--
DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = 54 AND QUESTION_VERSION_SID = 310;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 5 WHERE SECTION_VERSION_SID = 54 AND QUESTION_VERSION_SID = 311;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 6 WHERE SECTION_VERSION_SID = 54 AND QUESTION_VERSION_SID = 312;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 7 WHERE SECTION_VERSION_SID = 54 AND QUESTION_VERSION_SID = 313;

DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = 62 AND QUESTION_VERSION_SID IN (318, 392, 319, 393);
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = ORDER_BY - 4 WHERE SECTION_VERSION_SID = 62 AND QUESTION_VERSION_SID IN (367, 368, 369, 320);

DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = 63 AND QUESTION_VERSION_SID IN (323, 394, 325, 397, 326, 398, 370, 371, 372);
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 3 WHERE SECTION_VERSION_SID = 63 AND QUESTION_VERSION_SID = 324;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 4 WHERE SECTION_VERSION_SID = 63 AND QUESTION_VERSION_SID = 395;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 5 WHERE SECTION_VERSION_SID = 63 AND QUESTION_VERSION_SID = 396;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 6 WHERE SECTION_VERSION_SID = 63 AND QUESTION_VERSION_SID = 327;

DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = 64 AND QUESTION_VERSION_SID IN (330, 399, 332, 402, 333, 403);
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 3 WHERE SECTION_VERSION_SID = 64 AND QUESTION_VERSION_SID = 331;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 4 WHERE SECTION_VERSION_SID = 64 AND QUESTION_VERSION_SID = 400;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 5 WHERE SECTION_VERSION_SID = 64 AND QUESTION_VERSION_SID = 401;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 6 WHERE SECTION_VERSION_SID = 64 AND QUESTION_VERSION_SID = 334;

INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (74, 422, 1);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (74, 423, 2);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (74, 424, 3);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (74, 425, 4);

DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = 67 AND QUESTION_VERSION_SID = 341;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 5 WHERE SECTION_VERSION_SID = 67 AND QUESTION_VERSION_SID = 342;

INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (69, 426, 1);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (69, 427, 2);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (69, 428, 3);
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 4 WHERE SECTION_VERSION_SID = 69 AND QUESTION_VERSION_SID = 346;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = 5 WHERE SECTION_VERSION_SID = 69 AND QUESTION_VERSION_SID = 347;

INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (76, 429, 1);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (76, 434, 2);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (76, 435, 3);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (76, 430, 4);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (76, 431, 5);

DELETE FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = 71 AND QUESTION_VERSION_SID IN (404, 405);

INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (77, 432, 1);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
VALUES (77, 433, 2);

INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (77, 1);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (77, 3);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (77, 5);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (77, 7);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (74, 1);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (74, 3);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (74, 5);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (74, 7);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (76, 1);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (76, 3);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (76, 5);
INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID) VALUES (76, 7);

DELETE CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID IN (310, 318, 392, 319, 393, 323, 394, 325, 397, 326, 398, 370, 371, 372, 330, 399, 332, 402, 333, 403, 341, 404, 405);
DELETE CFG_QUESTION_CONDITIONS WHERE COND_QUESTION_VERSION_SID IN (310, 318, 392, 319, 393, 323, 394, 325, 397, 326, 398, 370, 371, 372, 330, 399, 332, 402, 333, 403, 341, 404, 405);
DELETE CFG_QUESTION_CONDITIONS WHERE QUESTION_VERSION_SID IN (310, 318, 392, 319, 393, 323, 394, 325, 397, 326, 398, 370, 371, 372, 330, 399, 332, 402, 333, 403, 341, 404, 405);

DECLARE 
    l_lov_type_sid NUMBER;
BEGIN
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('GGBIP2', 'Green budgeting in place V2', 0) RETURNING LOV_TYPE_SID INTO l_lov_type_sid;

    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, 'Yes, '||CHR(39)||'green'||CHR(39)||' budget tagging, identifying those budgetary measures/policies that are favourable and/or unfavourable to the environment', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Yes, conducting ex‑ante environmental impact assessments of budgetary measures/policies (i.e., before their inclusion in the budget)', NULL , 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Yes, conducting ex‑post environmental evaluations of budgetary measures/policies (i.e., after their implementation)', NULL , 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'No', NULL , 4, 3);
END;
/

DECLARE 
    l_lov_type_sid NUMBER;
BEGIN
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('CEIBEC2', 'Budgetary elements coverage V2', 0) RETURNING LOV_TYPE_SID INTO l_lov_type_sid;

    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, 'Environmentally favourable revenue', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Environmentally favourable expenditure', NULL , 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Environmentally favourable tax expenditure', NULL , 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Environmentally unfavourable revenue', NULL , 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Environmentally unfavourable expenditure', NULL , 5, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Environmentally unfavourable tax expenditure', NULL , 6, NULL);
END;
/

DECLARE 
    l_lov_type_sid NUMBER;
BEGIN
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('STKI2', 'Stakeholders involved MV2', 0) RETURNING LOV_TYPE_SID INTO l_lov_type_sid;

    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, 'Ad-hoc or temporary task force', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Central budget authority unit', NULL , 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Central budget authority unit only devoted to green budgeting', NULL , 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Ministry of Environment', NULL , 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Line ministries units', 1 , 5, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Line ministries units only devoted to green budgeting', 1 , 6, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Independent experts', 1 , 7, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'Other', 1 , 8, NULL);
END;
/

INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (27, 'Issuance of sovereign green/sustainable bonds', 7);
UPDATE CFG_LOVS SET ORDER_BY = 8 WHERE LOV_SID = 177;
UPDATE CFG_LOVS SET ORDER_BY = 9 WHERE LOV_SID = 178;

DECLARE 
    l_lov_type_sid NUMBER;
BEGIN
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('HPCM', 'Helpfulness COM training', 0) RETURNING LOV_TYPE_SID INTO l_lov_type_sid;

    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, 'To a large extent', 1, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'To some extent', 1 , 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'To a limited extent', 1 , 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'N/A [have not participated in the training]', NULL , 4, 3);
END;
/

UPDATE CFG_QUESTION_LOV_TYPES SET LOV_TYPE_SID = 251 WHERE QUESTION_VERSION_SID = 306;
UPDATE CFG_QUESTION_LOV_TYPES SET LOV_TYPE_SID = 251 WHERE QUESTION_VERSION_SID = 307;

UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 909 WHERE QUESTION_VERSION_SID IN (314,315,316, 317, 367, 368, 369, 320, 335, 336, 337) AND COND_QUESTION_VERSION_SID = 306;
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 910 WHERE QUESTION_VERSION_SID IN (321, 322, 324, 327, 346, 347, 338) AND COND_QUESTION_VERSION_SID = 306;
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 911 WHERE QUESTION_VERSION_SID IN (328, 329, 331, 334) AND COND_QUESTION_VERSION_SID = 306;
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 912 WHERE QUESTION_VERSION_SID = 307 AND COND_QUESTION_VERSION_SID = 306;
DELETE FROM CFG_QUESTION_CONDITIONS WHERE QUESTION_VERSION_SID = 339 AND COND_QUESTION_VERSION_SID = 306;

INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (427, 306, 910);
INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (425, 306, 911);
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 909 WHERE QUESTION_VERSION_SID IN (343, 344, 345, 348, 351, 353, 357, 360, 356, 373, 349, 311, 312, 340) AND COND_QUESTION_VERSION_SID = 306 AND LOV_SID = 7;
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 910 WHERE QUESTION_VERSION_SID IN (343, 344, 345, 348, 351, 353, 357, 360, 356, 373, 349, 311, 312, 340) AND COND_QUESTION_VERSION_SID = 306 AND LOV_SID = 8;
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 911 WHERE QUESTION_VERSION_SID IN (348, 351, 353, 357, 360, 356, 373, 349, 311, 312, 340) AND COND_QUESTION_VERSION_SID = 306 AND LOV_SID = 9;

DECLARE
    l_cond_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (426, 306, 910) RETURNING COND_SID INTO l_cond_sid;
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID) VALUES(426, l_cond_sid, 1);
END;
/

DECLARE
    l_cond_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (428, 306, 910) RETURNING COND_SID INTO l_cond_sid;
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID) VALUES(428, l_cond_sid, 253);
END;
/

DECLARE
    l_cond_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (422, 306, 911) RETURNING COND_SID INTO l_cond_sid;
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID) VALUES(422, l_cond_sid, 18);
END;
/

UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 909  WHERE LOV_SID = 11 AND COND_QUESTION_VERSION_SID = 307;
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 910  WHERE LOV_SID = 12 AND COND_QUESTION_VERSION_SID = 307;
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 911  WHERE LOV_SID = 13 AND COND_QUESTION_VERSION_SID = 307;

INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (427, 426, 1);
INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (434, 429, 1);

INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (423, 422, 105);
INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (423, 422, 106);
INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (424, 422, 106);

UPDATE CFG_QUESTION_LOV_TYPES SET LOV_TYPE_SID = 252 WHERE LOV_TYPE_SID = 15;
UPDATE CFG_SECTION_VERSIONS SET DESCR = 'Ex-post environmental evaluation analyses' WHERE SECTION_VERSION_SID = 64;
UPDATE CFG_SECTION_VERSIONS SET SECTION_SID = 64, DESCR = 'Ex-post environmental evaluation analyses' WHERE SECTION_VERSION_SID = 74;   

DECLARE
    l_cond_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (429, 306, 911) RETURNING COND_SID INTO l_cond_sid;
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID) VALUES(429, l_cond_sid, 1);
END;
/
DECLARE
    l_cond_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (435, 306, 911) RETURNING COND_SID INTO l_cond_sid;
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID) VALUES(435, l_cond_sid, 253);
END;
/

DECLARE
    l_cond_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (430, 306, 911) RETURNING COND_SID INTO l_cond_sid;
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID) VALUES(430, l_cond_sid, 30);
END;
/

INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID) VALUES(432, NULL, 254);
INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID) VALUES(433, NULL, 1);

CREATE TABLE TARGET_ENTRIES_ARCH (
    ROUND_SID NUMBER,
    ENTRY_SID NUMBER,
    QUESTION_VERSION_SID NUMBER,
    RESPONSE_SID NUMBER,
    VALUE NUMBER,
    NOT_APPLICABLE NUMBER,
    DESCR VARCHAR2(4000 BYTE)
);

CREATE TABLE ENTRY_CHOICES_ADD_INFOS_ARCH (
    ROUND_SID NUMBER,
    ENTRY_SID NUMBER,
    QUESTION_VERSION_SID NUMBER,
    DESCR VARCHAR2(4000 BYTE),
    PERIOD_SID NUMBER
);

CREATE TABLE ENTRY_CRITERIA_ARCH (
    ENTRY_CRITERIA_SID NUMBER,
    ENTRY_SID NUMBER,
    CRITERION_SID NUMBER,
    SCORE_VERSION_SID NUMBER,
    SCORE NUMBER,
    LDAP_LOGIN VARCHAR2(100 BYTE),
    DATETIME DATE,
    ORGANISATION VARCHAR2(100 BYTE),
    ROUND_SID NUMBER,
    ROUND_SID_ARCH  NUMBER);

CREATE TABLE LOG_INFO_SUCC(
    PROC_NAME VARCHAR2(200 BYTE),
    INFO_MSG  VARCHAR2(2000 BYTE),
    DATETIME DATE
);
CREATE TABLE LOG_INFO_FAIL(
    PROC_NAME VARCHAR2(200 BYTE),
    INFO_MSG  VARCHAR2(2000 BYTE),
    ERROR_MSG  VARCHAR2(2000 BYTE),
    DATETIME DATE
);

begin
   dbms_refresh.make(
     name                 => 'ROUND_REFRESH',
     list                 => '',
     next_date            => TRUNC(SYSDATE+1),
     interval             => 'SYSDATE + 1',
     implicit_destroy     => false,
     lax                  => false,
     job                  => 0,
     rollback_seg         => null,
     push_deferred_rpc    => true,
     refresh_after_errors => true,
     purge_option         => null,
     parallelism          => null,
     heap_size            => null);
end;
/

DECLARE
    l_job_name VARCHAR2(4000 BYTE);
    l_job_action VARCHAR2(400 BYTE) := 'begin CORE_JOBS.roundCheckJob; end;';
BEGIN
 SELECT job_name INTO l_job_name FROM user_scheduler_jobs;
--FREQ=MINUTELY;INTERVAL=2;BYHOUR=17;
    BEGIN
      dbms_scheduler.set_attribute (
        name      => l_job_name,
        attribute => 'JOB_ACTION',
        value     => l_job_action
      );
    END;
END;
/

--SCP-2231
DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = 62 AND QUESTION_VERSION_SID IN (316, 389);
UPDATE CFG_QSTNNR_SECTION_QUESTIONS
SET ORDER_BY = ORDER_BY - 2 WHERE SECTION_VERSION_SID = 62 AND ORDER_BY > 2;
UPDATE CFG_QUESTION_VERSIONS SET QUESTION_TYPE_SID = 1 WHERE QUESTION_VERSION_SID = 358;
DECLARE 
    l_lov_type_sid NUMBER;
BEGIN
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('MIGB', 'Magnitude of the impact of GB', 0) RETURNING LOV_TYPE_SID INTO l_lov_type_sid;

    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, '1 (somewhat effective)', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'2 (moderately effective)', NULL , 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid,'3 (very effective)', NULL , 3, NULL);
    
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (358, l_lov_type_sid);
END;
/

UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please provide additional comments related to other tools relevant to the greening of public finances.' WHERE QUESTION_VERSION_SID = 364;

UPDATE CFG_QUESTIONS SET DESCR = 'Please specify which actions' WHERE QUESTION_SID = 388;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please specify which actions from the Recovery and Resilience Plan' WHERE QUESTION_VERSION_SID = 388;

--SCP-2230
UPDATE CFG_UI_QSTNNR_ELEMENTS SET ELEMENT_TEXT = 'No Change in {YEAR2}/{YEAR1}' WHERE ELEMENT_TYPE_SID = 6 AND QSTNNR_VERSION_SID = 4;
UPDATE CFG_UI_QSTNNR_ELEMENTS SET ELEMENT_TEXT = 'Reformed/Modified in {YEAR2}/{YEAR1}' WHERE ELEMENT_TYPE_SID = 7 AND QSTNNR_VERSION_SID = 4;
UPDATE CFG_UI_QSTNNR_ELEMENTS SET ELEMENT_TEXT = 'Please report information on practices under implementation or planned between June {YEAR2} and January {YEAR}.' WHERE ELEMENT_TYPE_SID = 3 AND QSTNNR_VERSION_SID = 4;
UPDATE CFG_UI_QSTNNR_ELEMENTS SET ELEMENT_TEXT = 'Only practices implemented or planned between June {YEAR2} and January {YEAR} should be reported in the survey. Should the reported information need to be corrected and resubmitted, please send an email to ECFIN-GREEN-BUDGETING-SURVEY@ec.europa.eu' WHERE ELEMENT_TYPE_SID = 4 AND QSTNNR_VERSION_SID = 4;
UPDATE CFG_UI_QSTNNR_ELEMENTS SET ELEMENT_TEXT = '"To start 	Press '||chr(39)||'details'||chr(39)||' to review the answers from the previous year. ;
Press '||chr(39)||'no change in {YEAR2}/{YEAR1}'||chr(39)||' if there was not any practical or legal change during the year. In this case, no changes can be made to the answers. ;
Press '||chr(39)||'reformed/modified in {YEAR2}/{YEAR1}'||chr(39)||' in case there was a legal reform or change in practice with regard to your green budgeting practices. Please indicate the nature of the reform or change in practice in the pop-up screen. ;
Submit	After completing your questionnaire, remember to also press '||chr(39)||'submit'||chr(39)||' in the overview screen to finalise your submission. ;
Please, note that no further changes can be made after completion. In case you spot a mistake after completion or submission, please send an email to:   ECFIN-GREEN-BUDGETING-SURVEY@ec.europa
"' WHERE ELEMENT_TYPE_SID = 12 AND QSTNNR_VERSION_SID = 4;

UPDATE CFG_QUESTION_VERSIONS SET MANDATORY = 1 WHERE QUESTION_VERSION_SID IN (368, 369);

INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (339, 306, 910);

DELETE FROM CFG_QUESTION_CONDITIONS
WHERE QUESTION_VERSION_SID IN (343, 344, 345) AND LOV_SID = 910;

INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY) VALUES (67, 341, 5);
UPDATE CFG_QSTNNR_SECTION_QUESTIONS
SET ORDER_BY = 6 WHERE SECTION_VERSION_SID = 67 AND QUESTION_VERSION_SID = 342;
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (341, 340, 108);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (341, 340, 109);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (341, 340, 110);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (341, 340, 111);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (341, 340, 112);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (341, 340, 113);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (341, 340, 114);

UPDATE CFG_QUESTION_VERSIONS SET QUESTION_TYPE_SID = 2 WHERE QUESTION_VERSION_SID = 346;
UPDATE CFG_QUESTION_VERSIONS SET QUESTION_TYPE_SID = 2 WHERE QUESTION_VERSION_SID = 430;
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Please add a description of how the process works, including how responsibilities are allocated and calendar of actions.' WHERE QUESTION_VERSION_SID = 347;

DELETE CFG_QUESTION_CONDITIONS WHERE QUESTION_VERSION_SID = 427 AND COND_QUESTION_VERSION_SID = 306;

UPDATE CFG_QUESTION_VERSIONS
   SET HELP_TEXT = 'Please indicate the main challenges in introducing, implementing or further developing green budgeting. Please select the three most relevant options.'
 WHERE QUESTION_VERSION_SID = 353;
UPDATE CFG_QUESTIONS 
   SET DESCR = 'Main challenges in introducing, implementing or further developing green budgeting. Please select the three most relevant options.'
 WHERE QUESTION_SID = 353;

UPDATE CFG_QUESTION_VERSIONS 
   SET HELP_TEXT = 'Please indicate any other points you may want to make on the coverage of ex-ante environmental impact assessments analyses.'
 WHERE QUESTION_VERSION_SID = 327;
UPDATE CFG_QUESTIONS
   SET DESCR = 'Other remarks on the coverage of ex-ante environmental impact assessments analyses'
 WHERE QUESTION_SID = 327;  

UPDATE CFG_QUESTION_VERSIONS
   SET HELP_TEXT = 'Please provide any additional relevant information to the chosen methodology for ex-post environmental evaluation analyses.'
 WHERE QUESTION_VERSION_SID = 425;

  --SCP-2235
 UPDATE CFG_QUESTION_LOV_TYPES
  SET LOV_TYPE_SID = 2
 WHERE QUESTION_VERSION_SID = 433; 

INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
VALUES (431, 306, 911);
 DELETE FROM CFG_UI_QSTNNR_ELEMENTS
  WHERE ELEMENT_TYPE_SID = 6 AND QSTNNR_VERSION_SID = 4;
 --Commit to prod on 11/01/23

 --SCP-2236
 INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
  VALUES (6, 'No change in {YEAR2}/{YEAR1}', 4, 'DEFAULT');
  
  UPDATE CFG_QUESTION_VERSIONS
  SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID IN (
  SELECT QUESTION_VERSION_SID FROM cfg_qstnnr_section_questions WHERE SECTION_VERSION_SID IN (SELECT SECTION_VERSION_SID FROM cfg_qstnnr_ver_sections WHERE QSTNNR_VERSION_SID = 4) OR SECTION_VERSION_SID IN (SELECT SUB_SECTION_VERSION_SID FROM cfg_qstnnr_ver_subsections WHERE QSTNNR_VERSION_SID = 4));
 --Commit to prod on 12/01/23

 --SCP-2237
 INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
VALUES (353, 306, 912);

INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
VALUES (356, 307, 909);
INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
VALUES (356, 307, 910);
INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
VALUES (356, 307, 911);

DELETE CFG_QUESTION_CONDITIONS WHERE QUESTION_VERSION_SID = 378;
INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
VALUES (378, 373, 3);
UPDATE CFG_QUESTION_CONDITIONS SET LOV_SID = 1 WHERE QUESTION_VERSION_SID = 378;
--COMMIT TO PROD ON 13/01/23

--SCP-2238
UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Who is leading the evaluation analyses process? Please select all that apply.' WHERE QUESTION_VERSION_SID = 344;
--COMMIT TO PROD ON 13/01/23

--SCP-2240
UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'No change in {YEAR2}/{YEAR}'
 WHERE ELEMENT_TYPE_SID = 6
   AND QSTNNR_VERSION_SID = 4;
   
UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Reformed/Modified in {YEAR2}/{YEAR}'
 WHERE ELEMENT_TYPE_SID = 7
   AND QSTNNR_VERSION_SID = 4;  
--SCP-2241
UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'No change in {YEAR1}/{YEAR}'
 WHERE ELEMENT_TYPE_SID = 6
   AND QSTNNR_VERSION_SID = 4;
   
UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Reformed/Modified in {YEAR1}/{YEAR}'
 WHERE ELEMENT_TYPE_SID = 7
   AND QSTNNR_VERSION_SID = 4;  
   
UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Only practices implemented or planned between June {YEAR1} and January {YEAR} should be reported in the survey. Should the reported information need to be corrected and resubmitted, please send an email to ECFIN-GREEN-BUDGETING-SURVEY@ec.europa.eu'
 WHERE ELEMENT_TYPE_SID = 3
   AND QSTNNR_VERSION_SID = 4;

UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Please report information on practices under implementation or planned between June {YEAR1} and January {YEAR}.'
 WHERE ELEMENT_TYPE_SID = 2
   AND QSTNNR_VERSION_SID = 4;
   
   UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = '"To start 	Press '||chr(39)||'details'||chr(39)||' to review the answers from the previous year. ;
Press '||chr(39)||'no change in {YEAR1}/{YEAR}'||chr(39)||' if there was not any practical or legal change during the year. In this case, no changes can be made to the answers. ;
Press '||chr(39)||'reformed/modified in {YEAR1}/{YEAR}'||chr(39)||' in case there was a legal reform or change in practice with regard to your green budgeting practices. Please indicate the nature of the reform or change in practice in the pop-up screen. ;
Submit	After completing your questionnaire, remember to also press '||chr(39)||'submit'||chr(39)||' in the overview screen to finalise your submission. ;
Please, note that no further changes can be made after completion. In case you spot a mistake after completion or submission, please send an email to:   ECFIN-GREEN-BUDGETING-SURVEY@ec.europa
"'
 WHERE ELEMENT_TYPE_SID = 12
   AND QSTNNR_VERSION_SID = 4; 
COMMIT;   
--COMMIT TO PROD ON 16/01/23

--SCP-2242
UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Only practices implemented or planned between June {YEAR1} and the end of December {YEAR} should be reported in the survey. Should the reported information need to be corrected and resubmitted, please send an email to ECFIN-GREEN-BUDGETING-SURVEY@ec.europa.eu'
 WHERE ELEMENT_TYPE_SID = 3
   AND QSTNNR_VERSION_SID = 4;

UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Please report information on practices under implementation or planned between June {YEAR1} and the end of December {YEAR}.'
 WHERE ELEMENT_TYPE_SID = 2
   AND QSTNNR_VERSION_SID = 4;

UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Only practices implemented or planned between June {YEAR1} and the end of December {YEAR} should be reported in the survey. Should the reported information need to be corrected and resubmitted, please send an email to ECFIN-GREEN-BUDGETING-SURVEY@ec.europa.eu'
 WHERE ELEMENT_TYPE_SID = 4
   AND QSTNNR_VERSION_SID = 4;   
COMMIT;
--COMMIT TO PROD ON 19/01/23

-- DECLARE
--     --GET LIST OF QSTNNRS
--     CURSOR c_qsts IS 
--     SELECT * FROM CFG_QUESTIONNAIRES;
--     --GET THE INDEXES FOR THAT QST
--     CURSOR c_indices(pi_qst IN NUMBER) IS SELECT * FROM CFG_INDEXES WHERE QUESTIONNAIRE_SID = pi_qst;
--     --GET ALL ROUNDS FOR A QUESTIONNAIRE
--     CURSOR c_rounds(pi_app_id IN VARCHAR2) IS 
--     SELECT DISTINCT ROUND_SID FROM ENTRY_EDIT_STEPS WHERE ENTRY_SID IN (SELECT ENTRY_SID FROM ENTRIES WHERE APP_ID = pi_app_id);
--     --GET ALL THE ENTRIES THAT WERE ACTIVE IN THAT ROUND
-- CURSOR c_entries_data(pi_qst_sid IN NUMBER, pi_round_sid IN NUMBER) IS SELECT
--                            E.ENTRY_SID,
--                            E.ENTRY_VERSION,
--                            EES.EDIT_STEP_SID,
--                            CES.EDIT_STEP_ID,
--                            PES.EDIT_STEP_ID AS prev_step_id,
--                            CFG_QUESTIONNAIRE.getavailability(E.impl_date, E.reform_impl_date, E.reform_replaced_date, E.abolition_date
--                            ) AS availability,
--                            E.ENTRY_NO AS ENTRY_NUMBER
--                        FROM ENTRIES  E
--                            ,ENTRY_EDIT_STEPS EES
--                            ,CFG_EDIT_STEPS CES
--                            ,CFG_EDIT_STEPS PES
--                            ,CFG_QUESTIONNAIRES Q
--                        WHERE E.ENTRY_SID = EES.ENTRY_SID
--                          AND EES.EDIT_STEP_SID = CES.EDIT_STEP_SID
--                          AND EES.PREV_STEP_SID = PES.EDIT_STEP_SID(+)
--                          AND Q.APP_ID = E.APP_ID
--                          AND Q.QUESTIONNAIRE_SID = pi_qst_sid
-- --                         AND E.COUNTRY_ID = p_country_id
--                          AND EES.round_sid = pi_round_sid
--                          AND cfg_questionnaire.getavailability(E.IMPL_DATE, E.reform_impl_date, E.reform_replaced_date, E.abolition_date) IN (
--                                'C',
--                                'F'
--                            )
--                        ORDER BY
--                            ENTRY_NUMBER;
    
--     --GET THE LATEST SCORES FOR EACH ENTRY AND EACH INDEX
--     CURSOR c_scores(pi_entry_sid IN NUMBER, pi_index_sid IN NUMBER, pi_round_sid IN NUMBER) IS
--     WITH t AS (
--                 SELECT RC.ENTRY_SID
--                       ,E.ENTRY_NO
--                       ,E.ENTRY_VERSION
--                       ,RC.ROUND_SID
--                       ,C.CRITERION_SID
--                       ,RC.SCORE
--                       ,SV.ORDER_BY
--                       ,MAX(SV.ORDER_BY) OVER (PARTITION BY RC.ENTRY_SID, C.CRITERION_SID) MAX_ORDER_BY
--                   FROM ENTRY_CRITERIA RC
--                       ,CFG_INDEX_CRITERIA C
--                       ,CFG_INDEX_STAGES SV
--                       ,ENTRIES E
--                  WHERE RC.CRITERION_SID = C.CRITERION_SID
--                    AND SV.SCORE_VERSION_SID = RC.SCORE_VERSION_SID
--                    AND RC.ENTRY_SID = E.ENTRY_SID
--                    AND E.ENTRY_SID = pi_entry_sid
--                    AND C.INDEX_SID  = pi_index_sid
--                    AND (RC.ROUND_SID IS NULL OR RC.ROUND_SID = pi_round_sid) 
                   
--             )
--             SELECT DISTINCT ENTRY_SID,ENTRY_NO, ENTRY_VERSION, CRITERION_SID, SCORE FROM t WHERE t.ORDER_BY = t.MAX_ORDER_BY;
--     --ADD THE LATEST SCORES TO THE ARCHIVE OF SCORES

ALTER TABLE CFG_VINTAGE_ATTRIBUTES DROP COLUMN PREV_YEAR;
ALTER TABLE CFG_VINTAGE_ATTRIBUTES ADD (IS_FILTER NUMBER);

UPDATE CFG_VINTAGE_ATTRIBUTES
   SET IS_FILTER = 1
 WHERE VINTAGE_ATTR_SID in (86, 326, 327, 329, 331, 1, 43, 7, 187);

 
insert into indices_mtbfi_2022 values ('AT', 107, 0.5,	0.3333,	1	,0.75	,0.75, 0.67 );
insert into indices_mtbfi_2022 values ('BE', 97, 1	, 0.5, 	0.6667,	0.75,	0.5, 0.68 );
insert into indices_mtbfi_2022 values ('CZ', 94, 0.25,	0.6667,	0.6667,	0.5,	0.75, 0.57 );
insert into indices_mtbfi_2022 values ('FI', 328, 1, 0.8333,	0.66667,	0.75,	0.75, 0.8);



create table indices_mtbfi_2021 as select * from indices_mtbfi_2022;
delete  indices_mtbfi_2021;
insert into indices_mtbfi_2021(country_id, entry_sid) select country_id, entry_sid from indices_mtbfi_2022;
update indices_mtbfi_2021 set entry_sid = 95 where entry_sid = 351;
update indices_mtbfi_2021 set entry_sid = 116 where entry_sid = 328;
update indices_mtbfi_2021 set entry_sid = 100 where entry_sid = 391;
update indices_mtbfi_2021 set entry_sid = 111 where entry_sid = 373;
update indices_mtbfi_2021 set entry_sid = 114 where entry_sid = 350;
update indices_mtbfi_2021 set entry_sid = 118 where entry_sid = 354;
select * from indices_mtbfi_2021 order by 1;
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 0.5 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.5 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 0.75 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 0.25 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 0.3333, SDIM33 = 0, SDIM34 = 0.75 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 0.75 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.25 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.3333, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 0.75 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0, SDIM34 = 0.25 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2021 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';

UPDATE INDICES_MTBFI_2021 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);
CREATE TABLE INDICES_MTBFI_2020 AS SELECT * FROM INDICES_MTBFI_2021;
DELETE INDICES_MTBFI_2020;
INSERT INTO INDICES_MTBFI_2020(COUNTRY_ID, ENTRY_SID) SELECT COUNTRY_ID, ENTRY_SID FROM INDICES_MTBFI_2021;
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 0.5 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.5 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 0.75 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 0.25 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 0.3333, SDIM33 = 0, SDIM34 = 0.75 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 0.75 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.25 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.3333, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 0.75 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0, SDIM34 = 0.25 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2020 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2020 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);
UPDATE INDICES_MTBFI_2020 SET ENTRY_SID = 23 WHERE COUNTRY_ID = 'SK';

CREATE TABLE INDICES_MTBFI_2019 AS SELECT * FROM INDICES_MTBFI_2020;
DELETE INDICES_MTBFI_2019;
INSERT INTO INDICES_MTBFI_2019(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2020;
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 0.5 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.5 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 0.75 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 0.25 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 0.3333, SDIM33 = 0, SDIM34 = 0.75 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 0.75 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.25 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.3333, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 0.75 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0, SDIM34 = 0.25 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2019 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2019 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);

CREATE TABLE INDICES_MTBFI_2018 AS SELECT * FROM INDICES_MTBFI_2019;
DELETE INDICES_MTBFI_2018;
INSERT INTO INDICES_MTBFI_2018(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2019;
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 0.5 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.5 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 0.75 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 0.25 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 0.3333, SDIM33 = 0, SDIM34 = 0.75 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 0.75 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.25 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.3333, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 0.75 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0, SDIM34 = 0.25 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2018 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2018 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);


CREATE TABLE INDICES_MTBFI_2017 AS SELECT * FROM INDICES_MTBFI_2018;
DELETE INDICES_MTBFI_2017;
INSERT INTO INDICES_MTBFI_2017(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2018;
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 0.5 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.5 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 0.75 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 0.25 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 0.3333, SDIM33 = 0, SDIM34 = 0.75 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 0.75 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.25 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 0.75 , SDIM31 = 0.16667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 0.75 , SDIM31 = 0.16667, SDIM32 = 0.3333, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.16667, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 0.75 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.16667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0, SDIM34 = 0.25 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.16667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2017 SET SDIM30 = 0 , SDIM31 = 0, SDIM32 = 0, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2017 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);

CREATE TABLE INDICES_MTBFI_2016 AS SELECT * FROM INDICES_MTBFI_2017;
DELETE INDICES_MTBFI_2016;
INSERT INTO INDICES_MTBFI_2016(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2017;
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 0.5 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.5 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 0.75 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 0.25 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 0.3333, SDIM33 = 0, SDIM34 = 0.75 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 0.75 , SDIM31 = 0.6667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.8333, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 0.25 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.5, SDIM34 = 0.75 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 0.75 , SDIM31 = 0.1667, SDIM32 = 0.3333, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 0.75, SDIM34 = 0.75 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 0.75 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.6667, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0.5 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0.6667, SDIM33 = 0, SDIM34 = 0.25 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.1667, SDIM32 = 0.6667, SDIM33 = 1, SDIM34 = 0.75 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.5, SDIM32 = 1, SDIM33 = 0.5, SDIM34 = 1 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0.3333, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 0.75, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2016 SET SDIM30 = 0 , SDIM31 = 0, SDIM32 = 0, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2016 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);

CREATE TABLE INDICES_MTBFI_2015 AS SELECT * FROM INDICES_MTBFI_2016;
DELETE INDICES_MTBFI_2015;
INSERT INTO INDICES_MTBFI_2015(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2016;
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 0, SDIM34 = 2 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 0 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 2 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 2 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2015 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2015 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);

CREATE TABLE INDICES_MTBFI_2014 AS SELECT * FROM INDICES_MTBFI_2015;
DELETE INDICES_MTBFI_2014;
INSERT INTO INDICES_MTBFI_2014(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2015;
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 0, SDIM34 = 2 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 0 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 0 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 2 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2014 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2014 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);

CREATE TABLE INDICES_MTBFI_2013 AS SELECT * FROM INDICES_MTBFI_2014;
DELETE INDICES_MTBFI_2013;
INSERT INTO INDICES_MTBFI_2013(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2014;
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 0 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 0, SDIM34 = 2 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 0 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 0, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 3, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 0 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 2 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2013 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2013 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);

CREATE TABLE INDICES_MTBFI_2012 AS SELECT * FROM INDICES_MTBFI_2013;
DELETE INDICES_MTBFI_2012;
INSERT INTO INDICES_MTBFI_2012(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2013;
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 0 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 0, SDIM34 = 2 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 0 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 0, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 0 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 1 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 2 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2012 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2012 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);

CREATE TABLE INDICES_MTBFI_2011 AS SELECT * FROM INDICES_MTBFI_2012;
DELETE INDICES_MTBFI_2011;
INSERT INTO INDICES_MTBFI_2011(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2012;
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 0 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 0, SDIM34 = 2 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 0 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 0, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 0 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 0 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 2 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2011 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2011 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);

CREATE TABLE INDICES_MTBFI_2010 AS SELECT * FROM INDICES_MTBFI_2011;
DELETE INDICES_MTBFI_2010;
INSERT INTO INDICES_MTBFI_2010(COUNTRY_ID) SELECT COUNTRY_ID FROM INDICES_MTBFI_2011;
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'AT';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'BE';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 0, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'BG';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 0 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'CY';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 0, SDIM34 = 2 WHERE COUNTRY_ID = 'CZ';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'DE';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 0 WHERE COUNTRY_ID = 'DK';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 0, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'EE';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 0 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'EL';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 2 WHERE COUNTRY_ID = 'ES';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 1 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'FI';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'FR';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 2, SDIM34 = 0 WHERE COUNTRY_ID = 'HR';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 0, SDIM33 = 2, SDIM34 = 0 WHERE COUNTRY_ID = 'HU';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 1 , SDIM31 = 0, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'IE';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'IT';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'LT';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 0 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 1, SDIM34 = 0 WHERE COUNTRY_ID = 'LU';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'LV';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'MT';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'NL';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'PL';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 0 , SDIM31 = 1, SDIM32 = 1, SDIM33 = 0, SDIM34 = 0 WHERE COUNTRY_ID = 'PT';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 0, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'RO';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SE';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 1, SDIM33 = 2, SDIM34 = 1 WHERE COUNTRY_ID = 'SI';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 0, SDIM32 = 2, SDIM33 = 1, SDIM34 = 1 WHERE COUNTRY_ID = 'SK';
UPDATE INDICES_MTBFI_2010 SET SDIM30 = 2 , SDIM31 = 2, SDIM32 = 1, SDIM33 = 0, SDIM34 = 1 WHERE COUNTRY_ID = 'UK';
UPDATE INDICES_MTBFI_2010 SET SDIM35 = ROUND( (SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34)/5, 2);
COMMIT;

ALTER TABLE ENTRY_CHOICES
ADD (LAST_UPDATE DATE);
ALTER TABLE ENTRY_CHOICES_ARCH
ADD (LAST_UPDATE DATE);

--SCP-2249
DELETE FROM CFG_QSTNNR_VER_SUBSECTIONS
      WHERE PARENT_SECTION_VERSION_SID = 6
        AND SUB_SECTION_VERSION_SID = 7;
UPDATE CFG_QSTNNR_VER_SUBSECTIONS
   SET ORDER_BY = ORDER_BY - 1
 WHERE PARENT_SECTION_VERSION_SID = 6 AND ORDER_BY > 1;

--SCP-2253
DELETE CFG_QSTNNR_SECTION_QUESTIONS
  WHERE QUESTION_VERSION_SID = 12
    AND SECTION_VERSION_SID = 8;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS
   SET ORDER_BY = ORDER_BY - 1
 WHERE SECTION_VERSION_SID = 8
   AND ORDER_BY > 5;

--SCP-2251
ALTER TRIGGER CFG_QUESTION_TYPES_TRG DISABLE;
UPDATE CFG_QUESTION_TYPES
   SET ACCESSOR = 'EntryNumberValue'
 WHERE QUESTION_TYPE_SID = 7;
INSERT INTO CFG_QUESTION_TYPES(QUESTION_TYPE_SID, DESCR, ACCESSOR) VALUES (18, 'Assessment Number', 'EntryAssessmentNumberValue');
ALTER TRIGGER CFG_QUESTION_TYPES_TRG ENABLE;

UPDATE CFG_QUESTION_VERSIONS
   SET QUESTION_TYPE_SID = 18
 WHERE QUESTION_VERSION_SID IN (171, 172, 173, 174, 175, 176);  

DECLARE
    l_question_sid NUMBER;
    l_question_v_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Additional information on staff figures') RETURNING QUESTION_SID INTO l_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ALWAYS_MODIFY) 
    VALUES (l_question_sid, 13, 'Please, provide here any important classifications on the staff figures if you have any (e.g. if certain figures include temporary trainees or if a certain part of your employees is paid by another institution).', 0) RETURNING QUESTION_VERSION_SID INTO l_question_v_sid;
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (33, l_question_v_sid, 7);
    
END;
/
ALTER TABLE CFG_SECTION_VERSIONS ADD (INFO_MSG VARCHAR2(4000 BYTE));
UPDATE CFG_SECTION_VERSIONS
  SET INFO_MSG = 'When filling in the figures below, please take into account the following points:
  All staff figures are reported in fulltime equivalents (FTE).
  Figures should ALSO include staff working in your secretariat.
  Figures in the different categories should not overlap.
  In case of an attached/embedded IFI institution, please ONLY include staff working on IFI-related tasks (or please give a rough estimate).
  Please note that you can only use numbers. Any additional information or specifications can be added in the final question.'
  
WHERE SECTION_VERSION_SID = 33; 

--SCP-2246 TASK-1
DECLARE
    l_question_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Additional information on monitoring of compliance with fiscal rules') RETURNING QUESTION_SID INTO l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET QUESTION_SID = l_question_sid
          ,HELP_TEXT = 'Please give any additional information on monitoring of compliance with national fiscal rules that may not have been addressed in this section'
     WHERE QUESTION_VERSION_SID = 124;
END;
/
--SCP-2246 TASK-2
DECLARE
    l_question_sid NUMBER;
    l_qv_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_sid NUMBER;
    l_choice_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Endorsement of main forecast?') RETURNING QUESTION_SID INTO l_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, 1, 'If your produced macroeconomic forecast is not used for fiscal planning, do you also assess or officially endorse the macroeconomic forecast that IS used by the government for fiscal planning?', 1, 0)
    RETURNING QUESTION_VERSION_SID INTO l_qv_sid;
    
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
      SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID = 26 AND ORDER_BY > 3;  
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY) VALUES (26, l_qv_sid, 4);
    
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('YESWEBNO', 'Yes (provide weblink) or No', 0) RETURNING LOV_TYPE_SID INTO l_lov_type_sid;

    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (l_lov_type_sid, 'Yes (please provide weblink)', 1, 1);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (l_lov_type_sid, 'No', NULL, 2);
    
    SELECT LOV_SID INTO l_choice_sid FROM CFG_LOVS WHERE DESCR = 'Production of macro-economic forecasts, but these are not used for the national fiscal planning';
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_qv_sid, 127, l_choice_sid) RETURNING COND_SID INTO l_cond_sid;
    
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, COND_SID, LOV_TYPE_SID)
    VALUES (l_qv_sid, l_cond_sid, l_lov_type_sid);
END;
/

DECLARE
    l_question_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Additional information on macroeconomic forecasting') RETURNING QUESTION_SID INTO l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET QUESTION_SID = l_question_sid
          ,HELP_TEXT = 'Please give any additional information on macroeconomic forecasting that may not have been addressed in this section'
     WHERE QUESTION_VERSION_SID = 143;
END;
/

--SCP-2246 TASK-3
UPDATE CFG_LOVS
   SET DESCR = REPLACE(DESCR, 'budgetary forecasts', 'budgetary forecasts used for annual budget planning')
 WHERE LOV_TYPE_SID = 156;

DECLARE
    l_question_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Additional information on budgetary forecasting') RETURNING QUESTION_SID INTO l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET QUESTION_SID = l_question_sid
          ,HELP_TEXT = 'Please give any additional information on budgetary forecasting that may not have been addressed in this section'
     WHERE QUESTION_VERSION_SID = 155;
END;
/
UPDATE CFG_QUESTIONS
   SET DESCR = 'Time horizon of long-term projections'
 WHERE QUESTION_SID = 141;  
UPDATE CFG_QUESTION_VERSIONS
   SET HELP_TEXT = 'Please specify the time horizon of the long-term projections in number of years (n.b.: this is typically more than more than 5 years)'
 WHERE QUESTION_VERSION_SID IN (141, 152); 

--SCP-2246 TASK-4
UPDATE CFG_LOVS
  SET DESCR = 'Quality of government finances, e.g. in terms of composition of revenue and expenditure'
  WHERE LOV_SID = 186;

DELETE FROM CFG_QUESTION_CONDITIONS WHERE QUESTION_VERSION_SID IN (160, 161);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (160, 157, 835);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (160, 157, 836);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (161, 157, 837);
INSERT INTO CFG_QUESTION_CONDITIONS (QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (161, 157, 838);
UPDATE CFG_LOVS
  SET NEED_DET = 1
 WHERE LOV_SID = 839;
UPDATE CFG_LOVS
  SET DESCR = 'Quality of government finances, e.g. in terms of composition of revenue and expenditure'
 WHERE LOV_SID = 846;    

--SCP-2246 TASK-5
UPDATE CFG_QUESTIONS
   SET DESCR = 'Reaction from government during year of reference'
 WHERE QUESTION_SID = 202;  
UPDATE CFG_QUESTION_VERSIONS
   SET HELP_TEXT = 'There was at least one official response/reaction from the government to your reports published in the course of the year of reference, either as part of national comply-or-explain arrangement or other form of fiscal policy dialogue?'
 WHERE   QUESTION_VERSION_SID = 202;

--SCP-2250
UPDATE CFG_LOVS
   SET CFG_TYPE = 3
 WHERE LOV_SID IN (466, 470);

--SCP-2244
 DECLARE
    l_section_version_sid NUMBER;
    CURSOR c_data IS
        SELECT 1 AS no FROM DUAL
        UNION 
        SELECT 3 AS no FROM DUAL
        UNION
        SELECT 5 AS no FROM DUAL
        UNION
        SELECT 7 AS no FROM DUAL;
BEGIN
    INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD)
    VALUES (46,  'Targets', 1) RETURNING SECTION_VERSION_SID INTO l_section_version_sid;
    
    UPDATE CFG_QSTNNR_VER_SUBSECTIONS
       SET ORDER_BY = ORDER_BY + 1
     WHERE PARENT_SECTION_VERSION_SID = 45
       AND QSTNNR_VERSION_SID = 3;
    
    INSERT INTO CFG_QSTNNR_VER_SUBSECTIONS(QSTNNR_VERSION_SID, PARENT_SECTION_VERSION_SID, SUB_SECTION_VERSION_SID, ORDER_BY)
    VALUES (3, 45, l_section_version_sid, 1);
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, 299, 1);
    
    DELETE CFG_QSTNNR_SECTION_QUESTIONS
      WHERE QUESTION_VERSION_SID = 299
        AND SECTION_VERSION_SID = 46;
    
    FOR idx IN c_data LOOP
        INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS VALUES (l_section_version_sid, idx.no);
    END LOOP;
END;

--SCP-2254
DECLARE
    l_elem_type_sid NUMBER;
BEGIN
    INSERT INTO CFG_UI_ELEMENT_TYPES(ELEMENT_TYPE_ID, DESCR) VALUES ('VINTAGE_HEADER_INFO_MSG', 'Info message on Vintages page') RETURNING ELEMENT_TYPE_SID INTO l_elem_type_sid;
    
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'Please, note that the ad-hoc questions in the IFI survey are replaced each round to allow more topical analysis and are therefore different from year to year.', 2, 'DEFAULT');
END;
/
--COMMIT TO PROD ON 08/03/2023

--SCP-2259
UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Only practices implemented or planned between June {YEAR2} and the end of December {YEAR1} should be reported in the survey. Should the reported information need to be corrected and resubmitted, please send an email to ECFIN-GREEN-BUDGETING-SURVEY@ec.europa.eu'
 WHERE ELEMENT_TYPE_SID = 3
   AND QSTNNR_VERSION_SID = 4;

UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Please report information on practices under implementation or planned between June {YEAR2} and the end of December {YEAR1}.'
 WHERE ELEMENT_TYPE_SID = 2
   AND QSTNNR_VERSION_SID = 4;

UPDATE CFG_UI_QSTNNR_ELEMENTS
   SET ELEMENT_TEXT = 'Only practices implemented or planned between June {YEAR2} and the end of December {YEAR1} should be reported in the survey. Should the reported information need to be corrected and resubmitted, please send an email to ECFIN-GREEN-BUDGETING-SURVEY@ec.europa.eu'
 WHERE ELEMENT_TYPE_SID = 4
   AND QSTNNR_VERSION_SID = 4; 
-- commit to prod on 09/03/2023

--SCP-2244
UPDATE CFG_QSTNNR_VER_SECTIONS
  SET ORDER_BY = 1
  WHERE QSTNNR_VERSION_SID = 3
    AND SECTION_VERSION_SID = 45;
UPDATE CFG_QSTNNR_VER_SECTIONS
  SET ORDER_BY = ORDER_BY + 1
  WHERE QSTNNR_VERSION_SID = 3
    AND SECTION_VERSION_SID != 45;
-- commit to prod on 09/03/2023

--SCP-2246
update CFG_QUESTION_LOV_TYPES SET COND_SID = NULL WHERE QUESTION_VERSION_SID = 449;
-- commit to prod on 09/03/2023

DECLARE 
    l_qv NUMBER;
BEGIN
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ACCESSOR) VALUES (44, 6, 'Please indicate the main reasons for the reform', 'REFORM_REASON')
    RETURNING QUESTION_VERSION_SID INTO l_qv;
    
    INSERT INTO cfg_qstnnr_section_questions(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY) VALUES (54, l_qv, 8);
END;
/
update CFG_VINTAGE_ATTRIBUTES
set order_by = order_by +4 where app_id = 'GBD'
and order_by >60;
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'422','Transparency and accountability of the environmental evaluation analyses','Methodology',0,61,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'423','Link to public documentation','Methodology',0,62,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'424','Responsible for the independent evaluation','Methodology',0,63,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'425','Other remarks on the chosen methodology for the environmental evaluation analysis','Methodology',0,64,null);

update CFG_VINTAGE_ATTRIBUTES
set order_by = order_by + 3 where app_id = 'GBD'
and order_by >75;
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'426','Impact assessments linked to budgetary process','Legal basis and Governance',0,76,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'427','Weblink to document formalising process','Legal basis and Governance',0,77,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'428','Stakeholder(s) in the lead','Legal basis and Governance',0,78,null);
update CFG_VINTAGE_ATTRIBUTES
set order_by = order_by + 5 where app_id = 'GBD'
and order_by >78;
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'429','Evaluations analyses linked to budgetary process','Legal basis and Governance',0,80,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'434','Weblink to document formalising process','Legal basis and Governance',0,81,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'435','Stakeholder(s) in the lead','Legal basis and Governance',0,82,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'430','Stakeholders involved','Legal basis and Governance',0,83,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'431','Description of the process','Legal basis and Governance',0,84,null);

Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'432','Helpfulness COM training','Ad-hoc questions',0,114,null);
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'433','Further support','Ad-hoc questions',0,115,null);

update CFG_VINTAGE_ATTRIBUTES
set order_by = order_by + 1 where app_id = 'GBD'
and order_by > 9;
Insert into CFG_VINTAGE_ATTRIBUTES (APP_ID,ATTR_TYPE_SID,ATTR_VALUE,DISPLAY_NAME,DISPLAY_PREFIX,DEFAULT_SELECTED,ORDER_BY,IS_FILTER) values ('GBD',5,'438','Reason for the Reform','General',0,10,null);

--SCP-2257
UPDATE CFG_LOVS
   SET DESCR = 'Production of budgetary forecasts, but these are not used for the national fiscal planning'
 WHERE LOV_SID = 678;
UPDATE CFG_LOVS
  SET DESCR = 'Production of the official budgetary forecasts used for national fiscal planning'
  WHERE LOV_SID = 677;
UPDATE CFG_LOVS
   SET DESCR = 'Official endorsement of the government`s budgetary forecasts used for national fiscal planning (within the meaning of Art. 4.4 of the Two-Pack Regulation 473/2013)'
  WHERE LOV_SID = 679;
UPDATE CFG_LOVS
  SET DESCR = 'Assessment of budgetary forecasts BEFORE the adoption in the Parliament of the budgetary planning documents'
  WHERE LOV_SID = 680;
UPDATE CFG_LOVS
  SET DESCR = 'Assessment of the budgetary forecasts AFTER the adoption in the Parliament of the budgetary planning documents'
  WHERE LOV_SID = 681;
UPDATE CFG_LOVS
   SET DESCR = 'The fiscal institution is consulted at the start or during the preparation of budgetary forecasts used for national fiscal planning'
   WHERE LOV_SID = 682;
-- COMMIT TO PROD ON 21/03/23

--SCP-2260
UPDATE CFG_QUESTION_VERSIONS
  SET HELP_TEXT = 'Please specify the time horizon of the long-term projections in number of years (n.b. this is typically 5 years or more).'
  WHERE QUESTION_SID = 141;
-- COMMIT TO PROD ON 21/03/23  

--SCP-2252
DECLARE
    l_question_sid NUMBER;
    l_question_v1_sid NUMBER;
    l_question_v2_sid NUMBER;
    l_question_v3_sid NUMBER;
    l_question_v4_sid NUMBER;
    l_question_v5_sid NUMBER;
    l_question_v6_sid NUMBER;
    l_lov_type NUMBER;
    l_lov_type2 NUMBER;
    l_lov_type3 NUMBER;
    l_lov_type4 NUMBER;
    l_cond_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Sources of fiscal risks') RETURNING QUESTION_SID INTO l_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ALWAYS_MODIFY, MANDATORY) 
    VALUES (l_question_sid, 2, 'What are, in your IFI’s view, the most important sources of fiscal risk in your country? Please select up to four answers and please specify through which channel you see the risk could materialize (i.e., cause of the risk).', 0, 1) RETURNING QUESTION_VERSION_SID INTO l_question_v1_sid;
    
    
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('SFSRK', 'Sources of fiscal risk', 0) RETURNING LOV_TYPE_SID INTO l_lov_type;
    
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Climate change (e.g.: natural disasters; expenditure for adaptation; costs of structural change like education, investments, social compensation payments; stranded assets; etc.)', 1, 1, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Social discontent (i.e., high demand for social services leading to higher public spending)', 1, 2, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Disruptions to international trade', 1, 3, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Military tensions or conflicts (incl. defence spending)', 1, 4, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Global recession', 1, 5, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Realisation of contingent liabilities (e.g., calls on guarantees, non-performing loans incl. public-private partnerships and state-owned enterprises)', 1, 6, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Rising healthcare expenditure and ageing costs', 1, 7, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Price volatility / extreme inflation or deflation (incl. energy prices)', 1, 8, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'Other', 1, 9, NULL, NULL, 4);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type, 'None of the above', NULL, 10, 3, NULL, NULL);
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (72, l_question_v1_sid, 1);
    
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_v1_sid, l_lov_type);
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Quantification and disclosure') RETURNING QUESTION_SID INTO l_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ALWAYS_MODIFY, MANDATORY) VALUES (l_question_sid, 1, 'Are these risks quantified in some way? If yes, are the methodologies and calculations made public?', 0, 1) RETURNING QUESTION_VERSION_SID INTO l_question_v2_sid;
    
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('QUDISC', 'Quantification and disclosure', 0) RETURNING LOV_TYPE_SID INTO l_lov_type2;
    
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type2, '(Some of) these risks are quantified, and the methodology and calculations are (soon) made public. Please specify which risks, and provide weblink for relevant methodologies/calculations.', 1, 1, NULL, NULL, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type2, '(Some of) these risks are quantified, but the methodology and calculations are not made public. Please specify which risks are quantified.', 1, 2, NULL, NULL, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type2, 'None of these risks are quantified as far as we are aware. ', NULL, 3, NULL, NULL, NULL);
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (72, l_question_v2_sid, 2);
    
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_v2_sid, l_lov_type2);
    
    FOR rec IN (SELECT LOV_SID FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type AND DESCR != 'None of the above') LOOP
        INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (l_question_v2_sid, l_question_v1_sid, rec.LOV_SID);
    END LOOP;
    
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Tools and strategies in place for fiscal risks') RETURNING QUESTION_SID INTO l_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ALWAYS_MODIFY, MANDATORY) 
    VALUES (l_question_sid, 1, 'Are there, in your IFI’s view, sufficient budgetary tools or strategies (incl. in disclosure and forecasts) in place in your country’s national fiscal framework to reduce/manage/adapt to existing and emerging fiscal risks? ', 0, 1) RETURNING QUESTION_VERSION_SID INTO l_question_v3_sid;
    
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('TSPFRK', 'Tools and strategies in place for fiscal risks', 0) RETURNING LOV_TYPE_SID INTO l_lov_type3;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type3, 'Yes. Please specify which tools or strategies.', 1, 1, NULL, NULL, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type3, 'No. Please specify what, in your view, could be improved in that regard by your government?', 1, 2, NULL, NULL, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type3, 'Not sure. Please specify for what reason you are unsure (e.g., non-disclosure of risks by government)', 1, 3, NULL, NULL, NULL);
    
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_v3_sid, l_lov_type3);
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (72, l_question_v3_sid, 3);
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Your IFI'||chr(39)||'s activities on fiscal risks') RETURNING QUESTION_SID INTO l_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ALWAYS_MODIFY, MANDATORY) 
    VALUES (l_question_sid, 2, 'What does your IFI do (and/or would you like to do) to help your government mitigate/adapt to/manage these risks?', 0, 1) RETURNING QUESTION_VERSION_SID INTO l_question_v4_sid;
    
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('IFIACFRK', 'IFI activities on fiscal risks', 0) RETURNING LOV_TYPE_SID INTO l_lov_type4;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type4, 'Our IFI currently already undertakes activities that help mitigate such risks. Please describe which activities', 1, 1, NULL, NULL, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type4, 'Our IFI would like to undertake the following activities to help mitigate these risks in the future', 1, 2, NULL, NULL, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE, HELP_TEXT, CHOICE_LIMIT) VALUES (l_lov_type4, 'Our IFI currently undertakes no such activities and does not plan to do so.', 1, 3, 3, NULL, NULL);
    
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_v4_sid, l_lov_type4);
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (72, l_question_v4_sid, 4);
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('EU level policies on fiscal risks') RETURNING QUESTION_SID INTO l_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ALWAYS_MODIFY, MANDATORY) 
    VALUES (l_question_sid, 5, 'In your IFI’s view, what EU level policies or projects help to mitigate/adapt to these risks and what could be done more at EU level?', 0, 1) RETURNING QUESTION_VERSION_SID INTO l_question_v5_sid;
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Additional information on fiscal risks') RETURNING QUESTION_SID INTO l_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ALWAYS_MODIFY, MANDATORY) 
    VALUES (l_question_sid, 2, 'Do you have any other comments on fiscal risks in your country, that are not addressed in this section? ', 0, 0) RETURNING QUESTION_VERSION_SID INTO l_question_v6_sid;
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (72, l_question_v5_sid, 5);
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (72, l_question_v6_sid, 6);

    UPDATE CFG_SECTION_VERSIONS
      SET INFO_MSG = 'We use the following definition of fiscal risks: “factors (expected or unexpected) that can cause changes to fiscal outcomes (e.g. cause the general government debt ratio to be higher than initially expected)”'
    WHERE SECTION_VERSION_SID = 72;
    
END;
/

DECLARE
    l_q_sid NUMBER;
    l_qv_sid NUMBER;
BEGIN
    SELECT QUESTION_SID INTO l_q_sid FROM CFG_QUESTIONS WHERE DESCR = 'Additional information on fiscal risks';
    
    UPDATE CFG_QUESTION_VERSIONS SET QUESTION_TYPE_SID = 5 WHERE QUESTION_SID = l_q_sid;
COMMIT;
END;
/
--commit on prod on 21/03/23

--SCP-2262
UPDATE CFG_CUSTOM_HEADERS
  SET  IN_QUESTIONNAIRE = 'Status'
  WHERE CUSTOM_HEADER_ID = 'AVAILABILITY';
  
UPDATE CFG_HEADERS
  SET SHORT = 'First version in force since'
  WHERE QSTNNR_VERSION_SID = 1 AND QUESTION_VERSION_SID = 409;
COMMIT;
--commit to prod on 31/03/23  

--SCP-2269
UPDATE CFG_QUESTION_VERSIONS
   SET ALWAYS_MODIFY = 1
  WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Endorsement of main forecast?');
COMMIT;
--COMMIT TO PROD ON 14/04/2023

--UPDATE VINTAGE CFG
ALTER TABLE CFG_VINTAGE_ATTRIBUTES ADD (DISPLAY_HELP VARCHAR2(4000 BYTE));
DROP VIEW TMP_SECTION_SUBS;
create view TMP_SECTION_SUBS as WITH T AS (SELECT QVS.SECTION_VERSION_SID as parent_section_sid
                    , CS.SECTION_ID
                    ,SV.SECTION_VERSION_SID
              ,CS2.SECTION_ID as DESCR
              ,CQ.APP_ID
                 FROM CFG_QSTNNR_VERSIONS QV
                     ,CFG_QSTNNR_VER_SECTIONS QVS
                     ,CFG_SECTION_VERSIONS S
                     ,CFG_SECTIONS CS
                     ,CFG_QUESTIONNAIRES CQ
                     
                     , CFG_SECTIONS CS2
              ,CFG_SECTION_VERSIONS SV
              ,CFG_QSTNNR_VER_SUBSECTIONS QVSS
                WHERE QVS.QSTNNR_VERSION_SID = QV.QSTNNR_VERSION_SID
                  AND S.SECTION_VERSION_SID = QVS.SECTION_VERSION_SID
                  AND CS.SECTION_SID = S.SECTION_SID
                  AND CQ.QUESTIONNAIRE_SID = QV.QSTNNR_VERSION_SID
                  
                  
                  AND CS2.SECTION_SID = SV.SECTION_SID
           AND SV.SECTION_VERSION_SID = QVSS.SUB_SECTION_VERSION_SID
           AND QVSS.PARENT_SECTION_VERSION_SID = QVS.SECTION_VERSION_SID
UNION
    SELECT QVS.SECTION_VERSION_SID as parent_section_sid
                    , CS.SECTION_ID
                    ,NULL AS SECTION_VERSION_SID
              ,NULL as DESCR
              ,CQ.APP_ID
                 FROM CFG_QSTNNR_VERSIONS QV
                     ,CFG_QSTNNR_VER_SECTIONS QVS
                     ,CFG_SECTION_VERSIONS S
                     ,CFG_SECTIONS CS
                     ,CFG_QUESTIONNAIRES CQ
                     
                     
                WHERE QVS.QSTNNR_VERSION_SID = QV.QSTNNR_VERSION_SID
                  AND S.SECTION_VERSION_SID = QVS.SECTION_VERSION_SID
                  AND CS.SECTION_SID = S.SECTION_SID
                  AND CQ.QUESTIONNAIRE_SID = QV.QSTNNR_VERSION_SID
                  
                  AND QVS.SECTION_VERSION_SID NOT IN (SELECT PARENT_SECTION_VERSION_SID FROM CFG_QSTNNR_VER_SUBSECTIONS)
           )
SELECT CASE
        WHEN SECTION_VERSION_SID IS NULL THEN T.PARENT_SECTION_SID ELSE T.SECTION_VERSION_SID
      END AS SECTION_VERSION_SID
      , CASE
            WHEN SECTION_VERSION_SID IS NULL THEN T.SECTION_ID ELSE T.SECTION_ID || ' - ' || T.DESCR
    END AS SECTION_DESCR
        ,T.APP_ID
        FROM T;

declare
cursor c_nfr is
        select tab.app_id
              ,tab.section_version_sid
              ,tab.section_descr
              ,to_char(qsq.question_version_sid) as question_version_sid
              ,q.descr
              ,qv.help_text
              ,qv.accessor
              ,qv.question_type_sid
              ,qsq.order_by
              ,row_number() over (
              order by tab.app_id, tab.section_version_sid, qsq.order_by) as questionnaire_order_by
            from TMP_SECTION_SUBS tab,
                 cfg_qstnnr_section_questions qsq,
                 cfg_questions q,
                 cfg_question_versions qv
        where tab.section_version_sid = qsq.section_version_sid
          and qsq.question_version_sid = qv.question_version_sid
          and qv.question_sid = q.question_sid
          order by tab.app_id, tab.section_version_sid, qsq.order_by;
          
begin
    for rec in c_nfr loop
        update cfg_vintage_attributes
           set display_prefix = rec.section_descr
              ,display_name = rec.descr
              ,display_help = rec.help_text
          where attr_value = rec.question_version_sid
           ;
        if rec.app_id != 'NFR' then
            update cfg_vintage_attributes
            set order_by = rec.questionnaire_order_by
            where attr_value = rec.question_version_sid
           ;
        end if;
    end loop;
end; 
/        
COMMIT
--COMMIT TO PROD ON 18/04/2023

--SCP-2272
UPDATE CFG_QUESTIONS
   SET DESCR = 'Reference to rule in annual budget document'
 WHERE DESCR = 'Format of Reference'; 

DELETE CFG_QUESTION_CONDITIONS WHERE QUESTION_VERSION_SID IN (63);

UPDATE CFG_QUESTION_VERSIONS  
   SET QUESTION_TYPE_SID = 14
 WHERE QUESTION_VERSION_SID = 63;

DECLARE
    l_qv_sid NUMBER;
    l_lov_type NUMBER;
BEGIN
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, ALWAYS_MODIFY) 
    VALUES (42, 14, 'Please specify the extent to which the annual budget document reflects the fiscal rule.', 0) RETURNING QUESTION_VERSION_SID INTO l_qv_sid;
    
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID) VALUES ('FMTREF2', 'Format of reference', 0) RETURNING LOV_TYPE_SID INTO l_lov_type;
    
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_qv_sid, l_lov_type);
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY) VALUES (15, l_qv_sid, 13);
    DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = 15 AND QUESTION_VERSION_SID = 63;
    
    INSERT INTO CFG_LOVS (LOV_TYPE_SID, DESCR, ORDER_BY, HELP_TEXT) VALUES (l_lov_type, 'Chapter or Paragraph ', 1, 'Yes, there is a chapter/paragraph devoted to compliance with the target of the rule for the year of reference (i.e. ex-post compliance)');
    INSERT INTO CFG_LOVS (LOV_TYPE_SID, DESCR, ORDER_BY, HELP_TEXT) VALUES (l_lov_type, 'Cursory Reference', 2, 'Yes, there is cursory reference to the numerical fiscal rule and/or the implied target');
    INSERT INTO CFG_LOVS (LOV_TYPE_SID, DESCR, ORDER_BY, HELP_TEXT) VALUES (l_lov_type, 'No reference to rule in annual budget document', 3, NULL);
    INSERT INTO CFG_LOVS (LOV_TYPE_SID, DESCR, ORDER_BY, HELP_TEXT) VALUES (55, 'No reference to rule in annual budget document', 3, NULL);
END;
/
COMMIT;

--SCP-2273
UPDATE CFG_QUESTION_VERSIONS 
   SET MANDATORY = 1
 WHERE QUESTION_SID IN (
SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR IN( 'Was the rule complied with ex-ante?', 'Perceived Nature of the Constraint', 'Media Coverage', 'Reason for non compliance', 'Impact on next year'||CHR(39)||'s budget preparation')
);
COMMIT;
--COMMIT TO PROD ON 25/04/2023


--bugfixes and improvements
UPDATE CFG_QUESTION_VERSIONS
   SET ALWAYS_MODIFY = 1
   WHERE QUESTION_SID IN (
select QUESTION_SID from cfg_questions where descr = 'Activities in the area of normative recommendations');

UPDATE CFG_QUESTION_VERSIONS
   SET ALWAYS_MODIFY = 1
   WHERE QUESTION_SID IN (
select QUESTION_SID from cfg_questions where descr = 'Endorsement of main forecast?');1
COMMIT;
UPDATE CFG_LOVS
   SET DESCR = 'The government is free to use its own forecasts, but deviations from the fiscal institution'||CHR(39)||'s forecasts have to be justified publicly'
 WHERE DESCR = 'The government is free to use its own forecasts, but deviations from the fiscal institution`s forecasts have to be justified publicly' 
   AND lov_type_sid = 152;
UPDATE CFG_LOVS
   SET DESCR = 'The government is free to use its own forecasts, without any obligation to provide justification for deviations from the fiscal institution'||CHR(39)||'s forecasts'
 WHERE DESCR = 'The government is free to use its own forecasts, without any obligation to provide justification for deviations from the fiscal institution`s forecasts' 
   AND lov_type_sid = 152;
UPDATE CFG_LOVS
   SET DESCR = 'There is a legal or constitutional obligation to use the fiscal institution'||CHR(39)||'s forecasts'
 WHERE DESCR = 'There is a legal or constitutional obligation to use the fiscal institution`s forecasts' 
   AND lov_type_sid = 152;   
UPDATE CFG_LOVS
   SET DESCR = 'There is a political agreement that the fiscal institution'||CHR(39)||'s forecasts are generally used'
 WHERE DESCR = 'There is a political agreement that the fiscal institution`s forecasts are generally used' 
   AND lov_type_sid = 152;   
COMMIT;
UPDATE CFG_QUESTION_VERSIONS
  SET ADD_INFO = 0 WHERE QUESTION_VERSION_SID = 111;
COMMIT;
--SCP-2277
UPDATE CFG_LOVS
   SET HELP_TEXT = 'Please explain why not.'
   WHERE DESCR = 'Our IFI currently undertakes no such activities and does not plan to do so.';
COMMIT;
UPDATE CFG_QUESTION_VERSIONS
   SET ACCESSOR = 'REFORM_REASON'
 WHERE QUESTION_VERSION_SID IN( 75, 217);
 
 
 DECLARE
    CURSOR c_data IS SELECT ENTRY_SID, RESPONSE FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID IN (75, 217);
BEGIN
    FOR rec IN c_data LOOP
    UPDATE ENTRIES
      SET REFORM_REASON = rec.RESPONSE
      WHERE ENTRY_SID = rec.ENTRY_SID;
    END LOOP;
END;
/
COMMIT;
--commit to prod on 26.04.23     

--SCP-2276
update cfg_question_lov_types
  set lov_type_sid = 2 where question_version_sid = 111;
update entry_choices
   set response = 3 where response = 1 and question_version_sid = 111;
update entry_choices
   set response = 4 where response = 2 and question_version_sid = 111;
commit;

--SCP-2281
update cfg_question_versions 
   set help_text = 'What are, in your IFI'||chr(39)||'s view, the most important sources of fiscal risk in your country (affecting the government baseline scenario or more general)? Please select up to four answers ...' 
   where question_sid in (select question_sid from cfg_questions where descr = 'Sources of fiscal risks');

update cfg_question_versions 
   set help_text = 'Are these risks quantified in some way by you and/or your government? If yes, are the methodologies and calculations made public?' 
   where question_sid in (select question_sid from cfg_questions where descr = 'Quantification and disclosure');   

update cfg_question_versions 
   set help_text = 'Are there, in your IFI'||chr(39)||'s view, sufficient budgetary tools or strategies (e.g. with regard to disclosure, forecasts, early warning mechanisms or stress tests) in place in your country'||chr(39)||'s national fiscal framework to reduce/manage/adapt to existing and emerging fiscal risks.' 
   where question_sid in (select question_sid from cfg_questions where descr = 'Tools and strategies in place for fiscal risks'); 
commit;   

--SCP-2280
UPDATE CFG_DYNAMIC_LOVS
    SET DESCR = 'Rule {ENTRY_NO}: {QV1} - {QV2} (Coverage of GG finances: {COVERAGE})'
     WHERE DYN_SID = 2 AND DESCR = 'Rule {ENTRY_NO}: {QV1} - {QV2} - Coverage of GG finances: {COVERAGE}';
update cfg_question_versions 
  set help_text = 'Which of these fiscal rules does your institution monitor compliance for? These rules, including coverage, stem from the fiscal rules survey filled in by your Ministry. Please, note that GG stands for general government.'
  where question_sid in(select question_sid from cfg_questions where descr = 'Rules monitored by institution');
commit;
--commit to prod on 27.04.23

DROP SEQUENCE CFG_UI_FIELD_TYPES_SEQ;
DROP TABLE CFG_UI_FIELD_TYPES cascade constraints;
CREATE SEQUENCE CFG_UI_FIELD_TYPES_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE TABLE CFG_UI_FIELD_TYPES(
    FIELD_TYPE_SID NUMBER,
    FIELD_TYPE_ID VARCHAR2(4000 BYTE),
        CONSTRAINT "CFG_UI_FIELD_TYPES_PK" PRIMARY KEY ("FIELD_TYPE_SID")
    );
CREATE OR REPLACE TRIGGER CFG_UI_FIELD_TYPES_TRG 
    BEFORE INSERT
    ON CFG_UI_FIELD_TYPES
    FOR EACH ROW
    DECLARE
    BEGIN
       SELECT CFG_UI_FIELD_TYPES_SEQ.NEXTVAL INTO :NEW.FIELD_TYPE_SID FROM dual;
END CFG_UI_FIELD_TYPES_TRG;

/
ALTER TRIGGER "CFG_UI_FIELD_TYPES_TRG" ENABLE;

DROP TABLE CFG_UI_DIALOG_FIELDS;
DROP SEQUENCE CFG_UI_DIALOG_FIELDS_SEQ;
CREATE SEQUENCE CFG_UI_DIALOG_FIELDS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE TABLE CFG_UI_DIALOG_FIELDS(
    DF_SID NUMBER,
    FIELD_TYPE_SID NUMBER,
    QUESTIONNAIRE_SID NUMBER,
    FIELD_DISABLED NUMBER,
    FIELD_VALUE VARCHAR2(4000 BYTE),
    ENTRY_ADD_ATTRIBUTE VARCHAR2(4000 BYTE),
    ENTRY_ATTRIBUTE VARCHAR2(4000 BYTE),
    FIELD_LABEL VARCHAR2(4000 BYTE),
    FIELD_NAME  VARCHAR2(4000 BYTE),
    FIELD_VALIDATION VARCHAR2(4000 BYTE),
    FIELD_MIN_DATE NUMBER,
    FIELD_MAX_DATE NUMBER,
    ORDER_BY NUMBER,
        CONSTRAINT "CFG_UI_DIALOG_FIELDS_PK" PRIMARY KEY ("DF_SID"),
        CONSTRAINT "CFG_UI_DIALOG_FIELDS_FK1" FOREIGN KEY ("FIELD_TYPE_SID")
            REFERENCES "CFG_UI_FIELD_TYPES" ("FIELD_TYPE_SID"),
        CONSTRAINT "CFG_UI_DIALOG_FIELDS_FK2" FOREIGN KEY ("QUESTIONNAIRE_SID")
            REFERENCES "CFG_QUESTIONNAIRES" ("QUESTIONNAIRE_SID") ENABLE
);

CREATE OR REPLACE TRIGGER CFG_UI_DIALOG_FIELDS_TRG
    BEFORE INSERT
    ON CFG_UI_DIALOG_FIELDS
    FOR EACH ROW
    DECLARE
    BEGIN
       SELECT CFG_UI_DIALOG_FIELDS_SEQ.NEXTVAL INTO :NEW.DF_SID FROM dual;
END CFG_UI_DIALOG_FIELDS_TRG;
/
ALTER TRIGGER "CFG_UI_DIALOG_FIELDS_TRG" ENABLE;

INSERT INTO CFG_UI_FIELD_TYPES(FIELD_TYPE_ID) VALUES ('textarea');
INSERT INTO CFG_UI_FIELD_TYPES(FIELD_TYPE_ID) VALUES ('date');
INSERT INTO CFG_UI_FIELD_TYPES(FIELD_TYPE_ID) VALUES ('button');
INSERT INTO CFG_UI_FIELD_TYPES(FIELD_TYPE_ID) VALUES ('input');

INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (1, 4, 1, null, 'nfrText', null, 'You are about to modify the rule', null, null, 1);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (1, 4, 1, null, 'nfrEntryNo', null, NULL, null, 'ENTRY_NO', 2);                            
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (1, 4, 1, null, 'nfrText2', null, 'for', null, null, 3);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (1, 4, 1, null, 'nfrCountry', null, null, null, 'COUNTRY_ID', 4);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (1, 2, 0, 'Date of the reform', 'nfrRefDate', null, null, null, 'REFORM_ADOPT_DATE', 5); 
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (1, 2, 0, 'Date of entry into force of the reform', 'nfrRefForceDate', null, null, null, 'REFORM_REPLACED_DATE', 6);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (1, 1, 0, 'Please enter the nature/reason for the reform', 'nfrRefReason', null, null, null, 'REFORM_REASON', 7); 
                            
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (2, 4, 1, null, 'ifiText', null, 'You are about to modify the institution', null, null, 1);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (2, 4, 1, null, 'ifiName', null, NULL, 'DESCR', null, 2); 
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (2, 2, 0, 'Date of the reform', 'ifiRefDate', null, null, null, 'REFORM_ADOPT_DATE', 3); 
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (2, 2, 0, 'Date of entry into force of the reform', 'ifiRefForceDate', null, null, null, 'REFORM_REPLACED_DATE', 4);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (2, 1, 0, 'Please enter the nature/reason for the reform', 'ifiRefReason', null, null, null, 'REFORM_REASON', 5); 
                            
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (3, 4, 1, null, 'mtbfText', null, 'You are about to modify the entry for', null, null, 1);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (3, 4, 1, null, 'mtbfCountry', null, null, null, 'COUNTRY_ID', 2);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (3, 2, 0, 'Date of the reform', 'mtbfRefDate', null, null, null, 'REFORM_ADOPT_DATE', 3); 
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (3, 2, 0, 'Date of entry into force of the reform', 'mtbfRefForceDate', null, null, null, 'REFORM_REPLACED_DATE', 4);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (3, 1, 0, 'Please enter the nature/reason for the reform', 'mtbfRefReason', null, null, null, 'REFORM_REASON', 5);      
                            
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (4, 4, 1, null, 'gbdText', null, 'You are about to modify the entry for', null, null, 1);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (4, 4, 1, null, 'gbdCountry', null, null, null, 'COUNTRY_ID', 2);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (4, 2, 0, 'Date of the reform', 'gbdRefDate', null, null, null, 'REFORM_ADOPT_DATE', 3); 
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (4, 2, 0, 'Date of entry into force of the reform', 'gbdRefForceDate', null, null, null, 'REFORM_REPLACED_DATE', 4);
INSERT INTO CFG_UI_DIALOG_FIELDS(QUESTIONNAIRE_SID, FIELD_TYPE_SID, FIELD_DISABLED, FIELD_LABEL, FIELD_NAME, FIELD_VALIDATION, FIELD_VALUE, ENTRY_ADD_ATTRIBUTE, ENTRY_ATTRIBUTE, ORDER_BY) 
                            VALUES (4, 1, 0, 'Please enter the nature/reason for the reform', 'gbdRefReason', null, null, null, 'REFORM_REASON', 5);                               
COMMIT;


UPDATE CFG_SECTION_VERSIONS
  SET INFO_MSG = 'We use the following definition of fiscal risks: “factors (expected or unexpected) that can cause changes to fiscal outcomes (e.g. cause the general government debt ratio to be higher than initially expected)”'
  
WHERE SECTION_VERSION_SID = 72;
COMMIT;

--SCP-2282
UPDATE CFG_LOVS
  SET DESCR = 'Yes and they are broadly sufficient. Please specify which tools or strategies.'
  WHERE ORDER_BY = 1 AND LOV_TYPE_SID = (SELECT LOV_TYPE_SID FROM CFG_LOV_TYPES WHERE DESCR = 'Tools and strategies in place for fiscal risks');
UPDATE CFG_LOVS
  SET DESCR = 'Yes, but they could be improved. Please specify what, in your view, could be improved in that regard by your government.'
  WHERE ORDER_BY = 2 AND LOV_TYPE_SID = (SELECT LOV_TYPE_SID FROM CFG_LOV_TYPES WHERE DESCR = 'Tools and strategies in place for fiscal risks');
UPDATE CFG_LOVS
  SET DESCR = 'No. Please specify what, in your view, could be implemented in that regard by your government.'
  WHERE ORDER_BY = 3 AND LOV_TYPE_SID = (SELECT LOV_TYPE_SID FROM CFG_LOV_TYPES WHERE DESCR = 'Tools and strategies in place for fiscal risks');    
INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES
( (SELECT LOV_TYPE_SID FROM CFG_LOV_TYPES WHERE DESCR = 'Tools and strategies in place for fiscal risks'), 'Not sure. Please specify for what reason you are unsure (e.g., non-disclosure of risks by government)', 1, 4);
COMMIT;
--TO PROD ON 02/05/2023

--update descr of ameco indicators to correspond to FASTOP
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UBLGAPS.1.0.319.0' WHERE DESCR = '1.0.319.0.UBLGAPS';
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UBLGI.1.0.319.0' WHERE DESCR = '1.0.319.0.UBLGI';
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UBLGAP.1.0.319.0' WHERE DESCR = '1.0.319.0.UBLGAP';
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UBLGE.1.0.319.0' WHERE DESCR = '1.0.319.0.UBLGE';   
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UUTG.1.0.319.0' WHERE DESCR = '1.0.319.0.UUTG';    
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'OUTG.1.0.319.0' WHERE DESCR = '1.0.319.0.OUTG';   
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UUTG.1.0.0.0' WHERE DESCR = '1.0.0.0.UUTG';
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UBLGAP.1.0.319.0' WHERE DESCR = '1.0.319.0.UBLGP';
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UBLGAP.1.0.0.0' WHERE DESCR = '1.0.0.0.UBLGAP';  
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UDGG.1.0.380.0' WHERE DESCR = '1.0.380.0.UDGG';
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UUTG.9.0.0.0' WHERE DESCR = '9.0.0.0.UUTG';
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'OUTG.1.0.0.0' WHERE DESCR = '1.0.0.0.OUTG';  
   UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'OUTG.9.0.0.0' WHERE DESCR = '9.0.0.0.OUTG';
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UDGG.1.0.319.0' WHERE DESCR = '1.0.319.0.UDGG';   
UPDATE CFG_COMPLIANCE_REFS
   SET DESCR = 'UBLGE.1.0.0.0' WHERE DESCR = '1.0.0.0.UBLGE';
COMMIT;  

update CFG_COMPLIANCE_SOURCES
   set compliance_source_id = 'AMEC1' where compliance_source_sid = 6;

CREATE SYNONYM VW_FDMS_INDICATOR_DATA FOR VW_FDMS_INDICATOR_DATA@FASTOP;

--SCP-2283
UPDATE CFG_COMPLIANCE_SOURCES
   SET DESCR = 'AMECO Autumn forecast from year t-1' 
 WHERE COMPLIANCE_SOURCE_SID = 5;
UPDATE CFG_COMPLIANCE_SOURCES
   SET DESCR = 'AMECO Spring forecast from year t+1' 
 WHERE COMPLIANCE_SOURCE_SID = 6;
COMMIT;
--to prod on 15.05.2023

--SCP-2285
UPDATE CFG_SECTION_VERSIONS
  SET INFO_MSG = 'N.B.: {*}If the rule was fully suspended in the year of reference, please select '|| CHR(39)||'yes'||CHR(39)||' on both questions '||CHR(39)||'escape clause triggered ex-ante/ex-post'||CHR(39)||'{*}. If the rule was suspended through other means than the rule'||CHR(39)||'s own escape clause, please explain there by which means the rule was suspended.'
  WHERE SECTION_VERSION_SID IN (14,15,16);
COMMIT; 
--to prod on 17.05.2023

--SCP-2287
update cfg_question_versions
 set help_text = 'Please indicate which of the data sources provided is the most appropriate to assess ex-ante compliance with this rule for budgetary year {YEAR1} (according to the initial annual budgetary documents prepared in {YEAR2}). In case none of the sources is considered suitable, please choose "custom compliance assessment" to provide your own alternative source.'
 where question_version_sid = (select question_version_sid from cfg_question_versions where question_sid in (select question_sid from cfg_questions where descr = 'Planned Budgetary Data'));
 --to prod on 25.05.2023

--view for detailed cfg of qstnnr, section, subsection, questions and order
CREATE OR REPLACE VIEW vw_qstnnr_detailed_config
AS

select s.qstnnr_version_sid,
       s.section_version_sid as parent_section,
       ss.sub_section_version_sid as child_section ,
       qsq.question_version_sid,
       ps.descr as parent_section_name,
       css.section_id as child_section_name,
       q.descr as question_descr,
       qv.help_text as question_help,
       s.order_by parent_order_by,
       ss.order_by child_order_by,
       qsq.order_by question_order_by
   from cfg_qstnnr_ver_subsections ss,
        cfg_qstnnr_ver_sections s, 
        cfg_qstnnr_section_questions qsq,
        cfg_section_versions ps,
        cfg_section_versions cs,
        cfg_sections css,
        cfg_questions q,
        cfg_question_versions qv
  where s.qstnnr_version_sid = ss.qstnnr_version_sid(+)
    and s.section_version_sid = ss.parent_section_version_sid(+)
    and qsq.section_version_sid = 
        CASE
            when ss.parent_section_version_sid is null then s.section_version_sid
            else ss.sub_section_version_sid
        end
    and ps.section_version_sid = s.section_version_sid   
    and cs.section_version_sid(+) = ss.sub_section_version_sid
    and css.section_sid(+) = cs.section_sid
    and q.question_sid = qv.question_sid
    and qv.question_version_sid = qsq.question_version_sid
    ;

--updated accessor for horiz elements and cfg_scores pkb.
UPDATE CFG_HORIZONTAL_ELEMENTS
   SET ACCESSOR = 'SUBMIT_DATE', TAB_NAME = 'QSTNNR_CTY_STATUS'
 WHERE ELEM_TYPE_SID = 6;
commit;
 --to prod on 16.06.2023

 --SCP-2290
 delete cfg_score_conditions where choice_score_sid in (184, 185);
update cfg_score_conditions
 set or_choice_score_sid = null, and_choice_score_sid = null where criterion_sid = 14;
delete cfg_score_conditions where score_cond_sid = 20;
update cfg_score_conditions
   set or_choice_score_sid = 1 where score_cond_sid = 19;
update cfg_score_conditions
   set and_choice_score_sid = 1 where score_cond_sid = 21;
   
   delete cfg_index_choices_scores
   where choice_score_sid in (184, 185);
   commit;

--SCP-2295
DECLARE
   CURSOR c_questions IS
   SELECT * FROM cfg_qstnnr_section_questions where section_version_sid = 72 ORDER BY ORDER_BY;
   
   l_display_prefix VARCHAR2(4000 BYTE) := 'Ad-hoc questions';
   l_display_name VARCHAR2(4000 BYTE);
   l_display_help VARCHAR2(4000 BYTE);
   l_order_by NUMBER;
BEGIN
   select MAX(ORDER_BY) INTO l_order_by from cfg_vintage_attributes where app_id = 'IFI';
   FOR rec IN c_questions LOOP
       l_order_by := l_order_by + 1;
       SELECT DESCR INTO l_display_name FROM CFG_QUESTIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTION_VERSIONS WHERE QUESTION_VERSION_SID = rec.QUESTION_VERSION_SID);
       SELECT HELP_TEXT INTO l_display_help FROM CFG_QUESTION_VERSIONS WHERE QUESTION_VERSION_SID = rec.QUESTION_VERSION_SID;
       
       INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DISPLAY_PREFIX, DEFAULT_SELECTED, ORDER_BY, DISPLAY_HELP)
       VALUES ('IFI', '6', TO_CHAR(rec.QUESTION_VERSION_SID), l_display_name, l_display_prefix, 0, l_order_by, l_display_help);
       
       
   END LOOP;
END;  
/ 
--commit to prod on 18/07/2023

--SCP-2266
INSERT INTO CFG_VINTAGE_ATTR_TYPES(ATTR_ID, DB_ONLY, ACCESSOR) VALUES ('Entry Status', 0, 'getPreviousStep');

INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DEFAULT_SELECTED, ORDER_BY, DISPLAY_HELP)
VALUES ('NFR', 10, 'STATUS', 'Status', 1, 4, 'This shows whether the entry was reformed or not in the year of reference.');
UPDATE CFG_VINTAGE_ATTRIBUTES
   SET ORDER_BY = ORDER_BY + 1
 WHERE app_id = 'NFR' AND VINTAGE_ATTR_SID IN (328);  
 
INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DEFAULT_SELECTED, ORDER_BY, DISPLAY_HELP)
VALUES ('IFI', 10, 'STATUS', 'Status', 1, 2, 'This shows whether the entry was reformed or not in the year of reference.');


INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DEFAULT_SELECTED, ORDER_BY, DISPLAY_HELP)
VALUES ('MTBF', 10, 'STATUS', 'Status', 1, 2, 'This shows whether the entry was reformed or not in the year of reference.');

UPDATE CFG_VINTAGE_ATTRIBUTES
   SET ORDER_BY = ORDER_BY + 1
 WHERE app_id = 'MTBF' AND VINTAGE_ATTR_SID IN (2,3); 
 
 INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DEFAULT_SELECTED, ORDER_BY, DISPLAY_HELP)
VALUES ('GBD', 10, 'STATUS', 'Status', 1, 2, 'This shows whether the entry was reformed or not in the year of reference.');

UPDATE CFG_VINTAGE_ATTRIBUTES
   SET ORDER_BY = ORDER_BY + 2
 WHERE app_id = 'GBD' AND VINTAGE_ATTR_SID != 86; 
 --commit to prod on 27.07.2023


 --SCP-2297
 UPDATE ENTRIES_ADD_CFG
   SET IS_MONITORING = 1 WHERE entry_sid in (select entry_sid from entries where app_id = 'IFI' and country_id = 'SI') AND IFI_MAIN_ABRV = 'IMAD';
   
UPDATE ENTRIES_ADD_CFG
   SET IS_MONITORING = 0 WHERE entry_sid in (select entry_sid from entries where app_id = 'IFI' and country_id = 'SI') AND IFI_MAIN_ABRV = 'SFC';
COMMIT;
--commit to prod on 02/08/2023   

--SCP-2296
ALTER TABLE CFG_VINTAGE_ATTRIBUTES ADD (ADMIN_ONLY NUMBER);

UPDATE CFG_VINTAGE_ATTRIBUTES
   SET ADMIN_ONLY = 1
 WHERE APP_ID = 'NFR'
   AND DISPLAY_PREFIX LIKE 'Annual Compliance%';
   COMMIT;

--COMMIT TOT PROD ON 07/08/2023

--SCP-2290
insert into cfg_index_choices_scores(question_version_sid, lov_sid, criterion_sid, score)
values (68, 3, 14, 1);

delete cfg_score_conditions where choice_score_sid = 182;
commit;
--commit to prod on 08/08/20223


--SCP-2306; SCP-2305
DECLARE
    l_elem_type_sid NUMBER;
BEGIN
    INSERT INTO CFG_UI_ELEMENT_TYPES(ELEMENT_TYPE_ID, DESCR) VALUES ('VINTAGE_HEADER_IMP_MSG', 'Important info message on Vintages page')
    RETURNING ELEMENT_TYPE_SID INTO l_elem_type_sid;
    
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'IMPORTANT: Do not use this data in public/external communication (incl. visualisations, presentations, working documents, etc.) without an EXPLICIT prior check and permission by ECFIN. Please email to [ECFIN-GREEN-BUDGETING-SURVEY@ec.europa.eu] for any questions, data requests or permission to use data.',
    4, 'DEFAULT');  
    
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'IMPORTANT: Do not use this data in public/external communication (incl. visualisations, presentations, working documents, etc.) without an EXPLICIT prior check and permission by ECFIN. Please email to [ecfin-fiscalframeworks@ec.europa.eu] for any questions, data requests or permission to use data.',
    1, 'DEFAULT');
    
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'IMPORTANT: Do not use this data in public/external communication (incl. visualisations, presentations, working documents, etc.) without an EXPLICIT prior check and permission by ECFIN. Please email to [ecfin-fiscalframeworks@ec.europa.eu] for any questions, data requests or permission to use data.',
    2, 'DEFAULT');
    
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_elem_type_sid, 'IMPORTANT: Do not use this data in public/external communication (incl. visualisations, presentations, working documents, etc.) without an EXPLICIT prior check and permission by ECFIN. Please email to [ecfin-fiscalframeworks@ec.europa.eu] for any questions, data requests or permission to use data.',
    3, 'DEFAULT');
END;
/
COMMIT;
--COMMIT TO PROD ON 22/08/2023

--SCP-2299
--Add missing status column
BEGIN
    ALTER TABLE VINTAGE_NFR_2018 ADD (COL435 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_NFR_2019 ADD (COL435 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_NFR_2020 ADD (COL435 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_NFR_2021 ADD (COL435 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_NFR_2022 ADD (COL435 VARCHAR2(4000BYTE));
    
    ALTER TABLE VINTAGE_IFI_2019 ADD (COL436 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_IFI_2020 ADD (COL436 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_IFI_2021 ADD (COL436 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_IFI_2022 ADD (COL436 VARCHAR2(4000BYTE));
    
    ALTER TABLE VINTAGE_MTBF_2020 ADD (COL437 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_MTBF_2021 ADD (COL437 VARCHAR2(4000BYTE));
    ALTER TABLE VINTAGE_MTBF_2022 ADD (COL437 VARCHAR2(4000BYTE));
    
    ALTER TABLE VINTAGE_GBD_2021 ADD (COL438 VARCHAR2(4000BYTE));
END;
/

--fill status column
DECLARE
    CURSOR c_2018_nfr IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 87) AS STATUS FROM VINTAGE_NFR_2018 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 87) IS NOT NULL;
    
    CURSOR c_2019_nfr IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 94) AS STATUS FROM VINTAGE_NFR_2019 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 94) IS NOT NULL;
    
    CURSOR c_2020_nfr IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 104) AS STATUS FROM VINTAGE_NFR_2020 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 104) IS NOT NULL;
    
    CURSOR c_2021_nfr IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 260) AS STATUS FROM VINTAGE_NFR_2021 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 260) IS NOT NULL;
    
    CURSOR c_2022_nfr IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 380) AS STATUS FROM VINTAGE_NFR_2022 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 380) IS NOT NULL;
    
    CURSOR c_2019_ifi IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 94) AS STATUS FROM VINTAGE_IFI_2019 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 94) IS NOT NULL;
    CURSOR c_2020_ifi IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 104) AS STATUS FROM VINTAGE_IFI_2020 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 104) IS NOT NULL;
    CURSOR c_2021_ifi IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 260) AS STATUS FROM VINTAGE_IFI_2021 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 260) IS NOT NULL;
    CURSOR c_2022_ifi IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 380) AS STATUS FROM VINTAGE_IFI_2022 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 380) IS NOT NULL;
    
    CURSOR c_2020_mtbf IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 104) AS STATUS FROM VINTAGE_MTBF_2020 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 104) IS NOT NULL;
    CURSOR c_2021_mtbf IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 260) AS STATUS FROM VINTAGE_MTBF_2021 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 260) IS NOT NULL;
    CURSOR c_2022_mtbf IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 380) AS STATUS FROM VINTAGE_MTBF_2022 WHERE ENTRY_SID != 0 AND CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 380) IS NOT NULL;
    
    CURSOR c_2021_gbd IS
    SELECT ENTRY_SID, CFG_QUESTIONNAIRE.getPreviousStep(ENTRY_SID, 240) AS STATUS FROM VINTAGE_GBD_2021 WHERE ENTRY_SID != 0 ;
    
    
BEGIN
    FOR rec IN c_2018_nfr LOOP
        UPDATE VINTAGE_NFR_2018
           SET COL435 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2019_nfr LOOP
        UPDATE VINTAGE_NFR_2019
           SET COL435 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2020_nfr LOOP
        UPDATE VINTAGE_NFR_2020
           SET COL435 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2021_nfr LOOP
        UPDATE VINTAGE_NFR_2021
           SET COL435 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2022_nfr LOOP
        UPDATE VINTAGE_NFR_2022
           SET COL435 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    
    
    FOR rec IN c_2019_ifi LOOP
        UPDATE VINTAGE_IFI_2019
           SET COL436 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2020_ifi LOOP
        UPDATE VINTAGE_IFI_2020
           SET COL436 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2021_ifi LOOP
        UPDATE VINTAGE_IFI_2021
           SET COL436 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2022_ifi LOOP
        UPDATE VINTAGE_IFI_2022
           SET COL436 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    
    
    FOR rec IN c_2020_mtbf LOOP
        UPDATE VINTAGE_MTBF_2020
           SET COL437 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2021_mtbf LOOP
        UPDATE VINTAGE_MTBF_2021
           SET COL437 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    FOR rec IN c_2022_mtbf LOOP
        UPDATE VINTAGE_MTBF_2022
           SET COL437 = rec.STATUS
         WHERE ENTRY_SID = rec.ENTRY_SID; 
    END LOOP;
    
    UPDATE VINTAGE_GBD_2021 SET COL438 = 'New Entry' where entry_sid != 0;
END;
/

--update header
BEGIN
    UPDATE VINTAGE_NFR_2018 SET COL435 = 'Status' WHERE ENTRY_SID = 0;
    UPDATE VINTAGE_NFR_2019 SET COL435 = 'Status' WHERE ENTRY_SID = 0; 
    UPDATE VINTAGE_NFR_2020 SET COL435 = 'Status' WHERE ENTRY_SID = 0; 
    UPDATE VINTAGE_NFR_2021 SET COL435 = 'Status' WHERE ENTRY_SID = 0; 
    UPDATE VINTAGE_NFR_2022 SET COL435 = 'Status' WHERE ENTRY_SID = 0; 
    
    UPDATE VINTAGE_IFI_2019 SET COL436 = 'Status' WHERE ENTRY_SID = 0; 
    UPDATE VINTAGE_IFI_2020 SET COL436 = 'Status' WHERE ENTRY_SID = 0; 
    UPDATE VINTAGE_IFI_2021 SET COL436 = 'Status' WHERE ENTRY_SID = 0; 
    UPDATE VINTAGE_IFI_2022 SET COL436 = 'Status' WHERE ENTRY_SID = 0; 
    
    UPDATE VINTAGE_MTBF_2020 SET COL437 = 'Status' WHERE ENTRY_SID = 0; 
    UPDATE VINTAGE_MTBF_2021 SET COL437 = 'Status' WHERE ENTRY_SID = 0; 
    UPDATE VINTAGE_MTBF_2022 SET COL437 = 'Status' WHERE ENTRY_SID = 0; 
    
    UPDATE VINTAGE_GBD_2021 SET COL438 = 'Status' WHERE ENTRY_SID = 0;
END;
/
COMMIT;
--to prod on 23.08.2023

--SCP-2302
delete CFG_INDICES_ATTRIBUTES where attr_id != 'SECTOR';
insert into indices_frsi_2023(country_id, entry_sid) values ('HEADER', 0);
commit;
--to prod on 29.08.2023

--SCP-2321
update cfg_vintage_attributes
   set order_by = order_by + 1
  where order_by >=60
  and app_id = 'NFR';
  
INSERT INTO cfg_vintage_attributes(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DISPLAY_PREFIX, DEFAULT_SELECTED, ORDER_BY, DISPLAY_HELP)
VALUES ('NFR', 5, '17', 'Definition', 'Target '||chr(38)||' Sector - Escape Clause', 0, 60, 'Please indicate the extent to which escape clauses are defined in the statutory base of the rule.');
commit;
--to prod on 01.09.2023

--SCP-2300
DECLARE

    CURSOR c_ENTRIES_EXCL_ELEM IS SELECT ENTRY_SID, QUESTION_VERSION_SID, TO_NUMBER(RESPONSE) AS RESPONSE  FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = 4; 
BEGIN

    FOR rec IN c_ENTRIES_EXCL_ELEM LOOP
        IF (rec.RESPONSE) = 238 THEN
            DELETE TARGET_ENTRIES WHERE QUESTION_VERSION_SID = 5 AND ENTRY_SID = rec.ENTRY_SID;
        END IF;
    END LOOP;
END;
/
commit;
--to prod on 08.09.2023

--SCP-2327
UPDATE CFG_VINTAGE_ATTRIBUTES
   SET IS_FILTER = 1
 WHERE APP_ID = 'NFR'
   AND ATTR_VALUE IN ('COUNTRY_ID', '1', '2', '9');
   
   UPDATE CFG_VINTAGE_ATTRIBUTES
   SET IS_FILTER = 1
 WHERE APP_ID = 'IFI'
   AND ATTR_VALUE IN ('COUNTRY_ID');
   
   UPDATE CFG_VINTAGE_ATTRIBUTES
   SET IS_FILTER = 1
 WHERE APP_ID = 'MTBF'
   AND ATTR_VALUE IN ('COUNTRY_ID');
commit;
--to prod on 11/09/2023   

--SCP-2340
UPDATE CFG_LOVS SET CFG_TYPE = NULL WHERE LOV_TYPE_SID = 108 AND LOV_SID = 466;
COMMIT;
--TO PROD ON 13/08/2023

--SCP-2326
UPDATE cfg_score_conditions
   SET CHOICE_SCORE_SID = 182, COND_QUESTION_VERSION_SID = 68, COND_LOV_SID = 3, AND_CHOICE_SCORE_SID = NULL, OR_CHOICE_SCORE_SID = 1
 WHERE SCORE_COND_SID = 21; 
DELETE cfg_index_choices_scores WHERE QUESTION_VERSION_SID = 57 AND LOV_SID = 4 AND CRITERION_SID = 14;
UPDATE cfg_index_choices_scores
   SET CHOICE_SCORE_SID = 183
 WHERE QUESTION_VERSION_SID = 68 AND LOV_SID = 3 AND CRITERION_SID = 14;  
INSERT INTO  cfg_score_conditions(CRITERION_SID, CHOICE_SCORE_SID, COND_QUESTION_VERSION_SID, COND_LOV_SID, OR_CHOICE_SCORE_SID)
VALUES (14, 183, 57, 3, 1);
delete cfg_score_conditions where choice_score_sid = 183;
delete cfg_index_choices_scores where choice_score_sid = 183;
COMMIT;
--TO PROD ON 13/08/2023

--SCP-2369
UPDATE CFG_QUESTION_VERSIONS
   SET HELP_TEXT = 'For which sector does the fiscal institution prepare/endorse/assess budgetary forecasts?'
 WHERE QUESTION_VERSION_SID = 145;  

--SCP-2368
UPDATE CFG_QUESTIONS
   SET DESCR = 'Produced/endorsed macroeconomic forecasts used in fiscal planning?'
 WHERE QUESTION_SID = 142;


DECLARE
    l_question_sid NUMBER;
BEGIN
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Produced/endorsed budgetary forecasts used in fiscal planning?') RETURNING QUESTION_SID INTO l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET QUESTION_SID = l_question_sid
     WHERE HELP_TEXT = 'Please specify whether the budgetary forecasts produced/endorsed by the fiscal institution are used in the MTBF planning document (i.e. the medium-term plans)'  ;
END;
/
--commit to prod on 03/10/2023

--year_periods
DROP TABLE CFG_YEAR_PERIODS CASCADE CONSTRAINTS;
DROP SEQUENCE CFG_YEAR_PERIODS_SEQ;
CREATE SEQUENCE CFG_YEAR_PERIODS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE TABLE CFG_YEAR_PERIODS (
    YEAR_PERIOD_SID NUMBER(9),
    REPORTING_START DATE,
    REPORTING_END   DATE,
    EXERCISE_YEAR   NUMBER(4),
        CONSTRAINT "CFG_YEAR_PERIODS_PK" PRIMARY KEY ("YEAR_PERIOD_SID")
);

CREATE OR REPLACE TRIGGER CFG_YEAR_PERIODS_TRG 
    BEFORE INSERT
    ON CFG_YEAR_PERIODS
    FOR EACH ROW
    DECLARE
    BEGIN
       SELECT CFG_YEAR_PERIODS_SEQ.NEXTVAL INTO :NEW.YEAR_PERIOD_SID FROM dual;
END CFG_YEAR_PERIODS_TRG;

/
ALTER TRIGGER "FGD"."CFG_YEAR_PERIODS_TRG" ENABLE;


select to_char(sysdate, 'YYYY') from dual;

DECLARE
    l_start NUMBER(9) := 1990;
    l_end NUMBER(9);

BEGIN
    SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) INTO l_end FROM DUAL;
    
    FOR idx IN l_start..l_end LOOP
        INSERT INTO CFG_YEAR_PERIODS(REPORTING_START, REPORTING_END, EXERCISE_YEAR)
        VALUES (
            cfg_questionnaire.getStartDate(idx),
            cfg_questionnaire.getEndDate(idx),
            idx
        );
    END LOOP;
END; 
/


--SCP-2377
update cfg_ui_qstnnr_elements
   set element_text = 'IMPORTANT: Do not use this data in public/external communication (incl. visualisations, presentations, working documents, etc.) without an EXPLICIT prior check and permission by ECFIN. Please email to [ecfin-fiscalframework@ec.europa.eu] for any questions, data requests or permission to use data.'
   where element_text like '%frameworks%';
commit;
--to prod on 20/11/2023

--SCP-2382
update cfg_vintage_attributes 
set admin_only = 1
where app_id = 'MTBF' and attr_type_sid not in (1,10) and to_number(attr_value) in (select question_version_sid from cfg_qstnnr_section_questions where section_version_sid in (52, 53, 78));
commit;
--to prod on 06/12/2023


--IFI 24 UPDATES
--SCP-2415, SCP-2320  dev only
DECLARE
    l_qv_sid NUMBER;
    l_sv_sid NUMBER;
    l_pos_qv_sid NUMBER;
    l_order_by NUMBER;
    l_new_question_sid NUMBER;
    l_new_qv_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
BEGIN    

    SAVEPOINT save_ifi;
    SELECT QUESTION_VERSION_SID INTO l_qv_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN 
        (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Basis for quantification/policy costings of effects of policies');

    SELECT SECTION_VERSION_SID INTO l_sv_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Budgetary forecasts';
    
    SELECT QUESTION_VERSION_SID INTO l_pos_qv_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN 
        (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Additional information on budgetary forecasting');

    SELECT ORDER_BY INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_pos_qv_sid AND SECTION_VERSION_SID = l_sv_sid;
    
    DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_qv_sid;
    
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 2
     WHERE SECTION_VERSION_SID = l_sv_sid
       AND ORDER_BY >= l_order_by;
       
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_sv_sid, l_qv_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Details for quantification/policy costing of effects of policies') RETURNING QUESTION_SID INTO l_new_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_new_question_sid, 5, 'Please explain how the quantification/policy costing of (effects of) policies is done in your country and give a weblink if possible', 1, 1)
    RETURNING QUESTION_VERSION_SID INTO l_new_qv_sid;
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES
    WHERE QUESTION_VERSION_SID = l_qv_sid;
    
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 2;
    SELECT LOV_SID INTO l_choice_c FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 3;
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_c);
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_sv_sid, l_new_qv_sid, l_order_by);
    
    --Q1 Basis for long-term sustainability assessments
    SELECT QUESTION_VERSION_SID INTO l_qv_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN 
        (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Basis for long-term sustainability assessments');
    SELECT ORDER_BY  INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_qv_sid;
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Details for long-term sustainability assessments') RETURNING QUESTION_SID INTO l_new_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_new_question_sid, 5, 'Please explain how long-term sustainability assessments are done in your country and give a weblink if possible.', 1, 1)
    RETURNING QUESTION_VERSION_SID INTO l_new_qv_sid;
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES
    WHERE QUESTION_VERSION_SID = l_qv_sid;
    
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 2;
    SELECT LOV_SID INTO l_choice_c FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 3;
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_c);
    
    SELECT SECTION_VERSION_SID INTO l_sv_sid FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_qv_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
      SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID = l_sv_sid
       AND ORDER_BY > l_order_by;
    
    l_order_by := l_order_by + 1;
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_sv_sid, l_new_qv_sid, l_order_by);
    
    --Q3
    SELECT QUESTION_VERSION_SID INTO l_qv_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN 
        (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Basis for promotion of fiscal transparency');
    SELECT ORDER_BY  INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_qv_sid;
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Details for promotion of fiscal transparency') RETURNING QUESTION_SID INTO l_new_question_sid;
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_new_question_sid, 5, 'Please explain how fiscal transparency is promoted in your country and give a weblink if possible.', 1, 1)
    RETURNING QUESTION_VERSION_SID INTO l_new_qv_sid;
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES
    WHERE QUESTION_VERSION_SID = l_qv_sid;
    
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 2;
    SELECT LOV_SID INTO l_choice_c FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 3;
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_new_qv_sid, l_qv_sid, l_choice_c);
    
    SELECT SECTION_VERSION_SID INTO l_sv_sid FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_qv_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
      SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID = l_sv_sid
       AND ORDER_BY > l_order_by;
    
    l_order_by := l_order_by + 1;
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_sv_sid, l_new_qv_sid, l_order_by);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO save_ifi;
END;        
/

--SCP-2416
DECLARE
    l_question_sid NUMBER;
    l_question_version_sid NUMBER;
    l_check NUMBER;
    l_new_section_version_sid NUMBER;
    l_order_by NUMBER;
    l_after_question_version_sid NUMBER;
    l_dependent_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
BEGIN
    SAVEPOINT save_p2;
    select QUESTION_SID INTO l_question_sid from cfg_questions where descr = 'Time horizon of long-term projections';
    SELECT SECTION_VERSION_SID INTO l_check FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Budgetary forecasts';
    
    SELECT QV.QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS QV, CFG_QSTNNR_SECTION_QUESTIONS QSQ WHERE QV.QUESTION_SID = l_question_sid
    AND QSQ.QUESTION_VERSION_SID = QV.QUESTION_VERSION_SID AND QSQ.SECTION_VERSION_SID = l_check;
    
    
    SELECT SECTION_VERSION_SID INTO l_new_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Other tasks';
    
    DELETE cfg_qstnnr_section_questions
      WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    DELETE CFG_QUESTION_CONDITIONS
      WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    --GET ORDER BY OF QUESTION AFTER WHICH THIS ONE SHOULD BE ADDED
    select QUESTION_SID INTO l_question_sid from cfg_questions where descr = 'Details for long-term sustainability assessments';
    SELECT QUESTION_VERSION_SID INTO l_after_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    SELECT ORDER_BY INTO l_order_by FROM cfg_qstnnr_section_questions WHERE SECTION_VERSION_SID = l_new_section_version_sid AND QUESTION_VERSION_SID = l_after_question_version_sid;
    
    UPDATE cfg_qstnnr_section_questions
       SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID = l_new_section_version_sid
       AND ORDER_BY > l_order_by;
       
    l_order_by := l_order_by + 1;
    --INSERT THE QUESTION
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_new_section_version_sid, l_question_version_sid, l_order_by);
    
    --SELECT LOV_TYPE AND LOVS FOR DEPENDECIES OF QUESTION AND ADD THEM
    select QUESTION_SID INTO l_question_sid from cfg_questions where descr = 'Basis for long-term sustainability assessments';
    SELECT QUESTION_VERSION_SID INTO l_dependent_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_dependent_question_version_sid;
    
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 2;
    SELECT LOV_SID INTO l_choice_c FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 3;
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_dependent_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_dependent_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_dependent_question_version_sid, l_choice_c);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO save_p2;
END;        
/

--SCP-2417 
DECLARE
    l_question_sid NUMBER;
    l_question_version_sid NUMBER;
    l_check NUMBER;
    l_new_section_version_sid NUMBER;
    l_order_by NUMBER;
    l_after_question_version_sid NUMBER;
    l_dependent_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
BEGIN
    SAVEPOINT save_p3;
    select QUESTION_SID INTO l_question_sid from CFG_QUESTIONS where descr = 'Produced/endorsed forecasts used in fiscal planning?';
    UPDATE CFG_QUESTIONS
      SET DESCR = 'IFI`s forecast used in medium-term fiscal plans?'
    WHERE QUESTION_SID = l_question_sid;  
    
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Are the budgetary forecasts produced/endorsed by YOUR fiscal institution used in the MTBF planning documents? If yes, please specify in which ways.'
     WHERE QUESTION_SID =   l_question_sid;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO save_p3;
END;        
/

--SCP-2418 
DECLARE
    l_question_sid NUMBER;
    l_question_version_sid NUMBER;
    l_check NUMBER;
    l_new_section_version_sid NUMBER;
    l_order_by NUMBER;
    l_after_question_version_sid NUMBER;
    l_dependent_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
BEGIN
    SAVEPOINT save_p3;
    select question_version_sid into l_question_version_sid from cfg_question_versions where help_text = 'Explain the reasons for abolishing the fiscal institution';
    
    delete cfg_qstnnr_section_questions where question_version_sid = l_question_version_sid;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO save_p3;
END;        
/


--SCP-2264 
CREATE TABLE CFG_DETAILS(
  DETAILS_SID NUMBER,
  DETAIL_ID VARCHAR2(300 BYTE)
);

INSERT INTO CFG_DETAILS VALUES (1, 'Mandatory please specify box');
INSERT INTO CFG_DETAILS VALUES (2, 'Additional info on one of the IFIs');
INSERT INTO CFG_DETAILS VALUES (3, 'Additional info on the other one of the IFIs');
INSERT INTO CFG_DETAILS VALUES (4, 'Non-mandatory please specify box');
COMMIT;

--SCP-2427 
DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;
    --SECTION_VERSION_SID
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Ad-hoc questions') and info_msg is not null;
    
    DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid;
    --SET ORDER_BY
    l_order_by := 1;
    --q1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Frequency of meetings with DG ECFIN') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Over the last 2 years, how often did your IFI meet (virtually or in person) with country desks from DG ECFIN to discuss forecasts and/or your national budgetary framework (not counting EUNIFI meetings)?', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('FREQMDG', 0, 'Frequency of meetings with DG ECFIN') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'At least three times a year', NULL, 1, NULL)
    RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Once or twice a year', NULL, 2, NULL)
    RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Only once in the last 2 years', NULL, 3, NULL)
    RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'We did not meet with DG ECFIN in the last 2 years', 1, 4, NULL);
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --Q2
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Topics covered during meetings with ECFIN') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Which  of the following elements did you discuss (more than once) over the past 2 years? The discussions can also include assumptions, methodology, specific indicators, etc. ', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('TOPICSMDG', 0, 'Topics covered during meetings with ECFIN') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Monitoring of national and/or EU fiscal rules', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The Commission’s macroeconomic forecast', NULL, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Your own / your government’s macroeconomic forecasts', NULL, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The Commission’s budgetary forecast', NULL, 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Your own / your government’s budgetary forecasts', NULL, 5, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Long-term sustainability assessments', NULL, 6, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Overall consistency, coherence and/or effectiveness of the national budgetary framework', NULL, 7, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Implementation of the national Recovery and Resilience Plan', NULL, 8, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Green transition / climate change investment needs', NULL, 9, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other topics', 1, 10, NULL);
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q3
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Value added of meetings with DG ECFIN') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'What was for you the value added of your meetings with DG ECFIN?', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('VALADMDG', 0, 'Value added of meetings with DG ECFIN') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Opportunity to provide COM with more information on national policies', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Opportunity to provide COM with more information on our opinions / recommendations', NULL, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Clarification on COM assessment of national forecasts', NULL, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Clarification on COM assessment of compliance with the EU fiscal rules or COM debt sustainability analysis', NULL, 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Clarification on COM policy initiatives beyond the forecast (e.g., the general escape clause, economic governance review, the Recovery and Resilience Plan)', 1, 5, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other reasons', 1, 6, NULL);
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q4
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Room for improvement for exchange') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Regarding your exchange with DG ECFIN, how could this be developed further in your view? ', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    
    --Q5
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Tasks - more information needed from COM regarding…') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, '', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('TSKINFCOM', 0, 'Tasks - more information needed from COM regarding… ') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The design of the fiscal-structural plan', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The annual assessment of compliance with the expenditure path contained therein', NULL, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Consistency, coherence and effectiveness of the national budgetary framework', NULL, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, '(Multi)annual macroeconomic forecasts, incl. methodologies and indicators', NULL, 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Long-term fiscal sustainability analysis', NULL, 5, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Policy costings / quantification of the fiscal impact of policies', NULL, 6, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Fiscal impact of public investments', NULL, 7, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other', 1, 8, NULL);

    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q6
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Additional comment on exchange and/or EGR') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please share here any additional comment that you would like to share on cooperation with ECFIN and/or on preparing for tasks from the EGR.', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
END;        
/


DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;
    --SECTION_VERSION_SID Description
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Description');
    
    --SET ORDER_BY
    SELECT MAX(ORDER_BY) INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid;
    l_order_by := l_order_by + 1;
    --q1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Website') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'What is the web address of your institution?', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --Q2
    --SECTION_VERSION_SID Legal aspects
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Legal aspects');
    
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Date of establishment';
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Date of establishment of the institution'
     WHERE QUESTION_SID = l_question_sid;
     
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please indicate the date when the fiscal institution was founded which can be different from the date when it was assigned an IFI role.', ALWAYS_MODIFY = 1
     WHERE QUESTION_SID = l_question_sid;
     
    --Q3 
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Organisation and functioning grounded in law';
    UPDATE CFG_QUESTIONS
      SET DESCR = 'Organisation and practical functioning grounded in law'
     WHERE QUESTION_SID = l_question_sid;
     
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Are the implementing provisions governing the organisation and functioning in practice grounded in national law, regulation or binding administrative provisions?',
       ALWAYS_MODIFY = 1
     WHERE QUESTION_SID = l_question_sid;  
    
    --Q4
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Precise legal reference to functioning provisions';
    UPDATE CFG_QUESTIONS
      SET DESCR = 'Precise legal reference to practical functioning provisions'
     WHERE QUESTION_SID = l_question_sid;
    
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    SELECT ORDER_BY INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
    
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR ='Legal status');
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_question_version_sid;
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND UPPER(DESCR) = 'ATTACHED';
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND UPPER(DESCR) = 'EMBEDDED';
    l_cond_question_version_sid := l_question_version_sid;
    
    --Q5
    l_order_by := l_order_by + 1;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID = l_section_version_sid
       AND ORDER_BY >= l_order_by;
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Attached to / embedded in which institution?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Which other institution is your IFI attached to or embedded in?', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    
    --Q6
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Support from other institutions';
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please describe what kind of support is provided and by which other public institutions ', ALWAYS_MODIFY = 1
     WHERE QUESTION_SID = l_question_sid;
    
    --SECTION_VERSION_SID OPERATION AND ACCESS 
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Operation and access to information'); 
    
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Access to draft budgets and MTBF');
    SELECT ORDER_BY INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID = l_section_version_sid
       AND ORDER_BY >= l_order_by;
    
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Access to draft budgets and MTBF before publication'
     WHERE DESCR =  'Access to draft budgets and MTBF';
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Expert advisers from other countries?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Are there any specialists from other countries (seconded or otherwise) active in your IFI`s board? Or does your IFI receive regular and targeted advice from specialists from other countries?', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('EXADOTHCT', 0, 'Expert advisers from other countries?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, we have non-national experts in the Board', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, we have non-national experts in our staff', NULL, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, we receive regular and targeted advice from experts from other countries', NULL, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, CFG_TYPE)
    VALUES (l_lov_type_sid, 'No', NULL, 4, NULL, 3);
    
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --Q7
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Reaction from government in policy dialogue (incl. comply-or-explain)'
     WHERE DESCR = 'Practice on policy dialogue, c-o-e';
     
    --Q8
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Legal base for government reactions (policy dialogue incl. comply-or-explain)'
     WHERE DESCR = 'Legal base for policy dialogue, c-o-e';
    
    --Q9
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Description of funding arrangements';
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please describe the funding arrangements of the fiscal institution (i.e. from whom and under what circumstances it receives funding)', ALWAYS_MODIFY = 1
     WHERE QUESTION_SID =  l_question_sid;
     
    --Q10 
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Proportion of costs not covered by public sector funding';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    
    DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Proportion of costs not covered by public sector funding in the year of reference'
     WHERE QUESTION_SID = l_question_sid;
     
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Funding') and assessment_period = 0;  
    
    SELECT MAX(ORDER_BY) INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid;
    
    l_order_by := l_order_by + 1;
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --Q11
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Size of board';
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Size of Board of director(s)'
     WHERE QUESTION_SID = l_question_sid;  
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please specify the size of the governing/high-level board of the fiscal institution (choose `1` in case a single director makes the high-level decisions)',
       ALWAYS_MODIFY = 1
     WHERE QUESTION_SID =  l_question_sid;
     
    --Q12
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Composition of board';
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Composition of Board / leadership of IFI'
     WHERE QUESTION_SID = l_question_sid;  
     UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_SID = l_question_sid;
    
    --Q13
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Description of selection procedure for the board';
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Description of the selection procedure for the Board / leadership of IFI'
     WHERE QUESTION_SID = l_question_sid;  
     UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_SID = l_question_sid;
    
    --Q14
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Description of selection procedure for staff';
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Description of selection procedure and CV requirements for staff'
     WHERE QUESTION_SID = l_question_sid;  
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please describe the selection appointment procedure and any CV requirements regarding the staff of the fiscal institution', ALWAYS_MODIFY = 1
     WHERE QUESTION_SID =  l_question_sid;
    
    --Q15
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Powers of chairman/president';
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Powers of IFI Chairman/President'
     WHERE QUESTION_SID = l_question_sid;  
     SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
     UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
     
    --Q16
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Triggering of escape clauses?';
    UPDATE CFG_QUESTIONS
       SET DESCR = 'IFI involved in triggering/extending/exiting of escape clauses?'
     WHERE QUESTION_SID = l_question_sid; 
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'If the rule has an escape clause, does your institution issue an opinion on whether this clause should be triggered/extended/exited?',
       ALWAYS_MODIFY = 1
     WHERE QUESTION_SID =  l_question_sid;
    
    --Q17
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Macroeconomic forecasts'); 
    
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Performed task';
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'With regard to (multi-)annual macroeconomic forecasts, please indicate which of the following tasks is fulfilled by your institution (the question refers both to mandatory and optional tasks)',
       ALWAYS_MODIFY = 1
     WHERE QUESTION_SID =  l_question_sid
       AND HELP_TEXT LIKE '%macroeconomic%';
       
    --Q18
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Sector coverage';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid AND QUESTION_VERSION_SID = l_question_sid;
    
    DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
    
    --Q19
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Endorsement of main forecast?';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
    
    --Q20
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'IFI`s forecast used in medium-term fiscal plans?';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid and QUESTION_VERSION_SID = l_question_sid;
    DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
    
    --Q21
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Performed task';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid AND HELP_TEXT LIKE '%macroeconomic forecasts%';
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE DESCR = 'Official endorsement of the government`s macroeconomic forecasts used for fiscal planning for both the annual budgets and the medium-term plans (within the meaning of Art. 2.1b of the Two-Pack Regulation 473/2013)' AND LOV_TYPE_SID = l_lov_type_sid;
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE DESCR = 'Assessment of the official macroeconomic forecasts which is published before submission to the Parliament of the budgetary planning documents' AND LOV_TYPE_SID = l_lov_type_sid;
    
    SELECT ORDER_BY INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
    
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 1
     WHERE   SECTION_VERSION_SID = l_section_version_sid
       AND ORDER_BY > l_order_by;
    
    l_cond_question_version_sid :=   l_question_version_sid; 
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Endorsement/assessment based on your own macroeconomic forecast?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Is your endorsements/assessment (mostly) based on your own macroeconomic forecast figures? ', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);

    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('EASMCRFOR', 0, 'Endorsement/assessment based on your own macroeconomic forecast?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, mostly or fully based on our own forecast', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No, mostly or only based on forecasts produced by others -> Please specify by what other institution', 1, 2, NULL);
    
    l_order_by := l_order_by + 1;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --Q22
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Performed task';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid AND HELP_TEXT LIKE '%macroeconomic forecasts%';
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE DESCR = 'Production of macro-economic forecasts used for fiscal planning for both the annual budgets and the medium-term plans (within the meaning of Art. 2.1b of the Two-Pack Regulation 473/2013)' AND LOV_TYPE_SID = l_lov_type_sid;
    
    SELECT ORDER_BY INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
    
    l_cond_question_version_sid :=   l_question_version_sid; 
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Role in preparation';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid AND mandatory = 1;
    
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please indicate the role of your institution`s macroeconomic forecasts for the preparation of the annual budget.',
       ALWAYS_MODIFY = 1
     WHERE QUESTION_SID =  l_question_sid
       AND mandatory = 1;
     
    
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    
    --Q23
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Ex post evaluation provided?';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid AND HELP_TEXT LIKE '%macroeconomic%';
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES('Regular ex post evaluation of forecast accuracy provided by your IFI?') RETURNING QUESTION_SID INTO l_question_sid;
    
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = HELP_TEXT || 'Please note: this refers to an evaluation of how accurate the forecast has been and whether any systematic biases have been observed over the previous couple of years. It is thus different from the annual assessment/endorsement of the forecast mentioned under the question "performed task".'
          ,QUESTION_SID = l_question_sid
          ,ALWAYS_MODIFY = 1
     WHERE QUESTION_VERSION_SID = l_question_version_sid;
     
    --Q24
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Long-term projections provided?';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid AND HELP_TEXT LIKE '%macroeconomic%';
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES('Long-term projections provided by your IFI?') RETURNING QUESTION_SID INTO l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET QUESTION_SID = l_question_sid
     WHERE QUESTION_VERSION_SID = l_question_version_sid;
     
     --Q25
     SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Long-term projections provided?';
--     SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid AND help_text like '%macroeconomic%';
     
--     INSERT INTO CFG_QUESTIONS(DESCR) VALUES('Time horizon of long-term projections provided by your IFI') RETURNING QUESTION_SID INTO l_question_sid;
        UPDATE CFG_QUESTIONS
           set descr = 'Time horizon of long-term projections provided by your IFI'
          where  QUESTION_SID = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_SID = l_question_sid;
         

    --Q26
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Performed task';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid AND HELP_TEXT LIKE '%budgetary%';
    
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'With regard to (multi-)annual budgetary forecasts, which of the following tasks is fulfilled by your institution (the question refers both to mandatory and optional tasks)',
       ALWAYS_MODIFY = 1
     WHERE QUESTION_VERSION_SID =   l_question_version_sid;
     
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_question_version_sid;
    SELECT LOV_SID INTO l_choice FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
    
    l_cond_question_version_sid := l_question_version_sid;
    
    
    --q27
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Role in preparation of annual budget';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please indicate the role of your institution`s forecasts of budgetary variables for the preparation of the annual budget.',
       ALWAYS_MODIFY = 1
     WHERE QUESTION_VERSION_SID =   l_question_version_sid;
    
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice); 
    
    --Q28
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Interaction with government';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please specify the way in which the government interacts with the fiscal institution int the budgetary process',
        ALWAYS_MODIFY = 1
     WHERE QUESTION_VERSION_SID =   l_question_version_sid;
    
    DELETE CFG_QSTNNR_SECTION_QUESTIONS
      WHERE QUESTION_VERSION_SID = l_question_version_sid;
    DELETE CFG_QUESTION_CONDITIONS
     WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS
     WHERE DESCR = 'Policy dialogue' AND ASSESSMENT_PERIOD = 0;
     
    SELECT MAX(ORDER_BY) INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid;
    
    l_order_by := l_order_by + 1;
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --Q29
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Interaction with Parliament';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please specify the way in which the parliament interacts with the fiscal institution in the budgetary process',
       ALWAYS_MODIFY = 1
     WHERE QUESTION_VERSION_SID =   l_question_version_sid;
    
    DELETE CFG_QSTNNR_SECTION_QUESTIONS
      WHERE QUESTION_VERSION_SID = l_question_version_sid;
    DELETE CFG_QUESTION_CONDITIONS
     WHERE QUESTION_VERSION_SID = l_question_version_sid;
     
    l_order_by := l_order_by + 1;
    
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --Q30
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Basis for long-term sustainability assessments';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET ALWAYS_MODIFY = 1,
        HELP_TEXT = 'Please consider those sustainability studies with a long-term horizon which explicitly incorporates demographic changes, and was published either as a standalone documents, or as parts/subsections of a broader fiscal assessment report.'
     WHERE QUESTION_VERSION_SID =   l_question_version_sid; 
    
    SELECT ORDER_BY, SECTION_VERSION_SID INTO l_order_by, l_section_version_sid FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    l_order_by := l_order_by + 1;
    
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID  =  l_section_version_sid
       AND ORDER_BY >= l_order_by;
    
    l_cond_question_version_sid := l_question_version_sid;
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 2;
    SELECT LOV_SID INTO l_choice_c FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 3;
    
    --Q31
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Basis for quantification/policy costings of effects of policies';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please consider here numerical quantification/certification of budgetary impacts', ALWAYS_MODIFY = 1
     WHERE QUESTION_VERSION_SID =   l_question_version_sid; 
     
    
    --Q32
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Basis for promotion of fiscal transparency';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET ALWAYS_MODIFY = 1, HELP_TEXT = 'This task concerns active promotion of fiscal transparency (i.e.. making sure that budget, fiscal or forecast information presented by the government is complete, reliable and publicly available on time), including assessments of the accuracy of fiscal statistics or reporting on fiscal risks by your institution. It does not refer to the transparent operation of your institution (e.g. audits of your funding).'
     WHERE QUESTION_VERSION_SID =   l_question_version_sid;
    --Q33
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'External reviews';
    UPDATE CFG_QUESTIONS SET DESCR = 'External review in the year of reference?' WHERE QUESTION_SID = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_SID = l_question_sid;

    --Q34
    --section
    UPDATE CFG_SECTION_VERSIONS 
       SET DESCR = 'Annual activities and indicators' 
     WHERE DESCR = 'Annual activities';
     
     --SECTION HUMAN RES
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Human resources';
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Staff size: Total';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    UPDATE CFG_QUESTIONS SET DESCR = 'Staff size: Total (excl. Chair and Board)' WHERE QUESTION_SID = l_question_sid;
    
    SELECT ORDER_BY INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_question_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID =   l_section_version_sid
       AND ORDER_BY >= l_order_by;
       
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Staff size: IFI Chair '|| CHR(38) ||' Board members') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please provide the number of Board members (incl. the Chair) at the end of year of reference. In case of embedded/attached IFI, please only include figures for your IFI (department), not the whole institution.', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    
    UPDATE CFG_SECTION_VERSIONS
       SET DESCR = 'Outreach activities'
     WHERE DESCR = 'Media relations';  
     
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Budgetary appropriation: actual in the year of reference';
    UPDATE CFG_QUESTIONS
      SET DESCR = 'Budgetary appropriation: amount actually spent in the year of reference'
    WHERE QUESTION_SID =   l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_SID = l_question_sid;
    
    --Q35
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Policy dialogue' AND ASSESSMENT_PERIOD = 1;
    SELECT MAX(ORDER_BY) INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid;
    
    l_order_by := l_order_by + 1;
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Did your IFI produce output that warranted a government reaction?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please specify whether there was some output by your IFI that warranted a reaction from the government (or from a Ministry), but where you didn`t receive one', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('IFPOWRGVR', 0, 'Did your IFI produce output that warranted a government reaction?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No, we did not produce anything that necessitated a government reaction', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, we produced output that warranted a reaction from government, but the government didn`t respond', NULL, 2, NULL);
    
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Recommendation not complied with by government';
    UPDATE CFG_QUESTIONS
      SET DESCR = 'Did the government comply with all/some/none of your recommendations?'
    WHERE QUESTION_SID =   l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Approximately how many of your IFI`s normative recommendations did the government not comply with in the year of reference?',
       ALWAYS_MODIFY = 1
      WHERE QUESTION_SID = l_question_sid;
      
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Brief description';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
        
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;        
/

DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Freedom to communicate';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_question_version_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    UPDATE CFG_LOVS
       SET CFG_TYPE = 3,
           DESCR = 'No -> please specify what restrictions and by whom',
           ORDER_BY = 5
     WHERE LOV_TYPE_SID =    l_lov_type_sid AND ORDER_BY = 3;
    
    UPDATE CFG_LOVS
       SET CFG_TYPE = 4
      WHERE  LOV_TYPE_SID =    l_lov_type_sid AND ORDER_BY IN (1,2);
      
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID =  l_lov_type_sid AND ORDER_BY = 1;
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID =  l_lov_type_sid AND ORDER_BY = 2;
    
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, CFG_TYPE, ORDER_BY)
    VALUES (l_lov_type_sid, 'Yes, but only on set topics', NULL, 4, 3) RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, CFG_TYPE, ORDER_BY)
    VALUES (l_lov_type_sid, 'Yes, on any topic', NULL, 4, 4) RETURNING LOV_SID INTO l_choice_d;
    
    INSERT INTO CFG_CHOICES_CONDITIONS(LOV_SID, COND_LOV_SID)
    VALUES (l_choice_a, l_choice_b);
    INSERT INTO CFG_CHOICES_CONDITIONS(LOV_SID, COND_LOV_SID)
    VALUES (l_choice_b, l_choice_a);
    INSERT INTO CFG_CHOICES_CONDITIONS(LOV_SID, COND_LOV_SID)
    VALUES (l_choice_c, l_choice_d);
    INSERT INTO CFG_CHOICES_CONDITIONS(LOV_SID, COND_LOV_SID)
    VALUES (l_choice_d, l_choice_c);
    
    --
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Autonomy in recruitment decisions';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    UPDATE CFG_QUESTION_VERSIONS SET QUESTION_TYPE_SID = l_question_type_sid WHERE QUESTION_VERSION_SID = l_question_version_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('AUTRCDEC', 0, 'Autonomy in recruitment decisions') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, 'Yes, without restrictions from someone outside the organisation.', NULL, 1, 4) RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, 'Yes, but someone else sets restrictions on salaries -> Please specify what restrictions', 1, 2, 4) RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, 'Yes, but someone else sets CV restrictions (e.g. can hire only civil servants) -> Please specify who and what restrictions', 1, 3, 4) RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, CFG_TYPE)
    VALUES (l_lov_type_sid, 'No autonomy, someone else recruits or appoints personnel. -> Please specify who', 1, 4, 3) RETURNING LOV_SID INTO l_choice_d;
    
    INSERT INTO CFG_CHOICES_CONDITIONS(LOV_SID, COND_LOV_SID)
    VALUES (l_choice_a, l_choice_b);
    INSERT INTO CFG_CHOICES_CONDITIONS(LOV_SID, COND_LOV_SID)
    VALUES (l_choice_b, l_choice_a);
    INSERT INTO CFG_CHOICES_CONDITIONS(LOV_SID, COND_LOV_SID)
    VALUES (l_choice_a, l_choice_c);
    INSERT INTO CFG_CHOICES_CONDITIONS(LOV_SID, COND_LOV_SID)
    VALUES (l_choice_c, l_choice_a);
    --question_lov_type
    UPDATE CFG_QUESTION_LOV_TYPES SET LOV_TYPE_SID = l_lov_type_sid WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    --
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Legal base for access to information';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    UPDATE CFG_LOVS
       SET DESCR = 'Legislation -> please provide name and link', NEED_DET = 1
     WHERE LOV_TYPE_SID = l_lov_type_sid
       AND ORDER_BY = 1;
   UPDATE CFG_LOVS
       SET DESCR = 'Memorandum of understanding -> please provide name and link', NEED_DET = 1
     WHERE   LOV_TYPE_SID = l_lov_type_sid
       AND ORDER_BY = 2;
   INSERT INTO CFG_LOVS(DESCR, NEED_DET, LOV_TYPE_SID, CFG_TYPE) VALUES ('No legal base', NULL, l_lov_type_sid, 3);
   
    --
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Reaction from government in policy dialogue (incl. comply-or-explain)';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    UPDATE CFG_QUESTION_VERSIONS
       SET QUESTION_TYPE_SID = l_question_type_sid WHERE QUESTION_VERSION_SID = l_question_version_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;       
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_question_version_sid;

    DELETE CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 2;
    UPDATE CFG_LOVS SET ORDER_BY = 5 WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 3;
    UPDATE CFG_LOVS
       SET DESCR = 'Yes, the government reacts to (some of) our monitoring reports/statements on compliance with fiscal rules' WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
        
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (l_lov_type_sid, 'Yes, the government reacts to (some of) our reports/statements on debt sustainability', NULL, 2);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (l_lov_type_sid, 'Yes, the government reacts to (some of) our reports/statements on macroeconomic or budgetary forecasts', NULL, 3);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (l_lov_type_sid, 'Yes, the government reacts to (some of) our reports/statements on other matters -> please specify what type of reports', 1, 4);
    
    --
    DELETE CFG_LOVS WHERE DESCR = 'Production of macro-economic forecasts, but these are not used for the national fiscal planning';
    
    --
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'External review in the year of reference?';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('EXREVYREF', 0, 'External review in the year of reference?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No -> When was the last review?', 1, 2, NULL);
    
    --
    
    UPDATE CFG_LOVS SET DESCR = 'Yes, often, but in a brief and descriptive manner' WHERE DESCR = 'Yes, often, and in a brief and descriptive manner';
    
    --
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Did the government comply with all/some/none of your recommendations?';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID  = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS SET ALWAYS_MODIFY = 1 WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('DGVCRECM', 0, 'Did the government comply with all/some/none of your recommendations?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The government complied with most of our IFI`s recommendations', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The government complied only with some of our IFI`s recommendations', NULL, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The government did not comply with any of our IFI`s recommendations', NULL, 3, NULL);
    
    UPDATE CFG_QUESTION_LOV_TYPES SET LOV_TYPE_SID = l_lov_type_sid WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;        
/

--SCP-2436
DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;
    
    --SECTION_VERSION_SID Legal aspects
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Legal aspects');
    
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Support from other institutions';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    
    SELECT ORDER_BY INTO l_order_by FROM cfg_qstnnr_section_questions WHERE QUESTION_VERSION_SID  = l_question_version_sid AND SECTION_VERSION_SID = l_section_version_sid;
    l_order_by := l_order_by + 1;
    UPDATE cfg_qstnnr_section_questions SET ORDER_BY = ORDER_BY + 1 WHERE SECTION_VERSION_SID= l_section_version_sid AND ORDER_BY >= l_order_by;
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('IFI prohibited from taking outside instructions?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Does your institution’s statute (or similarly codified rules of operation) prohibit you from seeking or taking instructions from individuals or bodies outside the IFI?', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('IPTOINSTR', 0, 'IFI prohibited from taking outside instructions?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes -> please provide a reference to the relevant provisions if possible', 4, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No', 4, 2, NULL);
    
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;        
/

--SCP-2431 
UPDATE  CFG_DYNAMIC_LOVS
  SET DESCR = 'Rule {ENTRY_NO}: {QV1} - {QV2} - {QV3} - {QV4} (Coverage of GG finances: {COVERAGE})'
  WHERE DYN_SID = 2;

--SCP-2433 
ALTER TABLE CFG_LOVS ADD (
DETS_TXT VARCHAR2(4000 BYTE),
INFO_ICON NUMBER,
INFO_TXT VARCHAR2(4000 BYTE)
);

ALTER TABLE CFG_SPECIAL_LOVS ADD (
DETS_TXT VARCHAR2(4000 BYTE),
INFO_ICON NUMBER,
INFO_TXT VARCHAR2(4000 BYTE)
);

--install cfg_questionnaire pkg body and update view

UPDATE CFG_LOVS
   SET DESCR = substr(descr, 0, instr(descr, '->')-1),
       DETS_TXT = substr(descr, instr(descr, '->')+2, length(descr))
      WHERE DESCR like '%->%'; 

UPDATE CFG_LOVS
   SET DESCR = substr(descr, 0, instr(descr, '- >')-1),
       DETS_TXT = substr(descr, instr(descr, '- >')+3, length(descr))
      WHERE DESCR like '%- >%';

UPDATE CFG_LOVS
   SET DETS_TXT = LTRIM(DETS_TXT);

UPDATE CFG_LOVS
   SET DETS_TXT = REGEXP_REPLACE(DETS_TXT, SUBSTR(DETS_TXT,1,1), UPPER(SUBSTR(DETS_TXT,1,1)), 1, 1)
 WHERE DETS_TXT IS NOT NULL;


DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Frequency of meetings with DG ECFIN';
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Frequency of meetings with DG ECFIN country desks'
     WHERE QUESTION_SID  =   l_question_sid;
     
    UPDATE CFG_LOVS
       SET DETS_TXT = 'Please explain why not'
     WHERE DESCR = 'We did not meet with DG ECFIN in the last 2 years';  
     
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_LOV_TYPES WHERE DESCR = 'Topics covered during meetings with ECFIN';
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 2;
    SELECT LOV_SID INTO l_choice_c FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 3;
    SELECT LOV_SID INTO l_choice_d FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 4;
    SELECT LOV_SID INTO l_choice_e FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 5;
    
    UPDATE CFG_LOVS
       SET DESCR = 'The Commission’s MACROECONOMIC forecast'
     WHERE LOV_SID = l_choice_b;
    UPDATE CFG_LOVS
       SET DESCR = 'Your own / your government’s MACROECONOMIC forecasts'
     WHERE LOV_SID = l_choice_c; 
    UPDATE CFG_LOVS
       SET DESCR = 'The Commission’s BUDGETARY forecast'
     WHERE LOV_SID = l_choice_d;
    UPDATE CFG_LOVS
       SET DESCR = 'Your own / your government’s BUDGETARY forecasts'
     WHERE LOV_SID = l_choice_e;
     
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Tasks - more information needed from COM regarding…'; 
    UPDATE CFG_QUESTION_VERSIONS 
       SET HELP_TEXT = HELP_TEXT || ' To perform your ** tasks (including any new tasks resulting from the Economic Governance Review), in what areas would you need more information from the Commission?'
     WHERE QUESTION_SID = l_question_sid;
     
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_LOV_TYPES WHERE DESCR = 'Tasks - more information needed from COM regarding… ';
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 8;
    
    UPDATE CFG_LOVS
       SET DETS_TXT = 'Please elaborate on which topic'
     WHERE LOV_SID = l_choice_a;
     
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Room for improvement for exchange';
    UPDATE CFG_QUESTION_VERSIONS
       SET MANDATORY = NULL
     WHERE QUESTION_SID = l_question_sid;
     
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Additional comment on exchange and/or EGR';
    UPDATE CFG_QUESTION_VERSIONS
       SET MANDATORY = NULL
     WHERE QUESTION_SID = l_question_sid; 
     
    --
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN(SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Date of establishment of the institution');
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_question_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = 1
     WHERE SECTION_VERSION_SID =   l_section_version_sid
       AND ORDER_BY = 2;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = 2
     WHERE SECTION_VERSION_SID =   l_section_version_sid
       AND QUESTION_VERSION_SID = l_question_version_sid;
       
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN(SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Proportion of costs not covered by public sector funding in the year of reference');
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Funding' AND ASSESSMENT_PERIOD = 1;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET SECTION_VERSION_SID = l_section_version_sid
     WHERE QUESTION_VERSION_SID = l_question_version_sid;
     
    UPDATE CFG_QUESTIONS
       SET DESCR = 'Powers of IFI Chair/President'
     WHERE DESCR = 'Powers of IFI Chairman/President';
     
    --
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN(SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'External review in the year of reference?');
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('EXRVYREF', 0, 'External review in the year of reference?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, DETS_TXT)
    VALUES (l_lov_type_sid, 'No', 1, 2, NULL, 'When was the last review?');
    
    UPDATE CFG_QUESTION_LOV_TYPES
       SET LOV_TYPE_SID = l_lov_type_sid
     WHERE QUESTION_VERSION_SID =   l_question_version_sid;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;        
/
--DEV ONLY


--SCP-2438
DECLARE
    l_element_type_sid NUMBER;
    l_qstnnr_version_sid NUMBER;
    l_edit_step_id VARCHAR2(300 byte) := 'DEFAULT';
BEGIN
    SAVEPOINT svpt;
    INSERT INTO CFG_UI_ELEMENT_TYPES(ELEMENT_TYPE_ID, DESCR) VALUES ('QSTNNR_ALERT_HEADER', 'Header alert message on the questionnaire') RETURNING ELEMENT_TYPE_SID INTO l_element_type_sid;

    l_qstnnr_version_sid := 1; --NFR
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_element_type_sid, 'Following the announcement during the EFC-A meeting of October 2023, please note that we intend to make part of the NFR questionnaire public. This refers to questions in the design sections (so NOT annual compliance). Please contact ECFIN-FiscalFramework@ec.europa.eu in case of any questions.', l_qstnnr_version_sid, l_edit_step_id);
    
    l_qstnnr_version_sid := 3; --MTBF
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_element_type_sid, 'Following the announcement during the EFC-A meeting of October 2023, please note that we intend to make part of the MTBF-questionnaire public. This refers to questions in the design sections (so NOT annual developments). Please contact ECFIN-FiscalFramework@ec.europa.eu in case of any questions.', l_qstnnr_version_sid, l_edit_step_id);
    
    INSERT INTO CFG_UI_ELEMENT_TYPES(ELEMENT_TYPE_ID, DESCR) VALUES ('ENTRY_ALERT_HEADER', 'Header alert message on the entry') RETURNING ELEMENT_TYPE_SID INTO l_element_type_sid;

    l_qstnnr_version_sid := 1; --NFR
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_element_type_sid, 'Following the announcement during the EFC-A meeting of October 2023, please note that we intend to make part of the NFR questionnaire public. This refers to questions in the design sections (so NOT annual compliance). Please contact ECFIN-FiscalFramework@ec.europa.eu in case of any questions.', l_qstnnr_version_sid, l_edit_step_id);
    
    l_qstnnr_version_sid := 3; --MTBF
    INSERT INTO CFG_UI_QSTNNR_ELEMENTS(ELEMENT_TYPE_SID, ELEMENT_TEXT, QSTNNR_VERSION_SID, EDIT_STEP_ID)
    VALUES (l_element_type_sid, 'Following the announcement during the EFC-A meeting of October 2023, please note that we intend to make part of the MTBF-questionnaire public. This refers to questions in the design sections (so NOT annual developments). Please contact ECFIN-FiscalFramework@ec.europa.eu in case of any questions.', l_qstnnr_version_sid, l_edit_step_id);
    
 EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;
/

--SCP-2450
DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;
    
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Support from other institutions';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    SELECT QUESTION_VERSION_SID INTO l_cond_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Legal status');
    
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    SELECT ORDER_BY INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_cond_question_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
      SET ORDER_BY = ORDER_BY + 1
    WHERE SECTION_VERSION_SID = l_section_version_sid
      AND ORDER_BY > l_order_by;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
      SET ORDER_BY = l_order_by + 1
     WHERE SECTION_VERSION_SID = l_section_version_sid
       AND QUESTION_VERSION_SID = l_question_version_sid;
    
    --
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Policy dialogue' AND ASSESSMENT_PERIOD = 0;
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Additional info';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid AND QUESTION_VERSION_SID IN (SELECT QUESTION_VERSION_SID FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid);
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Additional information on policy dialogue') RETURNING QUESTION_SID INTO l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS
       SET QUESTION_SID = l_question_sid,
           HELP_TEXT = 'Please, provide here any potential additional information on the policy dialogue between your IFI and your government / parliament'
       WHERE QUESTION_VERSION_SID = l_question_version_sid;    
    
    
EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO svpt;
    raise;
END;
/


--SCP-2428
DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Legal aspects';
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Date of establishment as an IFI') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Date';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY, ACCESSOR)
    VALUES (l_question_sid, l_question_type_sid, 'Please indicate the date when the fiscal institution started operating as an IFI', 1, 1, 'APPRV_DATE') RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    l_order_by := 2;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY = ORDER_BY + 1 WHERE SECTION_VERSION_SID = l_section_version_sid AND ORDER_BY > 1;
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
      
    --    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;
/


--SCP-2429
UPDATE CFG_QUESTION_VERSIONS
  SET HELP_TEXT = 'Is the fiscal institution charged to provide a regular ex-post accuracy evaluation of official macroeconomic forecasts underlying fiscal planning (within the meaning of Article 4(6) of the 2011/85 Budgetary Frameworks Directive)? Please note: this refers to an evaluation of how accurate the forecast has been and whether any systematic biases have been observed over the previous couple of years. It is thus different from the annual assessment/endorsement of the forecast mentioned under the question "performed task".'
 WHERE QUESTION_SID IN  (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Regular ex post evaluation of forecast accuracy provided by your IFI?');
COMMIT;

--SCP-2456
DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;

    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Chairman/President';
    
    UPDATE CFG_QUESTIONS SET DESCR = 'Chair/President' WHERE QUESTION_SID = l_question_sid;
    UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'Is there a Chair/President of the fiscal institution?' WHERE QUESTION_SID = l_question_sid;
    
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Tasks - more information needed from COM regarding…';
    UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = ' To perform your tasks (including any new tasks resulting from the Economic Governance Review), in what areas would you need more information from the Commission?' WHERE QUESTION_SID = l_question_sid;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;
/

--SCP-2450
DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;
    
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Policy dialogue' AND ASSESSMENT_PERIOD = 0; 
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Additional information on policy dialogue';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    SELECT MAX(ORDER_BY) INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
      SET ORDER_BY = l_order_by + 1
    WHERE   SECTION_VERSION_SID = l_section_version_sid
      AND QUESTION_VERSION_SID = l_question_version_sid;
      
   --Macroeconomic forecasts
   SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Macroeconomic forecasts';
   SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Long-term projections provided by your IFI?';
   SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
   DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
   
   SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Description of long-term projections';
   SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid AND QUESTION_VERSION_SID IN (SELECT QUESTION_VERSION_SID FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid);
   DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
   
   SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Time horizon of long-term projections';
   SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid AND QUESTION_VERSION_SID IN (SELECT QUESTION_VERSION_SID FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid);
   DELETE CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_question_version_sid;
   
    --
    DELETE CFG_LOVS WHERE DESCR = 'Production of budgetary forecasts, but these are not used for the national fiscal planning';
    
    --Budgetary forecasts
    UPDATE CFG_QUESTION_VERSIONS SET HELP_TEXT = 'For which sector does the fiscal institution prepare/endorse/assess budgetary forecasts?'
    where question_version_sid = 145;
    --
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Basis for long-term sustainability assessments';
    UPDATE CFG_QUESTION_VERSIONS
       SET HELP_TEXT = 'Please consider those macroeconomic/fiscal sustainability studies with a long-term horizon which explicitly incorporates demographic changes, and was published either as a standalone document, or as parts/subsections of a broader fiscal assessment report.'
       WHERE QUESTION_SID = l_question_sid;
    
    --Staff size: IFI Chair & Board members
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Staff size: IFI Chair '|| CHR(38) ||' Board members';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE QUESTION_VERSION_sID = l_question_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 1 WHERE SECTION_VERSION_SID = l_section_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = 1 WHERE SECTION_VERSION_SID = l_section_version_sid
        AND QUESTION_VERSION_SID = l_question_version_sid;
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Assessment Number';
    UPDATE CFG_QUESTION_VERSIONS SET QUESTION_TYPE_SID = l_question_type_sid WHERE QUESTION_VERSION_SID = l_question_version_sid;
    
    --
    UPDATE CFG_SECTIONS
      SET SECTION_ID = 'Outreach activities' where section_sid in (SELECT SECTION_SID FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Outreach activities');
    
    --
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Reaction from government during year of reference';
    SELECT QUESTION_VERSION_SID INTO l_cond_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_cond_question_version_sid;
    SELECT LOV_SID INTO l_choice FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 2;
    
    SELECT QUESTION_SID INTO l_question_sid FROM CFG_QUESTIONS WHERE DESCR = 'Did your IFI produce output that warranted a government reaction?';
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID = l_question_sid;
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice);
    
    --
    UPDATE CFG_LOVS
       SET DESCR = 'The government complied with only some of our IFI`s recommendations'
     WHERE DESCR = 'The government complied only with some of our IFI`s recommendations';
    
    
    
EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO svpt;
    raise;
END;
/

--SCP-2457
DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;

    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE DESCR = 'Budgetary forecasts';
    SELECT QUESTION_VERSION_SID INTO l_cond_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Performed task') AND QUESTION_VERSION_SID IN
    (SELECT QUESTION_VERSION_SID FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid);
    SELECT ORDER_BY INTO l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS WHERE SECTION_VERSION_SID = l_section_version_sid AND QUESTION_VERSION_SID = l_cond_question_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 1
      WHERE SECTION_VERSION_SID = l_section_version_sid AND ORDER_BY > l_order_by;
    
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Endorsement/assessment based on your own budgetary forecast?') RETURNING QUESTION_SID INTO l_question_sid;
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Is your endorsement or assessment based on your own budgetary forecast figures, or someone else`s?', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    
    l_order_by := l_order_by + 1;
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('EAOBDGFRC', 0, 'Endorsement/assessment based on your own budgetary forecast?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, mostly or fully based on our own forecasts figures', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, DETS_TXT)
    VALUES (l_lov_type_sid, 'No, mostly or fully based on someone else`s figures', 1, 2, NULL, 'Please specify by what other institution');
    
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_cond_question_version_sid;
    SELECT LOV_SID INTO l_choice_b FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 3;
    SELECT LOV_SID INTO l_choice_c FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 4;
    SELECT LOV_SID INTO l_choice_d FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 5;
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_d);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;
/

--SCP-2445
DECLARE
    l_elem_type_sid NUMBER;
    l_elem_type_id VARCHAR2(400 BYTE) := 'DETAILS_TIP';
BEGIN
    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = l_elem_type_id;
    
    UPDATE CFG_UI_QSTNNR_ELEMENTS
       SET ELEMENT_TEXT = 'Press here to review the latest answers for this entry, before selecting '||chr(39)||'reformed'||chr(39)||' or '||chr(39)||'no change'||chr(39)
     WHERE ELEMENT_TYPE_SID = l_elem_type_sid; 
END;
/


--SCP-2447
DECLARE
    l_elem_type_sid NUMBER;
    l_elem_type_id VARCHAR2(400 BYTE) := 'FAB_HELP_TEXT';
BEGIN
    SELECT ELEMENT_TYPE_SID INTO l_elem_type_sid FROM CFG_UI_ELEMENT_TYPES WHERE ELEMENT_TYPE_ID = l_elem_type_id;
    
    UPDATE CFG_UI_QSTNNR_ELEMENTS
       SET ELEMENT_TEXT = 'LEGEND'
     WHERE ELEMENT_TYPE_SID = l_elem_type_sid; 
END;
/

--SCP-2458
DECLARE
    l_question_sid NUMBER;
    l_question_type_sid NUMBER;
    l_question_version_sid NUMBER;
    l_lov_type_sid NUMBER;
    l_cond_question_version_sid NUMBER;
    l_order_by NUMBER;
    l_choice NUMBER;
    l_choice_a NUMBER;
    l_choice_b NUMBER;
    l_choice_c NUMBER;
    l_choice_d NUMBER;
    l_choice_e NUMBER;
    l_choice_f NUMBER;
    l_choice_g NUMBER;
    l_choice_h NUMBER;
    l_section_version_sid NUMBER;
BEGIN
    SAVEPOINT svpt;

    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID
        FROM CFG_QUESTIONS WHERE DESCR = 'Attached to / embedded in which institution?');
    SELECT QUESTION_VERSION_SID INTO l_cond_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID
        FROM CFG_QUESTIONS WHERE DESCR = 'Legal status');
    SELECT SECTION_VERSION_SID, ORDER_BY INTO l_section_version_sid, l_order_by FROM CFG_QSTNNR_SECTION_QUESTIONS 
        WHERE QUESTION_VERSION_SID = l_cond_question_version_sid;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
       SET ORDER_BY = ORDER_BY + 1
     WHERE SECTION_VERSION_SID = l_section_version_sid
       AND ORDER_BY > l_order_by;
    UPDATE CFG_QSTNNR_SECTION_QUESTIONS
      SET ORDER_BY = l_order_by + 1
     WHERE SECTION_VERSION_SID = l_section_version_sid
       AND QUESTION_VERSION_SID = l_question_version_sid;
       
    --
    UPDATE CFG_LOVS
      SET NEED_DET = 1, DETS_TXT = 'Please specify for which topics'
     WHERE DESCR = 'Yes, but only on set topics'; 
    
    --
    SELECT QUESTION_VERSION_SID INTO l_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID
        FROM CFG_QUESTIONS WHERE DESCR = 'Powers of IFI Chair/President');
    SELECT QUESTION_VERSION_SID INTO l_cond_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID
        FROM CFG_QUESTIONS WHERE DESCR = 'Chair/President');
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_QUESTION_LOV_TYPES WHERE QUESTION_VERSION_SID = l_cond_question_version_sid;
    SELECT LOV_SID INTO l_choice FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
    
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO svpt;
        raise;
END;
/