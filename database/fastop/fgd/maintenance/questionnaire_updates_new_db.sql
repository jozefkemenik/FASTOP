-- SCP-2213 MTBF questionnaire updates
INSERT INTO CFG_LOVS (LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (877, 123, 'There is no independent monitoring report', 6);

UPDATE CFG_QUESTION_VERSIONS SET MANDATORY=1 WHERE QUESTION_VERSION_SID=299;

UPDATE TARGET_ENTRIES_CFG SET YEARS_FORW_COUNT=6 WHERE APP_ID='MTBF';

-- SCP-2214 NFR questionnaire updates
UPDATE CFG_QUESTIONS
SET descr = 'Numerical Target or ceiling (in selected Measurement Unit)'
WHERE question_sid=12;

UPDATE CFG_QUESTION_VERSIONS
SET help_text = 'Please indicate which of the data sources provided is the most appropriate to assess ex-ante compliance with this rule for budgetary year {YEAR} (according to the initial annual budgetary documents prepared in {YEAR1}). In case none of the sources is considered suitable, please choose "custom compliance assessment" to provide your own alternative source.'
WHERE QUESTION_VERSION_SID=52;

-- SCP-2215 GBD questionnaire updates
INSERT INTO CFG_QUESTION_CONDITIONS (COND_SID, QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (508, 353, 306, 7);
INSERT INTO CFG_QUESTION_CONDITIONS (COND_SID, QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (509, 353, 306, 8);
INSERT INTO CFG_QUESTION_CONDITIONS (COND_SID, QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID) VALUES (510, 353, 306, 9);

UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY=6 WHERE SECTION_VERSION_SID=58 AND QUESTION_VERSION_SID=384;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY=7 WHERE SECTION_VERSION_SID=58 AND QUESTION_VERSION_SID=382;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY=8 WHERE SECTION_VERSION_SID=58 AND QUESTION_VERSION_SID=350;
UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY=9 WHERE SECTION_VERSION_SID=58 AND QUESTION_VERSION_SID=383;

UPDATE CFG_LOVS SET CFG_TYPE=4 WHERE LOV_TYPE_SID=15;
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (17, 83, 84);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (18, 84, 83);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (19, 85, 86);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (20, 86, 85);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (21, 87, 88);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (22, 88, 87);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (23, 89, 90);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (24, 90, 89);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (25, 91, 92);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (26, 92, 91);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (27, 93, 94);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (28, 94, 93);


-- SCP-2216 IFI Questionnaire updates
UPDATE CFG_QUESTIONS SET DESCR = 'Involvement with preparation of the RRP' WHERE QUESTION_SID=213;

UPDATE CFG_QUESTION_VERSIONS
SET HELP_TEXT = 'Please indicate the involvement of the fiscal institution in the preparation of the recovery and resilience plan, i.e. before the government submitted the plan'
WHERE QUESTION_VERSION_SID=213;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution assessed/validated the policy costings included in the recovery and resilience plan, as part of its mandate'
WHERE LOV_SID=856;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution assessed/validated the policy costings included in the recovery and resilience plan as a result of an explicit ad hoc request by the government'
WHERE LOV_SID=857;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution assessed/validated the macroeconomic/budgetary forecasts used in the recovery and resilience plan  '
WHERE LOV_SID=858;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution performed any other task in the preparation (e.g. impact on fiscal stance; macroeconomic impact of policies, green or digital impacts)'
WHERE LOV_SID=859;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution was consulted on any other particular matter related to the preparation of the recovery and resilience plan'
WHERE LOV_SID=860;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution was not involved in the preparation of the recovery and resilience plan'
WHERE LOV_SID=861;


UPDATE CFG_QUESTIONS SET DESCR = 'Involvement with implementation/assessment of the RRP after approval' WHERE QUESTION_SID=214;

UPDATE CFG_QUESTION_VERSIONS
SET HELP_TEXT = 'Please indicate the actual or expected involvement of the fiscal institution with the implementation recovery and resilience plan, i.e. after  the plan had been approved at the EU level'
WHERE QUESTION_VERSION_SID=214;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution is expected to issue or has issued an opinion on the overall quality and feasibility of the recovery and resilience plan'
WHERE LOV_SID=862;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution is expected to issue or has issued an opinion on specific elements of the recovery and resilience plan'
WHERE LOV_SID=863;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution is expected to assess or has assessed certain milestones and targets'
WHERE LOV_SID=864;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution is expected to perform or has performed any other task in the implementation, including anything planned at your own initiative'
WHERE LOV_SID=865;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution is expected to be consulted or was consulted on any other particular matter related to the recovery and resilience plan'
WHERE LOV_SID=866;

UPDATE CFG_LOVS
SET DESCR = 'The fiscal institution has not been or is not expected to be involved in the implementation of the recovery and resilience plan after its submission'
WHERE LOV_SID=867;


UPDATE CFG_QUESTIONS SET DESCR = 'Challenges with IFI activities' WHERE QUESTION_SID=215;

UPDATE CFG_QUESTION_VERSIONS
SET HELP_TEXT = 'Could you elaborate on the main challenges, already encountered or expected, in relation to the activities of your IFI during the Covid-19 crisis?'
WHERE QUESTION_VERSION_SID=215;

UPDATE CFG_QSTNNR_SECTION_QUESTIONS SET ORDER_BY=5 WHERE SECTION_VERSION_SID=72 AND QUESTION_VERSION_SID=215;

-- NEW QUESTIONS
INSERT INTO CFG_QUESTIONS(QUESTION_SID, DESCR) VALUES (414, 'Effects of Covid-19 crisis for resources/guidance for IFI');
INSERT INTO CFG_QUESTIONS(QUESTION_SID, DESCR) VALUES (415, 'Reason for change in resources');
INSERT INTO CFG_QUESTIONS(QUESTION_SID, DESCR) VALUES (416, 'Potential expansion of IFI activities');

-- NEW QUESTION VERSIONS
INSERT INTO CFG_QUESTION_VERSIONS
(QUESTION_VERSION_SID, QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY)
VALUES
    (418, 414, 2,'During the Covid-19 crisis, our IFI was affected in the following ways', 1);

INSERT INTO CFG_QUESTION_VERSIONS
(QUESTION_VERSION_SID, QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY)
VALUES
    (419, 415, 1,'Were the changes in resources mostly due to increased workload during the COVID-19 crisis?', 1);

INSERT INTO CFG_QUESTION_VERSIONS
(QUESTION_VERSION_SID, QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY)
VALUES
    (420, 416, 2,'If provided with sufficient resources in the coming years, which new areas of activity would you find most relevant to engage in?', 1);

INSERT INTO CFG_QUESTION_VERSIONS
(QUESTION_VERSION_SID, QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT)
VALUES
    (421, 39, 5,'Are there any further points that you would like to raise regarding the activities or resources of the fiscal institution during the COVID-19 crisis?');

-- NEW QUESTIONNAIRE SECTION QUESTIONS
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS (SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY) VALUES (72, 418, 3);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS (SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY) VALUES (72, 419, 4);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS (SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY) VALUES (72, 420, 6);
INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS (SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY) VALUES (72, 421, 7);

-- NEW LOV TYPES
INSERT INTO CFG_LOV_TYPES (LOV_TYPE_SID, LOV_TYPE_ID, DESCR, DYN_SID) VALUES (248, 'EFFC19RG', 'Effects of Covid-19 crisis for resources/guidance for IFI', 0);
INSERT INTO CFG_LOV_TYPES (LOV_TYPE_SID, LOV_TYPE_ID, DESCR, DYN_SID) VALUES (249, 'RCHGRSC', 'Reason for change in resources', 0);
INSERT INTO CFG_LOV_TYPES (LOV_TYPE_SID, LOV_TYPE_ID, DESCR, DYN_SID) VALUES (250, 'PEXIFIA', 'Potential expansion of IFI activities', 0);

-- NEW LOVS
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (878, 248, 'The fiscal institution got access to new relevant expertise than in the previous years', 1);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (879, 248, 'The fiscal institution got access to more staff than in the previous years', 2);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (880, 248, 'The fiscal institution got access to more funds than in the previous years', 3);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (881, 248, 'The fiscal institution benefited from more administrative guidance from the government than in previous years', 4);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (882, 248, 'The fiscal institution got access to more resources of another type', 1, 5);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (883, 248, 'The fiscal institution had access to less relevant expertise than in the previous years', 6);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (884, 248, 'The fiscal institution had access to less staff than in the previous years', 7);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (885, 248, 'The fiscal institution had access to less funds than in the previous years', 8);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (886, 248, 'The fiscal institution received less administrative guidance from the government than in previous years', 9);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (887, 248, 'The fiscal institution got access to less resources of another type', 1, 10);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY, CFG_TYPE) VALUES (888, 248, 'There was no change in the resources or guidance that the fiscal institution received in order to perform its tasks', 11, 3);

INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (889, 249, 'Yes', 1);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (890, 249, 'Sometimes (please specify in which cases they did and alternative factors for the other cases)', 1, 2);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (891, 249, 'No (please explain what other factors played a role)', 1, 3);

INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (892, 250, 'Distributional impact analysis', 1);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (893, 250, 'Debt sustainability analysis / long-term sustainability analysis', 2);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (894, 250, 'Green budgeting / environmental impact analysis', 3);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (895, 250, 'Spending reviews', 4);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (896, 250, 'Monitoring compliance with fiscal rules', 5);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (897, 250, 'Monitoring connectedness of budgets with medium-term plans', 6);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (898, 250, 'Assessing medium-term plans more thoroughly', 7);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (899, 250, 'Producing a macroeconomic forecast', 8);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (900, 250, 'Assessing the budgetary forecast', 9);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (901, 250, 'Producing a budgetary forecast', 10);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (902, 250, 'Policy costing / quantification of effects of policies', 11);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (903, 250, 'Active promotion of fiscal transparency', 12);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (904, 250, 'Assessing efficiency and effectiveness of public investment', 13);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY) VALUES (905, 250, 'Assessing the fiscal impact of climate change', 14);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (906, 250, 'More cooperation with or technical assistance from the European Commission (please explain on what topics/in what ways)', 1, 15);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY) VALUES (907, 250, 'Other', 1, 16);
INSERT INTO CFG_LOVS(LOV_SID, LOV_TYPE_SID, DESCR, ORDER_BY, CFG_TYPE) VALUES (908, 250, 'None of the above', 17, 3);

INSERT INTO CFG_QUESTION_LOV_TYPES (QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (418, 248);
INSERT INTO CFG_QUESTION_LOV_TYPES (QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (419, 249);
INSERT INTO CFG_QUESTION_LOV_TYPES (QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (420, 250);

-- IFI
UPDATE CFG_QUESTION_VERSIONS
SET HELP_TEXT = 'Please indicate at which point of budgetary cycle monitoring/ assessment of compliance with numerical fiscal rules is carried out. If different arrangements apply to different rules, please specify by selecting other'
WHERE QUESTION_VERSION_SID = 121;

-- MTBF
UPDATE CFG_LOVS SET CFG_TYPE = 4 WHERE LOV_SID IN (540,542,543,544);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (29, 543, 544);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (30, 544, 543);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (31, 540, 542);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (32, 542, 540);

UPDATE CFG_LOVS SET CFG_TYPE = 4 WHERE LOV_SID IN (557,558,559,562);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (33, 557, 558);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (34, 558, 557);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (35, 559, 562);
INSERT INTO CFG_CHOICES_CONDITIONS (CHOICE_SID, LOV_SID, COND_LOV_SID) VALUES (36, 562, 559);

COMMIT;

