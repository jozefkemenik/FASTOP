CREATE OR REPLACE VIEW FGD_GBD_DEFAULT_VINTAGE_VW AS
SELECT
    DISTINCT 
    R.COUNTRY_ID,
    fgd_cfg_accessors.getattributevintagetext('GEN_IN_PLACE_SID', r.entry_sid, 4)||' ' as GEN_IN_PLACE_SID,
    fgd_cfg_accessors.getattributevintagetext('GEN_PLANS_INTRO_SID', r.entry_sid, 4)||' ' as GEN_PLANS_INTRO_SID,
    fgd_cfg_accessors.getattributevintagetext('GEN_FTHR_DEV_SID', r.entry_sid, 4)||' ' as GEN_FTHR_DEV_SID,
    fgd_cfg_accessors.getattributevintagetext('GEN_MOTIV_SID', r.entry_sid, 4)||' ' as GEN_MOTIV_SID,
    fgd_cfg_accessors.getattributevintagetext('CVLT_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVLT_ENV_OBJ_SID,
    fgd_cfg_accessors.getattributevintagetext('CVLT_BDGT_ELMT_SID', r.entry_sid, 4)||' ' as CVLT_BDGT_ELMT_SID,
    fgd_cfg_accessors.getattributevintagetext('CVLT_PUB_SECT_SID', r.entry_sid, 4)||' ' as CVLT_PUB_SECT_SID,
    r.CVLT_SB_COV ,
    fgd_cfg_accessors.getattributevintagetext('CVBT_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVBT_ENV_OBJ_SID,
    fgd_cfg_accessors.getattributevintagetext('CVBT_BGT_ELMT_SID', r.entry_sid, 4)||' ' as CVBT_BGT_ELMT_SID,
    fgd_cfg_accessors.getattributevintagetext('CVBT_PUB_SECT_SID', r.entry_sid, 4)||' ' as CVBT_PUB_SECT_SID,
    r.CVBT_SB_TAG ,
    fgd_cfg_accessors.getattributevintagetext('CVEI_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVEI_ENV_OBJ_SID,
    fgd_cfg_accessors.getattributevintagetext('CVEI_BDGT_ELMT_SID', r.entry_sid, 4)||' ' as CVEI_BDGT_ELMT_SID,
    fgd_cfg_accessors.getattributevintagetext('CVEI_PUB_SECT_SID', r.entry_sid, 4)||' ' as CVEI_PUB_SECT_SID,
    fgd_cfg_accessors.getattributevintagetext('MTBT_TAG_MTHD_SID', r.entry_sid, 4)||' ' as MTBT_TAG_MTHD_SID,
    fgd_cfg_accessors.getattributevintagetext('LBGB_CTRY_STRAT_SID', r.entry_sid, 4)||' ' as LBGB_CTRY_STRAT_SID,
    fgd_cfg_accessors.getattributevintagetext('LBGB_LEG_BAS_SID', r.entry_sid, 4)||' ' as LBGB_LEG_BAS_SID,
    fgd_cfg_accessors.getattributevintagetext('LBTG_STAKE_LD_SID', r.entry_sid, 4)||' ' as LBTG_STAKE_LD_SID,
    fgd_cfg_accessors.getattributevintagetext('LBTG_STAKE_INV_SID', r.entry_sid, 4)||' ' as LBTG_STAKE_INV_SID,
    fgd_cfg_accessors.getattributevintagetext('LBEI_STAKE_INV_SID', r.entry_sid, 4)||' ' as LBEI_STAKE_INV_SID,
    fgd_cfg_accessors.getattributevintagetext('TRAC_RPT_GB_SID', r.entry_sid, 4)||' ' as TRAC_RPT_GB_SID,
    fgd_cfg_accessors.getattributevintagetext('TRAC_AC_GBR_SID', r.entry_sid, 4)||' ' as TRAC_AC_GBR_SID,
    fgd_cfg_accessors.getattributevintagetext('EIEE_SUP_IMPL_SID', r.entry_sid, 4)||' ' as EIEE_SUP_IMPL_SID,
    fgd_cfg_accessors.getattributevintagetext('EIEE_CHAL_IMPL_SID', r.entry_sid, 4)||' ' as EIEE_CHAL_IMPL_SID,
    fgd_cfg_accessors.getattributevintagetext('EIGB_IAT_PROC_SID', r.entry_sid, 4)||' ' as EIGB_IAT_PROC_SID,
    fgd_cfg_accessors.getattributevintagetext('EIGB_EFECT_GB_SID', r.entry_sid, 4)||' ' as EIGB_EFECT_GB_SID,
    fgd_cfg_accessors.getattributevintagetext('CVRS_MEAS_GB_SID', r.entry_sid, 4)||' ' as CVRS_MEAS_GB_SID,
    fgd_cfg_accessors.getattributevintagetext('CVRS_RRP_SID', r.entry_sid, 4)||' ' as CVRS_RRP_SID,
    fgd_cfg_accessors.getattributevintagetext('OTTL_OTHR_TOOL_SID', r.entry_sid, 4)||' ' as OTTL_OTHR_TOOL_SID
FROM fgd_gbd_entries r
    JOIN fgd_gbd_entry_edit_steps res ON r.entry_sid = res.entry_sid
    JOIN fgd_cfg_edit_steps         es ON res.edit_step_sid = es.edit_step_sid
    WHERE res.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 0);
