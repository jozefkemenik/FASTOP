
ALTER TRIGGER "CFG_QUESTION_TYPES_TRG" DISABLE;
REM INSERTING into CFG_QUESTION_TYPES
SET DEFINE OFF;
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (1,'Single choice',null,'EntrySidValue',null,1);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (2,'Multiple choice',1,'EntryMultValue',null,1);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (3,'Single dropdown',null,'EntrySidValue',null,1);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (4,'Multiple dropdown',1,'EntryMultValue',null,1);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (5,'Free text',null,'EntryTextValue',null,null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (6,'Single line',null,'EntryTextValue',null,null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (7,'Number',null,null,null,null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (8,'Linked Entries',1,'EntryLinkableEntries','EntryLinkableEntries',null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (9,'No answer',null,null,null,null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (10,'Numerical Target',1,'CurrentTargetValue',null,null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (11,'Date',null,'EntryDateValue',null,null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (12,'No choice',1,'EntryMultValue',null,1);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (13,'Assessment text',null,'EntryAssessmentTextValue',null,null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (14,'Assessment single choice',null,'EntryAssessmentSidValue',null,1);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (15,'Assessment multiple choice',1,'EntryAssessmentMultValue',null,1);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (16,'Assessment multiple text',1,'EntryAssessmentMultTextValue',null,null);
Insert into CFG_QUESTION_TYPES (QUESTION_TYPE_SID,DESCR,MULTIPLE,ACCESSOR,OPTIONS,MAP_TO_RESP_CHOICES) values (17,'Assessment Compliance',null,'EntryAssessmentSidValue',null,null);
ALTER TRIGGER "CFG_QUESTION_TYPES_TRG" ENABLE;

DECLARE

CURSOR c_old_questions IS
SELECT DISTINCT A.QUESTION_SID, A.DESCR, A.QUESTION_TYPE_SID, B.ATTR_SID,
        B.MANDATORY, B.HELP_TEXT, B.INDEX_ATTR, B.MASTER_SID, B.ADD_INFO, A.QUESTIONNAIRE_SID
FROM fgd_cfg_questions A,
    FGD_CFG_ATTRIBUTES B
    WHERE A.QUESTION_SID = B.QUESTION_SID
      AND A.QUESTION_TYPE_SID != 11
      AND A.QUESTION_TYPE_SID != 16
      AND B.ATTR_SID != 0
      AND B.ATTR_NAME NOT IN ('MTP_SECTOR_MACRO_SID', 'OCCUP_LIMIT_SID')
    ORDER BY A.QUESTIONNAIRE_SID, A.QUESTION_SID;
      
l_key CFG_questions.QUESTION_SID%TYPE;
l_version_key NUMBER;
BEGIN
    FOR r_question IN c_old_questions LOOP
        BEGIN
            BEGIN
                INSERT INTO CFG_questions(DESCR) values (r_question.DESCR)
                RETURNING question_sid INTO l_key;
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT QUESTION_SID INTO l_key FROM CFG_QUESTIONS WHERE DESCR = r_question.DESCR;
                END;

                BEGIN
                INSERT INTO QUESTIONS_MIG (OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
                VALUES (r_question.QUESTION_SID, l_key, 1);
                EXCEPTION
                 WHEN OTHERS THEN
                 LOG_FAIL('QUESTIONS_MIG', SYSDATE, SQLERRM(), l_key);
                end;
                log_info('CFG_QUESTIONS', SYSDATE, 'Migrated with SUCC ' , r_question.question_sid);
                
                BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID)
                    VALUES (l_key, r_question.QUESTION_TYPE_SID, r_question.HELP_TEXT, r_question.MANDATORY, r_question.INDEX_ATTR, r_question.ADD_INFO, r_question.MASTER_SID)
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
                EXCEPTION
                 WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_key);
                END;
                log_info('CFG_QUESTION_VERSIONS', SYSDATE, 'Migrated with SUCC ' , r_question.question_sid);
				INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (r_question.ATTR_SID, l_version_key);
				log_info('QUESTION_VERSIONS_MIG', SYSDATE, 'Migrated with SUCC ' , l_version_key);
				
				UPDATE QUESTIONS_MIG
				   SET NEW_QUESTION_VERSION_SID = l_version_key
				 WHERE OLD_QUESTION_SID =  r_question.QUESTION_SID 
				   AND NEW_QUESTION_SID = l_key;
				COMMIT;
			l_version_key := 0;
            l_key := 0;
        EXCEPTION
            WHEN OTHERS THEN
                log_fail('general failure', SYSDATE, SQLERRM(), r_question.question_sid);
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        log_fail('general failure', SYSDATE, SQLERRM(), -1);
END;
/

--mig date questions separetely
DECLARE
    CURSOR c_data IS
        SELECT 'Date of 1st Entry into force' AS DESCR FROM DUAL
        UNION
        SELECT 'Date of Entry into Force' AS DESCR FROM DUAL
        UNION
        SELECT 'Adoption Date' AS DESCR FROM DUAL
        UNION
        SELECT 'Last Reform Date' AS DESCR FROM DUAL
        UNION
        SELECT 'Date of establishment' AS DESCR FROM DUAL
        UNION
        SELECT 'Abolition Date' AS DESCR FROM DUAL
        UNION
        SELECT 'Date of last reform' AS DESCR FROM DUAL
        UNION
        SELECT 'Entry into force of last reform' AS DESCR FROM DUAL;
    
    l_question_sid NUMBER;
    l_version_key NUMBER;
BEGIN
    FOR rec IN c_data LOOP
        BEGIN
            INSERT INTO CFG_QUESTIONS(DESCR)
            VALUES (rec.DESCR)
            RETURNING QUESTION_SID INTO l_question_sid;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_FAIL('CFG_QUESTIONS', sysdate, sqlerrm(), -11);
        END;
        
        IF rec.DESCR = 'Date of 1st Entry into force' THEN
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (3, l_question_sid, 1);
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (233, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please indicate the date that this rule entered into force for the first time.', NULL, NULL, NULL, NULL, 'IMPL_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (3, l_version_key);
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (77, l_version_key);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please specify when the current MTBF first entered into force', 1, NULL, NULL, NULL, 'IMPL_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (227, l_version_key);
            
        ELSIF rec.DESCR = 'Date of Entry into Force' THEN
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (40, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please indicate the date in which the reform entered/will enter into force.', NULL, NULL, NULL, NULL, 'REFORM_IMPL_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (51, l_version_key);
                
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, NULL, NULL, NULL, NULL, NULL, 'REFORM_ADOPT_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (78, l_version_key);
        ELSIF rec.DESCR = 'Adoption Date' THEN
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (37, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please indicate the approval date of the rule.', NULL, NULL, NULL, NULL, 'APPRV_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (48, l_version_key);
                
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (232, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please specify when the current MTBF was first adopted', 1, NULL, NULL, NULL, 'APPRV_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (226, l_version_key);
       ELSIF rec.DESCR = 'Last Reform Date' THEN
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (39, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please indicate the date in which the reform to the rule was adopted.', NULL, NULL, NULL, NULL, 'REFORM_ADOPT_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (50, l_version_key);
      ELSIF rec.DESCR = 'Date of establishment' THEN
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (90, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please indicate the date when the fiscal institution started operating', NULL, NULL, NULL, NULL, 'IMPL_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (83, l_version_key);
        ELSIF rec.DESCR = 'Abolition Date' THEN
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (42, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please indicate the date in which the rule was/is to be abolished.', NULL, NULL, NULL, NULL, 'ABOLITION_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (53, l_version_key);
                
        ELSIF rec.DESCR = 'Date of last reform' THEN
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (91, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please indicate the date the last reform entered into force', NULL, NULL, NULL, NULL, 'REFORM_IMPL_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (84, l_version_key);
                
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (234, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please specify when the most recent reform to the current MTBF was adopted', NULL, NULL, NULL, NULL, 'REFORM_IMPL_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (228, l_version_key);
        ELSIF rec.DESCR = 'Entry into force of last reform' THEN
            INSERT INTO QUESTIONS_MIG(OLD_QUESTION_SID, NEW_QUESTION_SID, STATUS)
            VALUES (235, l_question_sid, 1);
            
            BEGIN
                    INSERT INTO CFG_QUESTION_VERSIONS(QUESTION_SID, QUESTION_TYPE_SID, HELP_TEXT, MANDATORY, INDEX_ATTR, ADD_INFO, MASTER_SID, ACCESSOR)
                    VALUES (l_question_sid, 11, 'Please specify when the most recent reform to the current MTBF entered into force', NULL, NULL, NULL, NULL, 'REFORM_ADOPT_DATE')
					RETURNING QUESTION_VERSION_SID INTO l_version_key;
            EXCEPTION
                WHEN OTHERS THEN 
                 log_fail('CFG_QUESTION_VERSIONS', sysdate, sqlerrm(), l_question_sid);
            END;
            
            INSERT INTO QUESTION_VERSIONS_MIG(OLD_ATTR_SID, NEW_QUESTION_VERSION_SID)
				VALUES (229, l_version_key);
        END IF;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('MIG DATE QUESTIONS', sysdate, sqlerrm(), -22);
END;
/

UPDATE cfg_question_versions SET ACCESSOR = 'ABOLITION_REASON'
WHERE QUESTION_VERSION_SID IN (
SELECT cqv.question_version_sid 
    FROM cfg_question_versions  cqv
        ,question_versions_mig qvm
        ,fgd_cfg_attributes ca
   WHERE CQV.QUESTION_VERSION_SID = QVM.NEW_QUESTION_VERSION_SID
     AND QVM.OLD_ATTR_SID = CA.ATTR_SID
     AND CA.attr_name like '%ABOL%REASON%');
COMMIT;
/     

        