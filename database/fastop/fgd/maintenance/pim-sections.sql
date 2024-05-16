-- NOT IN PROD
DECLARE
    l_section_sid NUMBER;
    l_section_version_sid NUMBER;
    l_qstnnr_version_sid NUMBER := 5;
    l_order_by NUMBER;
    CURSOR c_upd_sections IS
    SELECT EDIT_STEP_SID FROM CFG_EDIT_STEPS WHERE EDIT_STEP_SID IN (1,3,5,7);
BEGIN
    l_order_by := 1;
    --Create new sections and section versions
    INSERT INTO CFG_SECTIONS(SECTION_ID) VALUES ('Investment Planning') RETURNING SECTION_SID INTO l_section_sid;
    INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD)
    VALUES (l_section_sid, 'Investment Planning', 0) RETURNING SECTION_VERSION_SID INTO l_section_version_sid;
    INSERT INTO CFG_QSTNNR_VER_SECTIONS(QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY)
    VALUES (l_qstnnr_version_sid, l_section_version_sid, l_order_by);
    l_order_by := l_order_by + 1;
    FOR rec IN c_upd_sections LOOP
        INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID)
        VALUES (l_section_version_sid, rec.EDIT_STEP_SID);
    END LOOP;
    
    INSERT INTO CFG_SECTIONS(SECTION_ID) VALUES ('Project appraisal and selection') RETURNING SECTION_SID INTO l_section_sid;
    INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD)
    VALUES (l_section_sid, 'Project appraisal and selection', 0) RETURNING SECTION_VERSION_SID INTO l_section_version_sid;
    INSERT INTO CFG_QSTNNR_VER_SECTIONS(QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY)
    VALUES (l_qstnnr_version_sid, l_section_version_sid, l_order_by);
    l_order_by := l_order_by + 1;
    FOR rec IN c_upd_sections LOOP
        INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID)
        VALUES (l_section_version_sid, rec.EDIT_STEP_SID);
    END LOOP;
    
    INSERT INTO CFG_SECTIONS(SECTION_ID) VALUES ('Budgeting for investment') RETURNING SECTION_SID INTO l_section_sid;
    INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD)
    VALUES (l_section_sid, 'Budgeting for investment', 0) RETURNING SECTION_VERSION_SID INTO l_section_version_sid;
    INSERT INTO CFG_QSTNNR_VER_SECTIONS(QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY)
    VALUES (l_qstnnr_version_sid, l_section_version_sid, l_order_by);
    l_order_by := l_order_by + 1;
    FOR rec IN c_upd_sections LOOP
        INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID)
        VALUES (l_section_version_sid, rec.EDIT_STEP_SID);
    END LOOP;
    
    INSERT INTO CFG_SECTIONS(SECTION_ID) VALUES ('Project implementation and monitoring/adjustment') RETURNING SECTION_SID INTO l_section_sid;
    INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD)
    VALUES (l_section_sid, 'Project implementation and monitoring/adjustment', 0) RETURNING SECTION_VERSION_SID INTO l_section_version_sid;
    INSERT INTO CFG_QSTNNR_VER_SECTIONS(QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY)
    VALUES (l_qstnnr_version_sid, l_section_version_sid, l_order_by);
    l_order_by := l_order_by + 1;
    FOR rec IN c_upd_sections LOOP
        INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID)
        VALUES (l_section_version_sid, rec.EDIT_STEP_SID);
    END LOOP;
    
    INSERT INTO CFG_SECTIONS(SECTION_ID) VALUES ('Ex-post impact evaluation and asset registers') RETURNING SECTION_SID INTO l_section_sid;
    INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD)
    VALUES (l_section_sid, 'Ex-post impact evaluation and asset registers', 0) RETURNING SECTION_VERSION_SID INTO l_section_version_sid;
    INSERT INTO CFG_QSTNNR_VER_SECTIONS(QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY)
    VALUES (l_qstnnr_version_sid, l_section_version_sid, l_order_by);
    l_order_by := l_order_by + 1;
    FOR rec IN c_upd_sections LOOP
        INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID)
        VALUES (l_section_version_sid, rec.EDIT_STEP_SID);
    END LOOP;
    
    INSERT INTO CFG_SECTIONS(SECTION_ID) VALUES ('Other issues: ongoing/planned reforms, EU funds, administrative capacity, State-owned enterprises') RETURNING SECTION_SID INTO l_section_sid;
    INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD)
    VALUES (l_section_sid, 'Other issues: ongoing/planned reforms, EU funds, administrative capacity, State-owned enterprises', 0) RETURNING SECTION_VERSION_SID INTO l_section_version_sid;
    INSERT INTO CFG_QSTNNR_VER_SECTIONS(QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY)
    VALUES (l_qstnnr_version_sid, l_section_version_sid, l_order_by);
    l_order_by := l_order_by + 1;
    FOR rec IN c_upd_sections LOOP
        INSERT INTO CFG_UPDATABLE_SECTION_VERSIONS(SECTION_VERSION_SID, EDIT_STEP_SID)
        VALUES (l_section_version_sid, rec.EDIT_STEP_SID);
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
        CORE_JOBS.LOG_INFO_FAIL('Add SECTIONS cfg script', 'Smth went wrong', SQLERRM, trunc(SYSDATE));
        ROLLBACK;
END;
/