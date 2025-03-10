--not in prod
DECLARE 
    CURSOR c_section_questions IS
    SELECT section_version_sid, question_version_sid, order_by
     FROM CFG_QSTNNR_SECTION_QUESTIONS
     WHERE SECTION_VERSION_SID IN (SELECT SECTION_VERSION_SID FROM CFG_QSTNNR_VER_SECTIONS WHERE QSTNNR_VERSION_SID = 5)
     ORDER BY SECTION_VERSION_SID, ORDER_BY;

    l_attr_type_sid NUMBER := 5;
    l_display_name   VARCHAR2(1000 BYTE); --question descr
    l_display_prefix VARCHAR2(1000 BYTE); --section_version descr
    l_display_help   VARCHAR2(1000 BYTE); --question version help_text
    l_order_by  NUMBER;
    l_app_id VARCHAR2(40 BYTE) := 'PIM';
BEGIN
    SAVEPOINT vintage_one;
    l_order_by := 1;
    FOR rec IN c_section_questions LOOP
        SELECT DESCR INTO l_display_prefix FROM CFG_SECTION_VERSIONS WHERE SECTION_VERSION_SID = rec.SECTION_VERSION_SID;
        SELECT DESCR INTO l_display_name FROM CFG_QUESTIONS WHERE QUESTION_SID IN (SELECT QUESTION_SID FROM CFG_QUESTION_VERSIONS WHERE QUESTION_VERSION_SID = rec.QUESTION_VERSION_SID);
        SELECT HELP_TEXT INTO l_display_help FROM CFG_QUESTION_VERSIONS WHERE QUESTION_VERSION_SID = rec.QUESTION_VERSION_SID;
        
        INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DISPLAY_PREFIX, DEFAULT_SELECTED, ORDER_BY, DISPLAY_HELP)
        VALUES (l_app_id, l_attr_type_sid, TO_CHAR(rec.QUESTION_VERSION_SID), l_display_name, l_display_prefix, 1, l_order_by, l_display_help);
        l_order_by := l_order_by + 1;
    END LOOP;
    
    UPDATE CFG_VINTAGE_ATTRIBUTES
    SET ORDER_BY = ORDER_BY + 2
    WHERE APP_ID = l_app_id;
    
    --INSERT FOR COUNTRY_ID
    INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DISPLAY_PREFIX, DEFAULT_SELECTED, ORDER_BY, IS_FILTER)
    VALUES (l_app_id, 1, 'COUNTRY_ID', 'Country', null, 1, 1, 1);
    --INSERT FOR AVAILABILITY
    INSERT INTO CFG_VINTAGE_ATTRIBUTES(APP_ID, ATTR_TYPE_SID, ATTR_VALUE, DISPLAY_NAME, DISPLAY_PREFIX, DEFAULT_SELECTED, ORDER_BY, IS_FILTER)
    VALUES (l_app_id, 10, 'STATUS', 'Status', null, 1, 2, 1);
    
    UPDATE CFG_VINTAGE_ATTRIBUTES
       SET IS_FILTER = 1 
     WHERE APP_ID = l_app_id
       AND ORDER_BY <= 4;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO vintage_one;
END;
/