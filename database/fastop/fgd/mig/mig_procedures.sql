CREATE OR REPLACE PROCEDURE LOG_INFO (
    P_TABLE_NAME IN VARCHAR2,
    P_TIMESTMP IN DATE,
    P_MSG IN VARCHAR2,
    P_KEY IN NUMBER)
IS
BEGIN
    INSERT INTO MIG_LOG_INFO(TABLE_NAME, TIMESTMP, MESSAGE, KEY)
    VALUES (P_TABLE_NAME, P_TIMESTMP, P_MSG, P_KEY);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE LOG_FAIL (
    P_TABLE_NAME IN VARCHAR2,
    P_TIMESTMP IN DATE,
    P_MSG IN VARCHAR2,
    P_KEY IN NUMBER)
IS
BEGIN
    INSERT INTO MIG_LOG_FAIL(TABLE_NAME, TIMESTMP, MESSAGE, KEY)
    VALUES (P_TABLE_NAME, P_TIMESTMP, P_MSG, P_KEY);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
CREATE OR REPLACE FUNCTION get_question_type (pi_question_version number)
RETURN NUMBER
IS
l_out number;
BEGIN
    SELECT QUESTION_TYPE_SID INTO l_out FROM CFG_QUESTION_VERSIONS
        WHERE QUESTION_VERSION_SID = pi_question_version;
    RETURN l_out;
END;
/
CREATE OR REPLACE FUNCTION get_lov_sid (pi_old_lov_sid number)
RETURN NUMBER
IS
l_out NUMBER;
BEGIN
    IF pi_old_lov_sid = NULL THEN
        l_out := NULL;
    ELSE
        SELECT DISTINCT NEW_LOV_SID INTO l_out
          FROM LOVS_MIG WHERE OLD_LOV_SID = pi_old_lov_sid;
        
    END IF;
    RETURN l_out;
END;
/
CREATE OR REPLACE FUNCTION get_new_question_version_sid (pi_old_question_sid IN NUMBER)
RETURN NUMBER IS
l_ret NUMBER := 0;
BEGIN
    SELECT DISTINCT QM.NEW_QUESTION_VERSION_SID
      INTO l_ret
      FROM QUESTIONS_MIG QM
     WHERE QM.OLD_QUESTION_SID = pi_old_question_sid;
     
    RETURN l_ret;
END;
/
CREATE OR REPLACE FUNCTION get_new_lov_type (pi_old_lov_type IN NUMBER)
RETURN NUMBER IS
l_ret NUMBER := 0;
BEGIN

    SELECT NEW_LOV_TYPE_SID
      INTO l_ret
      FROM LOV_TYPES_MIG
     WHERE old_lov_type_sid = pi_old_lov_type;
     
    RETURN l_ret;
END get_new_lov_type;
/
CREATE OR REPLACE FUNCTION get_new_cond_sid (pi_old_cond_sid IN NUMBER)
RETURN NUMBER IS
l_ret NUMBER := 0;
BEGIN
    SELECT NEW_COND_SID
      INTO l_ret
      FROM CONDITIONS_MIG
     WHERE OLD_COND_SID = pi_old_cond_sid;
    
    RETURN NVL(l_ret,0);
END get_new_cond_sid;
/

CREATE OR REPLACE FUNCTION get_new_entry_sid (pi_old_entry_sid IN NUMBER, pi_old_table IN VARCHAR2)
RETURN NUMBER IS
l_ret NUMBER := 0;
BEGIN
    SELECT NEW_SID
      INTO l_ret
      FROM ENTRIES_MIG
     WHERE OLD_SID = pi_old_entry_sid
       AND OLD_TABLE = pi_old_table;
    
    RETURN NVL(l_ret,0);
END get_new_entry_sid;
/

CREATE OR REPLACE FUNCTION get_question_version_sid (pi_old_ATTR_sid IN NUMBER)
RETURN NUMBER IS
l_ret NUMBER := 0;
BEGIN
    SELECT DISTINCT QM.NEW_QUESTION_VERSION_SID
      INTO l_ret
      FROM QUESTION_VERSIONS_MIG QM
     WHERE QM.OLD_ATTR_SID = pi_old_ATTR_sid;
     
    RETURN l_ret;
END;
/
CREATE OR REPLACE FUNCTION getCoverage(p_entry_sid  IN NUMBER, p_sector IN NUMBER)
RETURN VARCHAR2
IS
    l_country VARCHAR2(200 BYTE);
    l_sector NUMBER;
    l_sector_value NUMBER;
    l_numeric_value NUMBER;
    
    cg_value NUMBER;
    rg_value NUMBER;
    lg_value NUMBER;
    ss_value NUMBER;
    l_coverage CFG_COVERAGE_CONDITIONS%ROWTYPE;
    l_stat varchar2(2000 BYTE);
    l_val varchar2(2000 BYTE);
    o_ret varchar2(2000 BYTE);

    l_eurostat varchar(200 BYTE);
BEGIN
    --Get country of the entry
    SELECT COUNTRY_ID INTO l_country FROM ENTRIES WHERE ENTRY_SID = p_entry_sid;
    --Get eurostat values for non-GG sectors
    SELECT CG_VALUE, RG_VALUE, LG_VALUE, SS_VALUE
      INTO cg_value, rg_value, lg_value, ss_value 
      FROM CFG_EUROSTAT_COVERAGE 
     WHERE COUNTRY_ID = l_country;

    --Get numeric value of that sector
    BEGIN
        SELECT value INTO l_sector_value FROM TARGET_ENTRIES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = 5 AND RESPONSE_SID = p_sector;
    EXCEPTION
        WHEN OTHERS THEN
         l_sector_value := NULL;
    END;
    IF l_sector_value IS NOT NULL THEN
        l_numeric_value := 1;
        SELECT * INTO l_coverage FROM CFG_COVERAGE_CONDITIONS WHERE LOV_SID = p_sector AND NUMERIC_VALUE = l_numeric_value ;
    ELSE
        l_numeric_value := NULL;
        SELECT * INTO l_coverage FROM CFG_COVERAGE_CONDITIONS WHERE LOV_SID = p_sector AND NUMERIC_VALUE IS NULL;
    END IF;
    
    
    IF l_coverage.NEED_EUROSTAT_CFG = 1 THEN 
        IF l_numeric_value IS NULL THEN
            l_eurostat := REPLACE(l_coverage.EUROSTAT_CFG, 'CG_VALUE',cg_value);
            l_eurostat := REPLACE(l_eurostat, 'RG_VALUE', rg_value);
            l_eurostat := REPLACE(l_eurostat, 'LG_VALUE', lg_value);
            l_eurostat := REPLACE(l_eurostat, 'SS_VALUE', ss_value);
            o_ret := REPLACE(l_coverage.DESCR, ':EUROSTAT_CFG', l_eurostat);
        ELSE
            l_eurostat := REPLACE(l_coverage.EUROSTAT_CFG, 'CG_VALUE',cg_value);
            l_eurostat := REPLACE(l_eurostat, 'RG_VALUE', rg_value);
            l_eurostat := REPLACE(l_eurostat, 'LG_VALUE', lg_value);
            l_eurostat := REPLACE(l_eurostat, 'SS_VALUE', ss_value);
            o_ret := REPLACE(l_coverage.DESCR, ':EUROSTAT_CFG', l_eurostat);
            o_ret := REPLACE(o_ret, ':NUMERIC_VALUE', l_sector_value);
            
        END IF;
    ELSE
        IF l_numeric_value IS NULL THEN
            o_ret := l_coverage.DESCR;
        ELSE
            o_ret := REPLACE(l_coverage.DESCR, ':NUMERIC_VALUE', l_sector_value);
        END IF;
    END IF;
    
    l_stat := 'BEGIN :val := '|| o_ret || '; END;';
    EXECUTE IMMEDIATE l_stat USING OUT l_val;

    RETURN l_val;
END;
/

FUNCTION getAttributeVintageText(pi_attr_name IN VARCHAR2, pi_entry_sid IN NUMBER)
RETURN VARCHAR2
IS
    l_cursor_id INTEGER;
    l_out VARCHAR2(4000 BYTE);
    l_statement VARCHAR2(2000 BYTE);
BEGIN

    l_statement := 'SELECT ' || pi_attr_name || ' FROM ENTRIES WHERE ENTRY_SID = ' || pi_entry_sid ;
    EXECUTE IMMEDIATE l_statement INTO l_out;
    
    RETURN l_out;
END;

FUNCTION getQuestionVintageText(pi_question_version_sid IN NUMBER, pi_entry_sid IN NUMBER, pi_round_sid IN NUMBER)
RETURN VARCHAR2
IS
    l_out VARCHAR2(9000 BYTE);
    l_out_info VARCHAR2(4000 BYTE);
    
    l_question_type NUMBER;
    l_add_info      NUMBER;
    T_QUESTION_TYPES CORE_TYPES.T_QUESTION_TYPES;
BEGIN
    SELECT QUESTION_TYPE_SID, ADD_INFO INTO l_question_type, l_add_info FROM CFG_QUESTION_VERSIONS WHERE QUESTION_VERSION_SID = pi_question_version_sid;
    
    IF l_question_type IN ( T_QUESTION_TYPES.FREE_TEXT, T_QUESTION_TYPES.SINGLE_LINE) THEN
        BEGIN
            --free text, just take the response
            SELECT RESPONSE
            INTO l_out
            FROM ENTRY_CHOICES_ARCH
            WHERE ENTRY_SID = pi_entry_sid
            AND QUESTION_VERSION_SID = pi_question_version_sid
            AND ROUND_SID = pi_round_sid;
        EXCEPTION
            WHEN OTHERS THEN
                l_out := NULL;
        END;
        --if the question is marked with add_info, concatenate the additional info as well
        IF l_add_info = 1 AND l_out IS NOT NULL THEN
            BEGIN
                SELECT NVL(DESCR,null) INTO l_out_info FROM ENTRY_CHOICES_ADD_INFOS WHERE ENTRY_SID = pi_entry_sid AND QUESTION_VERSION_SID = pi_question_version_sid;
            EXCEPTION
                WHEN OTHERS THEN
                    l_out_info := NULL;
            END;
            IF l_out_info IS NOT NULL THEN
                l_out := l_out || ' - ' || l_out_info;
            END IF;
        END IF;
    ELSIF l_question_type IN (T_QUESTION_TYPES.SINGLE_CHOICE, T_QUESTION_TYPES.ASSESSMENT_SINGLE_CHOICE, T_QUESTION_TYPES.SINGLE_DROPDOWN) THEN
        BEGIN
            --single choice/dropdown, assessment single choice, take the text of the response and the provide details, if any
            SELECT DISTINCT
                CASE
                    WHEN E.DETAILS IS NULL THEN V.DESCR 
                    ELSE V.DESCR || ' - ' || E.DETAILS
                END INTO l_out
            FROM ENTRY_CHOICES_ARCH E
                ,RESPONSE_CHOICES_VW V
            WHERE E.ENTRY_SID = pi_entry_sid
            AND E.QUESTION_VERSION_SID = pi_question_version_sid
            AND E.ROUND_SID = pi_round_sid
            AND E.RESPONSE = V.RESPONSE_SID;
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
            SELECT LISTAGG(choice, ' ') WITHIN GROUP (ORDER BY choice) INTO l_out FROM ( SELECT 
                CASE
                    WHEN E.DETAILS IS NULL THEN V.DESCR 
                    ELSE V.DESCR || ' - ' || E.DETAILS
                END AS choice
            FROM ENTRY_CHOICES_ARCH E
                ,RESPONSE_CHOICES_VW V
            WHERE E.ENTRY_SID = pi_entry_sid
            AND E.QUESTION_VERSION_SID = pi_question_version_sid
            AND E.ROUND_SID = pi_round_sid
            AND E.RESPONSE = V.RESPONSE_SID);
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
        l_out := '';
    ELSIF l_question_type = T_QUESTION_TYPES.NO_CHOICE THEN
        l_out := '';
    ELSIF l_question_type = T_QUESTION_TYPES.LINKED_ENTRIES THEN
        l_out := '';
    END IF;
    
    RETURN NVL(l_out, '');
    
        
END;