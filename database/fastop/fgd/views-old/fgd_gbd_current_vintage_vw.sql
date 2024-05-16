CREATE OR REPLACE VIEW FGD_GBD_CURRENT_VINTAGE_VW  AS 
  SELECT
    DISTINCT 
    R.COUNTRY_ID,
    fgd_cfg_accessors.getattributevintagetext('GEN_IN_PLACE_SID', r.entry_sid, 4)||' ' as GEN_IN_PLACE_SID,
    fgd_cfg_accessors.getattributevintagetext('GEN_PLANS_INTRO_SID', r.entry_sid, 4)||' ' as GEN_PLANS_INTRO_SID,
    r.GEN_TIMELINE,
    r.GEN_SUP_DOCS,
    fgd_cfg_accessors.getattributevintagetext('GEN_CHALLGE_SID', r.entry_sid, 4)||' ' as GEN_CHALLGE_SID,
    fgd_cfg_accessors.getattributevintagetext('GEN_FTHR_DEV_SID', r.entry_sid, 4)||' ' as GEN_FTHR_DEV_SID,
    fgd_cfg_accessors.getattributevintagetext('GEN_MOTIV_SID', r.entry_sid, 4)||' ' as GEN_MOTIV_SID,
    r.GEN_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('CVLT_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVLT_ENV_OBJ_SID,
    fgd_cfg_accessors.getattributevintagetext('CVLT_BDGT_ELMT_SID', r.entry_sid, 4)||' ' as CVLT_BDGT_ELMT_SID,
    fgd_cfg_accessors.getattributevintagetext('CVLT_BDGT_ELMT_EO_SID', r.entry_sid, 4)||' ' as CVLT_BDGT_ELMT_EO_SID,
    r.CVLT_BECEO_ADD_INFO,
    fgd_cfg_accessors.getattributevintagetext('CVLT_PUB_SECT_SID', r.entry_sid, 4)||' ' as CVLT_PUB_SECT_SID,
    r.CVLT_SUBNAT_GOV_COV,
    r.CVLT_XBGT_FND_COV,
    fgd_cfg_accessors.getattributevintagetext('CVLT_PS_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVLT_PS_ENV_OBJ_SID,
    r.CVLT_PSCEO_ADD_INFO,
    fgd_cfg_accessors.getattributevintagetext('CVLT_PS_BGT_EL_SID', r.entry_sid, 4)||' ' as CVLT_PS_BGT_EL_SID,
    r.CVLT_PSCBE_ADD_INFO,
    r.CVLT_SB_COV,
    r.CVLT_SB_FAV,
    r.CVLT_SB_UNFAV,
    r.CVLT_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('CVBT_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVBT_ENV_OBJ_SID,
    fgd_cfg_accessors.getattributevintagetext('CVBT_BGT_ELMT_SID', r.entry_sid, 4)||' ' as CVBT_BGT_ELMT_SID,
    fgd_cfg_accessors.getattributevintagetext('CVBT_BGT_ELMT_EO_SID', r.entry_sid, 4)||' ' as CVBT_BGT_ELMT_EO_SID,
    r.CVBT_BECEO_ADD_INFO,
    fgd_cfg_accessors.getattributevintagetext('CVBT_PUB_SECT_SID', r.entry_sid, 4)||' ' as CVBT_PUB_SECT_SID,
    r.CVBT_SUBNAT_GOV_COV,
    r.CVBT_XBGT_FND_COV,
    fgd_cfg_accessors.getattributevintagetext('CVBT_PS_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVBT_PS_ENV_OBJ_SID,
    r.CVBT_PSCEO_ADD_INFO,
    fgd_cfg_accessors.getattributevintagetext('CVBT_PS_BGT_EL_SID', r.entry_sid, 4)||' ' as CVBT_PS_BGT_EL_SID,
    r.CVBT_PSCBE_ADD_INFO,
    r.CVBT_SB_TAG,
    r.CVBT_SB_FAV,
    r.CVBT_SB_UNFAV,
    r.CVBT_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('CVEI_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVEI_ENV_OBJ_SID,
    fgd_cfg_accessors.getattributevintagetext('CVEI_BDGT_ELMT_SID', r.entry_sid, 4)||' ' as CVEI_BDGT_ELMT_SID,
    fgd_cfg_accessors.getattributevintagetext('CVEI_BGT_ELMT_EO_SID', r.entry_sid, 4)||' ' as CVEI_BGT_ELMT_EO_SID,
    r.CVEI_BECEO_ADD_INFO,
    fgd_cfg_accessors.getattributevintagetext('CVEI_PUB_SECT_SID', r.entry_sid, 4)||' ' as CVEI_PUB_SECT_SID,
    r.CVEI_SUBNAT_GOV_COV,
    r.CVEI_XBGT_FND_COV,
    fgd_cfg_accessors.getattributevintagetext('CVEI_PS_ENV_OBJ_SID', r.entry_sid, 4)||' ' as CVEI_PS_ENV_OBJ_SID,
    r.CVEI_PSCEO_ADD_INFO,
    fgd_cfg_accessors.getattributevintagetext('CVEI_PS_BGT_EL_SID', r.entry_sid, 4)||' ' as CVEI_PS_BGT_EL_SID,
    r.CVEI_PSCBE_ADD_INFO,
    r.CVEI_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('MTBT_TAG_MTHD_SID', r.entry_sid, 4)||' ' as MTBT_TAG_MTHD_SID,
    fgd_cfg_accessors.getattributevintagetext('MTBT_TA_MTHD_SID', r.entry_sid, 4)||' ' as MTBT_TA_MTHD_SID,
    r.MTBT_LNK_PUB_DOC,
    r.MTBT_RSP_IND_EVAL,
    r.MTBT_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('MTEI_TA_SID', r.entry_sid, 4)||' ' as MTEI_TA_SID,
    r.MTEI_LNK_PUB_DOC,
    r.MTEI_IND_EVAL,
    r.MTEI_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('LBGB_CTRY_STRAT_SID', r.entry_sid, 4)||' ' as LBGB_CTRY_STRAT_SID,
    r.LBGB_LNK_REL_DOC,
    r.LBGB_STRAT_DESCR,
    fgd_cfg_accessors.getattributevintagetext('LBGB_LEG_BAS_SID', r.entry_sid, 4)||' ' as LBGB_LEG_BAS_SID,
    r.LBGB_LB_YR,
    r.LBGB_LB_LNK,
    fgd_cfg_accessors.getattributevintagetext('LBTG_STAKE_LD_SID', r.entry_sid, 4)||' ' as LBTG_STAKE_LD_SID,
    fgd_cfg_accessors.getattributevintagetext('LBTG_STAKE_INV_SID', r.entry_sid, 4)||' ' as LBTG_STAKE_INV_SID,
    r.LBTG_DESC_PROC,
    fgd_cfg_accessors.getattributevintagetext('LBEI_STAKE_INV_SID', r.entry_sid, 4)||' ' as LBEI_STAKE_INV_SID,
    r.LBEI_DESC_PROC,
    fgd_cfg_accessors.getattributevintagetext('TRAC_RPT_GB_SID', r.entry_sid, 4)||' ' as TRAC_RPT_GB_SID,
    r.TRAC_LNK_DOCS,
    r.TRAC_OTHR_LNK_DOCS,
    fgd_cfg_accessors.getattributevintagetext('TRAC_AC_GBR_SID', r.entry_sid, 4)||' ' as TRAC_AC_GBR_SID,
    r.TRAC_RSP_ASSES,
    r.TRAC_RSP_RVW,
    fgd_cfg_accessors.getattributevintagetext('TRAC_TR_GBR_SID', r.entry_sid, 4)||' ' as TRAC_TR_GBR_SID,
    r.TRAC_LNK_ASS_RVW,
    r.TRAC_PROC_PMT_DISC,
    r.TRAC_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('EIEE_SUP_IMPL_SID', r.entry_sid, 4)||' ' as EIEE_SUP_IMPL_SID,
    fgd_cfg_accessors.getattributevintagetext('EIEE_CHAL_IMPL_SID', r.entry_sid, 4)||' ' as EIEE_CHAL_IMPL_SID,
    fgd_cfg_accessors.getattributevintagetext('EIEE_SUP_EC_SID', r.entry_sid, 4)||' ' as EIEE_SUP_EC_SID,
    r.EIEE_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('EIGB_IAT_PROC_SID', r.entry_sid, 4)||' ' as EIGB_IAT_PROC_SID,
    r.EIGB_TL_PROC_DTL,
    fgd_cfg_accessors.getattributevintagetext('EIGB_EFECT_GB_SID', r.entry_sid, 4)||' ' as EIGB_EFECT_GB_SID,
    r.EIGB_MAG_IMP_GB_SID,
    r.EIGB_MAG_EXAMPL,
    r.EIGB_SCT_IMP,
    r.EIGB_OTHR_REM,
    fgd_cfg_accessors.getattributevintagetext('CVRS_MEAS_GB_SID', r.entry_sid, 4)||' ' as CVRS_MEAS_GB_SID,
    r.CVRS_NO_ACTN,
    fgd_cfg_accessors.getattributevintagetext('CVRS_RRP_SID', r.entry_sid, 4)||' ' as CVRS_RRP_SID,
    r.CVRS_EX_ACTN,
    fgd_cfg_accessors.getattributevintagetext('OTTL_OTHR_TOOL_SID', r.entry_sid, 4)||' ' as OTTL_OTHR_TOOL_SID,
    r.OTTL_OTHR_REM_GTOOL,
    r.OTTL_OTHR_REM_GBGT
FROM fgd_gbd_entries r
    JOIN fgd_gbd_entry_edit_steps res ON r.entry_sid = res.entry_sid
    JOIN fgd_cfg_edit_steps         es ON res.edit_step_sid = es.edit_step_sid
    WHERE res.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 0);