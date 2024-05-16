create or replace PACKAGE BODY CFG_VINTAGES
AS
    /***        
        NAME: CFG_VINTAGES
        USAGE: Functions used in Creating and Accessing Vintages
    ***/
    

    FUNCTION getLovDescription(pi_lov_sid IN NUMBER)
    RETURN VARCHAR2
    IS
        l_out VARCHAR2(4000 BYTE);
    BEGIN
        SELECT DESCR INTO l_out FROM CFG_LOVS WHERE LOV_SID = pi_lov_sid;
        RETURN l_out;
    END;

    ----------------------------------------------------------------------------
    -- @name assignYears
    -- @return string with assigned year values
    ----------------------------------------------------------------------------
    FUNCTION assignYears(p_text IN VARCHAR2, pi_round_sid IN NUMBER, p_round_year IN NUMBER)
        RETURN VARCHAR2
    IS
        l_year_m1 NUMBER;
        l_year_p1 NUMBER;
        l_year_p2 NUMBER;
    BEGIN
        l_year_m1 := p_round_year - 1;
        l_year_p1 := p_round_year + 1;
        l_year_p2 := p_round_year + 2;

        RETURN REPLACE(REPLACE(REPLACE(REPLACE(p_text, '{YEAR}', p_round_year), '{YEARM1}', l_year_m1)
                   , '{YEARP1}', l_year_p1)
                   , '{YEARP2}', l_year_p2);
    END;

    PROCEDURE getQuestionVintageText(pi_question_version_sid IN NUMBER, pi_entry_sid IN NUMBER, pi_round_sid IN NUMBER, pi_year IN NUMBER, pi_is_archive IN NUMBER, o_res OUT VARCHAR2)
    IS
        l_out VARCHAR2(9000 BYTE);
        l_out_info VARCHAR2(4000 BYTE);
        l_app_id VARCHAR2(10 BYTE);
        l_period_sid NUMBER;

        l_question_type NUMBER;
        l_add_info      NUMBER;
        T_QUESTION_TYPES CORE_TYPES.T_QUESTION_TYPES;
    BEGIN
        SELECT DISTINCT APP_ID INTO l_app_id FROM ENTRIES WHERE ENTRY_SID = pi_entry_sid;
        SELECT QUESTION_TYPE_SID, ADD_INFO INTO l_question_type, l_add_info FROM CFG_QUESTION_VERSIONS WHERE QUESTION_VERSION_SID = pi_question_version_sid;
        
        cfg_accessors.getQuestionPeriod(pi_question_version_sid, l_period_sid);

        IF l_question_type IN ( T_QUESTION_TYPES.FREE_TEXT, T_QUESTION_TYPES.ASSESSMENT_TEXT, T_QUESTION_TYPES.SINGLE_LINE,
                T_QUESTION_TYPES.ASSESSMENT_NUMBER) THEN
            BEGIN
                IF pi_is_archive = 1 THEN
                    SELECT RESPONSE
                      INTO l_out
                      FROM ENTRY_CHOICES_ARCH
                     WHERE ENTRY_SID = pi_entry_sid
                      AND QUESTION_VERSION_SID = pi_question_version_sid
                      AND ROUND_SID = pi_round_sid
                      AND ASSESSMENT_PERIOD = CASE
                                                WHEN l_question_type IN( T_QUESTION_TYPES.ASSESSMENT_TEXT, T_QUESTION_TYPES.ASSESSMENT_NUMBER) THEN l_period_sid
                                                ELSE 0
                                             END
                        ;
                ELSE       
                --free text, just take the response
                    SELECT RESPONSE
                      INTO l_out
                      FROM ENTRY_CHOICES
                     WHERE ENTRY_SID = pi_entry_sid
                       AND QUESTION_VERSION_SID = pi_question_version_sid
                       AND ASSESSMENT_PERIOD = CASE
                                                WHEN l_question_type IN ( T_QUESTION_TYPES.ASSESSMENT_TEXT, T_QUESTION_TYPES.ASSESSMENT_NUMBER) THEN l_period_sid
                                                ELSE 0
                                             END;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    l_out := NULL;
            END;

            --if the question is marked with add_info, concatenate the additional info as well
            IF l_add_info = 1 AND l_out IS NOT NULL THEN
                BEGIN
                    SELECT NVL(DESCR,'No additional info') INTO l_out_info FROM ENTRY_CHOICES_ADD_INFOS WHERE ENTRY_SID = pi_entry_sid AND QUESTION_VERSION_SID = pi_question_version_sid;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_out_info := NULL;
                END;
                IF l_out_info IS NOT NULL THEN
                    l_out := l_out || ' - ' || l_out_info;
                END IF;
            END IF;
        ELSIF l_question_type IN (
                T_QUESTION_TYPES.SINGLE_CHOICE, 
                T_QUESTION_TYPES.ASSESSMENT_SINGLE_CHOICE,
                T_QUESTION_TYPES.SINGLE_DROPDOWN) THEN
            BEGIN
                --single choice/dropdown, assessment single choice, take the text of the response and the provide details, if any
                IF pi_is_archive = 1 THEN
                    SELECT DISTINCT
                        CASE
                            WHEN E.DETAILS IS NULL THEN V.DESCR 
                            ELSE V.DESCR || ' - ' || E.DETAILS
                        END INTO l_out
                    FROM ENTRY_CHOICES_ARCH E
                        ,RESPONSE_CHOICES_VW V
                    WHERE E.ENTRY_SID = pi_entry_sid
                    AND E.QUESTION_VERSION_SID = pi_question_version_sid
                    AND E.RESPONSE = V.RESPONSE_SID
                    AND E.ROUND_SID = pi_round_sid
                    AND ASSESSMENT_PERIOD = CASE
                                                WHEN l_question_type = T_QUESTION_TYPES.ASSESSMENT_SINGLE_CHOICE THEN l_period_sid
                                                ELSE 0
                                             END;
                ELSE
                    SELECT DISTINCT
                        CASE
                            WHEN E.DETAILS IS NULL THEN V.DESCR 
                            ELSE V.DESCR || ' - ' || E.DETAILS
                        END INTO l_out
                    FROM ENTRY_CHOICES E
                        ,RESPONSE_CHOICES_VW V
                    WHERE E.ENTRY_SID = pi_entry_sid
                    AND E.QUESTION_VERSION_SID = pi_question_version_sid
                    AND E.RESPONSE = V.RESPONSE_SID
                    AND ASSESSMENT_PERIOD = CASE
                                                WHEN l_question_type = T_QUESTION_TYPES.ASSESSMENT_SINGLE_CHOICE THEN l_period_sid
                                                ELSE 0
                                             END;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    l_out := NULL;
            END;
            --if the question is marked with add_info, concatenate the additional info as well
            IF l_add_info = 1 AND l_out IS NOT NULL THEN
                BEGIN
                    SELECT NVL(DESCR,'No additional info') INTO l_out_info FROM ENTRY_CHOICES_ADD_INFOS WHERE ENTRY_SID = pi_entry_sid AND QUESTION_VERSION_SID = pi_question_version_sid;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_out_info := NULL;
                END;
                IF l_out_info IS NOT NULL THEN
                    l_out := l_out || ' - ' || l_out_info;
                END IF;
            END IF;

        ELSIF l_question_type IN (T_QUESTION_TYPES.MULTIPLE_CHOICE, T_QUESTION_TYPES.MULTIPLE_DROPDOWN, T_QUESTION_TYPES.ASSESSMENT_MULTIPLE_CHOICE) THEN
                BEGIN
                    --multiple choice/dropdown, assessment multiple choice, list all choices and their details, if any
                    IF pi_is_archive = 1 THEN
                        SELECT LISTAGG(choice, ', ') WITHIN GROUP (ORDER BY choice) INTO l_out FROM ( SELECT 
                            CASE
                                WHEN E.DETAILS IS NULL THEN V.DESCR 
                                ELSE V.DESCR || ' - ' || E.DETAILS
                            END AS choice
                        FROM ENTRY_CHOICES_ARCH E
                            ,RESPONSE_CHOICES_VW V
                        WHERE E.ENTRY_SID = pi_entry_sid
                        AND E.QUESTION_VERSION_SID = pi_question_version_sid
                        AND E.RESPONSE = V.RESPONSE_SID
                        AND E.ROUND_SID = pi_round_sid
                        AND ASSESSMENT_PERIOD = CASE
                                                WHEN l_question_type = T_QUESTION_TYPES.ASSESSMENT_MULTIPLE_CHOICE THEN l_period_sid
                                                ELSE 0
                                             END);
                    ELSE
                        SELECT LISTAGG(choice, ', ') WITHIN GROUP (ORDER BY choice) INTO l_out FROM ( SELECT 
                            CASE
                                WHEN E.DETAILS IS NULL THEN V.DESCR 
                                ELSE V.DESCR || ' - ' || E.DETAILS
                            END AS choice
                        FROM ENTRY_CHOICES E
                            ,RESPONSE_CHOICES_VW V
                        WHERE E.ENTRY_SID = pi_entry_sid
                        AND E.QUESTION_VERSION_SID = pi_question_version_sid
                        AND E.RESPONSE = V.RESPONSE_SID
                        AND ASSESSMENT_PERIOD = CASE
                                                WHEN l_question_type = T_QUESTION_TYPES.ASSESSMENT_MULTIPLE_CHOICE THEN l_period_sid
                                                ELSE 0
                                             END);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_out := NULL;
                END;
            --if the question is marked with add_info, concatenate the additional info as well
            IF l_add_info = 1 AND l_out IS NOT NULL THEN
                BEGIN
                    SELECT NVL(DESCR,'No additional info') INTO l_out_info FROM ENTRY_CHOICES_ADD_INFOS WHERE ENTRY_SID = pi_entry_sid AND QUESTION_VERSION_SID = pi_question_version_sid;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_out_info := NULL;
                END;
                IF l_out_info IS NOT NULL THEN
                    l_out := l_out || ' - ' || l_out_info;
                END IF;
            END IF;
        ELSIF l_question_type = T_QUESTION_TYPES.ASSESSMENT_COMPLIANCE THEN
            IF pi_is_archive = 1 THEN
                SELECT DETAILS INTO l_out
                FROM ENTRY_CHOICES_ARCH
                WHERE ENTRY_SID = pi_entry_sid
                  AND ROUND_SID = pi_round_sid
                  AND QUESTION_VERSION_SID = pi_question_version_sid
                  AND ASSESSMENT_PERIOD = l_period_sid;
            ELSE
                SELECT DETAILS INTO l_out
                 FROM ENTRY_CHOICES
                WHERE ENTRY_SID = pi_entry_sid
                  AND QUESTION_VERSION_SID = pi_question_version_sid
                  AND ASSESSMENT_PERIOD = l_period_sid;
            END IF;
        ELSIF l_question_type = T_QUESTION_TYPES.NO_CHOICE THEN
            l_out := '';
        ELSIF l_question_type = T_QUESTION_TYPES.LINKED_ENTRIES THEN
            IF pi_is_archive = 1 THEN
                BEGIN
                    SELECT LISTAGG(CHOICE, ', ') WITHIN GROUP (ORDER BY CHOICE) INTO l_out FROM
                    (SELECT 'Rule '|| ENTRY_NUMBER || ': '|| NATURE || ' '|| SECTOR AS CHOICE FROM 
                    (WITH
                        ENTRY_SECTORS
                        AS
                            (SELECT R.ENTRY_SID
                                , R.ENTRY_VERSION
                                , R.ENTRY_NO as ENTRY_NUMBER
                                , R.COUNTRY_ID
                                , to_number(RS.RESPONSE) AS SECTOR_SID
                                , L.LOV_ID AS SECTOR
                                , L2.DESCR AS NATURE
                            FROM ENTRIES  R
                                ,ENTRY_CHOICES_ARCH RS
                                ,ENTRY_CHOICES_ARCH RS2
                                ,CFG_LOVS L
                                ,CFG_LOVS L2
                            WHERE RS.ENTRY_SID = R.ENTRY_SID
                                AND RS2.ENTRY_SID = R.ENTRY_SID
                                AND RS2.QUESTION_VERSION_SID = 1
                                AND TO_NUMBER(RS2.RESPONSE) = L2.LOV_SID
                                AND RS.QUESTION_VERSION_SID = 2
                                AND TO_NUMBER(RS.RESPONSE) = L.LOV_SID
                                AND RS.ROUND_SID = pi_round_sid
                                AND RS2.ROUND_SID = pi_round_sid
                                )
                        SELECT DISTINCT 
                                     RS2.ENTRY_NUMBER
                                    ,RS2.SECTOR
                                    ,RS2.NATURE
                                FROM ENTRY_SECTORS RS1
                                    ,ENTRY_SECTORS RS2
                                WHERE RS1.SECTOR_SID = RS2.SECTOR_SID
                                    AND RS1.COUNTRY_ID  = RS2.COUNTRY_ID
                                    AND RS2.ENTRY_SID != RS1.ENTRY_SID
                                    AND RS1.ENTRY_SID = pi_entry_sid) 
                                    )
                        ;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_out := '';
                END;
            ELSE
                BEGIN
                    SELECT LISTAGG(CHOICE, ', ') WITHIN GROUP (ORDER BY CHOICE) INTO l_out FROM
                    (SELECT 'Rule '|| ENTRY_NUMBER || ': '|| NATURE || ' - '|| SECTOR AS CHOICE FROM 
                    (WITH
                        ENTRY_SECTORS
                        AS
                            (SELECT R.ENTRY_SID
                                , R.ENTRY_VERSION
                                , R.ENTRY_NO as ENTRY_NUMBER
                                , R.COUNTRY_ID
                                , to_number(RS.RESPONSE) AS SECTOR_SID
                                , L.LOV_ID AS SECTOR
                                , L2.DESCR AS NATURE
                            FROM ENTRIES  R
                                ,ENTRY_CHOICES RS
                                ,ENTRY_CHOICES RS2
                                ,CFG_LOVS L
                                ,CFG_LOVS L2
                            WHERE RS.ENTRY_SID = R.ENTRY_SID
                                AND RS2.ENTRY_SID = R.ENTRY_SID
                                AND RS2.QUESTION_VERSION_SID = 1
                                AND TO_NUMBER(RS2.RESPONSE) = L2.LOV_SID
                                AND RS.QUESTION_VERSION_SID = 2
                                AND TO_NUMBER(RS.RESPONSE) = L.LOV_SID
                                AND cfg_questionnaire.getAvailability(R.IMPL_DATE
                                                                    ,R.REFORM_IMPL_DATE
                                                                    ,R.REFORM_REPLACED_DATE
                                                                    ,R.ABOLITION_DATE) =
                                    'Current'
                                )
                        SELECT DISTINCT 
                                     RS2.ENTRY_NUMBER
                                    ,RS2.SECTOR
                                    ,RS2.NATURE
                                FROM ENTRY_SECTORS RS1
                                    ,ENTRY_SECTORS RS2
                                WHERE RS1.SECTOR_SID = RS2.SECTOR_SID
                                    AND RS1.COUNTRY_ID  = RS2.COUNTRY_ID
                                    AND RS2.ENTRY_SID != RS1.ENTRY_SID
                                    AND RS1.ENTRY_SID = pi_entry_sid) 
                                    )
                        ;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_out := '';
                END;
            END IF;
            l_out := '';
        ELSIF l_question_type = T_QUESTION_TYPES.NUMERICAL_TARGET THEN
            BEGIN 
                SELECT VALUE
                  INTO l_out
                  FROM TARGET_ENTRIES
                 WHERE ENTRY_SID =  pi_entry_sid
                   AND QUESTION_VERSION_SID = pi_question_version_sid
                   AND RESPONSE_SID = pi_year;
            EXCEPTION
                    WHEN OTHERS THEN
                        l_out := NULL;
            END;
        END IF;
        o_res := l_out;
        -- RETURN NVL(l_out, '');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            CORE_JOBS.LOG_INFO_FAIL('getQuestionVintageText', 'No data found for entry:'||pi_entry_sid||' qv: '||pi_question_version_sid||' round: '||pi_round_sid, SQLERRM, SYSDATE);
            o_res := NULL;
        WHEN OTHERS THEN
            raise_application_error(-20011,SQLERRM || ' ---- ' || l_question_type || '---') ;

    END;

    FUNCTION getAttributeVintageText(pi_attr_name IN VARCHAR2, pi_entry_sid IN NUMBER)
    RETURN VARCHAR2
    IS
        l_out VARCHAR2(4000 BYTE);
        l_statement VARCHAR2(2000 BYTE);
        t_availability CORE_TYPES.T_AVAILABILITY;
    BEGIN
        l_statement := 'SELECT ' || pi_attr_name || ' FROM ENTRIES WHERE ENTRY_SID = ' || pi_entry_sid;
        EXECUTE IMMEDIATE l_statement INTO l_out;
        RETURN l_out;
    END;

    FUNCTION getSectorValue(pi_attr_name IN VARCHAR2, pi_entry_sid IN NUMBER)
    RETURN VARCHAR2
    IS
        l_out VARCHAR2(4000 BYTE);
    BEGIN
        
            SELECT 
                LISTAGG(choice, ', ') WITHIN GROUP (ORDER BY choice) INTO l_out FROM (SELECT
                V.DESCR || ' - ' || DECODE(T.VALUE, null, 'N/A', T.VALUE) AS choice
                FROM TARGET_ENTRIES T
                ,RESPONSE_CHOICES_VW V
                WHERE T.ENTRY_SID = pi_entry_sid
                AND T.RESPONSE_SID = V.RESPONSE_SID
                AND T.QUESTION_VERSION_SID = TO_NUMBER(pi_attr_name)
                );
        
        RETURN l_out;

    END;
    PROCEDURE createVintageApp(p_app_id IN VARCHAR2, p_round_sid IN NUMBER, p_year  IN NUMBER, p_is_archive IN NUMBER)
    IS
        t_availability CORE_TYPES.T_AVAILABILITY;
        
        CURSOR c_vntg_attrs IS
            SELECT * FROM CFG_VINTAGE_ATTRIBUTES
            WHERE APP_ID = p_app_id
            and attr_type_sid in (1, 5,6,7, 8, 9, 10) ORDER BY ORDER_BY;

        CURSOR c_entries_arch IS
            SELECT E.*  FROM ENTRIES E, ENTRY_EDIT_STEPS S WHERE E.ENTRY_SID = S.ENTRY_SID and E.APP_ID = p_app_id AND S.ROUND_SID = p_round_sid
            AND S.EDIT_STEP_SID = 4;
        CURSOR c_entries_cur IS
            SELECT E.*  FROM ENTRIES E, ENTRY_EDIT_STEPS S WHERE E.ENTRY_SID = S.ENTRY_SID and E.APP_ID = p_app_id AND S.ROUND_SID = p_round_sid
            AND cfg_questionnaire.getAvailability(E.IMPL_DATE
                            ,E.REFORM_IMPL_DATE
                            ,E.REFORM_REPLACED_DATE
                            ,E.ABOLITION_DATE
                            ) IN (t_availability.C, t_availability.F)
            
                ; 
        l_cursor_id INTEGER;
        l_target_year NUMBER;
        l_table_statement VARCHAR2(4000 BYTE);
        l_tab_name VARCHAR2(500 BYTE);
        l_add_row_statement VARCHAR2(4000 BYTE);
        l_insert_entry_stat VARCHAR2(4000 BYTE);
        l_ref_entry_stat VARCHAR2(4000 BYTE);
        l_header VARCHAR2(4000 BYTE);
        l_rowcount NUMBER;

        l_debug NUMBER;

        l_update_statement VARCHAR2(4000 BYTE);
        l_help VARCHAR2(4000 BYTE);
        l_stat VARCHAR2(4000 BYTE);
        l_check VARCHAR2(4000 BYTE);
        l_drop_stat VARCHAR2(2000 BYTE);
        l_upd_rowcount NUMBER;

        l_custom_stat VARCHAR2(500 BYTE);
        l_custom_value VARCHAR2(2500 BYTE);
        l_text_value VARCHAR2(4000 BYTE);

        l_current_active_round  NUMBER;
        l_archive   VARCHAR2(200 BYTE) := '_ARCH';

        l_sectors ARRAY_N := ARRAY_N();
        l_sector_count NUMBER;
        l_sector_column NUMBER := 329;
        o_ret NUMBER;
        o_res NUMBER;
    BEGIN
        --OPEN A CURSOR
        l_cursor_id := dbms_sql.open_cursor;

        --COMPOSE TABLE_NAME
        l_tab_name := 'VINTAGE_' || p_app_id || '_' || p_year;
        --COMPOSE CREATE TABLE STATEMENT
        l_table_statement := 'CREATE TABLE ' || l_tab_name || '(ENTRY_SID NUMBER)';

        --PARSE THE CURSOR SO THAT TABLE WILL BE CREATED
        BEGIN
            dbms_sql.parse(l_cursor_id, l_table_statement, dbms_sql.native);
        EXCEPTION
        --if vintages exists, recreate the vintage table to have fresh data
            WHEN OTHERS THEN
                l_drop_stat := 'DROP TABLE '|| l_tab_name;
                dbms_sql.parse(l_cursor_id, l_drop_stat, dbms_sql.native);
                dbms_sql.parse(l_cursor_id, l_table_statement, dbms_sql.native);
        END;

        --insert reference entry_sid = 0 which will have header display names
        l_ref_entry_stat := 'INSERT INTO '|| l_tab_name || '(ENTRY_SID) VALUES (0)';
        EXECUTE IMMEDIATE l_ref_entry_stat;

        --Loop through vintage attributes
        FOR rec_attr IN c_vntg_attrs LOOP
        l_debug := -20;
            --Compose alter table statement
            l_add_row_statement := 'ALTER TABLE ' || l_tab_name || ' ADD (COL' || rec_attr.VINTAGE_ATTR_SID || ' VARCHAR2(4000 BYTE) )';
            --PARSE THE CURSOR SO THAT COLUMN IS ADDED
            dbms_sql.parse(l_cursor_id, l_add_row_statement, dbms_sql.native);


        END LOOP;

        --Loop through vintage attributes to set the headers
        FOR rec_attr IN c_vntg_attrs LOOP
        l_debug := -4000;
            IF rec_attr.DISPLAY_PREFIX IS NULL THEN
                l_header := rec_attr.DISPLAY_NAME;
            ELSE
                IF  rec_attr.ATTR_TYPE_SID  = 8 THEN
                    l_header := rec_attr.DISPLAY_PREFIX || ' - ' || assignYears(rec_attr.DISPLAY_NAME, p_round_sid, p_year);
                ELSE
                    l_header := rec_attr.DISPLAY_PREFIX || ' - ' || rec_attr.DISPLAY_NAME;
                END IF;
            END IF;
            l_ref_entry_stat := 'UPDATE '|| l_tab_name || ' SET COL'|| rec_attr.VINTAGE_ATTR_SID || ' = :header ' ;
            --PARSE THE CURSOR with the update statement
            l_debug := -4001;
            dbms_sql.parse(l_cursor_id, l_ref_entry_stat, dbms_sql.native);
            l_debug := -4002;
            dbms_sql.bind_variable(l_cursor_id,':header', l_header);
            BEGIN
                l_debug := -4010;
                l_upd_rowcount := dbms_sql.execute(l_cursor_id);
            EXCEPTION
                WHEN OTHERS THEN
                    CORE_JOBS.LOG_INFO_FAIL('CreateVintageApp', 'HEADER ERROR', SQLERRM, SYSDATE);
            END;
--            EXECUTE IMMEDIATE l_ref_entry_stat;
        END LOOP;

--        --insert reference entry_sid = 99999 which will have help_text 
        l_ref_entry_stat := 'INSERT INTO '|| l_tab_name || '(ENTRY_SID) VALUES (99999)';
--        --Loop through vintage attributes to set the help text
        EXECUTE IMMEDIATE l_ref_entry_stat;
        l_debug := -5000;
        FOR rec_attr IN c_vntg_attrs LOOP
            l_debug := -5001;
            l_ref_entry_stat := 'UPDATE '|| l_tab_name || ' SET COL'|| rec_attr.VINTAGE_ATTR_SID || ' = '|| chr(39) || rec_attr.DISPLAY_HELP || chr(39) ||' WHERE ENTRY_SID = 99999';
            l_debug := -5002;
            -- dbms_sql.parse(l_cursor_id, l_ref_entry_stat, dbms_sql.native);
            -- l_debug := -5003;
            -- l_help := rec_attr.DISPLAY_HELP;
            -- l_debug := -5004;
            -- dbms_sql.bind_variable(l_cursor_id,':val',l_help);
            BEGIN
            l_debug := -5005;
                --execute statement so that row is UPDATED

                EXECUTE IMMEDIATE l_ref_entry_stat;
            EXCEPTION
                WHEN OTHERS THEN
                    CORE_JOBS.LOG_INFO_FAIL('CreateVintageApp', 'HELP ERROR', SQLERRM, SYSDATE);
            END;
        END LOOP;


        IF p_is_archive = 1 THEN
            --Insert all the entry_sid-s into the vintage table
            FOR rec_entry IN c_entries_arch LOOP
                l_debug := -7001;
                --Compose insert entry statement
                l_insert_entry_stat := 'INSERT INTO ' || l_tab_name || ' (ENTRY_SID) VALUES (:val)';
                --PARSE THE CURSOR 
                dbms_sql.parse(l_cursor_id, l_insert_entry_stat, dbms_sql.native);
                --bind the variables
                dbms_sql.bind_variable(l_cursor_id,':val',rec_entry.ENTRY_SID);
                --execute statement so that row is inserted
                l_rowcount := dbms_sql.execute(l_cursor_id);


                --loop through cfg and start getting the values for the inserted entry_sid
                FOR rec_attr IN c_vntg_attrs LOOP
                    -- IF rec_attr.ATTR_TYPE_SID IN (4, 7) AND p_app_id = 'NFR' THEN
                    l_update_statement := 'UPDATE ' || l_tab_name || ' SET COL'|| rec_attr.VINTAGE_ATTR_SID || ' = :val WHERE ENTRY_SID = :entry ';
                    -- END IF;
                    l_debug := -7002;
                    --PARSE THE CURSOR with the update statement
                    dbms_sql.parse(l_cursor_id, l_update_statement, dbms_sql.native);
                    l_debug := -7003;
                    --bind the variables
                    IF rec_attr.ATTR_TYPE_SID IN (5, 6) THEN
                        l_debug := 2;
                        --question with answers in ENTRY_CHOICES
                        getQuestionVintageText(rec_attr.ATTR_VALUE, rec_entry.ENTRY_SID, p_round_sid, NULL, p_is_archive, l_text_value);
                        dbms_sql.bind_variable(l_cursor_id,':val',l_text_value);

                    ELSIF rec_attr.ATTR_TYPE_SID  = 1 THEN
                        l_debug := 3;
                        --question with answers in ENTRIES
                        dbms_sql.bind_variable(l_cursor_id,':val',getAttributeVintageText(rec_attr.ATTR_VALUE, rec_entry.ENTRY_SID));
                    ELSIF rec_attr.ATTR_TYPE_SID  = 7 THEN
                        dbms_sql.bind_variable(l_cursor_id,':val',getSectorValue(rec_attr.ATTR_VALUE, rec_entry.ENTRY_SID));
                    ELSIF rec_attr.ATTR_TYPE_SID  = 8 THEN
                        l_debug := 7;
                        --question with answers in target_entries
                        --get the year from the cfg
                        l_target_year := assignYears(rec_attr.DISPLAY_NAME, p_round_sid, p_year);
                        -- dbms_output.put_line('target');
                        --bind the variable
                        getQuestionVintageText(rec_attr.ATTR_VALUE, rec_entry.ENTRY_SID, p_round_sid, NULL, p_is_archive, l_text_value);
                        dbms_sql.bind_variable(l_cursor_id,':val',l_text_value);
                    ELSIF rec_attr.ATTR_TYPE_SID  = 9 THEN
                        l_debug := 8;
                        l_custom_stat := 'SELECT '|| rec_attr.ATTR_VALUE || ' FROM DUAL';
                        EXECUTE IMMEDIATE l_custom_stat INTO l_custom_value;
                        --custom function, directly bind
                        dbms_sql.bind_variable(l_cursor_id,':val',l_custom_value);
                    ELSIF rec_attr.ATTR_TYPE_SID  = 10 THEN
                        l_debug := 9;
                        --custom function
                        SELECT CFG_QUESTIONNAIRE.getPreviousStep(rec_entry.ENTRY_SID, p_round_sid, p_year) INTO l_custom_value FROM DUAL;
                        l_debug := -999;
                        dbms_sql.bind_variable(l_cursor_id,':val', l_custom_value);
                    END IF;
                    l_debug := 10;
                    dbms_sql.bind_variable(l_cursor_id,':entry',rec_entry.ENTRY_SID);
                    l_debug := 11;
                    --execute statement so that row is updated
                    l_upd_rowcount := dbms_sql.execute(l_cursor_id);
                    if rec_attr.ATTR_TYPE_SID = 6 and rec_entry.ENTRY_SID = 252 then
                            dbms_output.put_line('l_upd_rowcount='||l_upd_rowcount || '-- getQuestionVintageText');
                        end if;
                END LOOP;


            END LOOP;
        ELSE
            FOR rec_entry IN c_entries_cur LOOP
                l_debug := -7001;
                --Compose insert entry statement
                l_insert_entry_stat := 'INSERT INTO ' || l_tab_name || ' (ENTRY_SID) VALUES (:val)';
                --PARSE THE CURSOR 
                dbms_sql.parse(l_cursor_id, l_insert_entry_stat, dbms_sql.native);
                --bind the variables
                dbms_sql.bind_variable(l_cursor_id,':val',rec_entry.ENTRY_SID);
                --execute statement so that row is inserted
                l_rowcount := dbms_sql.execute(l_cursor_id);


                --loop through cfg and start getting the values for the inserted entry_sid
                FOR rec_attr IN c_vntg_attrs LOOP
                    -- IF rec_attr.ATTR_TYPE_SID IN (4, 7) AND p_app_id = 'NFR' THEN
                    l_update_statement := 'UPDATE ' || l_tab_name || ' SET COL'|| rec_attr.VINTAGE_ATTR_SID || ' = :val WHERE ENTRY_SID = :entry ';
                    -- END IF;
                    l_debug := -7002;
                    --PARSE THE CURSOR with the update statement
                    dbms_sql.parse(l_cursor_id, l_update_statement, dbms_sql.native);
                    l_debug := -7003;
                    --bind the variables
                    IF rec_attr.ATTR_TYPE_SID IN (5, 6) THEN
                        l_debug := 2;
                        --question with answers in ENTRY_CHOICES
                        getQuestionVintageText(rec_attr.ATTR_VALUE, rec_entry.ENTRY_SID, p_round_sid, NULL, p_is_archive, l_text_value);
                        dbms_sql.bind_variable(l_cursor_id,':val',l_text_value);

                    ELSIF rec_attr.ATTR_TYPE_SID  = 1 THEN
                        l_debug := 3;
                        --question with answers in ENTRIES
                        dbms_sql.bind_variable(l_cursor_id,':val',getAttributeVintageText(rec_attr.ATTR_VALUE, rec_entry.ENTRY_SID));
                    ELSIF rec_attr.ATTR_TYPE_SID  = 7 THEN
                        dbms_sql.bind_variable(l_cursor_id,':val',getSectorValue(rec_attr.ATTR_VALUE, rec_entry.ENTRY_SID));
                    ELSIF rec_attr.ATTR_TYPE_SID  = 8 THEN
                        l_debug := 7;
                        --question with answers in target_entries
                        --get the year from the cfg
                        l_target_year := assignYears(rec_attr.DISPLAY_NAME, p_round_sid, p_year);
                        -- dbms_output.put_line('target');
                        --bind the variable
                        getQuestionVintageText(rec_attr.ATTR_VALUE, rec_entry.ENTRY_SID, p_round_sid, NULL, p_is_archive, l_text_value);
                        dbms_sql.bind_variable(l_cursor_id,':val',l_text_value);
                    ELSIF rec_attr.ATTR_TYPE_SID  = 9 THEN
                        l_debug := 8;
                        l_custom_stat := 'SELECT '|| rec_attr.ATTR_VALUE || ' FROM DUAL';
                        EXECUTE IMMEDIATE l_custom_stat INTO l_custom_value;
                        --custom function, directly bind
                        dbms_sql.bind_variable(l_cursor_id,':val',l_custom_value);
                    ELSIF rec_attr.ATTR_TYPE_SID  = 10 THEN
                        l_debug := 9;
                        --custom function
                        SELECT CFG_QUESTIONNAIRE.getPreviousStep(rec_entry.ENTRY_SID, p_round_sid, p_year) INTO l_custom_value FROM DUAL;
                        l_debug := -999;
                        dbms_sql.bind_variable(l_cursor_id,':val', l_custom_value);
                    END IF;
                    l_debug := 10;
                    dbms_sql.bind_variable(l_cursor_id,':entry',rec_entry.ENTRY_SID);
                    l_debug := 11;
                    --execute statement so that row is updated
                    l_upd_rowcount := dbms_sql.execute(l_cursor_id);
                    if rec_attr.ATTR_TYPE_SID = 6 and rec_entry.ENTRY_SID = 252 then
                            dbms_output.put_line('l_upd_rowcount='||l_upd_rowcount || '-- getQuestionVintageText');
                        end if;
                END LOOP;


            END LOOP;
        END IF;
        --Close cursor
        Dbms_sql.close_cursor(l_cursor_id);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM || ' ' || l_update_statement || ' - '|| l_debug );
            raise_application_error(-20011,SQLERRM || ' ---- ' || l_ref_entry_stat || '---' ||l_debug) ;
    END;

    PROCEDURE getVintageData(p_app_id        IN  VARCHAR2
                            ,p_year          IN  NUMBER
                            ,o_cur           OUT SYS_REFCURSOR)
    IS
        l_tab_name VARCHAR2(500 BYTE);
        l_round_sid NUMBER;
        l_round_year NUMBER;
        l_check_tab VARCHAR2(500 BYTE);
        l_check_create DATE;
        l_ret BOOLEAN := FALSE;
    BEGIN
        l_tab_name := 'VINTAGE_' || UPPER(p_app_id) || '_' || p_year;
        OPEN o_cur FOR 'SELECT * FROM '||l_tab_name;

        
        
               
            
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;     

    PROCEDURE getVtAppAttrs(p_app_id        IN  VARCHAR2
                           ,o_cur           OUT SYS_REFCURSOR)    
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT VINTAGE_ATTR_SID,
                   DISPLAY_NAME,
                   DEFAULT_SELECTED,
                   DISPLAY_HELP,
                   ORDER_BY,
                   IS_FILTER,
                   ADMIN_ONLY
              FROM CFG_VINTAGE_ATTRIBUTES
             WHERE APP_ID =  UPPER(p_app_id);
    END;    

END CFG_VINTAGES;