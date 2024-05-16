DECLARE
    CURSOR c_sections IS
        SELECT A.section_sid ,
               A.section_id,
               A.descr ,
               A.QUESTIONNAIRE_SID,
               NULL AS NO_HELP
        FROM FGD_CFG_SECTIONS A
        ORDER BY 1;
        
l_err_key NUMBER;
l_key NUMBER;
l_version_key NUMBER;
BEGIN
    FOR r_rec IN c_sections LOOP
        l_err_key := r_rec.SECTION_SID;
        BEGIN
            INSERT INTO CFG_SECTIONS(SECTION_ID)
            VALUES (r_rec.SECTION_ID)
            RETURNING SECTION_SID INTO l_key;
            
        EXCEPTION 
            WHEN OTHERS THEN
                SELECT SECTION_SID INTO l_key FROM CFG_SECTIONS WHERE SECTION_ID = r_rec.SECTION_ID;
                
        END;

            LOG_info('CFG_SECTIONS', sysdate, 'Migrated with SUCC', l_key);

        BEGIN
            INSERT INTO CFG_SECTION_VERSIONS(SECTION_SID, DESCR, ASSESSMENT_PERIOD, NO_HELP)
            VALUES (l_key, r_rec.DESCR, 0, r_rec.NO_HELP)
            RETURNING SECTION_VERSION_SID INTO l_version_key;
        EXCEPTION 
            WHEN OTHERS THEN
            l_version_key := 0;
                LOG_FAIL('CFG_SECTION_VERSIONS', sysdate, sqlerrm(), l_key);
                
        END;
            IF l_version_key = 0 THEN
                SELECT SECTION_VERSION_SID INTO l_version_key FROM CFG_SECTION_VERSIONS WHERE SECTION_SID = l_key AND DESCR = r_rec.DESCR;
            END IF;
            LOG_info('CFG_SECTION_VERSIONS', sysdate, 'Migrated with SUCC', l_version_key);
            INSERT INTO SECTIONS_MIG(OLD_SECTION_SID, NEW_SECTION_SID, SECTION_VERSION_SID, OLD_QST)
            VALUES (r_rec.SECTION_SID, l_key, l_version_key, r_rec.QUESTIONNAIRE_SID);
            
            LOG_info('SECTIONS_MIG', sysdate, 'Migrated with SUCC', l_key);
            
            
        l_key := 0;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('Migrate Sections', sysdate, sqlerrm() , l_err_key);
END;
/
UPDATE CFG_SECTION_VERSIONS
SET ASSESSMENT_PERIOD = 1 WHERE
SECTION_VERSION_SID IN (
select sm.section_version_sid from
FGD_CFG_SECTIONS fs,
fgd_cfg_qstnnr_sections fqs,
SECTIONS_MIG sm
where fs.section_sid = fqs.section_sid
  and fs.section_sid = sm.old_section_sid
  AND fqs.assessment_period = 1
);
UPDATE CFG_SECTION_VERSIONS
SET ASSESSMENT_PERIOD = 2 WHERE
SECTION_VERSION_SID IN (
select sm.section_version_sid from
FGD_CFG_SECTIONS fs,
fgd_cfg_qstnnr_sections fqs,
SECTIONS_MIG sm
where fs.section_sid = fqs.section_sid
  and fs.section_sid = sm.old_section_sid
  AND fqs.assessment_period = 2
);
COMMIT;