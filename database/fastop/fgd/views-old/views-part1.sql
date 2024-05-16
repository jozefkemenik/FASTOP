CREATE OR REPLACE FORCE VIEW "FGD_NFR_RULE_DCQ_INST_VW" (
    "RULE_SID",
    "DCQ_INSTITUTION_SID",
    "DESCR"
) AS
    SELECT
        ir.rule_sid,
        ir.institution_sid,
        ir.detail_descr
    FROM
        fgd_nfr_instn_rules         ir
        JOIN fgd_nfr_institution_types   it ON it.institution_type_sid = ir.institution_type_sid
    WHERE
        it.institution_type_id = 'DCQ';

CREATE OR REPLACE FORCE VIEW "FGD_NFR_RULE_EAM_INST_VW" (
    "RULE_SID",
    "EAM_INSTITUTION_SID",
    "DESCR"
) AS
    SELECT
        ir.rule_sid,
        ir.institution_sid,
        ir.detail_descr
    FROM
        fgd_nfr_instn_rules         ir
        JOIN fgd_nfr_institution_types   it ON it.institution_type_sid = ir.institution_type_sid
    WHERE
        it.institution_type_id = 'EAM';

CREATE OR REPLACE FORCE VIEW "FGD_NFR_RULE_EPM_INST_VW" (
    "RULE_SID",
    "EPM_INSTITUTION_SID",
    "DESCR"
) AS
    SELECT
        ir.rule_sid,
        ir.institution_sid,
        ir.detail_descr
    FROM
        fgd_nfr_instn_rules         ir
        JOIN fgd_nfr_institution_types   it ON it.institution_type_sid = ir.institution_type_sid
    WHERE
        it.institution_type_id = 'EPM';

CREATE OR REPLACE FORCE VIEW "FGD_NFR_RULE_ESC_INST_VW" (
    "RULE_SID",
    "ESC_INSTITUTION_SID",
    "DESCR"
) AS
    SELECT
        ir.rule_sid,
        ir.institution_sid,
        ir.detail_descr
    FROM
        fgd_nfr_instn_rules         ir
        JOIN fgd_nfr_institution_types   it ON it.institution_type_sid = ir.institution_type_sid
    WHERE
        it.institution_type_id = 'ESC';

@@../tables/fgd_nfr_rule_dcq_inst_trg.sql

@@../tables/fgd_nfr_rule_eam_inst_trg.sql

@@../tables/fgd_nfr_rule_epm_inst_trg.sql

@@../tables/fgd_nfr_rule_esc_inst_trg.sql

CREATE OR REPLACE FORCE VIEW "FGD_NFR_LOV_LOV_TYPE_VW" (
    "LOV_SID",
    "LOV_TYPE_SID",
    "LOV_DESCR",
    "NEED_DET",
    "ORDER_BY",
    "LOV_TYPE_ID",
    "LOV_TYPE_DESCR"
) AS
    SELECT
        lov.lov_sid,
        lov.lov_type_sid,
        lov.descr        AS lov_descr,
        need_det,
        lov.order_by,
        lov_type.lov_type_id,
        lov_type.descr   AS lov_type_descr
    FROM
        fgd_nfr_lov_types   lov_type,
        fgd_nfr_lovs        lov
    WHERE
        1 = 1
        AND lov.lov_type_sid = lov_type.lov_type_sid;

CREATE OR REPLACE FORCE VIEW "FGD_CFG_QUESTIONNAIRES_VW" (
    "QUESTIONNAIRE_SID",
    "QSTNNR_VERSION_SID",
    "YEAR",
    "QUESTION_SID",
    "QUESTION_TYPE_SID",
    "ATTR_SID",
    "ATTR_TABLE",
    "ATTR_NAME",
    "UPD_ROLES"
) AS
    SELECT DISTINCT
        qn.questionnaire_sid,
        qv.qstnnr_version_sid,
        to_char(sysdate, 'YYYY') - 1 AS year,
        q.question_sid,
        q.question_type_sid,
        a.attr_sid,
        a.attr_table,
        a.attr_name,
        LISTAGG(ur.group_id, ',') WITHIN GROUP(
                ORDER BY
                    ur.group_id
            )
    FROM
        fgd_cfg_questionnaires          qn
        JOIN fgd_cfg_qstnnr_versions         qv ON qv.questionnaire_sid = qn.questionnaire_sid
        JOIN fgd_cfg_qstnnr_ver_sections     qvs ON qvs.qstnnr_version_sid = qv.qstnnr_version_sid
        JOIN (
            SELECT
                qs.qstnnr_section_sid parent_section_sid,
                coalesce(qss.sub_section_sid, qs.qstnnr_section_sid) sub_section_sid
            FROM
                fgd_cfg_qstnnr_sections      qs
                LEFT JOIN fgd_cfg_qstnnr_subsections   qss ON qss.parent_section_sid = qs.qstnnr_section_sid
        ) sec ON sec.parent_section_sid = qvs.qstnnr_section_sid
        JOIN fgd_cfg_qstnnr_sec_attributes   qsa ON qsa.qstnnr_section_sid = sec.sub_section_sid
        JOIN fgd_cfg_attributes              a ON a.attr_sid = qsa.attr_sid
        JOIN fgd_cfg_questions               q ON q.question_sid = a.question_sid
        LEFT JOIN fgd_cfg_attribute_upd_roles     ur ON ur.attr_sid = a.attr_sid
    GROUP BY
        qn.questionnaire_sid,
        qv.qstnnr_version_sid,
        to_char(sysdate, 'YYYY') - 1,
        q.question_sid,
        q.question_type_sid,
        a.attr_sid,
        a.attr_table,
        a.attr_name;


 

CREATE OR REPLACE FORCE VIEW "FGD_NFR_ALL_LOV_VW" (
    "LOV_SID",
    "LOV_TYPE_ID",
    "LOV_DESCR",
    "ORDER_BY"
) AS
    SELECT
        lov_sid,
        lov_type_id,
        lov_descr,
        order_by
    FROM
        fgd_nfr_lov_lov_type_vw
    UNION ALL
    SELECT
        sector_sid,
        'SCT',
        descr,
        order_by
    FROM
        fgd_nfr_sectors
    UNION ALL
    SELECT
        rule_type_sid,
        'TYP',
        descr,
        order_by
    FROM
        fgd_nfr_rule_types
    UNION
    SELECT
        budg_agg_sid,
        'BAGG',
        descr,
        order_by
    FROM
        fgd_nfr_budg_aggs;

CREATE OR REPLACE FORCE VIEW "FGD_RULE_DATE_VALUES_VW" (
    "QUESTIONNAIRE_SID",
    "RULE_SID",
    "ATTRIBUTE",
    "VALUE"
) AS
    SELECT
        "1",
        "RULE_SID",
        "VALUE",
        "ATTR"
    FROM
        (
            SELECT
                1,
                rule_sid,
                apprv_date,
                impl_date,
                abolition_date,
                reform_impl_date,
                reform_adopt_date,
                reform_replaced_date,
                coalesce(reform_impl_date, impl_date) in_force_since
            FROM
                fgd_nfr_rules
        ) UNPIVOT ( attr
            FOR value
        IN ( apprv_date,
             impl_date,
             abolition_date,
             reform_impl_date,
             reform_adopt_date,
             reform_replaced_date,
             in_force_since ) )
    UNION
    SELECT
        "2",
        "INSTITUTION_SID" AS "RULE_SID",
        "VALUE",
        "ATTR"
    FROM
        (
            SELECT
                2,
                institution_sid,                                --Attributes
                estab_date,
                l_ref_date
            FROM
                fgd_ifi_institutions
        ) UNPIVOT ( attr
            FOR value
        IN ( estab_date,
             l_ref_date ) )
    UNION
    SELECT
        "3",
        "FRAME_SID" AS "RULE_SID",
        "VALUE",
        "ATTR"
    FROM
        (
            SELECT
                3,
                frame_sid,                                --Attributes
                mtbf_adop_date,
                entry_date,
                l_ref_entry,
                l_ref_dateM
            FROM
                fgd_mtbf_frames
        ) UNPIVOT ( attr
            FOR value
        IN ( mtbf_adop_date,
             entry_date,
             l_ref_entry,
             l_ref_datem ) );


  
  


CREATE OR REPLACE FORCE VIEW "FGD_RULE_ASS_SID_VALUES_VW" (
    "QUESTIONNAIRE_SID",
    "RULE_SID",
    "ROUND_SID",
    "PERIOD_SID",
    "ATTRIBUTE",
    "VALUE"
) AS
    SELECT
        "1",
        "RULE_SID",
        "ROUND_SID",
        "PERIOD_SID",
        "VALUE",
        "ATTR"
    FROM
        (
            SELECT
                1,
                rule_sid,
                round_sid,
                period_sid                                     -- Attributes
                ,
                compliance_source_sid,
                is_compliant_sid,
                is_escc_triggered_sid,
                is_flex_prov_sid,
                is_in_budget_sid,
                media_cvg_sid,
                perceived_constr_sid
            FROM
                fgd_nfr_rule_assessments
        ) UNPIVOT ( attr
            FOR value
        IN ( compliance_source_sid,
             is_compliant_sid,
             is_escc_triggered_sid,
             is_flex_prov_sid,
             is_in_budget_sid,
             media_cvg_sid,
             perceived_constr_sid ) )
    UNION ALL
    SELECT
        "2",
        "INSTITUTION_SID",
        "ROUND_SID",
        "PERIOD_SID",
        "VALUE",
        "ATTR"
    FROM
        (
            SELECT
                2,
                institution_sid,
                round_sid,
                period_sid                                     -- Attributes
                ,
                ext_revws_sid,
                info_acc_prob_sid,
                parl_he_sid,
                parl_qu_sid,
                press_rel_sid,
                press_conf_sid,
                media_intvws_sid,
                press_art_sid,
                funding_adeq_sid,
                dialg_prev_sid,
                gov_react_time_sid,
                media_echo_sid,
                polic_asess_resp_sid,
                recom_compl_gov_sid
            FROM
                fgd_ifi_inst_assessments
        ) UNPIVOT ( attr
            FOR value
        IN ( ext_revws_sid,
             info_acc_prob_sid,
             parl_he_sid,
             parl_qu_sid,
             press_rel_sid,
             press_conf_sid,
             media_intvws_sid,
             press_art_sid,
             funding_adeq_sid,
             dialg_prev_sid,
             gov_react_time_sid,
             media_echo_sid,
             polic_asess_resp_sid,
             recom_compl_gov_sid ) )
    UNION ALL
    SELECT
        "3",
        "FRAME_SID",
        "ROUND_SID",
        "PERIOD_SID",
        "VALUE",
        "ATTR"
    FROM
        (
            SELECT
                3,
                frame_sid,
                round_sid,
                period_sid                                     -- Attributes
                ,
                obj_compl_prep_18_sid,
                obj_compl_exe_18_sid,
                body_main_monitor_sid,
                mech_corr_dev_bl_sid,
                corr_mes_trig_19_sid,
                corr_budget_19_sid,
                upd_forec_rev_budg_sid
            FROM
                fgd_mtbf_frame_assessments
        ) UNPIVOT ( attr
            FOR value
        IN ( obj_compl_prep_18_sid,
             obj_compl_exe_18_sid,
             body_main_monitor_sid,
             mech_corr_dev_bl_sid,
             corr_mes_trig_19_sid,
             corr_budget_19_sid,
             upd_forec_rev_budg_sid ) );

CREATE OR REPLACE FORCE VIEW "FGD_RULE_ASS_TEXT_VALUES_VW" (
    "QUESTIONNAIRE_SID",
    "RULE_SID",
    "ROUND_SID",
    "PERIOD_SID",
    "TEXT_NO",
    "ATTRIBUTE",
    "VALUE"
) AS
    SELECT
        "1",
        "RULE_SID",
        "ROUND_SID",
        "PERIOD_SID",
        "NULL--ATTRIBUTES",
        "VALUE",
        "ATTR"
    FROM
        (
            SELECT
                1,
                rule_sid,
                round_sid,
                period_sid,
                NULL                                           -- Attributes
                ,
                add_info,
                budg_prep_impact,
                cust_datasource,
                cust_link,
                cust_reason,
                non_compl_specify
            FROM
                fgd_nfr_rule_assessments
        ) UNPIVOT ( attr
            FOR value
        IN ( add_info,
             budg_prep_impact,
             cust_datasource,
             cust_link,
             cust_reason,
             non_compl_specify ) )
    UNION ALL
    SELECT
        1,
        a.rule_sid,
        a.round_sid,
        a.period_sid,
        od.other_doc_no,
        'OTHER_DOC_NO',
        od.descr
    FROM
        fgd_nfr_rule_assess_oth_docs   od
        JOIN fgd_nfr_rule_assessments       a ON a.rule_assessment_sid = od.rule_assessment_sid
    UNION ALL
    SELECT
        "2",
        "INSTITUTION_SID",
        "ROUND_SID",
        "PERIOD_SID",
        "NULL--ATTRIBUTES",
        "VALUE",
        "ATTR"
    FROM
        (
            SELECT
                2,
                institution_sid,
                round_sid,
                period_sid,
                NULL                                           -- Attributes
                ,
                compl_reps,
                ext_revws_desc,
                staff_man,
                staff_eco,
                staff_legal,
                staff_adm,
                staff_total,
                staff_others,
                opt_clarif,
                budg_appr_prev,
                budg_appr_act,
                budg_appr_curr,
                ex_pol_cost,
                ex_long_term,
                ex_research,
                ex_transp_ini,
                reaction_links,
                episode_brief
            FROM
                fgd_ifi_inst_assessments
        ) UNPIVOT ( attr
            FOR value
        IN ( compl_reps,
             ext_revws_desc,
             staff_man,
             staff_eco,
             staff_legal,
             staff_adm,
             staff_total,
             staff_others,
             opt_clarif,
             budg_appr_prev,
             budg_appr_act,
             budg_appr_curr,
             ex_pol_cost,
             ex_long_term,
             ex_research,
             ex_transp_ini,
             reaction_links,
             episode_brief ) );



