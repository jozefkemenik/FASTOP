DECLARE

    CURSOR c_qst_sections IS
    SELECT A.QSTNNR_VERSION_SID as OLD_questionnaire_sid,
           A.QSTNNR_SECTION_SID as OLD_section_sid,
           A.ORDER_BY,
           m.section_version_sid,
           QM.QSTNNR_VERSION_SID
      FROM fgd_cfg_qstnnr_ver_sections A,
           SECTIONS_MIG M,
           QUESTIONNAIRES_MIG QM
     WHERE M.OLD_SECTION_SID = A.QSTNNR_SECTION_SID
       AND M.OLD_QST = A.QSTNNR_VERSION_SID
       AND A.QSTNNR_VERSION_SID = QM.old_questionnaire_sid
       ORDER BY 5, 3
      ;
    CURSOR c_qst_subsections IS
    SELECT par.section_version_sid AS PARENT_SECTION, 
          sub.section_version_sid AS  SUBSECTION,
          OLD.PARENT_SECTION_SID AS OLD_PARENT_SECTION,
          OLD.SUB_SECTION_SID AS OLD_SUBSECTION,
          qm.qstnnr_version_sid,
          OLD.ORDER_BY ,
          qm.old_questionnaire_sid
       FROM FGD_CFG_QSTNNR_SUBSECTIONS OLD,
            SECTIONS_MIG PAR,
            SECTIONS_MIG SUB,
            fgd_cfg_qstnnr_ver_sections VS,
            questionnaires_mig QM
      WHERE par.old_section_sid = OLD.PARENT_SECTION_SID
        AND SUB.OLD_SECTION_SID = OLD.SUB_SECTION_SID
        AND VS.QSTNNR_SECTION_SID = OLD.PARENT_SECTION_SID
        AND VS.QSTNNR_VERSION_SID = qm.old_questionnaire_sid

       ORDER BY 5, 1, 6;
       
    l_eu VARCHAR2(20 BYTE) := 'EU';
    l_cc VARCHAR2(20 BYTE) := 'EUCC';
    
l_key NUMBER;
BEGIN
    FOR r_rec IN c_qst_sections LOOP
        BEGIN
            INSERT INTO CFG_QSTNNR_VER_SECTIONS(QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY)
            VALUES (r_rec.QSTNNR_VERSION_SID, r_rec.section_version_sid, r_rec.ORDER_BY)
            ;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_FAIL('CFG_QSTNNR_VER_SECTIONS', sysdate, sqlerrm(), 0);
        END;
            INSERT INTO QSTNNR_VER_SECTIONS_MIG(OLD_QUESTIONNAIRE_SID, OLD_SECTION_SID, QSTNNR_VERSION_SID, SECTION_VERSION_SID, ORDER_BY)
            VALUES (r_rec.OLD_QUESTIONNAIRE_SID, r_rec.OLD_SECTION_SID, r_rec.QSTNNR_VERSION_SID, r_rec.SECTION_VERSION_SID, r_rec.ORDER_BY);
    END LOOP;
    
    FOR r_rec IN c_qst_subsections LOOP
        BEGIN
            INSERT INTO CFG_QSTNNR_VER_SUBSECTIONS(QSTNNR_VERSION_SID, PARENT_SECTION_VERSION_SID, SUB_SECTION_VERSION_SID, ORDER_BY)
            VALUES (r_rec.QSTNNR_VERSION_SID, r_rec.PARENT_SECTION, r_rec.SUBSECTION, r_rec.ORDER_BY)
            ;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_FAIL('CFG_QSTNNR_VER_SUBSECTIONS', sysdate, sqlerrm(), 0);
        END;
            INSERT INTO QSTNNR_VER_SUBSECTIONS_MIG(OLD_QUESTIONNAIRE_SID, OLD_PARENT_SECTION, OLD_SECTION, QSTNNR_VERSION_SID, PARENT_SECTION, SECTION, ORDER_BY)
            VALUES (r_rec.OLD_QUESTIONNAIRE_SID, r_rec.OLD_PARENT_SECTION, r_rec.OLD_SUBSECTION, r_rec.QSTNNR_VERSION_SID, r_rec.PARENT_SECTION, r_rec.SUBSECTION, r_rec.ORDER_BY);
    END LOOP;
    
 EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('MIG CFG_QSTNNR_VER_SUBSECTIONS FAIL', sysdate, sqlerrm(), 0);
END;
    