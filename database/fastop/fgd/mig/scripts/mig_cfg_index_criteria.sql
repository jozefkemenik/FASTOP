DECLARE
    CURSOR c_data IS
    SELECT * FROM fgd_idx_criteria ORDER BY CRITERION_SID;
BEGIN
    FOR rec IN c_data LOOP
        INSERT INTO CFG_INDEX_CRITERIA(CRITERION_ID, SUB_CRITERION_ID, DESCR, INDEX_SID, HELP_TEXT)
        VALUES (rec.CRITERION_ID, rec.SUB_CRITERION_ID, rec.DESCR, rec.INDEX_SID, rec.HELP_TEXT);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        log_fail('CFG_INDEX_CRITERIA failure', SYSDATE, SQLERRM(), -1);
END;
/
INSERT INTO CFG_INDEX_CRITERIA_SCORES SELECT * FROM FGD_IDX_CRITERIA_SCORES;
COMMIT;