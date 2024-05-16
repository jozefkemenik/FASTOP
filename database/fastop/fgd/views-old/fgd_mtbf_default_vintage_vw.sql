CREATE OR REPLACE VIEW FGD_MTBF_DEFAULT_VINTAGE_VW as
SELECT
    DISTINCT 
    R.COUNTRY_ID,
    fgd_cfg_accessors.getattributevintagetext('LB_DOCS_SID', r.frame_sid, 3)||' ' as LB_DOCS_SID,
    fgd_cfg_accessors.getattributevintagetext('MT_PL_DOC_LAW_SID', r.frame_sid, 3)||' ' as MT_PL_DOC_LAW_SID,
    fgd_cfg_accessors.getattributevintagetext('LB_BUDGET_SID', r.frame_sid, 3)||' ' as LB_BUDGET_SID,
    fgd_cfg_accessors.getattributevintagetext('MT_PL_DOC_PRAC_SID', r.frame_sid, 3)||' ' as MT_PL_DOC_PRAC_SID,
    fgd_cfg_accessors.getattributevintagetext('TIMEFRAME_MTBF_SID', r.frame_sid, 3)||' ' as TIMEFRAME_MTBF_SID,
    fgd_cfg_accessors.getattributevintagetext('TARGET_BIND_SID', r.frame_sid, 3)||' ' as TARGET_BIND_SID,
    fgd_cfg_accessors.getattributevintagetext('TARGET_REVIS_SID', r.frame_sid, 3)||' ' as TARGET_REVIS_SID,
    fgd_cfg_accessors.getattributevintagetext('SEC_COV_MTBF_TARG_SID', r.frame_sid, 3)||' ' as SEC_COV_MTBF_TARG_SID,
    fgd_cfg_accessors.getattributevintagetext('MTBF_SHARE_GG_SID', r.frame_sid, 3)||' ' as MTBF_SHARE_GG_SID,
    fgd_cfg_accessors.getattributevintagetext('COORD_MECH_INVOLVE_SID', r.frame_sid, 3)||' ' as COORD_MECH_INVOLVE_SID,
    fgd_cfg_accessors.getattributevintagetext('TARGET_VARIABLES_SID', r.frame_sid, 3)||' ' as TARGET_VARIABLES_SID,
    fgd_cfg_accessors.getattributevintagetext('MF_AGG_BUDG_PROC_SID', r.frame_sid, 3)||' ' as MF_AGG_BUDG_PROC_SID,
    fgd_cfg_accessors.getattributevintagetext('POL_SCENE_SID', r.frame_sid, 3)||' ' as POL_SCENE_SID,
    fgd_cfg_accessors.getattributevintagetext('POLICY_IMPACT_SID', r.frame_sid, 3)||' ' as POLICY_IMPACT_SID,
    fgd_cfg_accessors.getattributevintagetext('FP_ADOPT_ANBUD_SID', r.frame_sid, 3)||' ' as FP_ADOPT_ANBUD_SID,
    fgd_cfg_accessors.getattributevintagetext('BO_CONN_ANBUD_SID', r.frame_sid, 3)||' ' as BO_CONN_ANBUD_SID,
    fgd_cfg_accessors.getattributevintagetext('IFI_INVOLVE_SID', r.frame_sid, 3)||' ' as IFI_INVOLVE_SID,
    fgd_cfg_accessors.getattributevintagetext('PARL_INVOLVE_SID', r.frame_sid, 3)||' ' as PARL_INVOLVE_SID,
    fgd_cfg_accessors.getattributevintagetext('EXA_BUDG_COMPL_SID', r.frame_sid, 3)||' ' as EXA_BUDG_COMPL_SID,
    fgd_cfg_accessors.getattributevintagetext('EXP_BUDG_COMPL_SID', r.frame_sid, 3)||' ' as EXP_BUDG_COMPL_SID,
    fgd_cfg_accessors.getattributevintagetext('CORR_ACT_DEVIATE_SID', r.frame_sid, 3)||' ' as CORR_ACT_DEVIATE_SID
FROM fgd_mtbf_frames r
    JOIN fgd_mtbf_frame_edit_steps res ON r.frame_sid = res.frame_sid
    JOIN fgd_cfg_edit_steps         es ON res.edit_step_sid = es.edit_step_sid
    LEFT JOIN fgd_mtbf_frame_assessments ra ON r.frame_sid = ra.frame_sid
    WHERE res.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
      and ra.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1);