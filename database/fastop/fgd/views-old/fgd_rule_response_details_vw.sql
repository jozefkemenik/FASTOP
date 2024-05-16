CREATE OR REPLACE FORCE EDITIONABLE VIEW "FGD_RULE_RESPONSE_DETAILS_VW" ("QUESTIONNAIRE_SID", "RULE_SID", "ATTR_SID", "RESPONSE_GROUP_SID", "RESPONSE_SID", "DESCR", "NUMERIC_VALUE") AS 
  SELECT
        1,
        rld.rule_sid,
        rld.attr_sid,
        l.lov_type_sid,
        rld.lov_sid,
        rld.descr,
        NULL
    FROM
        fgd_nfr_rule_lov_dets   rld
        LEFT JOIN fgd_nfr_lovs            l ON l.lov_sid = rld.lov_sid
    UNION ALL
    SELECT
        1,
        rs.rule_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'SECTOR_SID'
                AND master_sid IS NULL
        ),
        rc.response_group_sid,
        rs.sector_sid,
        rs.descr,
        rs.est_share_value
    FROM
        fgd_nfr_rule_sectors          rs
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = rs.sector_sid
    UNION ALL
    SELECT
        1,
        tr.rule_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'YEAR'
                AND master_sid IS NULL
        ),
        NULL,
        tr.year,
        NULL,
        tr.value
    FROM
        fgd_nfr_target_rules tr
    UNION ALL
    SELECT
        1,
        eer.rule_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXCL_ELEM_SID'
                AND master_sid IS NULL
        ),
        rc.response_group_sid,
        eer.excl_elem_sid,
        eer.descr,
        NULL
    FROM
        fgd_nfr_excl_elem_rules       eer
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = eer.excl_elem_sid
    UNION ALL
    SELECT
        1,
        tr.rule_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'DCQ_TRG_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        tr.dcq_trg_sid,
        tr.descr,
        NULL
    FROM
        fgd_nfr_dcq_trg_rules   tr
        LEFT JOIN fgd_nfr_lovs            l ON l.lov_sid = tr.dcq_trg_sid
    UNION ALL
    SELECT
        1,
        ri.rule_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'ESC_INSTITUTION_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        ri.esc_institution_sid,
        ri.descr,
        NULL
    FROM
        fgd_nfr_rule_esc_inst_vw   ri
        LEFT JOIN fgd_nfr_lovs               l ON l.lov_sid = ri.esc_institution_sid
    UNION ALL
    SELECT
        1,
        ri.rule_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EAM_INSTITUTION_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        ri.eam_institution_sid,
        ri.descr,
        NULL
    FROM
        fgd_nfr_rule_eam_inst_vw   ri
        LEFT JOIN fgd_nfr_lovs               l ON l.lov_sid = ri.eam_institution_sid
    UNION ALL
    SELECT
        1,
        ri.rule_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EPM_INSTITUTION_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        ri.epm_institution_sid,
        ri.descr,
        NULL
    FROM
        fgd_nfr_rule_epm_inst_vw   ri
        LEFT JOIN fgd_nfr_lovs               l ON l.lov_sid = ri.epm_institution_sid
    UNION ALL
    SELECT
        1,
        ri.rule_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'DCQ_INSTITUTION_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        ri.dcq_institution_sid,
        ri.descr,
        NULL
    FROM
        fgd_nfr_rule_dcq_inst_vw   ri
        LEFT JOIN fgd_nfr_lovs               l ON l.lov_sid = ri.dcq_institution_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        rld.attr_sid,
        l.lov_type_sid,
        rld.lov_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_institution_lov_dets   rld
        LEFT JOIN fgd_ifi_lovs                   l ON l.lov_sid = rld.lov_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'TIME_COMP_ASSESS_SID'
        ),
        l.lov_type_sid,
        rld.time_comp_assess_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_inst_time_comp_assess   rld
        LEFT JOIN fgd_ifi_lovs                    l ON l.lov_sid = rld.time_comp_assess_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'SECTOR_BUDG_SID'
        ),
        l.lov_type_sid,
        rld.sector_budg_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_inst_sector_budg   rld
        LEFT JOIN fgd_ifi_lovs               l ON l.lov_sid = rld.sector_budg_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'ANBUD_SECTOR_MACRO_SID'
        ),
        l.lov_type_sid,
        rld.anbud_sector_macro_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_inst_sector_macro   rld
        LEFT JOIN fgd_ifi_lovs                l ON l.lov_sid = rld.anbud_sector_macro_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'VARIABLE_SID'
        ),
        l.lov_type_sid,
        rld.variable_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_inst_variable   rld
        LEFT JOIN fgd_ifi_lovs            l ON l.lov_sid = rld.variable_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'ACTIVS_NORMS_SID'
        ),
        l.lov_type_sid,
        rld.activs_norms_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_inst_activs_norms   rld
        LEFT JOIN fgd_ifi_lovs                l ON l.lov_sid = rld.activs_norms_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'DRAFT_TOPICS_SID'
        ),
        l.lov_type_sid,
        rld.draft_topics_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_inst_draft_topics   rld
        LEFT JOIN fgd_ifi_lovs                l ON l.lov_sid = rld.draft_topics_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'IMPLEM_TOPICS_SID'
        ),
        l.lov_type_sid,
        rld.implem_topics_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_inst_implem_topics   rld
        LEFT JOIN fgd_ifi_lovs                 l ON l.lov_sid = rld.implem_topics_sid
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'LBI_ACCESS_SID'
        ),
        l.lov_type_sid,
        rld.lbi_access_sid,
        rld.descr,
        NULL
    FROM
        fgd_ifi_inst_lbi_access   rld
        LEFT JOIN fgd_ifi_lovs              l ON l.lov_sid = rld.lbi_access_sid
    --
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXA_RRP_SID'
        ),
        l.lov_type_sid,
        rld.EXA_RRP_SID,
        rld.descr,
        NULL
    FROM
        FGD_IFI_EXA_RRP   rld
        LEFT JOIN fgd_ifi_lovs              l ON l.lov_sid = rld.EXA_RRP_SID
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXP_RRP_SID'
        ),
        l.lov_type_sid,
        rld.EXP_RRP_SID,
        rld.descr,
        NULL
    FROM
        FGD_IFI_EXP_RRP   rld
        LEFT JOIN fgd_ifi_lovs              l ON l.lov_sid = rld.EXP_RRP_SID
    UNION ALL
    SELECT
        2,
        rld.institution_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'RRP_CHA_SID'
        ),
        l.lov_type_sid,
        rld.RRP_CHA_SID,
        rld.descr,
        NULL
    FROM
        FGD_IFI_RPP_CHA   rld
        LEFT JOIN fgd_ifi_lovs              l ON l.lov_sid = rld.RRP_CHA_SID
    UNION ALL
    SELECT
        3,
        rld.frame_sid,
        rld.attr_sid,
        l.lov_type_sid,
        rld.lov_sid,
        rld.descr,
        NULL
    FROM
        fgd_mtbf_frame_lov_dets   rld
        LEFT JOIN fgd_mtbf_lovs             l ON l.lov_sid = rld.lov_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'TARGET_REVIS_SID'
        ),
        l.lov_type_sid,
        f.target_revis_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_target_revis   f
        LEFT JOIN fgd_mtbf_lovs           l ON l.lov_sid = f.target_revis_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'SEC_COV_MTBF_TARG_SID'
        ),
        l.lov_type_sid,
        f.sec_cov_mtbf_targ_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_sec_cov_mtbf_targ   f
        LEFT JOIN fgd_mtbf_lovs                l ON l.lov_sid = f.sec_cov_mtbf_targ_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'XSEC_COORD_MECH_SID'
        ),
        l.lov_type_sid,
        f.xsec_coord_mech_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_xsec_coord_mech   f
        LEFT JOIN fgd_mtbf_lovs              l ON l.lov_sid = f.xsec_coord_mech_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'COORD_MECH_INVOLVE_SID'
        ),
        l.lov_type_sid,
        f.coord_mech_involve_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_coord_mech_involve   f
        LEFT JOIN fgd_mtbf_lovs                 l ON l.lov_sid = f.coord_mech_involve_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'TARGET_VARIABLES_SID'
        ),
        l.lov_type_sid,
        f.target_variables_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_target_variables   f
        LEFT JOIN fgd_mtbf_lovs               l ON l.lov_sid = f.target_variables_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'DISAGG_EXPEND_SID'
        ),
        l.lov_type_sid,
        f.disagg_expend_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_disagg_expend   f
        LEFT JOIN fgd_mtbf_lovs            l ON l.lov_sid = f.disagg_expend_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'BUDG_BAL_EXCL_SID'
        ),
        l.lov_type_sid,
        f.budg_bal_excl_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_budg_bal_excl   f
        LEFT JOIN fgd_mtbf_lovs            l ON l.lov_sid = f.budg_bal_excl_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXPEND_EXCL_SID'
        ),
        l.lov_type_sid,
        f.expend_excl_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_expend_excl   f
        LEFT JOIN fgd_mtbf_lovs          l ON l.lov_sid = f.expend_excl_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'POL_SCENE_IND_SID'
        ),
        l.lov_type_sid,
        f.pol_scene_ind_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_pol_scene_ind   f
        LEFT JOIN fgd_mtbf_lovs            l ON l.lov_sid = f.pol_scene_ind_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'DISAGG_EXP_PROJ_SID'
        ),
        l.lov_type_sid,
        f.disagg_exp_proj_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_disagg_exp_proj   f
        LEFT JOIN fgd_mtbf_lovs              l ON l.lov_sid = f.disagg_exp_proj_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'DISAGG_LEV_POL_SID'
        ),
        l.lov_type_sid,
        f.disagg_lev_pol_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_disagg_lev_pol   f
        LEFT JOIN fgd_mtbf_lovs             l ON l.lov_sid = f.disagg_lev_pol_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'BUDG_TARG_DIFFER_SID'
        ),
        l.lov_type_sid,
        f.budg_targ_differ_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_budg_targ_differ   f
        LEFT JOIN fgd_mtbf_lovs               l ON l.lov_sid = f.budg_targ_differ_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'MTBF_PREP_ACTOR_SID'
        ),
        l.lov_type_sid,
        f.mtbf_prep_actor_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_mtbf_prep_actor   f
        LEFT JOIN fgd_mtbf_lovs              l ON l.lov_sid = f.mtbf_prep_actor_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'IFI_INVOLVE_SID'
        ),
        l.lov_type_sid,
        f.ifi_involve_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_ifi_involve   f
        LEFT JOIN fgd_mtbf_lovs          l ON l.lov_sid = f.ifi_involve_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXA_CHARGE_BUDG_COMPL_SID'
        ),
        l.lov_type_sid,
        f.exa_charge_budg_compl_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_exa_charge_budg_c   f
        LEFT JOIN fgd_mtbf_lovs                l ON l.lov_sid = f.exa_charge_budg_compl_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXA_MONIT_SID'
        ),
        l.lov_type_sid,
        f.exa_monit_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_exa_monit   f
        LEFT JOIN fgd_mtbf_lovs        l ON l.lov_sid = f.exa_monit_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXP_MONIT_REP_SID'
        ),
        l.lov_type_sid,
        f.exp_monit_rep_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_exp_monit_rep   f
        LEFT JOIN fgd_mtbf_lovs        l ON l.lov_sid = f.exp_monit_rep_sid
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'ALT_MACRO_SCENE_SID'
        ),
        l.lov_type_sid,
        f.alt_macro_scene_sid,
        f.descr,
        NULL
    FROM
        fgd_mtbf_alt_macro_scene   f
        LEFT JOIN fgd_mtbf_lovs              l ON l.lov_sid = f.alt_macro_scene_sid
--
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXA_RESULT_PRES_SID'
        ),
        l.lov_type_sid,
        f.EXA_RESULT_PRES_SID,
        f.descr,
        NULL
    FROM
        FGD_MTBF_EXA_RESULT_PRES   f
        LEFT JOIN fgd_mtbf_lovs              l ON l.lov_sid = f.EXA_RESULT_PRES_SID
    UNION ALL
    SELECT
        3,
        f.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EXP_RESULT_PRES_SID'
        ),
        l.lov_type_sid,
        f.EXP_RESULT_PRES_SID,
        f.descr,
        NULL
    FROM
        FGD_MTBF_EXP_RESULT_PRES   f
        LEFT JOIN fgd_mtbf_lovs              l ON l.lov_sid = f.EXP_RESULT_PRES_SID        
    UNION ALL
    SELECT
        3,
        tr.frame_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'MTBF_NUM_TARGET_SID'
                AND master_sid IS NULL
        ),
        NULL,
        tr.MTBF_NUM_TARGET_SID,
        NULL,
        tr.value
    FROM
        FGD_MTBF_TARGET_FRAMES tr
    UNION ALL
    SELECT
        4,
        rld.entry_sid,
        rld.attr_sid,
        l.lov_type_sid,
        rld.lov_sid,
        rld.descr,
        NULL
    FROM
        fgd_gbd_entrie_lov_dets   rld
        LEFT JOIN gbd_lovs                   l ON l.lov_sid = rld.lov_sid
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'GEN_IN_PLACE_SID'),
        l.lov_type_sid,
        f.GEN_IN_PLACE_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_GEN_IN_PLACE f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.GEN_IN_PLACE_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'GEN_PLANS_INTRO_SID'),
        l.lov_type_sid,
        f.GEN_PLANS_INTRO_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_GEN_PLANS_INTRO f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.GEN_PLANS_INTRO_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'GEN_CHALLGE_SID'),
        l.lov_type_sid,
        f.GEN_CHALLGE_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_GEN_CHALLGE f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.GEN_CHALLGE_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'GEN_MOTIV_SID'),
        l.lov_type_sid,
        f.GEN_MOTIV_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_GEN_MOTIV f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.GEN_MOTIV_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVLT_ENV_OBJ_SID'),
        l.lov_type_sid,
        f.CVLT_ENV_OBJ_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVLT_ENV_OBJ f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVLT_ENV_OBJ_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVLT_BDGT_ELMT_SID'),
        l.lov_type_sid,
        f.CVLT_BDGT_ELMT_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVLT_BDGT_ELMT f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVLT_BDGT_ELMT_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVLT_PUB_SECT_SID'),
        l.lov_type_sid,
        f.CVLT_PUB_SECT_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVLT_PUB_SECT f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVLT_PUB_SECT_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVBT_ENV_OBJ_SID'),
        l.lov_type_sid,
        f.CVBT_ENV_OBJ_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVBT_ENV_OBJ f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVBT_ENV_OBJ_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVBT_BGT_ELMT_SID'),
        l.lov_type_sid,
        f.CVBT_BGT_ELMT_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVBT_BGT_ELMT f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVBT_BGT_ELMT_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVBT_PUB_SECT_SID'),
        l.lov_type_sid,
        f.CVBT_PUB_SECT_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVBT_PUB_SECT f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVBT_PUB_SECT_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVEI_ENV_OBJ_SID'),
        l.lov_type_sid,
        f.CVEI_ENV_OBJ_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVEI_ENV_OBJ f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVEI_ENV_OBJ_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVEI_BDGT_ELMT_SID'),
        l.lov_type_sid,
        f.CVEI_BDGT_ELMT_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVEI_BDGT_ELMT f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVEI_BDGT_ELMT_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVEI_PUB_SECT_SID'),
        l.lov_type_sid,
        f.CVEI_PUB_SECT_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVEI_PUB_SECT f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVEI_PUB_SECT_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'MTBT_TA_MTHD_SID'),
        l.lov_type_sid,
        f.MTBT_TA_MTHD_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_MTBT_TA_MTHD f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.MTBT_TA_MTHD_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'MTEI_TA_SID'),
        l.lov_type_sid,
        f.MTEI_TA_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_MTEI_TA f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.MTEI_TA_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'LBGB_LEG_BAS_SID'),
        l.lov_type_sid,
        f.LBGB_LEG_BAS_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_LBGB_LEG_BAS f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.LBGB_LEG_BAS_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'LBTG_STAKE_LD_SID'),
        l.lov_type_sid,
        f.LBTG_STAKE_LD_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_LBTG_STAKE_LD f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.LBTG_STAKE_LD_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'LBTG_STAKE_INV_SID'),
        l.lov_type_sid,
        f.LBTG_STAKE_INV_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_LBTG_STAKE_INV f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.LBTG_STAKE_INV_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'TRAC_RPT_GB_SID'),
        l.lov_type_sid,
        f.TRAC_RPT_GB_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_TRAC_RPT_GB f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.TRAC_RPT_GB_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'TRAC_AC_GBR_SID'),
        l.lov_type_sid,
        f.TRAC_AC_GBR_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_TRAC_AC_GBR f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.TRAC_AC_GBR_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EIEE_SUP_IMPL_SID'),
        l.lov_type_sid,
        f.EIEE_SUP_IMPL_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_EIEE_SUP_IMPL f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.EIEE_SUP_IMPL_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EIEE_CHAL_IMPL_SID'),
        l.lov_type_sid,
        f.EIEE_CHAL_IMPL_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_EIEE_CHAL_IMPL f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.EIEE_CHAL_IMPL_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'EIEE_SUP_EC_SID'),
        l.lov_type_sid,
        f.EIEE_SUP_EC_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_EIEE_SUP_EC f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.EIEE_SUP_EC_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'CVRS_MEAS_GB_SID'),
        l.lov_type_sid,
        f.CVRS_MEAS_GB_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_CVRS_MEAS_GB f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.CVRS_MEAS_GB_SID
    UNION ALL
    SELECT
        4,
        f.entry_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'OTTL_OTHR_TOOL_SID'),
        l.lov_type_sid,
        f.OTTL_OTHR_TOOL_SID,
        f.descr,
        NULL
    FROM
        FGD_GBD_OTTL_OTHR_TOOL f
        LEFT JOIN gbd_lovs               l ON l.lov_sid = f.OTTL_OTHR_TOOL_SID;