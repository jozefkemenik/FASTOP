
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_IFI_CURRENT_VINTAGE_VW" ("COUNTRY_ID", "ORIG_NAME", "ORIG_ABRV", "ENG_NAME", "ENG_ABRV", "ESTAB_DATE", "L_REF_DATE", "REF_REASON", "ABOL_REASON", "LAW_TYPE_SID", "LEGAL_STATUS", "INST_SUP", "ORG_FUNCT_SID", "PREC_REF_ESTAB", "PREC_REF_FUNCT", "ANN_PROGRAM", "COMM_FREE_SID", "CONTR_ARR_FREE_SID", "RECR_AUTO_SID", "DRAFT_ACCESS_SID", "NPI_ACCESS_SID", "LBI_ACCESS_SID", "POLY_PRACTICE_SID", "POLY_LEGAL_SID", "POLY_ADD_INFO", "FUND_ARR_DESC", "FUND_GROUND_SID", "PROCS_FUNDS_SID", "FIN_SOURCES_SID", "COST_PROPORTION", "FIN_AUTO_SID", "BOARD_SIZE", "BOARD_COMP", "BOARD_SELECT", "SELECT_GROUND_SID", "BOARD_CV", "BOARD_MANDATE", "MANDATE_RENEW_SID", "RENEW_TIMES_SID", "SIM_MEMBERS_SID", "STAG_DESCR", "BOARD_POLITIC_SID", "BOARD_PUBLIC_SID", "BOARD_LIMITS_SID", "DECISN_ADOPT_SID", "PRESIDENT_SID", "PRESIDENT_POWERS", "STAFF_SELECT_PROC", "ADVIS_BOARD_SID", "ADVIS_BOARD_DETS", "OCCUP_LIMIT_SID", "BASIS_EXAA", "BASIS_EXPA", "RULE_MON_INST_SID", "TIME_COMP_ASSESS_SID", "INST_CORR_MECH_SID", "TRIG_ESCC_MON", "ADD_INFO_MON", "ANBUD_BASIS_MACRO_SID", "ANBUD_SECTOR_MACRO_SID", "ANBUD_TASK_MACRO_SID", "ANBUD_RECONC_SID", "ANBUD_DOC_FRAME", "ANBUD_PREP_ROLE_SID", "EXP_EVAL_MACRO_SID", "FOREC_LNK_MACRO", "LT_PROJ_MACRO_SID", "PROJ_MACRO_DESCR", "PROJ_MACRO_TIME", "FOREC_FISC_PLAN_SID", "ADD_INFO_MACRO", "BASIS_BUDG_SID", "SECTOR_BUDG_SID", "VARIABLE_SID", "TASK_BUDG_SID", "QUANT_OPINION_SID", "ROLE_BUDG_SID", "EXP_EVAL_BUDG_SID", "FOREC_LNK_BUDG", "LT_PROJ_BUDG_SID", "PROJ_BUDG_DESCR", "PROJ_BUDG_TIME", "FOREC_FISCP_SID", "FOREC_INVOLV", "ADD_INFO_BUDG", "BASIS_NORM_SID", "ACTIVS_NORMS_SID", "GOV_INTERACT_SID", "PARL_INTERACT_SID", "DRAFT_TOPICS_SID", "IMPLEM_TOPICS_SID", "BASIS_SUSTAIN_SID", "BASIS_QUANTIF_SID", "BASIS_TRANSP_SID", "OTHER_TASK_INST_SID", "MANDATE_BEYOND_SID", "FI_OUTPUT_SID", "COMPL_REPS", "EXT_REVWS_SID", "EXT_REVWS_DESC", "STAFF_MAN", "STAFF_ECO", "STAFF_LEGAL", "STAFF_ADM", "STAFF_TOTAL", "STAFF_OTHERS", "INFO_ACC_PROB_SID", "DOM_NAT_SID", "INFO_DOM1_SID", "INFO_DOM2_SID", "INFO_DOM3_SID", "INFO_DOM4_SID", "INFO_DOM5_SID", "INFO_DOM6_SID", "INFO_DOM7_SID", "INFO_DOM8_SID", "OPT_CLARIF", "PARL_AG_SID", "PARL_HE_SID", "PARL_QU_SID", "PRESS_REL_SID", "PRESS_CONF_SID", "MEDIA_INTVWS_SID", "PRESS_ART_SID", "BUDG_APPR_PREV", "BUDG_APPR_ACT", "BUDG_APPR_CURR", "FUNDING_ADEQ_SID", "EX_POL_COST", "EX_LONG_TERM", "EX_RESEARCH", "EX_TRANSP_INI", "DIALG_PREV_SID", "REACTION_LINKS", "GOV_REACT_TIME_SID", "GOV_REACT_FORM_SID", "MEDIA_ECHO_SID", "POLIC_ASESS_RESP_SID", "RECOM_COMPL_GOV_SID", "EPISODE_BRIEF") AS 
  SELECT      distinct                                           
        r.country_id,
        r.orig_name,
        r.orig_abrv,
        r.eng_name,
        r.eng_abrv,
        to_char(r.estab_date, 'YYYY-MM-DD') as estab_date,
        to_char(r.l_ref_date, 'YYYY-MM-DD') as l_ref_date,
        r.ref_reason,
        r.abol_reason,
        fgd_cfg_accessors.getattributevintagetext('LAW_TYPE_SID', r.institution_sid, 2)
        || ' ' AS law_type_sid,
        fgd_cfg_accessors.getattributevintagetext('LEGAL_STATUS', r.institution_sid, 2)
        || ' ' AS legal_status,
        r.inst_sup,
        fgd_cfg_accessors.getattributevintagetext('ORG_FUNCT_SID', r.institution_sid, 2)
        || ' ' AS org_funct_sid,
        r.prec_ref_estab,
        r.prec_ref_funct,
        r.ann_program,
        fgd_cfg_accessors.getattributevintagetext('COMM_FREE_SID', r.institution_sid, 2)
        || ' ' AS comm_free_sid,
        fgd_cfg_accessors.getattributevintagetext('CONTR_ARR_FREE_SID', r.institution_sid, 2)
        || ' ' AS contr_arr_free_sid,
        fgd_cfg_accessors.getattributevintagetext('RECR_AUTO_SID', r.institution_sid, 2)
        || ' ' AS recr_auto_sid,
        fgd_cfg_accessors.getattributevintagetext('DRAFT_ACCESS_SID', r.institution_sid, 2)
        || ' ' AS draft_access_sid,
        fgd_cfg_accessors.getattributevintagetext('NPI_ACCESS_SID', r.institution_sid, 2)
        || ' ' AS npi_access_sid,
        fgd_cfg_accessors.getattributevintagetext('LBI_ACCESS_SID', r.institution_sid, 2)
        || ' ' AS lbi_access_sid,
        fgd_cfg_accessors.getattributevintagetext('POLY_PRACTICE_SID', r.institution_sid, 2)
        || ' ' AS poly_practice_sid,
        fgd_cfg_accessors.getattributevintagetext('POLY_LEGAL_SID', r.institution_sid, 2)
        || ' ' AS poly_legal_sid,
        r.poly_add_info,
        r.fund_arr_desc,
        fgd_cfg_accessors.getattributevintagetext('FUND_GROUND_SID', r.institution_sid, 2)
        || ' ' AS fund_ground_sid,
        fgd_cfg_accessors.getattributevintagetext('PROCS_FUNDS_SID', r.institution_sid, 2) AS procs_funds_sid,
        fgd_cfg_accessors.getattributevintagetext('FIN_SOURCES_SID', r.institution_sid, 2)
        || ' ' AS fin_sources_sid,
        r.cost_proportion,
        fgd_cfg_accessors.getattributevintagetext('FIN_AUTO_SID', r.institution_sid, 2)
        || ' ' AS fin_auto_sid,
        r.board_size,
        r.board_comp,
        r.board_select,
        fgd_cfg_accessors.getattributevintagetext('SELECT_GROUND_SID', r.institution_sid, 2)
        || ' ' AS select_ground_sid,
        r.board_cv,
        r.board_mandate,
        fgd_cfg_accessors.getattributevintagetext('MANDATE_RENEW_SID', r.institution_sid, 2)
        || ' ' AS mandate_renew_sid,
        fgd_cfg_accessors.getattributevintagetext('RENEW_TIMES_SID', r.institution_sid, 2)
        || ' ' AS renew_times_sid,
        fgd_cfg_accessors.getattributevintagetext('SIM_MEMBERS_SID', r.institution_sid, 2)
        || ' ' AS sim_members_sid,
        r.stag_descr,
        fgd_cfg_accessors.getattributevintagetext('BOARD_POLITIC_SID', r.institution_sid, 2)
        || ' ' AS board_politic_sid,
        fgd_cfg_accessors.getattributevintagetext('BOARD_PUBLIC_SID', r.institution_sid, 2)
        || ' ' AS board_public_sid,
        fgd_cfg_accessors.getattributevintagetext('BOARD_LIMITS_SID', r.institution_sid, 2)
        || ' ' AS board_limits_sid,
        fgd_cfg_accessors.getattributevintagetext('DECISN_ADOPT_SID', r.institution_sid, 2)
        || ' ' AS decisn_adopt_sid,
        fgd_cfg_accessors.getattributevintagetext('PRESIDENT_SID', r.institution_sid, 2)
        || ' ' AS president_sid,
        r.president_powers,
        r.staff_select_proc,
        fgd_cfg_accessors.getattributevintagetext('ADVIS_BOARD_SID', r.institution_sid, 2)
        || ' ' AS advis_board_sid,
        r.advis_board_dets,
        fgd_cfg_accessors.getattributevintagetext('OCCUP_LIMIT_SID', r.institution_sid, 2)
        || ' ' AS occup_limit_sid,
        fgd_cfg_accessors.getattributevintagetext('BASIS_EXAA', r.institution_sid, 2)
        || ' ' AS basis_exaa,
        fgd_cfg_accessors.getattributevintagetext('BASIS_EXPA', r.institution_sid, 2)
        || ' ' AS basis_expa,
        fgd_cfg_accessors.getattributevintagetext('RULE_MON_INST_SID', r.institution_sid, 2)
        || ' ' AS rule_mon_inst_sid,
        fgd_cfg_accessors.getattributevintagetext('TIME_COMP_ASSESS_SID', r.institution_sid, 2)
        || ' ' AS time_comp_assess_sid,
        fgd_cfg_accessors.getattributevintagetext('INST_CORR_MECH_SID', r.institution_sid, 2)
        || ' ' AS inst_corr_mech_sid,
        fgd_cfg_accessors.getattributevintagetext('TRIG_ESCC_MON', r.institution_sid, 2)
        || ' ' AS trig_escc_mon,
        r.add_info_mon,
        fgd_cfg_accessors.getattributevintagetext('ANBUD_BASIS_MACRO_SID', r.institution_sid, 2)
        || ' ' AS anbud_basis_macro_sid,
        fgd_cfg_accessors.getattributevintagetext('ANBUD_SECTOR_MACRO_SID', r.institution_sid, 2)
        || ' ' AS anbud_sector_macro_sid,
        fgd_cfg_accessors.getattributevintagetext('ANBUD_TASK_MACRO_SID', r.institution_sid, 2) AS anbud_task_macro_sid,
        fgd_cfg_accessors.getattributevintagetext('ANBUD_RECONC_SID', r.institution_sid, 2)
        || ' ' AS anbud_reconc_sid,
        r.anbud_doc_frame,
        fgd_cfg_accessors.getattributevintagetext('ANBUD_PREP_ROLE_SID', r.institution_sid, 2)
        || ' ' AS anbud_prep_role_sid,
        fgd_cfg_accessors.getattributevintagetext('EXP_EVAL_MACRO_SID', r.institution_sid, 2)
        || ' ' AS exp_eval_macro_sid,
        r.forec_lnk_macro,
        fgd_cfg_accessors.getattributevintagetext('LT_PROJ_MACRO_SID', r.institution_sid, 2)
        || ' ' AS lt_proj_macro_sid,
        r.proj_macro_descr,
        r.proj_macro_time,
        fgd_cfg_accessors.getattributevintagetext('FOREC_FISC_PLAN_SID', r.institution_sid, 2)
        || ' ' AS forec_fisc_plan_sid,
        r.add_info_macro,
        fgd_cfg_accessors.getattributevintagetext('BASIS_BUDG_SID', r.institution_sid, 2)
        || ' ' AS basis_budg_sid,
        fgd_cfg_accessors.getattributevintagetext('SECTOR_BUDG_SID', r.institution_sid, 2)
        || ' ' AS sector_budg_sid,
        fgd_cfg_accessors.getattributevintagetext('VARIABLE_SID', r.institution_sid, 2)
        || ' ' AS variable_sid,
        fgd_cfg_accessors.getattributevintagetext('TASK_BUDG_SID', r.institution_sid, 2)
        || ' ' AS task_budg_sid,
        fgd_cfg_accessors.getattributevintagetext('QUANT_OPINION_SID', r.institution_sid, 2)
        || ' ' AS quant_opinion_sid,
        fgd_cfg_accessors.getattributevintagetext('ROLE_BUDG_SID', r.institution_sid, 2)
        || ' ' AS role_budg_sid,
        fgd_cfg_accessors.getattributevintagetext('EXP_EVAL_BUDG_SID', r.institution_sid, 2)
        || ' ' AS exp_eval_budg_sid,
        r.forec_lnk_budg,
        fgd_cfg_accessors.getattributevintagetext('LT_PROJ_BUDG_SID', r.institution_sid, 2)
        || ' ' AS lt_proj_budg_sid,
        r.proj_budg_descr,
        r.proj_budg_time,
        fgd_cfg_accessors.getattributevintagetext('FOREC_FISCP_SID', r.institution_sid, 2)
        || ' ' AS forec_fiscp_sid,
        r.forec_involv,
        r.add_info_budg,
        fgd_cfg_accessors.getattributevintagetext('BASIS_NORM_SID', r.institution_sid, 2)
        || ' ' AS basis_norm_sid,
        fgd_cfg_accessors.getattributevintagetext('ACTIVS_NORMS_SID', r.institution_sid, 2)
        || ' ' AS activs_norms_sid,
        fgd_cfg_accessors.getattributevintagetext('GOV_INTERACT_SID', r.institution_sid, 2)
        || ' ' AS gov_interact_sid,
        fgd_cfg_accessors.getattributevintagetext('PARL_INTERACT_SID', r.institution_sid, 2)
        || ' ' AS parl_interact_sid,
        fgd_cfg_accessors.getattributevintagetext('DRAFT_TOPICS_SID', r.institution_sid, 2)
        || ' ' AS draft_topics_sid,
        fgd_cfg_accessors.getattributevintagetext('IMPLEM_TOPICS_SID', r.institution_sid, 2)
        || ' ' AS implem_topics_sid,
        fgd_cfg_accessors.getattributevintagetext('BASIS_SUSTAIN_SID', r.institution_sid, 2)
        || ' ' AS basis_sustain_sid,
        fgd_cfg_accessors.getattributevintagetext('BASIS_QUANTIF_SID', r.institution_sid, 2)
        || ' ' AS basis_quantif_sid,
        fgd_cfg_accessors.getattributevintagetext('BASIS_TRANSP_SID', r.institution_sid, 2)
        || ' ' AS basis_transp_sid,
        fgd_cfg_accessors.getattributevintagetext('OTHER_TASK_INST_SID', r.institution_sid, 2)
        || ' ' AS other_task_inst_sid,
        fgd_cfg_accessors.getattributevintagetext('MANDATE_BEYOND_SID', r.institution_sid, 2)
        || ' ' AS mandate_beyond_sid,
        fgd_cfg_accessors.getattributevintagetext('FI_OUTPUT_SID', r.institution_sid, 2)
        || ' ' AS fi_output_sid,
        ifa.compl_reps,
        fgd_cfg_accessors.getattributevintagetext('EXT_REVWS_SID', r.institution_sid, 2)
        || ' ' AS ext_revws_sid,
        ifa.ext_revws_desc,
        ifa.staff_man,
        ifa.staff_eco,
        ifa.staff_legal,
        ifa.staff_adm,
        ifa.staff_total,
        ifa.staff_others,
        fgd_cfg_accessors.getattributevintagetext('INFO_ACC_PROB_SID', r.institution_sid, 2)
        || ' ' AS info_acc_prob_sid,
        fgd_cfg_accessors.getattributevintagetext('DOM_NAT_SID', r.institution_sid, 2)
        || ' ' AS dom_nat_sid,
        fgd_cfg_accessors.getattributevintagetext('INFO_DOM1_SID', r.institution_sid, 2)
        || ' ' AS info_dom1_sid,
        fgd_cfg_accessors.getattributevintagetext('INFO_DOM2_SID', r.institution_sid, 2)
        || ' ' AS info_dom2_sid,
        fgd_cfg_accessors.getattributevintagetext('INFO_DOM3_SID', r.institution_sid, 2)
        || ' ' AS info_dom3_sid,
        fgd_cfg_accessors.getattributevintagetext('INFO_DOM4_SID', r.institution_sid, 2)
        || ' ' AS info_dom4_sid,
        fgd_cfg_accessors.getattributevintagetext('INFO_DOM5_SID', r.institution_sid, 2)
        || ' ' AS info_dom5_sid,
        fgd_cfg_accessors.getattributevintagetext('INFO_DOM6_SID', r.institution_sid, 2)
        || ' ' AS info_dom6_sid,
        fgd_cfg_accessors.getattributevintagetext('INFO_DOM7_SID', r.institution_sid, 2)
        || ' ' AS info_dom7_sid,
        fgd_cfg_accessors.getattributevintagetext('INFO_DOM8_SID', r.institution_sid, 2)
        || ' ' AS info_dom8_sid,
        ifa.opt_clarif,
        fgd_cfg_accessors.getattributevintagetext('PARL_AG_SID', r.institution_sid, 2)
        || ' ' AS parl_ag_sid,
        fgd_cfg_accessors.getattributevintagetext('PARL_HE_SID', r.institution_sid, 2)
        || ' ' AS parl_he_sid,
        fgd_cfg_accessors.getattributevintagetext('PARL_QU_SID', r.institution_sid, 2)
        || ' ' AS parl_qu_sid,
        fgd_cfg_accessors.getattributevintagetext('PRESS_REL_SID', r.institution_sid, 2)
        || ' ' AS press_rel_sid,
        fgd_cfg_accessors.getattributevintagetext('PRESS_CONF_SID', r.institution_sid, 2)
        || ' ' AS press_conf_sid,
        fgd_cfg_accessors.getattributevintagetext('MEDIA_INTVWS_SID', r.institution_sid, 2) media_intvws_sid,
        fgd_cfg_accessors.getattributevintagetext('PRESS_ART_SID', r.institution_sid, 2)
        || ' ' AS press_art_sid,
        ifa.budg_appr_prev,
        ifa.budg_appr_act,
        ifa.budg_appr_curr,
        fgd_cfg_accessors.getattributevintagetext('FUNDING_ADEQ_SID', r.institution_sid, 2)
        || ' ' AS funding_adeq_sid,
        ifa.ex_pol_cost,
        ifa.ex_long_term,
        ifa.ex_research,
        ifa.ex_transp_ini,
        fgd_cfg_accessors.getattributevintagetext('DIALG_PREV_SID', r.institution_sid, 2)
        || ' ' AS dialg_prev_sid,
        ifa.reaction_links,
        fgd_cfg_accessors.getattributevintagetext('GOV_REACT_TIME_SID', r.institution_sid, 2)
        || ' ' AS gov_react_time_sid,
        fgd_cfg_accessors.getattributevintagetext('GOV_REACT_FORM_SID', r.institution_sid, 2)
        || ' ' AS gov_react_form_sid,
        fgd_cfg_accessors.getattributevintagetext('MEDIA_ECHO_SID', r.institution_sid, 2)
        || ' ' AS media_echo_sid,
        fgd_cfg_accessors.getattributevintagetext('POLIC_ASESS_RESP_SID', r.institution_sid, 2)
        || ' ' AS polic_asess_resp_sid,
        fgd_cfg_accessors.getattributevintagetext('RECOM_COMPL_GOV_SID', r.institution_sid, 2)
        || ' ' AS recom_compl_gov_sid,
        ifa.episode_brief
    FROM
        fgd_ifi_institutions       r
        JOIN fgd_ifi_inst_edit_steps    res ON r.institution_sid = res.institution_sid
        JOIN fgd_cfg_edit_steps         es ON res.edit_step_sid = es.edit_step_sid
        LEFT JOIN fgd_ifi_inst_assessments   ifa ON r.institution_sid = ifa.institution_sid
        
    WHERE res.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
          and ifa.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1);
