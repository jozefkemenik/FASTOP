-- NOT IN PROD
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
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Investment Planning');
    
    --SET ORDER_BY
    l_order_by := 1;
    --q1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Long-term strategic investment plans?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Does your country have long-term strategic investment plans, at the national or sectoral level?', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('YESHNO', 0, 'Long-term strategic investment plans?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes', NULL, 1, 'Long-term strategic investment plans are systematic, coordinated and possibly comprehensive set of long-term actions surrounding the creation and maintenance of public assets (tangible and intangible), with clearly specified national objectives for these projects.')
    RETURNING LOV_SID INTO l_choice;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No', NULL, 2, NULL);
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --q2
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Types of strategic investment plans?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'The long-term planning of public investment consists of: (Select all that apply; when you list concrete plans, please, clarify which bodies are involved by indicating A for line ministries independently, B for line ministries in cooperation, C for Planning Ministry, D for Ministry of Finance, E for other (please specify))', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice);
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('TYPSIP', 0, 'Types of strategic investment plans?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --lovs
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, LOV_ID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'National strategy', 'A national strategy for public investment, which contains a vision for the country development over the long term (e.g. a national development plan)', NULL, 1, 'Guidance for public investment priorities derived from a national plan or other medium to long-term strategic documents covering the central government or including also sub-national government projects above a relevant size. It provides a vision for the country’s development priorities and tends to be less developed than plans at the sectoral/sub-sectoral level.')
    RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, LOV_ID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Sectoral plan', 'Sectoral plans for public investment (e.g. infrastructure, transport) -> please mention all sectors that apply from the COFOG II list', NULL, 2, 'A document that gives guidance for public investment priorities for an individual specific sector (e.g. infrastructure, transport, industrial strategy) over the medium to long term.')
    RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, LOV_ID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Sub-sectoral plans', 'Sub-sectoral plans for public investment (for example, in the case of transport (COFOG 4.5) select if there are railways/roads sub-plans)', NULL, 3, 'A document that gives guidance for public investment priorities for a specific sub-sector (e.g.: railway, roads, airports, water supply and sanitation) over the medium-to-long term.')
    RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, LOV_ID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other', 'Other', 1, 4, 'For example, in the case of federal states where competencies are at the level of regions, each with their own sectoral plans')
    RETURNING LOV_SID INTO l_choice_d;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --Q2.1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Name and link to strategic investment plans') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please provide name and link to the strategic investment plans', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_d);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q2.2
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('COFOG II list') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please mention all sectors that apply from the COFOG list (first- and second-level). For the list, see here: https://www.oecd.org/gov/48250728.pdf', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --CFG_QUESTION_CONDITIONS
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q3
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Measurable targets/outcomes?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Do strategic plans include measurable indicators/targets for outputs (e.g. miles of roads constructed) or outcomes (e.g. reduction in traffic congestion) of investment projects?', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    SELECT QUESTION_VERSION_SID INTO l_cond_question_version_sid FROM CFG_QUESTION_VERSIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTIONS WHERE DESCR = 'Long-term strategic investment plans?');
    SELECT LOV_SID INTO l_choice FROM CFG_LOVS WHERE LOV_TYPE_SID IN (SELECT LOV_TYPE_SID FROM CFG_LOV_TYPES WHERE LOV_TYPE_ID = 'YESHNO') AND DESCR = 'Yes';
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice);
    --LOV_TYPES
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('MESTO', 0, 'Measurable targets/outcomes?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, to a large extent -> please specify for which sector/plan', 1, 1, 'Measurable indicators for outputs are the direct results of the project required to achieve the project purpose. What will be delivered by the project upon completion should be determined ex-ante (i.e. outcome). This should include quantity and characteristics.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, to a limited extent -> please specify for which sector/plan', 1, 2, 'Measurable indicators for outputs are the direct results of the project required to achieve the project purpose. What will be delivered by the project upon completion should be determined ex-ante (i.e. outcome). This should include quantity and characteristics. ');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No -> please explain possible challenges', 1, 3, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q4
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Are national and/or sectoral strategies costed?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Are the government’s national and/or sectoral strategies costed, with details at the general, sectoral and local levels?', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice);
    --LOV_TYPES
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('NATSTRATC', 0,'Are national and/or sectoral strategies costed?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, to a significant extent -> please specify for which sector/plan ', 1, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, to a limited extent -> please specify for which sector/plan', 1, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No -> please explain possible challenges', 1, 3, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q5
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Tools to promote alignment between investment plans and annual budget?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'What tools are in place to promote alignment between strategic investment plans (national and/or sectoral) and budgetary allocation (select all that apply):', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice);
    --LOV_TYPES
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('TLSIPAB', 0,'Tools to promote alignment between investment plans and annual budget?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Medium-term expenditure framework/funds outside regular budgets explicitly aligned with strategic investment plans', NULL, 1, 'Special purpose instruments used in some countries to maintain and facilitate long-term investments in key sectors of the economy (e.g. infrastructure, defence), managed outside the regular budget process. Funds have a long time-span (e.g. 14 years), include obligatory cost-benefit analysis and often involve strong private-public partnerships. They have their own management structure.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Strategic investment plan has annual milestones and resourcing indications that facilitate alignment with the annual budgetary allocations à please specify for which sector/plan', 1, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The central budget authority has a leadership role in promoting alignment between annual budget and strategic investment plans', NULL, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'There is a central review to ensure that projects receiving funding through the annual budgets are in line with the strategic documents', NULL, 4, 'Central review: a check on projects presented in budget requests to ensure compliance with requirements for project appraisal and selection, usually performed by the budget department.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Coordination and alignment is handled via discussions at Cabinet / Council of ministers', NULL, 5, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Coordination takes place through informal and/or ad hoc coordination mechanisms between line ministries / agencies', NULL, 6, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, CFG_TYPE)
    VALUES (l_lov_type_sid, 'No direct alignment between strategic investment plans and budget allocations', NULL, 7, NULL, 3);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> please specify which tools', 1, 8, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q6
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Do strategic planning documents have info on capital stock?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Strategic planning documents (national/sectoral/subsectoral) integrate existing information on the capital stock in the following way (select all that apply): ', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice);
    --LOV_TYPES
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('SPDCAPIFO', 0,'Do strategic planning documents have info on capital stock?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'They include information on existing assets provided by comprehensive and up-to-date asset registers -> specify which plans/sectors', 1, 1, 'An official record of the property owned by the state and its institutions. These should be comprehensive and updated regularly at reasonable intervals. This is a useful way to monitor the financial and non-financial performance throughout their lifetime.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'They include information on the renewal of assets at the end of their life and/or maintenance of the existing stock of fixed assets-> specify which plans/sectors', 1, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'They include information on the capital stock estimated from national accounts data > specify which plans/sectors', 1, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> please elaborate on which type of information', 1, 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, CFG_TYPE)
    VALUES (l_lov_type_sid, 'None of the above -> please elaborate on possible challenges', 1, 5, NULL, 3);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    --Second section
    --SECTION_VERSION_SID
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Project appraisal and selection');
    
    l_order_by := 1;
    
    --q7
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Pre-appraisal of projects must include:') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Pre-appraisal of projects is required for, at least, some projects and must include the following elements (select all that apply):', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('APPPROJ', 0,'Pre-appraisal of projects must include:') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Justification for the project rationale', NULL, 1, '')
    RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Strategic relevance of the project (by linking it to specific strategic document)', NULL, 2, NULL)
    RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'An order of magnitude assessment of costs and benefits', NULL, 3, NULL)
    RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Ensuring a full range of alternatives are considered ', NULL, 4, NULL)
    RETURNING LOV_SID INTO l_choice_d;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Checking sustainability issues', NULL, 5, NULL)
    RETURNING LOV_SID INTO l_choice_e;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Identifying potential risks and constraints', NULL, 6, 'Risks related to the creation and maintenance of assets / infrastructure that can materialize as large fiscal costs with significant macroeconomic impact.')
    RETURNING LOV_SID INTO l_choice_f;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Flagging potential for adopting PPPs', NULL, 7, 'Public-private partnerships')
    RETURNING LOV_SID INTO l_choice_g;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Planning for appraisal', NULL, 8, 'Involves preparing a feasibility study or the equivalent. A feasibility study should cover both technical and economic dimensions and be supported by a preliminary technical or engineering design for the project, including cost estimates and detailed forecasts of demand for the services provided by the asset to be created or improved.')
    RETURNING LOV_SID INTO l_choice_h;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, CFG_TYPE)
    VALUES (l_lov_type_sid, 'Pre-appraisal is not required', NULL, 9, 'An ex-ante brief evaluation of the project with respect to a number of criteria, usually presented in the form of a concept note A comprehensive pre-appraisal process may involve the following criteria: checking the project rationale, verifying strategic relevance, costs and benefits assessments, ensuring that a full range of alternatives is considered, managing the project pipeline, checking sustainability, potential risks and constraints, flagging potential for adopting public-private-partnerships, and planning for appraisal. It provides an opportunity to identify and eliminate weak projects before they advance too far in the planning process or before they have gained too much political commitment.', 3);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --q7.1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Type, size and sector of the pre-appraised projects') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'For each option selected above, please provide the details where possible (type of project, size, sector)', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_d);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_e);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_f);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_g);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_h);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q8
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Appraisal process has following features:') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'The appraisal process has the following features:', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('APPPRFTS', 0,'Appraisal process has following features:') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'There are provisions requiring that all projects above a certain size and/or of a certain type (e.g. sector) be appraised based on the same methodology', NULL, 1, NULL)
    RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'There is a standardised methodology required only for a limited subset of projects (by type or size or other) ', NULL, 2, NULL)
    RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'There is no unified framework to appraisals; the methodology for appraisals is decided in an ad-hoc manner', NULL, 3, NULL)
    RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other - > please specify', 1, 4, NULL)
    RETURNING LOV_SID INTO l_choice_d;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, CFG_TYPE)
    VALUES (l_lov_type_sid, 'There is no formal appraisal of projects -> please describe how the best value for money is achieved', 1, 5, NULL, 3)
    RETURNING LOV_SID INTO l_choice_e;
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --q8.1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Details on each feature') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_versions
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please provide relevant details (e.g. list the size/type of projects based on COFOG II for which standardised methodology is required, including explicit exclusions (e.g. projects funded by PPPs or specific sub-sectors); provide example of specific methodology)', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_d);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q9
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Central support unit in the government?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, ' Is there a central support for the appraisal of projects in the form of a central government unit which provides, for example, technical analysis, training on development and implementation of appraisal methodologies?', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('YESSPNO', 0, 'Central support unit in the government?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes', 1, 1, 'Please explain (e.g. name of the unit; which line ministry; number of staff; responsibility (e.g. type of projects) and brief history)')
    RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No', NULL, 2, NULL)
    RETURNING LOV_SID INTO l_choice_b;
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q10
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Usage of appraisal results in project selection process:') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Which of the following statements is true in relation to the appraisal results as they then feed into the project selection process:', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('USAPRPSP', 0, 'Usage of appraisal results in project selection process:') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Appraisal results of projects of a certain size/sector are subject to independent and impartial review (external agency) for quality and objectivity and the review recommendations have an advisory value only', NULL, 1, NULL)
    RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Appraisal results of projects of a certain size/sector are subject to independent and impartial evaluation (external agency) for quality and objectivity, but projects with negative review recommendations cannot proceed', NULL, 2, NULL)
    RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other (e.g. ad-hoc independent and impartial evaluation of projects)', 1, 3, NULL)
    RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'There is no independent and impartial review of the appraisal results', NULL, 4, 'Input of experts that are independent and have nothing to gain from the project going ahead. The review is usually conducted by the finance ministry, a planning ministry, or an independent agency and aims to counter overestimation of demand and underestimation of costs.')
    RETURNING LOV_SID INTO l_choice_d;
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;

    --q10.1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Examples of independent reviewers (incl. type/sector):') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please provide examples of independent reviewers, including size/type/sector of projects they apply to', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_d);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;

    --q11
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Any standard criteria for project selection set by government?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Has the government set (public) standard criteria, and/ or a required process for project selection at the annual budget allocation stage?', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('SCRPSGOV', 0, 'Any standard criteria for project selection set by government?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes -> please clarify for which sectors/line ministries, type of projects and type of criteria (e.g. cost-benefit analysis, relative value for money, political interest/agenda)', 1, 1, 'Project selection is the formal decision on a project’s social viability and sustainability, and confirmation of its eligibility to be proposed for budget funding. Selection does not mean that funding is guaranteed as this can only happen through the budgetary process.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'To some extent -> please clarify for which sectors/line ministries, type of projects and type of criteria (e.g. cost-benefit analysis, relative value for money, political interest/agenda)', 1, 2, 'Project selection is the formal decision on a project’s social viability and sustainability, and confirmation of its eligibility to be proposed for budget funding. Selection does not mean that funding is guaranteed as this can only happen through the budgetary process.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No -> please explain how the project selection is done at the budget allocation stage', 1, 3, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q12
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Does the government undertake a central review?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Does the government undertake a central review of project appraisals to ensure the standard appraisal methodology has been applied prior to inclusion in the budget? ', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('GOVUNTKCREV', 0, 'Does the government undertake a central review?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, to a large extent -> please explain (e.g. name of the unit; which line ministry; number of staff; type of projects covered)', 1, 1, 'A central review is a check on projects presented in budget requests to ensure compliance with requirements for project appraisal and selection, usually performed by the budget department. ');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, to some extent -> please explain (e.g. name of the unit; which line ministry; number of staff; type of projects covered)', 1, 2, 'A central review is a check on projects presented in budget requests to ensure compliance with requirements for project appraisal and selection, usually performed by the budget department. ');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No', NULL, 3, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q13
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Does the government maintain a shortlist of projects?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Does the government/line ministry maintain a shortlist of projects for budgetary consideration? ', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('GOVMSHPR', 0, 'Does the government maintain a shortlist of projects?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, there is one list at the government/central level', NULL, 1, 'A shortlist of projects is a (reduced) list of projects that have been positively assessed and prioritized. Projects on the short-list are considered for funding.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, there are different lists by sectors/line ministries', NULL, 2, 'A shortlist of projects is a (reduced) list of projects that have been positively assessed and prioritized. Projects on the short-list are considered for funding. ');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No -> please explain how the selection of projects is undertaken in the absence of a list (free text)', 1, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> please explain', 1, 4, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q14
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('At what stage is value for money checked?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'How many times is the value for money of investment projects checked (select all that apply and please specify sector/type for each selected option):', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('STGVMONC', 0, 'At what stage is value for money checked?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Only during assessment and selection of project -> please specify sector/type', 1, 1, 'Value for money is not paying more for a good or service than its quality would justify. In relation to public spending, it implies a concern with economy (cost minimization), efficiency (output maximization) and effectiveness (full attainment of the intended results).  ');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'After public procurement process and before signing the contract -> please specify sector/type', 1, 2, 'Value for money is not paying more for a good or service than its quality would justify. In relation to public spending, it implies a concern with economy (cost minimization), efficiency (output maximization) and effectiveness (full attainment of the intended results).  ');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'During implementation of the project, if some significant risks materialised -> please specify sector/type', 1, 3, 'Risks related to the creation and maintenance of assets / infrastructure that can materialize as large fiscal costs with significant macroeconomic impact.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'After implementation of the project -> please specify sector/type', 1, 4, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q15
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Consequences of not meeting value for money requirements?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'What happens to the investment projects, if assessment does not demonstrate the sufficient value for money and social economic benefits?', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('CMTVMOBREQ', 0, 'Consequences of not meeting value for money requirements?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Project will be rejected -> please specify if this only applies to certain sectors', 1, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Project will be passed to the political decision -> please specify if this only applies to certain sectors', 1, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Project will be restructured in order to improve the value for money -> please specify if this only applies to certain sectors', 1, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> Please specify the other consequences', 1, 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No consequences if projects do not meet value for money requirements.', 1, 5, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    
    --Third section
    --SECTION_VERSION_SID
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Budgeting for investment');
    
    l_order_by := 1;
    
    --q16
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Capital investment considered in MTBF?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'How is capital investment considered in the medium-term budgetary framework? ', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('CAPINMTB', 0, 'Capital investment considered in MTBF?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Multi-year commitment appropriations at ministry or programme level', NULL, 1, 'An initial multiannual commitment is made for the total cost of the approved project. This appropriation is reserved for one specific project and may not be used for other purposes. The unused balance of the multiannual appropriation, if any, is then carried forward to subsequent years so as to remain available when further contracts for the project are signed. ');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Specific capital expenditure allocations -> please elaborate on how binding they are (can they be revised every year?)', 1, 2, 'Expenditure incurred in the acquisition, creation or significant improvement of a fixed asset, both physical and intangible (e.g. building, machinery, R'||CHR(38)||'D, computer software).');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Mandatory expenditure ceilings', NULL, 3, 'Limits of expenditure fixed by law or by agreement. Ceilings can be aggregated by sector, by ministry or programme. They are usually presented in the national medium-term fiscal or budgetary documents.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Guiding expenditure ceilings', NULL, 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Capital investments are not considered in the medium-term budgetary framework', NULL, 5, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> please provide details ', 1, 6, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q17
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Submission of and decision on expenditure') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Regarding capital expenditure and related current expenditure', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('SUBMEXPD', 0, 'Submission of expenditure') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Capital and current expenditure are submitted and considered in an integrated way, either by a single ministry or by different ministries ', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Capital and current expenditure requests are submitted together by line ministries/single ministries, but the process for deciding upon capital and operating budget requests are distinct ', NULL, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Capital and current expenditure requests are submitted separately by line ministries and the process for deciding upon capital and operating budget requests are distinct ', NULL, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> please explain the procedure for submission of and decision on expenditure figures', 1, 4, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q18
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Features of maintenance funding') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Regarding maintenance funding (select all that apply):', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('GOVUCREV', 0, 'Features of maintenance funding') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'There is a standard methodology for estimating routine maintenance needs or costs (part of the life cycle costs assessment and management)', NULL, 1, 'Funds for maintenance and repairs that are essential, as the expected service life of the asset may be drastically shortened otherwise. These are recurrent costs and are classified as current expenditure. Maintenance costs are usually included in life cycle cost estimates of capital projects, together with initial capital costs, operating costs and the asset’s residual value at the end of its life.')
    RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The appropriate amounts for standard maintenance are generally allocated to the budget', NULL, 2, NULL)
    RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Routine maintenance costs are systematically identified in the budget or other documentation', NULL, 3, NULL)
    RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, CFG_TYPE)
    VALUES (l_lov_type_sid, 'There is no standard methodology for estimating routine maintenance needs or costs', NULL, 4, NULL, 3);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The appropriate amounts for standard maintenance are not allocated to the budget and cannot be systematically identified in the budget', NULL, 5, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --Q18.1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Additional information on maintenance funding') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please provide any additional info on maintenance funding (e.g. sector/type of project)', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);    

    --Fourth section
    --SECTION_VERSION_SID
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Project implementation and monitoring/adjustment');
    
    l_order_by := 1;
    
    --q19
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('At what levels does the monitoring take place?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Monitoring of implementation plans takes place', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('LVLMONPLC', 0, 'At what levels does the monitoring take place?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'At the level of the implementing agency/line ministry only ', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Both at the level of the implementing agency/line ministry and centrally (Ministry of planning or development/Ministry of finance/ Council of ministers) ', NULL, 2, NULL)
    RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Centrally, at the level of Ministry of Planning/Development or Ministry of Finance/Council of Ministers', NULL, 3, NULL)
    RETURNING LOV_SID INTO l_choice_c;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> please explain the other level monitoring takes place at', 1, 4, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --Q19.1
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Which monitoring body?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please indicate which body is monitoring at the central level', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q19.2
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Details on monitoring') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please specify for which projects (sector/size)', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q20
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Is there a monitoring system for public investment?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Is there a monitoring system for public investment in your country?', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    SELECT LOV_TYPE_SID INTO l_lov_type_sid FROM CFG_LOV_TYPES WHERE LOV_TYPE_ID = 'YESNO';
    --l_choice_a
    SELECT LOV_SID INTO l_choice_a FROM CFG_LOVS WHERE LOV_TYPE_SID = l_lov_type_sid AND ORDER_BY = 1;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --Q21
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Which type(s) of monitoring?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'If yes to Q20, what type of monitoring is carried out? (select all that apply and please provide for each answer the relevant details on the operation of the monitoring system): ', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('TYPMONIT', 0, 'Which type(s) of monitoring?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Financial (Costs)', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Procedural', NULL, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Physical', NULL, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> please explain the other type of monitoring', 1, 4, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --Q22
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Rules, procedures or guidelines for adjusting projects?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Are there rules, procedures or guidelines to enable project adjustment?', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('RPGADJPJ', 0, 'Rules, procedures or guidelines for adjusting projects?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, only for certain projects ', NULL, 1, 'Project adjustment is a procedure that allows action when there are deviations from initially agreed-on aspects of a project (e.g. exceeding budget or schedule). Fundamental adjustments to improve the chances of success are done.')
    RETURNING LOV_SID INTO l_choice_a;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Yes, for all projects', NULL, 2, 'Project adjustment is a procedure that allows action when there are deviations from initially agreed-on aspects of a project (e.g. exceeding budget or schedule). Fundamental adjustments to improve the chances of success are done.')
    RETURNING LOV_SID INTO l_choice_b;
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'No -> please elaborate on possible challenges (e.g. regulatory) to implementing project adjustment', 1, 3, NULL);
    
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_cond_question_version_sid := l_question_version_sid;
    l_order_by := l_order_by + 1;
    
    --q23
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Which rules and types of procedures?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please select all that apply, and then, for each answer, please specify by which types/size of the projects.', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_a);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('RLSTYPRC', 0, 'Which rules, types of procedures?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'If, during implementation, the total cost exceeds a certain threshold, a reassessment of the feasibility of the project is required -> specify details (type/size of project)', 1, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'If, during implementation, the exceeding costs threaten to jeopardize the viability of the project, an adjustment is needed, such as cutting costs by changing the project’s scope or closing down the project entirely -> specify details (type/size of project)', 1, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'A framework is in place to enable the termination of a project in case its costs no longer justify the benefits to society -> specify details (type/size of project)', 1, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Other -> please explain the other rule(s) and or type(s) of procedure and specify type/size of project', 1, 4, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --fifth section
    --SECTION_VERSION_SID
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Ex-post impact evaluation and asset registers');
    
    l_order_by := 1;
    
    --q24
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Ex-post reviews used by the government?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Are ex-post reviews of projects used by the government to adjust project implementation policies and procedures:', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('EXPREVGOV', 0, 'Ex-post reviews used by the government?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Ex-post reviews of projects are neither systematically required, nor frequently conducted -> please explain (on potential impediments/difficulties)', 1, 1, 'An assessment of the project implementation policies and procedures in order to inform the design of policy and the development of similar future projects and to strengthen accountability for project results');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Ex-post reviews of projects, focusing on project costs, deliverables and outputs are sometimes conducted -> please explain sector/project size, incl. possible difficulties', 1, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Ex-post reviews of projects, focusing on project costs, deliverables and outputs are conducted regularly by an independent entity or experts, and are used to adjust project implementation policies and procedures -> please explain sector/project size, incl. possible difficulties', 1, 3, NULL);
    
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q25
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Specifics on asset registers:') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Regarding asset registers (select all that apply):', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('SPECASSREG', 0, 'Specifics on asset registers:') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Asset registers are comprehensive -> please specify (type of projects/sectors covered)', 1, 1, 'An official record of the property owned by the state and its institutions. These should be comprehensive and updated regularly at reasonable intervals. This is a useful way to monitor the financial and non-financial performance throughout their lifetime.');
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Asset registers are updated regularly at reasonable intervals -> please specify frequency/process', 1, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Asset registers are used for regulatory decisions or planning purposes -> please provide an example of a feedback loop between asset registers and regulatory decisions/planning', 1, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Financial and non-financial asset values are not systematically nor comprehensively recorded in the government financial accounts', NULL, 4, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    
    --sixth section
    --SECTION_VERSION_SID
    SELECT SECTION_VERSION_SID INTO l_section_version_sid FROM CFG_SECTION_VERSIONS WHERE SECTION_SID IN (SELECT SECTION_SID FROM CFG_SECTIONS WHERE DESCR = 'Other issues: ongoing/planned reforms, EU funds, administrative capacity, State-owned enterprises');
    
    l_order_by := 1;
    
    --q26
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Any PIM reforms ongoing or planned?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'If relevant, please elaborate on ongoing or planned reforms of relevance for any of the questions of the survey. Please indicate the question when providing details (free text) ', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q27
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Any administrative capacity constraints?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Please elaborate on how administrative capacity or capacity constraints of any kind (e.g. construction) is hampering any of the functions of public investment management listed above and what steps are taken in response. (free text)', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q28
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Differences in management of nationally financed vs EU cofinanced investments?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Are there significant differences in the management of EU funds vs nationally financed investments along the issues addressed by the survey questions? Should that be the case, please elaborate on key differences while indicating the question number. (free text) ', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q29
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Differences in management of tangible vs. intangible investments?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Free text';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'Are there significant differences in the management of intangible assets vs. tangible assets along the issues addressed by the survey questions? Should that be the case, please elaborate on key differences while indicating the question number. (free text) ', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --cfg_question_conditions
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_b);
    INSERT INTO CFG_QUESTION_CONDITIONS(QUESTION_VERSION_SID, COND_QUESTION_VERSION_SID, LOV_SID)
    VALUES (l_question_version_sid, l_cond_question_version_sid, l_choice_c);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q30
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Specifics on state-owned enterprise investments') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Single choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'With respect to investments by state-owned enterprises:', 1, 0) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('SPECSOEINV', 0, 'Specifics on state-owned enterprise investments') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'They represent a meaningful share of public spending -> indicate the key sectors they operate in', 1, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Investment by state-owned enterprises generally follow different rules than centrally-funded investments à indicate some significant differences while including a reference to the survey questions, if possible', 1, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'None of the above', 1, 3, NULL);

    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
    --q31
    --cfg_question
    INSERT INTO CFG_QUESTIONS(DESCR) VALUES ('Role of Commission in PIM?') RETURNING QUESTION_SID INTO l_question_sid;
    --question_type
    SELECT QUESTION_TYPE_SID INTO l_question_type_sid FROM CFG_QUESTION_TYPES WHERE DESCR = 'Multiple choice';
    --cfg_question_version
    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, ALWAYS_MODIFY)
    VALUES (l_question_sid, l_question_type_sid, 'How would you like to see the European Commission support future developments in public investment management (PIM)? Please select all that apply.', 1, 1) RETURNING QUESTION_VERSION_SID INTO l_question_version_sid;
    --lov_type
    INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DYN_SID, DESCR) VALUES ('ROLCOMPIM', 0, 'Role of Commission in PIM?') RETURNING LOV_TYPE_SID INTO l_lov_type_sid;
    --question_lov_type
    INSERT INTO CFG_QUESTION_LOV_TYPES(QUESTION_VERSION_SID, LOV_TYPE_SID) VALUES (l_question_version_sid, l_lov_type_sid);
    --LOVS
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The development of country-specific plans for further strengthening of PIM;', NULL, 1, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'The development of guidance for PIM and its tools and processes. ', NULL, 2, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Country-specific technical support for further strengthening of PIM;', NULL, 3, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Identifying international best practices in PIM (use and results);', NULL, 4, NULL);
    INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT)
    VALUES (l_lov_type_sid, 'Organising meetings to share country experiences with PIM', NULL, 5, NULL);
    --CFG_SECTION_QUESTIONS
    INSERT INTO CFG_QSTNNR_SECTION_QUESTIONS(SECTION_VERSION_SID, QUESTION_VERSION_SID, ORDER_BY)
    VALUES (l_section_version_sid, l_question_version_sid, l_order_by);
    
    l_order_by := l_order_by + 1;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM || 'SECTION = ' ||  l_section_version_sid || 'ORDER_BY = ' ||l_order_by);
        ROLLBACK TO SVPT;
END;
/
