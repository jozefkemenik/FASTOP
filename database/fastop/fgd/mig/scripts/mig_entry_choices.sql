--MIGRATE DESIGN PART
--NFR 

DECLARE
    CURSOR c_OLD_entries_CFG IS
    SELECT DISTINCT ATTR.*, 
           QVM.NEW_QUESTION_VERSION_SID, 
           get_question_type(QVM.NEW_QUESTION_VERSION_SID) as question_type 
        FROM FGD_CFG_ATTRIBUTES ATTR,
            QUESTION_VERSIONS_MIG QVM
     WHERE ATTR.ATTR_SID = QVM.OLD_ATTR_SID
     AND ATTR.QUESTIONNAIRE_SID = 1
     AND ATTR.ATTR_TABLE != 'DUMMY'
     AND ATTR.ATTR_NAME != 'DUMMY'
     AND ATTR.ATTR_NAME NOT LIKE '%ABOL%REASON%'
     AND ATTR.QUESTION_SID NOT IN (SELECT QUESTION_SID FROM FGD_CFG_QUESTIONS WHERE QUESTION_TYPE_SID = 11)
     ORDER BY ATTR.QUESTIONNAIRE_SID, ATTR.ATTR_SID
     ;
     --TAKE ONLY CURRENT ENTRIES(ROUND_SID = 380)
     CURSOR c_mig_entries IS
     SELECT e.* FROM ENTRIES_MIG e,
                    ENTRY_EDIT_STEPS S
        WHERE e.OLD_TABLE = 'FGD_NFR_RULES' 
         AND E.NEW_SID = S.ENTRY_SID
         AND S.ROUND_SID = 380;
     
    
     c_mig_multi SYS_REFCURSOR;
     l_query_string varchar2(4000 byte);
     TYPE r_query_result IS RECORD
         (
         ATTR_VALUE NUMBER(9),
         DESCR VARCHAR2(4000 BYTE)
         );
     t_result r_query_result;
     
     TYPE r_query_multi_result IS RECORD (
        ATTR_VALUE  NUMBER(9),
        ADDITIONAL_ATTR_VALUE NUMBER(9),
        DESCR VARCHAR2(4000 BYTE)
        );
    t_multi_result r_query_multi_result;
    


l_question_value VARCHAR2(4000 BYTE);
l_new_question_value VARCHAR2(4000 BYTE);
l_question_name VARCHAR2(4000 BYTE);

l_add_info VARCHAR2(4000 BYTE);
l_statement VARCHAR2(4000 byte);

l_attr_name VARCHAR2(500 byte);
l_debug number(9);
l_old_rule number(9);
l_assessment_sid number(9);
l_budg_sid NUMBER(9);

BEGIN
    FOR r_entry IN c_mig_entries LOOP
        l_old_rule := r_entry.OLD_SID;
        FOR r_rec IN c_OLD_entries_CFG LOOP
        l_debug := 0;

        l_attr_name := r_rec.ATTR_NAME;
            IF r_rec.ATTR_TABLE = 'FGD_NFR_RULES' THEN
                l_statement := 'SELECT ' || r_rec.ATTR_NAME || ' FROM ' || r_rec.ATTR_TABLE || ' WHERE RULE_SID = ' || r_entry.OLD_SID;
                l_debug := 1;
                BEGIN
                    EXECUTE IMMEDIATE l_statement INTO  l_question_value;
                EXCEPTION
                    WHEN OTHERS THEN   
                        l_question_value := NULL;
                END;
                l_debug := 211;
                IF l_attr_name like '%_SID' AND l_question_value IS NOT NULL THEN
                    
                    l_new_question_value := get_lov_sid(l_question_value);
                ELSE
                     l_new_question_value := NULL;   
				END IF;


                l_debug := 3;
                    BEGIN
                        IF l_attr_name like '%_SID' THEN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_new_question_value, null,  0);
                        ELSE
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_question_value, null,  0);
                        END IF;
                    EXCEPTION
                    WHEN OTHERS THEN
                        LOG_FAIL('ENTRY_CHOICES INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                END;

                l_debug := 4;
            ELSIF r_rec.ATTR_TABLE NOT IN ( 'FGD_NFR_RULE_ASSESSMENTS', 'FGD_NFR_RULES', 'FGD_NFR_RULE_RULES', 'FGD_NFR_RULE_SECTORS', 'FGD_NFR_TARGET_RULES') AND
                  r_rec.ATTR_TABLE NOT LIKE '%ASSESS%' THEN
                    l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE RULE_SID = ' || r_entry.OLD_SID ;
                    l_debug := 5;
                    OPEN c_mig_multi FOR l_query_string;
                    l_debug := 6;
                    LOOP
                        FETCH c_mig_multi INTO t_result;
                        EXIT WHEN c_mig_multi%NOTFOUND;
                        l_debug := 7;
                        BEGIN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(t_result.ATTR_VALUE),  t_result.DESCR, 0);
                            
                        EXCEPTION
                            WHEN OTHERS THEN 
                                LOG_FAIL('ENTRY_CHOICES MULTI INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                        END;
                        
                    END LOOP;
                    CLOSE c_mig_multi;
            END IF;
        END LOOP;

    END LOOP;
EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('MIG ENTRY_CHOICES FAIL', sysdate, sqlerrm() || l_attr_name || ' ' || l_old_rule , l_debug);
END;     
/
--IFI
DECLARE
    CURSOR c_OLD_entries_CFG IS
    SELECT DISTINCT ATTR.*, 
           QVM.NEW_QUESTION_VERSION_SID, 
           get_question_type(QVM.NEW_QUESTION_VERSION_SID) as question_type 
        FROM FGD_CFG_ATTRIBUTES ATTR,
            QUESTION_VERSIONS_MIG QVM
     WHERE ATTR.ATTR_SID = QVM.OLD_ATTR_SID
     AND ATTR.QUESTIONNAIRE_SID = 2
     AND ATTR.ATTR_TABLE != 'DUMMY'
     AND ATTR.ATTR_NAME != 'DUMMY'
     AND ATTR.QUESTION_SID NOT IN (SELECT QUESTION_SID FROM FGD_CFG_QUESTIONS WHERE QUESTION_TYPE_SID = 11)
     AND ATTR.ATTR_NAME NOT IN ( 'MTP_SECTOR_MACRO_SID', 'OCCUP_LIMIT_SID')
     ORDER BY ATTR.QUESTIONNAIRE_SID, ATTR.ATTR_SID
     ;
     --TAKE ONLY CURRENT ENTRIES(ROUND_SID = 380)
     CURSOR c_mig_entries IS
     SELECT e.* FROM ENTRIES_MIG e,
                    ENTRY_EDIT_STEPS S
        WHERE e.OLD_TABLE = 'FGD_IFI_INSTITUTIONS' 
         AND E.NEW_SID = S.ENTRY_SID
         AND S.ROUND_SID = 380;
     
    
     c_mig_multi SYS_REFCURSOR;
     l_query_string varchar2(4000 byte);
     TYPE r_query_result IS RECORD
         (
         ATTR_VALUE NUMBER(9),
         DESCR VARCHAR2(4000 BYTE)
         );
     t_result r_query_result;
     
     TYPE r_query_multi_result IS RECORD (
        ATTR_VALUE  NUMBER(9),
        ADDITIONAL_ATTR_VALUE NUMBER(9),
        DESCR VARCHAR2(4000 BYTE)
        );
    t_multi_result r_query_multi_result;
    


l_question_value VARCHAR2(4000 BYTE);
l_new_question_value VARCHAR2(4000 BYTE);
l_question_name VARCHAR2(4000 BYTE);

l_add_info VARCHAR2(4000 BYTE);
l_statement varchar2(4000 byte);

l_attr_name varchar2(500 byte);
l_debug number(9);
l_old_rule number(9);
l_assessment_sid number(9);


BEGIN
    FOR r_entry IN c_mig_entries LOOP
        l_old_rule := r_entry.OLD_SID;
        FOR r_rec IN c_OLD_entries_CFG LOOP
        l_debug := 0;
--        dbms_output.put_line(r_rec.ATTR_NAME || l_debug);
        l_attr_name := r_rec.ATTR_NAME;
            IF r_rec.ATTR_TABLE = 'FGD_IFI_INSTITUTIONS' THEN
                l_statement := 'SELECT ' || r_rec.ATTR_NAME || ' FROM ' || r_rec.ATTR_TABLE || ' WHERE INSTITUTION_SID = ' || r_entry.OLD_SID;
                l_debug := 1;
                BEGIN
                    EXECUTE IMMEDIATE l_statement INTO  l_question_value;
                EXCEPTION
                    WHEN OTHERS THEN   
                        LOG_FAIL('MIG ENTRY_CHOICES FAIL', sysdate, sqlerrm(), l_attr_name);
                        l_question_value := NULL;
                END;
                l_debug := 3;
                BEGIN
                    IF l_attr_name like '%_SID' OR l_attr_name = 'BASIS_EXAA' OR l_attr_name = 'BASIS_EXPA' or l_attr_name = 'LEGAL_STATUS' OR l_attr_name = 'TRIG_ESCC_MON' THEN 
                        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                        VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(l_question_value), null,  0);
                    ELSE
                        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                        VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_question_value, null,  0);
                    END IF;
                EXCEPTION
                WHEN OTHERS THEN
                    LOG_FAIL('ENTRY_CHOICES INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                END;

                l_debug := 4;
            ELSIF r_rec.ATTR_TABLE NOT IN ( 'FGD_IFI_INST_ASSESSMENTS', 'FGD_IFI_INSTITUTIONS') AND
                  r_rec.ATTR_TABLE NOT LIKE '%ASS%' THEN
                    l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE INSTITUTION_SID = ' || r_entry.OLD_SID ;
                    l_debug := 5;
                    OPEN c_mig_multi FOR l_query_string;
                    l_debug := 6;
                    LOOP
                        FETCH c_mig_multi INTO t_result;
                        EXIT WHEN c_mig_multi%NOTFOUND;
                        l_debug := 7;
                        BEGIN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(t_result.ATTR_VALUE),  t_result.DESCR, 0);
                            
                        EXCEPTION
                            WHEN OTHERS THEN 
                                LOG_FAIL('ENTRY_CHOICES MULTI INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                        END;
                        
                    END LOOP;
                    CLOSE c_mig_multi;

            END IF;
        END LOOP;

    END LOOP;
EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('ENTRY_CHOICES', sysdate, sqlerrm() || l_attr_name || ' ' || l_old_rule , l_debug);
END;      
/
--MTBF
DECLARE
    CURSOR c_OLD_entries_CFG IS
    SELECT DISTINCT ATTR.*, 
           QVM.NEW_QUESTION_VERSION_SID, 
           get_question_type(QVM.NEW_QUESTION_VERSION_SID) as question_type 
        FROM FGD_CFG_ATTRIBUTES ATTR,
            QUESTION_VERSIONS_MIG QVM
     WHERE ATTR.ATTR_SID = QVM.OLD_ATTR_SID
     AND ATTR.QUESTIONNAIRE_SID = 3
     AND ATTR.ATTR_TABLE != 'DUMMY'
     AND ATTR.ATTR_NAME != 'DUMMY'
     AND ATTR.ATTR_NAME NOT LIKE '%ABOL%REASON%'
     AND ATTR.QUESTION_SID NOT IN (SELECT QUESTION_SID FROM FGD_CFG_QUESTIONS WHERE QUESTION_TYPE_SID = 11)
     ORDER BY ATTR.QUESTIONNAIRE_SID, ATTR.ATTR_SID
     ;
     --TAKE ONLY CURRENT ENTRIES(ROUND_SID = 380)
     CURSOR c_mig_entries IS
     SELECT e.* FROM ENTRIES_MIG e,
                    ENTRY_EDIT_STEPS S
        WHERE e.OLD_TABLE = 'FGD_MTBF_FRAMES' 
         AND E.NEW_SID = S.ENTRY_SID
         AND S.ROUND_SID = 380;
     
    
     c_mig_multi SYS_REFCURSOR;
     l_query_string varchar2(4000 byte);
     TYPE r_query_result IS RECORD
         (
         ATTR_VALUE NUMBER(9),
         DESCR VARCHAR2(4000 BYTE)
         );
     t_result r_query_result;
     
     TYPE r_query_multi_result IS RECORD (
        ATTR_VALUE  NUMBER(9),
        ADDITIONAL_ATTR_VALUE NUMBER(9),
        DESCR VARCHAR2(4000 BYTE)
        );
    t_multi_result r_query_multi_result;
    


l_question_value VARCHAR2(4000 BYTE);
l_new_question_value NUMBER;
l_question_name VARCHAR2(4000 BYTE);

l_add_info VARCHAR2(4000 BYTE);
l_statement varchar2(4000 byte);

l_attr_name varchar2(500 byte);
l_debug number(9);
l_old_rule number(9);
l_assessment_sid number(9);


BEGIN
    FOR r_entry IN c_mig_entries LOOP
        l_old_rule := r_entry.OLD_SID;
        FOR r_rec IN c_OLD_entries_CFG LOOP
        l_debug := 0;
--        dbms_output.put_line(r_rec.ATTR_NAME || l_debug);
        l_attr_name := r_rec.ATTR_NAME;
            IF r_rec.ATTR_TABLE = 'FGD_MTBF_FRAMES' THEN
                l_statement := 'SELECT ' || r_rec.ATTR_NAME || ' FROM ' || r_rec.ATTR_TABLE || ' WHERE FRAME_SID = ' || r_entry.OLD_SID;
                l_debug := 1;
                BEGIN
                    EXECUTE IMMEDIATE l_statement INTO  l_question_value;
                EXCEPTION
                    WHEN OTHERS THEN   
                        LOG_FAIL('MIG ENTRY_CHOICES FAIL', sysdate, sqlerrm(), l_attr_name);
                        l_question_value := NULL;
                END;
                l_debug := 2;
                
                BEGIN
                    IF l_attr_name like '%_SID' AND l_question_value IS NOT NULL THEN
                        l_new_question_value := get_lov_sid(l_question_value);
                        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                        VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_new_question_value, NULL,  0);
                    ELSIF l_attr_name like '%_SID' AND l_question_value IS NULL THEN
                        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                        VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, NULL, NULL,  0);
                    ELSE
                        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                        VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_question_value, null,  0);
                    END IF;
                EXCEPTION
                WHEN OTHERS THEN
                    LOG_FAIL('ENTRY_CHOICES INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                END;
                l_debug := 4;
            ELSIF r_rec.ATTR_TABLE NOT IN ( 'FGD_MTBF_FRAME_ASSESSMENTS', 'FGD_MTBF_FRAMES', 'FGD_MTBF_TARGET_FRAMES') AND
                  r_rec.ATTR_TABLE NOT LIKE '%ASS%' THEN
                    l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE FRAME_SID = ' || r_entry.OLD_SID ;
                    l_debug := 5;
                    OPEN c_mig_multi FOR l_query_string;
                    l_debug := 6;
                    LOOP
                        FETCH c_mig_multi INTO t_result;
                        EXIT WHEN c_mig_multi%NOTFOUND;
                        l_debug := 7;
                        BEGIN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(t_result.ATTR_VALUE),  t_result.DESCR, 0);
                            
                        EXCEPTION
                            WHEN OTHERS THEN 
                                LOG_FAIL('ENTRY_CHOICES MULTI INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                        END;
                        
                    END LOOP;
                    CLOSE c_mig_multi;

            END IF;
        END LOOP;

    END LOOP;
EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('MIG ENTRY_CHOICES FAIL', sysdate, sqlerrm() || l_attr_name || ' ' || l_old_rule , l_debug);
END; 
/

--GBD
DECLARE
    CURSOR c_OLD_entries_CFG IS
    SELECT DISTINCT ATTR.*, 
           QVM.NEW_QUESTION_VERSION_SID, 
           get_question_type(QVM.NEW_QUESTION_VERSION_SID) as question_type 
        FROM FGD_CFG_ATTRIBUTES ATTR,
            QUESTION_VERSIONS_MIG QVM
     WHERE ATTR.ATTR_SID = QVM.OLD_ATTR_SID
     AND ATTR.QUESTIONNAIRE_SID = 4
     AND ATTR.ATTR_TABLE != 'DUMMY'
     AND ATTR.ATTR_NAME != 'DUMMY'
     AND ATTR.QUESTION_SID NOT IN (SELECT QUESTION_SID FROM FGD_CFG_QUESTIONS WHERE QUESTION_TYPE_SID = 11)
     ORDER BY ATTR.QUESTIONNAIRE_SID, ATTR.ATTR_SID
     ;
     --TAKE ONLY CURRENT ENTRIES(ROUND_SID = 380)
     CURSOR c_mig_entries IS
     SELECT e.* FROM ENTRIES_MIG e,
                    ENTRY_EDIT_STEPS S
        WHERE e.OLD_TABLE = 'FGD_GBD_ENTRIES' 
         AND E.NEW_SID = S.ENTRY_SID
         AND S.ROUND_SID = 380;
     
    
     c_mig_multi SYS_REFCURSOR;
     l_query_string varchar2(4000 byte);
     TYPE r_query_result IS RECORD
         (
         ATTR_VALUE NUMBER(9),
         DESCR VARCHAR2(4000 BYTE)
         );
     t_result r_query_result;
     
     TYPE r_query_multi_result IS RECORD (
        ATTR_VALUE  NUMBER(9),
        ADDITIONAL_ATTR_VALUE NUMBER(9),
        DESCR VARCHAR2(4000 BYTE)
        );
    t_multi_result r_query_multi_result;
    


l_question_value VARCHAR2(4000 BYTE);
l_question_name VARCHAR2(4000 BYTE);

l_add_info VARCHAR2(4000 BYTE);
l_statement varchar2(4000 byte);

l_attr_name varchar2(500 byte);
l_debug number(9);
l_old_rule number(9);
l_assessment_sid number(9);


BEGIN
    FOR r_entry IN c_mig_entries LOOP
        l_old_rule := r_entry.OLD_SID;
        FOR r_rec IN c_OLD_entries_CFG LOOP
        l_debug := 0;
--        dbms_output.put_line(r_rec.ATTR_NAME || l_debug);
        l_attr_name := r_rec.ATTR_NAME;
            IF r_rec.ATTR_TABLE = 'FGD_GBD_ENTRIES' THEN
                l_statement := 'SELECT ' || r_rec.ATTR_NAME || ' FROM ' || r_rec.ATTR_TABLE || ' WHERE ENTRY_SID = ' || r_entry.OLD_SID;
                l_debug := 1;
                
                BEGIN
                    EXECUTE IMMEDIATE l_statement INTO  l_question_value;
                EXCEPTION
                    WHEN OTHERS THEN   
                        LOG_FAIL('MIG ENTRY_CHOICES FAIL', sysdate, sqlerrm(), l_attr_name);
                        l_question_value := NULL;
                END;
                l_debug := 2;
                
                BEGIN
                    IF l_attr_name like '%_SID' AND l_question_value IS NOT NULL THEN
                        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                        VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(l_question_value), NULL,  0);
                    ELSIF l_attr_name like '%_SID' AND l_question_value IS NULL THEN
                        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                        VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, NULL, NULL,  0);
                    ELSE
                        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                        VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_question_value, NULL,  0);
                    END IF;
                EXCEPTION
                WHEN OTHERS THEN
                    LOG_FAIL('ENTRY_CHOICES INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                END;

                l_debug := 4;
            ELSIF r_rec.ATTR_TABLE NOT IN ( 'FGD_GBD_ENTRIES') AND
                  r_rec.ATTR_TABLE NOT LIKE '%ASS%' THEN
                    l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE ENTRY_SID = ' || r_entry.OLD_SID ;
                    l_debug := 5;
                    OPEN c_mig_multi FOR l_query_string;
                    l_debug := 6;
                    LOOP
                        FETCH c_mig_multi INTO t_result;
                        EXIT WHEN c_mig_multi%NOTFOUND;
                        l_debug := 7;
                        BEGIN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(t_result.ATTR_VALUE), t_result.DESCR,  0);
                            
                        EXCEPTION
                            WHEN OTHERS THEN 
                                LOG_FAIL('ENTRY_CHOICES MULTI INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                        END;
                        
                    END LOOP;
                    CLOSE c_mig_multi;

            END IF;
        END LOOP;

    END LOOP;
EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('MIG ENTRY_CHOICES FAIL', sysdate, sqlerrm() || l_attr_name || ' ' || l_old_rule , l_debug);
END; 
/

--assessments mig
DECLARE
    CURSOR c_OLD_entries_CFG IS
    SELECT DISTINCT ATTR.*, 
           QVM.NEW_QUESTION_VERSION_SID, 
           get_question_type(QVM.NEW_QUESTION_VERSION_SID) as question_type 
        FROM FGD_CFG_ATTRIBUTES ATTR,
            QUESTION_VERSIONS_MIG QVM
     WHERE ATTR.ATTR_SID = QVM.OLD_ATTR_SID
--     AND ATTR.QUESTIONNAIRE_SID = 4
     AND ATTR.ATTR_TABLE LIKE '%ASS%'
     AND ATTR.ATTR_NAME != 'DUMMY'
     AND ATTR.QUESTION_SID NOT IN (SELECT QUESTION_SID FROM FGD_CFG_QUESTIONS WHERE QUESTION_TYPE_SID = 11)
     ORDER BY ATTR.QUESTIONNAIRE_SID, ATTR.ATTR_SID
     ;
     --TAKE ONLY CURRENT ENTRIES(ROUND_SID = 380)
     CURSOR c_mig_entries IS
     SELECT e.*, 'NFR' AS tab FROM ENTRIES_MIG e,
                    ENTRY_EDIT_STEPS S,
                    FGD_NFR_RULE_ASSESSMENTS R
        WHERE E.NEW_SID = S.ENTRY_SID
         AND R.RULE_SID = E.OLD_SID
         AND S.ROUND_SID = R.ROUND_SID
         AND S.ROUND_SID = 380
        UNION
     SELECT e.*, 'IFI' AS tab FROM ENTRIES_MIG e,
                    ENTRY_EDIT_STEPS S,
                    FGD_IFI_INST_ASSESSMENTS R
        WHERE E.NEW_SID = S.ENTRY_SID
         AND R.INSTITUTION_SID = E.OLD_SID
         AND S.ROUND_SID = R.ROUND_SID
         AND S.ROUND_SID = 380
        UNION
     SELECT e.*, 'MTBF' AS tab FROM ENTRIES_MIG e,
                    ENTRY_EDIT_STEPS S,
                    FGD_MTBF_FRAME_ASSESSMENTS R
        WHERE E.NEW_SID = S.ENTRY_SID
         AND R.FRAME_SID = E.OLD_SID
         AND S.ROUND_SID = R.ROUND_SID
         AND S.ROUND_SID = 380;
     
     
    
     c_mig_multi SYS_REFCURSOR;
     l_query_string varchar2(4000 byte);

     TYPE r_query_result IS RECORD
         (
         ATTR_VALUE NUMBER(9),
         DESCR VARCHAR2(4000 BYTE)
         );
     t_result r_query_result;

    


l_question_value VARCHAR2(4000 BYTE);
l_new_question_value VARCHAR2(4000 BYTE);
l_question_name VARCHAR2(4000 BYTE);

l_statement varchar2(4000 byte);

l_attr_name varchar2(500 byte);
l_debug number(9);
l_old_rule number(9);
l_assessment_sid number(9);

l_assessment_exists number;

l_section NUMBER;
l_section_assessment_period VARCHAR2(4000 BYTE);

BEGIN
    FOR r_entry IN c_mig_entries LOOP
        l_old_rule := r_entry.OLD_SID;
        FOR r_rec IN c_OLD_entries_CFG LOOP
        l_debug := 0;
--        dbms_output.put_line(r_rec.ATTR_NAME || l_debug);
        l_attr_name := r_rec.ATTR_NAME;
            IF r_rec.ATTR_TABLE = 'FGD_NFR_RULE_ASSESSMENTS' AND r_entry.TAB = 'NFR' THEN
                l_debug := 1;
                --verify  is there is an assessment record
                BEGIN
                    SELECT  RULE_ASSESSMENT_SID
                      INTO l_assessment_exists
                      FROM FGD_NFR_RULE_ASSESSMENTS
                     WHERE RULE_SID = r_entry.OLD_SID
                       AND PERIOD_SID = 1
                       AND ROUND_SID = 380;
                EXCEPTION
                        WHEN OTHERS THEN
                            l_assessment_exists := NULL;
                END;
                IF l_assessment_exists IS NOT NULL AND r_rec.ATTR_NAME != 'COMPLIANCE_SOURCE_SID' THEN
                --TAKE period_sid = 1 
                    l_statement := 'SELECT '|| r_rec.ATTR_NAME ||' FROM ' || r_rec.ATTR_TABLE || ' WHERE RULE_SID = ' || r_entry.OLD_SID ||
                        ' AND PERIOD_SID = 1 AND ROUND_SID = 380';
                    BEGIN
                        EXECUTE IMMEDIATE l_statement INTO l_question_value;
                    EXCEPTION
                        WHEN OTHERS THEN
                            LOG_FAIL('MIG ENTRY_CHOICES FAIL ASSEESSMENT', sysdate, sqlerrm(), l_attr_name);
                    END;
                     
                    l_debug := 2;
                        BEGIN
                        --verify to which assessment_period the question_version corresponds and insert only for that period(period_sid = 1)
                        l_debug := 2002;
                        select count(s.ASSESSMENT_PERIOD)
                          INTO l_section_assessment_period
                          FROM fgd_cfg_qstnnr_sections S,
                               FGD_CFG_QSTNNR_SEC_ATTRIBUTES A
                         WHERE S.QSTNNR_SECTION_SID = A.QSTNNR_SECTION_SID
                           AND S.ASSESSMENT_PERIOD = 1
                           AND A.ATTR_SID = r_rec.ATTR_SID;    
                        
                        
                        IF l_section_assessment_period = 1 THEN
                            IF l_attr_name NOT like '%_SID' THEN
                                l_debug := 2224;
                                INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                                VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_question_value, NULL,  1);
                            ELSIF l_attr_name like '%_SID' AND l_question_value IS NOT NULL THEN
                            l_debug := 2222;
                                INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                                VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(l_question_value), NULL, 1);
                            ELSIF l_attr_name like '%_SID' AND l_question_value IS NULL THEN
                            l_debug := 2223;
                                INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                                VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, NULL, NULL, 1);
                            END IF;
                        END IF;
                        EXCEPTION
                        WHEN OTHERS THEN
                            LOG_FAIL('ENTRY_CHOICES INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                        END;
                END IF;    
                --verify  is there is an assessment record
                BEGIN
                    SELECT  RULE_ASSESSMENT_SID
                      INTO l_assessment_exists
                      FROM FGD_NFR_RULE_ASSESSMENTS
                     WHERE RULE_SID = r_entry.OLD_SID
                       AND PERIOD_SID = 2
                       AND ROUND_SID = 380;
                EXCEPTION
                        WHEN OTHERS THEN
                            l_assessment_exists := NULL;
                END;
                l_debug := 31;
                --TAKE period_sid = 2 
                IF l_assessment_exists IS NOT NULL AND r_rec.ATTR_NAME != 'COMPLIANCE_SOURCE_SID' THEN
                    l_statement := 'SELECT '|| r_rec.ATTR_NAME ||' FROM ' || r_rec.ATTR_TABLE || ' WHERE RULE_SID = ' || r_entry.OLD_SID ||
                        ' AND PERIOD_SID = 2 AND ROUND_SID = 380';
                    l_debug := 313;
                    BEGIN
                        EXECUTE IMMEDIATE l_statement INTO l_question_value;
                    EXCEPTION
                        WHEN OTHERS THEN
                            LOG_FAIL('MIG ENTRY_CHOICES FAIL ASSEESSMENT', sysdate, sqlerrm(), l_attr_name);
                    END;
                    l_debug := 32;
                    BEGIN
                    --verify to which assessment_period the question_version corresponds and insert only for that period(period_sid = 2)
                    select count(s.ASSESSMENT_PERIOD)
                          INTO l_section_assessment_period
                          FROM fgd_cfg_qstnnr_sections S,
                               FGD_CFG_QSTNNR_SEC_ATTRIBUTES A
                         WHERE S.QSTNNR_SECTION_SID = A.QSTNNR_SECTION_SID
                           AND S.ASSESSMENT_PERIOD = 2
                           AND A.ATTR_SID = r_rec.ATTR_SID; 
                    IF l_section_assessment_period = 1 THEN
                        IF l_attr_name NOT like '%_SID' THEN
                            l_debug := 3224;
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_question_value, null,  2);
                        ELSIF l_attr_name like '%_SID' AND l_question_value IS NOT NULL THEN
                        l_debug := 3222;
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(l_question_value), null,  2);
                        ELSIF l_attr_name like '%_SID' AND l_question_value IS NULL THEN
                        l_debug := 3223;
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, NULL, NULL,  2);
                        END IF;
                    END IF;
                    EXCEPTION
                    WHEN OTHERS THEN
                        LOG_FAIL('ENTRY_CHOICES INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                    END;
                END IF;
            ELSIF r_rec.ATTR_TABLE != 'FGD_NFR_RULE_ASSESSMENTS' AND r_entry.TAB = 'NFR' AND
                  r_rec.ATTR_TABLE LIKE '%NFR%' THEN
                    --verify  is there is an assessment record
                    BEGIN
                        SELECT  RULE_ASSESSMENT_SID
                          INTO l_assessment_exists
                          FROM FGD_NFR_RULE_ASSESSMENTS
                         WHERE RULE_SID = r_entry.OLD_SID
                           AND PERIOD_SID = 1
                           AND ROUND_SID = 380;
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_assessment_exists := NULL;
                    END;
                    --PERIOD_SID = 1
                    IF l_assessment_exists IS NOT NULL THEN
                        l_statement := 'SELECT RULE_ASSESSMENT_SID FROM FGD_NFR_RULE_ASSESSMENTS WHERE PERIOD_SID = 1 AND ROUND_SID = 380 AND RULE_SID = ' || r_entry.OLD_SID ;
                        EXECUTE IMMEDIATE l_statement INTO l_assessment_sid;
                        l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE RULE_ASSESSMENT_SID = ' || l_assessment_sid ;
                        l_debug := 4;
                        OPEN c_mig_multi FOR l_query_string;
                        l_debug := 5;
                        LOOP
                            FETCH c_mig_multi INTO t_result;
                            EXIT WHEN c_mig_multi%NOTFOUND;
                            l_debug := 6;
                            BEGIN
                                INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                                VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(t_result.ATTR_VALUE),  t_result.DESCR, 1);
                                
                            EXCEPTION
                                WHEN OTHERS THEN 
                                    LOG_FAIL('ENTRY_CHOICES MULTI INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                            END;
                            
                        END LOOP;
                        CLOSE c_mig_multi;
                    END IF;
                    --verify  is there is an assessment record
                    BEGIN
                        SELECT  RULE_ASSESSMENT_SID
                          INTO l_assessment_exists
                          FROM FGD_NFR_RULE_ASSESSMENTS
                         WHERE RULE_SID = r_entry.OLD_SID
                           AND PERIOD_SID = 2
                           AND ROUND_SID = 380;
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_assessment_exists := NULL;
                    END;
                    --PERIOD_SID = 2
                    IF l_assessment_exists IS NOT NULL THEN
                        l_statement := 'SELECT RULE_ASSESSMENT_SID FROM FGD_NFR_RULE_ASSESSMENTS WHERE PERIOD_SID = 2 AND ROUND_SID = 380 AND RULE_SID = ' || r_entry.OLD_SID ;
                        EXECUTE IMMEDIATE l_statement INTO l_assessment_sid;
                        l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE RULE_ASSESSMENT_SID = ' || l_assessment_sid ;
                        l_debug := 24;
                        OPEN c_mig_multi FOR l_query_string;
                        l_debug := 25;
                        LOOP
                            FETCH c_mig_multi INTO t_result;
                            EXIT WHEN c_mig_multi%NOTFOUND;
                            l_debug := 26;
                            BEGIN
                                INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                                VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(t_result.ATTR_VALUE), t_result.DESCR, 2);
                                
                            EXCEPTION
                                WHEN OTHERS THEN 
                                    LOG_FAIL('ENTRY_CHOICES MULTI INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                            END;
                            
                        END LOOP;
                        CLOSE c_mig_multi;
                    END IF;
            ELSIF r_rec.ATTR_TABLE = 'FGD_IFI_INST_ASSESSMENTS' AND r_entry.TAB = 'IFI' THEN
                l_debug := 1;
                --ONLY period_sid = 1 
                l_statement := 'SELECT '|| r_rec.ATTR_NAME ||' FROM ' || r_rec.ATTR_TABLE || ' WHERE INSTITUTION_SID = ' || r_entry.OLD_SID ||
                    ' AND PERIOD_SID = 1 AND ROUND_SID = 380';
                BEGIN
                    EXECUTE IMMEDIATE l_statement INTO l_question_value;
                EXCEPTION
                    WHEN OTHERS THEN
                        LOG_FAIL('MIG ENTRY_CHOICES FAIL ASSEESSMENT', sysdate, sqlerrm(), l_attr_name);
                        l_question_value := NULL;
                END;
            
                l_debug := 2;
                    BEGIN
                        IF l_attr_name like '%_SID' AND l_question_value IS NOT NULL THEN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(l_question_value), null,  1);
                        ELSIF l_attr_name like '%_SID' AND l_question_value IS NULL THEN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, NULL, null,  1);
                        ELSE
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_question_value, null,  1);
                        END IF;
                    EXCEPTION
                    WHEN OTHERS THEN
                        LOG_FAIL('ENTRY_CHOICES INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                    END;
            
                l_debug := 3;
            ELSIF r_rec.ATTR_TABLE != 'FGD_IFI_INST_ASSESSMENTS' AND r_entry.TAB = 'IFI' AND
                  r_rec.ATTR_TABLE LIKE '%IFI%_ASS%' THEN
                    --PERIOD_SID = 1
                    IF r_rec.ATTR_TABLE = 'FGD_IFI_INST_TIME_COMP_ASSESS' THEN
                        l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE INSTITUTION_SID = ' || r_entry.OLD_SID ;
                    ELSE 
                        l_statement := 'SELECT INSTITUTION_ASSESSMENT_SID FROM FGD_IFI_INST_ASSESSMENTS WHERE PERIOD_SID = 1 AND ROUND_SID = 380 AND INSTITUTION_SID = ' || r_entry.OLD_SID ;
                        EXECUTE IMMEDIATE l_statement INTO l_assessment_sid;
                        l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE INSTITUTION_ASSESSMENT_SID = ' || l_assessment_sid ;
                    END IF;
                    l_debug := 4;
                    OPEN c_mig_multi FOR l_query_string;
                    l_debug := 5;
                    LOOP
                        FETCH c_mig_multi INTO t_result;
                        EXIT WHEN c_mig_multi%NOTFOUND;
                        l_debug := 6;
                        BEGIN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(t_result.ATTR_VALUE),  t_result.DESCR, 1);
                            
                        EXCEPTION
                            WHEN OTHERS THEN 
                                LOG_FAIL('ENTRY_CHOICES MULTI INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                        END;
                        
                    END LOOP;
                    CLOSE c_mig_multi;
            ELSIF r_rec.ATTR_TABLE = 'FGD_MTBF_FRAME_ASSESSMENTS' AND r_entry.TAB = 'MTBF' THEN
                l_debug := 1;
                --ONLY period_sid = 1 
                l_statement := 'SELECT '|| r_rec.ATTR_NAME ||' FROM ' || r_rec.ATTR_TABLE || ' WHERE FRAME_SID = ' || r_entry.OLD_SID ||
                    ' AND PERIOD_SID = 1 AND ROUND_SID = 380';
                BEGIN
                    EXECUTE IMMEDIATE l_statement INTO l_question_value;
                EXCEPTION
                    WHEN OTHERS THEN
                        LOG_FAIL('MIG ENTRY_CHOICES FAIL ASSEESSMENT', sysdate, sqlerrm(), l_attr_name);
                        l_question_value := NULL;
                END;
            
                l_debug := 2;
                    BEGIN
                        IF l_attr_name like '%_SID' AND l_question_value IS NOT NULL THEN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(l_question_value), null,  1);
                        ELSIF l_attr_name like '%_SID' AND l_question_value IS NULL THEN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, NULL, null,  1);
                        ELSE
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, l_question_value, null,  1);
                        END IF;
                    EXCEPTION
                    WHEN OTHERS THEN
                        LOG_FAIL('ENTRY_CHOICES INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                    END;
            
                l_debug := 3;
            ELSIF r_rec.ATTR_TABLE != 'FGD_MTBF_FRAME_ASSESSMENTS' AND r_entry.TAB = 'MTBF' AND
                  r_rec.ATTR_TABLE LIKE '%MTBF%' THEN
                    --PERIOD_SID = 1
                    l_statement := 'SELECT FRAME_ASSESSMENT_SID FROM FGD_MTBF_FRAME_ASSESSMENTS WHERE PERIOD_SID = 1 AND ROUND_SID = 380 AND FRAME_SID = ' || r_entry.OLD_SID ;
                    EXECUTE IMMEDIATE l_statement INTO l_assessment_sid;
                    l_query_string := 'SELECT ' || r_rec.ATTR_NAME || ', DESCR FROM ' || r_rec.ATTR_TABLE || ' WHERE FRAME_ASSESSMENT_SID = ' || l_assessment_sid ;
                    l_debug := 4;
                    OPEN c_mig_multi FOR l_query_string;
                    l_debug := 5;
                    LOOP
                        FETCH c_mig_multi INTO t_result;
                        EXIT WHEN c_mig_multi%NOTFOUND;
                        l_debug := 6;
                        BEGIN
                            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
                            VALUES (r_entry.NEW_SID, r_rec.NEW_QUESTION_VERSION_SID, get_lov_sid(t_result.ATTR_VALUE),  t_result.DESCR, 1);
                            
                        EXCEPTION
                            WHEN OTHERS THEN 
                                LOG_FAIL('ENTRY_CHOICES MULTI INSERT FAIL', sysdate, sqlerrm(), l_attr_name);
                        END;
                        
                    END LOOP;
                    CLOSE c_mig_multi;
                            
            END IF;
        END LOOP;

    END LOOP;
EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('ENTRY_CHOICES', sysdate, sqlerrm() || l_attr_name || ' ' || l_old_rule , l_debug);
END; 
/
DECLARE
    CURSOR c_compliance IS
  SELECT e.NEW_SID, R.COMPLIANCE_SOURCE_SID, R.ASSESS_VAL, R.PERIOD_SID FROM ENTRIES_MIG e,
                    ENTRY_EDIT_STEPS S,
                    FGD_NFR_RULE_ASSESSMENTS R
        WHERE E.NEW_SID = S.ENTRY_SID
         AND R.RULE_SID = E.OLD_SID
         AND S.ROUND_SID = R.ROUND_SID
         AND S.ROUND_SID = 380;
CURSOR c_old IS 
    SELECT ATTR.*, 
           QVM.NEW_QUESTION_VERSION_SID, 
           get_question_type(QVM.NEW_QUESTION_VERSION_SID) as question_type 
        FROM FGD_CFG_ATTRIBUTES ATTR,
            QUESTION_VERSIONS_MIG QVM
     WHERE ATTR.ATTR_SID = QVM.OLD_ATTR_SID
     AND ATTR.QUESTION_SID  IN (SELECT QUESTION_SID FROM FGD_CFG_QUESTIONS WHERE QUESTION_TYPE_SID = 17);

BEGIN
    FOR r_ass_entry IN c_compliance LOOP
        FOR r_question IN c_old LOOP
            INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS,  ASSESSMENT_PERIOD)
            VALUES  (r_ass_entry.NEW_SID, r_question.NEW_QUESTION_VERSION_SID, r_ass_entry.COMPLIANCE_SOURCE_SID,  r_ass_entry.ASSESS_VAL,  r_ass_entry.PERIOD_SID);
        END LOOP;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('Error migration Compliance values', sysdate, sqlerrm() , 0);
END; 
/
DELETE entry_choices
WHERE QUESTION_VERSION_SID = 52 AND assessment_period = 2;
DELETE entry_choices
WHERE QUESTION_VERSION_SID = 65 AND assessment_period = 1;
COMMIT;
