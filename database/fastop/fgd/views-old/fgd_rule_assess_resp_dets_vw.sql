CREATE OR REPLACE FORCE VIEW "FGD_RULE_ASSESS_RESP_DETS_VW" (
    "QUESTIONNAIRE_SID",
    "RULE_SID",
    "ROUND_SID",
    "PERIOD_SID",
    "ATTR_SID",
    "RESPONSE_GROUP_SID",
    "RESPONSE_SID",
    "DESCR",
    "NUMERIC_VALUE"
) AS
    SELECT
        1,
        a.rule_sid,
        a.round_sid,
        a.period_sid,
        ld.attr_sid,
        l.lov_type_sid,
        ld.lov_sid,
        ld.descr,
        NULL
    FROM
        fgd_nfr_rule_assess_lov_dets   ld
        JOIN fgd_nfr_rule_assessments       a ON a.rule_assessment_sid = ld.rule_assessment_sid
        LEFT JOIN fgd_nfr_lovs                   l ON l.lov_sid = ld.lov_sid
    UNION ALL
    SELECT
        1,
        a.rule_sid,
        a.round_sid,
        a.period_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'NON_COMPL_SPECIFY_SID'
                AND master_sid IS NULL
        ),
        rc.response_group_sid,
        nc.non_compl_specify_sid,
        nc.descr,
        NULL
    FROM
        fgd_nfr_rule_assess_non_cmpl   nc
        JOIN fgd_nfr_rule_assessments       a ON a.rule_assessment_sid = nc.rule_assessment_sid
        JOIN fgd_cfg_response_choices_vw    rc ON rc.response_sid = nc.non_compl_specify_sid
    UNION ALL
    SELECT
        2,
        a.institution_sid,
        a.round_sid,
        a.period_sid,
        ld.attr_sid,
        l.lov_type_sid,
        ld.lov_sid,
        ld.descr,
        NULL
    FROM
        fgd_ifi_inst_assess_lov_dets   ld
        JOIN fgd_ifi_inst_assessments       a ON a.institution_assessment_sid = ld.institution_assessment_sid
        LEFT JOIN fgd_ifi_lovs                   l ON l.lov_sid = ld.lov_sid
    UNION ALL
    SELECT
        2,
        a.institution_sid,
        a.round_sid,
        a.period_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'FI_OUTPUT_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        ld.fi_output_sid,
        ld.descr,
        NULL
    FROM
        fgd_ifi_inst_fi_output_ass   ld
        JOIN fgd_ifi_inst_assessments     a ON a.institution_assessment_sid = ld.institution_assessment_sid
        LEFT JOIN fgd_ifi_lovs                 l ON l.lov_sid = ld.fi_output_sid
    UNION ALL
    SELECT
        2,
        a.institution_sid,
        a.round_sid,
        a.period_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'PARL_AG_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        ld.parl_ag_sid,
        ld.descr,
        NULL
    FROM
        fgd_ifi_inst_parl_ag_ass   ld
        JOIN fgd_ifi_inst_assessments   a ON a.institution_assessment_sid = ld.institution_assessment_sid
        LEFT JOIN fgd_ifi_lovs               l ON l.lov_sid = ld.parl_ag_sid
    UNION ALL
    SELECT
        2,
        a.institution_sid,
        a.round_sid,
        a.period_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'GOV_REACT_FORM_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        ld.gov_react_form_sid,
        ld.descr,
        NULL
    FROM
        fgd_ifi_inst_gov_react_ass   ld
        JOIN fgd_ifi_inst_assessments     a ON a.institution_assessment_sid = ld.institution_assessment_sid
        LEFT JOIN fgd_ifi_lovs                 l ON l.lov_sid = ld.gov_react_form_sid
    UNION ALL
    SELECT
        3,
        a.frame_sid,
        a.round_sid,
        a.period_sid,
        ld.attr_sid,
        l.lov_type_sid,
        ld.lov_sid,
        ld.descr,
        NULL
    FROM
        fgd_mtbf_frame_assess_lov_dets   ld
        JOIN fgd_mtbf_frame_assessments       a ON a.frame_assessment_sid = ld.frame_assessment_sid
        LEFT JOIN fgd_mtbf_lovs                    l ON l.lov_sid = ld.lov_sid
    UNION ALL
    SELECT
        3,
        a.frame_sid,
        a.round_sid,
        a.period_sid,
        (
            SELECT
                attr_sid
            FROM
                fgd_cfg_attributes
            WHERE
                attr_name = 'R_COR_BUD_SID'
                AND master_sid IS NULL
        ),
        l.lov_type_sid,
        ld.r_cor_bud_sid,
        ld.descr,
        NULL
    FROM
        fgd_mtbf_r_cor_bud_ass       ld
        JOIN fgd_mtbf_frame_assessments   a ON a.frame_assessment_sid = ld.frame_assessment_sid
        LEFT JOIN fgd_mtbf_lovs                l ON l.lov_sid = ld.r_cor_bud_sid;