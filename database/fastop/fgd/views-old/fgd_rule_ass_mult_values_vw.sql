CREATE OR REPLACE FORCE VIEW "FGD_RULE_ASS_MULT_VALUES_VW" (
    "QUESTIONNAIRE_SID",
    "RULE_SID",
    "ROUND_SID",
    "PERIOD_SID",
    "ATTRIBUTE",
    "VALUE",
    "RESPONSE_GROUP_SID"
) AS
    SELECT
        1,
        ra.rule_sid,
        ra.round_sid,
        ra.period_sid,
        'REF_FMT_SID',
        rf.ref_fmt_sid,
        rc.response_group_sid
    FROM
        fgd_nfr_rule_assess_ref_fmts   rf
        JOIN fgd_nfr_rule_assessments       ra ON ra.rule_assessment_sid = rf.rule_assessment_sid
        JOIN fgd_cfg_response_choices_vw    rc ON rc.response_sid = rf.ref_fmt_sid
    UNION ALL
    SELECT
        1,
        ra.rule_sid,
        ra.round_sid,
        ra.period_sid,
        'NON_COMPL_SPECIFY_SID',
        nc.non_compl_specify_sid,
        rc.response_group_sid
    FROM
        fgd_nfr_rule_assess_non_cmpl   nc
        JOIN fgd_nfr_rule_assessments       ra ON ra.rule_assessment_sid = nc.rule_assessment_sid
        JOIN fgd_cfg_response_choices_vw    rc ON rc.response_sid = nc.non_compl_specify_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'FI_OUTPUT_SID',
        ifo.fi_output_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_fi_output_ass    ifo
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = ifo.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = ifo.fi_output_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'INFO_DOM1_SID',
        id1.info_dom1_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_info_dom1_ass    id1
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = id1.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = id1.info_dom1_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'INFO_DOM2_SID',
        id2.info_dom2_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_info_dom2_ass    id2
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = id2.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = id2.info_dom2_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'INFO_DOM3_SID',
        id3.info_dom3_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_info_dom3_ass    id3
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = id3.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = id3.info_dom3_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'INFO_DOM4_SID',
        id4.info_dom4_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_info_dom4_ass    id4
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = id4.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = id4.info_dom4_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'INFO_DOM5_SID',
        id5.info_dom5_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_info_dom5_ass    id5
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = id5.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = id5.info_dom5_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'INFO_DOM6_SID',
        id6.info_dom6_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_info_dom6_ass    id6
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = id6.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = id6.info_dom6_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'INFO_DOM7_SID',
        id7.info_dom7_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_info_dom7_ass    id7
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = id7.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = id7.info_dom7_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'INFO_DOM8_SID',
        id8.info_dom8_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_info_dom8_ass    id8
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = id8.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = id8.info_dom8_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'PARL_AG_SID',
        ipa.parl_ag_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_parl_ag_ass      ipa
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = ipa.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = ipa.parl_ag_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'GOV_REACT_FORM_SID',
        igr.gov_react_form_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_gov_react_ass    igr
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = igr.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = igr.gov_react_form_sid
    UNION ALL
    SELECT
        2,
        ia.institution_sid,
        ia.round_sid,
        ia.period_sid,
        'DOM_NAT_SID',
        idn.dom_nat_sid,
        rc.response_group_sid
    FROM
        fgd_ifi_inst_dom_nat_ass      idn
        JOIN fgd_ifi_inst_assessments      ia ON ia.institution_assessment_sid = idn.institution_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = idn.dom_nat_sid
    UNION ALL
    SELECT
        3,
        ia.frame_sid,
        ia.round_sid,
        ia.period_sid,
        'R_COR_BUD_SID',
        idn.r_cor_bud_sid,
        rc.response_group_sid
    FROM
        fgd_mtbf_r_cor_bud_ass        idn
        JOIN fgd_mtbf_frame_assessments    ia ON ia.frame_assessment_sid = idn.frame_assessment_sid
        JOIN fgd_cfg_response_choices_vw   rc ON rc.response_sid = idn.r_cor_bud_sid;