CREATE OR REPLACE FORCE VIEW "FGD_RULE_SCORES_VW" (
    "RULE_SID",
    "cr1",
    "cr2",
    "cr3a",
    "cr3b",
    "cr3c",
    "cr3d",
    "cr4",
    "cr5a",
    "cr5b",
    "cr5c",
    "cr5d"
) AS
    SELECT
        "RULE_SID",
        "'1'",
        "'2'",
        "'3a'",
        "'3b'",
        "'3c'",
        "'3d'",
        "'4'",
        "'5a'",
        "'5b'",
        "'5c'",
        "'5d'"
    FROM
        (
            SELECT
                rule_sid,
                criterion,
                score
            FROM
                (
                    SELECT
                        rc.rule_sid,
                        c.criterion_id || c.sub_criterion_id criterion,
                        rc.score,
                        sv.order_by,
                        MAX(sv.order_by) OVER(
                            PARTITION BY rc.rule_sid, rc.criterion_sid
                        ) max_order_by
                    FROM
                        fgd_nfr_rule_criteria    rc
                        JOIN fgd_idx_criteria         c ON c.criterion_sid = rc.criterion_sid
                        JOIN fgd_idx_score_versions   sv ON sv.score_version_sid = rc.score_version_sid
                    WHERE
                        rc.score IS NOT NULL
                        AND rc.round_sid IS NULL
                )
            WHERE
                order_by = max_order_by
        ) PIVOT (
            MAX ( score )
            FOR criterion
            IN ( '1',
            '2',
            '3a',
            '3b',
            '3c',
            '3d',
            '4',
            '5a',
            '5b',
            '5c',
            '5d' )
        );

CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_FRSI_DATA_VW" ("RULE_SID", "RULE_NO", "RULE_VERSION", "COUNTRY_ID", "SECTOR_ID", "FRSI", "COVERAGE", "IN_FORCE", "FRI", "RANKING") AS 
  WITH t AS (
        SELECT DISTINCT
            fgd_cfg_accessors.calcfrsi(rs."cr1", rs."cr2", rs."cr3a", rs."cr3b", rs."cr3c",
                                       rs."cr3d", rs."cr4", rs."cr5a", rs."cr5b", rs."cr5c",
                                       rs."cr5d") AS frsi,
            rs.rule_sid,
            r.rule_no,
            r.rule_version,
            r.country_id,
                     --ES.PREV_STEP_SID,
            CASE
                WHEN fgd_nfr_rule_pkg.getavailability(r.impl_date, r.reform_impl_date, r.reform_replaced_date, r.abolition_date) =
                'C' THEN
                    1
                ELSE
                    0
            END in_force,
            sec.sector_id,
            (
                CASE
                    WHEN rc.numeric_value IS NULL THEN
                        (
                            CASE
                                WHEN sec.sector_id = 'GG' THEN
                                    1
                                WHEN sec.sector_id = 'SS' THEN
                                    euc.ss_value
                                WHEN sec.sector_id = 'LG' THEN
                                    euc.lg_value
                                WHEN sec.sector_id = 'RG' THEN
                                    euc.rg_value
                                WHEN sec.sector_id = 'CG' THEN
                                    euc.cg_value
                            END
                        )
                    ELSE
                        (
                            CASE
                                WHEN sec.sector_id = 'GG' THEN
                                    1 - rc.numeric_value / 100
                                WHEN sec.sector_id = 'SS' THEN
                                    euc.ss_value * ( 1 - rc.numeric_value / 100 )
                                WHEN sec.sector_id = 'LG' THEN
                                    euc.lg_value * ( 1 - rc.numeric_value / 100 )
                                WHEN sec.sector_id = 'RG' THEN
                                    euc.rg_value * ( 1 - rc.numeric_value / 100 )
                                WHEN sec.sector_id = 'CG' THEN
                                    euc.cg_value * ( 1 - rc.numeric_value / 100 )
                            END
                        )
                END
            ) AS coverage
        FROM
            fgd_nfr_rules                  r,
            fgd_rule_scores_vw             rs,
            fgd_nfr_rule_edit_steps        es,
            fgd_rule_response_details_vw   rc,
            fgd_nfr_rule_sectors           rsec,
            fgd_nfr_sectors                sec,
            fgd_eurostat_coverage          euc
        WHERE
            rs.rule_sid = r.rule_sid
            AND es.rule_sid = r.rule_sid
            AND rc.rule_sid = r.rule_sid
            AND rsec.rule_sid = r.rule_sid
            AND sec.sector_sid = rsec.sector_sid
            AND euc.country_id = r.country_id
            AND rc.response_sid = rsec.sector_sid
            AND rc.attr_sid = 2
            AND fgd_nfr_rule_pkg.getavailability(r.impl_date, r.reform_impl_date, r.reform_replaced_date, r.abolition_date) = 'C'
            AND es.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
        ORDER BY
            r.country_id
    )
    SELECT
        t.rule_sid,
        t.rule_no,
        t.rule_version,
        t.country_id,
        t.sector_id,
        round(t.frsi, 4),
        t.coverage,
        t.in_force,
        round(t.frsi * t.coverage, 4) AS fri,
        DENSE_RANK() OVER(
            PARTITION BY country_id, sector_id
            ORDER BY
                round(t.frsi, 4) * t.coverage * 10 DESC
        ) AS ranking
    FROM
        t
    WHERE
        t.coverage IS NOT NULL
    ORDER BY
        t.rule_no,
        t.rule_version;

CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_RULE_SCORES_ANNUAL_VW" ("RULE_SID", "ROUND_SID", "cr1", "cr2", "cr3") AS 
  SELECT
        "RULE_SID",
        "ROUND_SID",
        "'1'",
        "'2'",
        "'3'"
    FROM
        (
            SELECT
                rule_sid,
                round_sid,
                criterion,
                score
            FROM
                (
                    SELECT
                        rc.rule_sid,
                        c.criterion_id || c.sub_criterion_id criterion,
                        rc.score,
                        rc.round_sid,
                        sv.order_by,
                        MAX(sv.order_by) OVER(
                            PARTITION BY rc.rule_sid, rc.criterion_sid
                        ) max_order_by
                    FROM
                        fgd_nfr_rule_criteria    rc
                        JOIN fgd_idx_criteria         c ON c.criterion_sid = rc.criterion_sid
                        JOIN fgd_idx_score_versions   sv ON sv.score_version_sid = rc.score_version_sid
                    WHERE
                        rc.score IS NOT NULL
                        AND rc.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
                )
            WHERE
                order_by = max_order_by
        ) PIVOT (
            MAX ( score )
            FOR criterion
            IN ( '1',
            '2',
            '3' )
        );

CREATE OR REPLACE FORCE VIEW "FGD_SIFI_DATA_VW" (
    "RULE_SID",
    "COUNTRY_ID",
    "SDIM1",
    "SDIM2",
    "SDIM3",
    "SDIM4",
    "SDIM5",
    "SDIM6",
    "SIFI"
) AS
    WITH t AS (
        SELECT
            ifi.institution_sid AS rule_sid,
            ifi.country_id,
            round((((sc.tk1a + sc.tk1b + sc.tk1c) * sc.ctk1) / 3) * 30, 4) AS sdim1,
            round((((sc.tk2a + sc.tk2b + sc.tk2c) * sc.ctk2) / 3) * 25, 4) AS sdim2,
            round((((sc.tk3a + sc.tk3b) * sc.ctk3) / 3.5) * 20, 4) AS sdim3,
            sc.tk4 * 10 AS sdim4,
            sc.tk5 * 5 AS sdim5,
            sc.tk6 * 10 AS sdim6
        FROM
            fgd_ifi_institutions   ifi
            JOIN fgd_ifi_scores_vw      sc ON ifi.institution_sid = sc.institution_sid
    )
    SELECT
        t.rule_sid,
        t.country_id,
        nvl(t.sdim1, 0),
        nvl(t.sdim2, 0),
        nvl(t.sdim3, 0),
        nvl(t.sdim4, 0),
        nvl(t.sdim5, 0),
        nvl(t.sdim6, 0),
        ( nvl(t.sdim1, 0) + nvl(t.sdim2, 0) + nvl(t.sdim3, 0) + nvl(t.sdim4, 0) + nvl(t.sdim5, 0) + nvl(t.sdim6, 0) ) AS sifi
    FROM
        t;


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_FRCI_DATA_VW" ("RULE_SID", "RULE_NO", "RULE_VERSION", "COUNTRY_ID", "SECTOR_ID", "ROUND_SID", "EX_ANTE_COMPLIANCE", "EX_POST_COMPLIANCE", "BONUS", "COMPLIANCEWITHBONUS", "COVERAGE", "RANKING", "ESCAPE_CLAUSES_TRIGGERED", "COMPLIANCEBYCOVERAGE", "RULEWEIGHT", "RULEFRCI_INDEX", "NA") AS 
  WITH t AS (
        SELECT DISTINCT
            rs.rule_sid,
            rs.round_sid,
            rs."cr1"   AS ex_ante_compliance,
            rs."cr2"   AS ex_post_compliance,
            rs."cr3"   AS escape_clauses_triggered,
            r.is_ambitious,
            r.rule_no,
            r.rule_version,
            r.country_id,
            frsi.sector_id,
            CASE
                WHEN fgd_nfr_rule_pkg.getavailability(r.impl_date, r.reform_impl_date, r.reform_replaced_date, r.abolition_date) =
                'C' THEN
                    1
                ELSE
                    0
            END in_force,
            fgd_cfg_accessors.calccomplianceb(rs."cr1", rs."cr2", rs."cr3", r.is_ambitious) AS compliance_scoring,
            CASE
                WHEN fgd_cfg_accessors.getog(r.country_id, rs.round_sid) < ( - 3 ) THEN
                    1
                WHEN ( - 1.45 ) < fgd_cfg_accessors.getog(r.country_id, rs.round_sid)
                     AND fgd_cfg_accessors.getog(r.country_id, rs.round_sid) < - 3 THEN
                    0.5
                ELSE
                    0
            END comp_bonus,
            frsi.coverage,
            frsi.ranking
        FROM
            fgd_nfr_rules               r
            JOIN fgd_rule_scores_annual_vw   rs ON rs.rule_sid = r.rule_sid
            JOIN fgd_nfr_rule_edit_steps     es ON es.rule_sid = r.rule_sid
                                               AND es.round_sid = rs.round_sid
            JOIN fgd_frsi_data_vw            frsi ON r.rule_sid = frsi.rule_sid
        WHERE
            fgd_nfr_rule_pkg.getavailability(impl_date, reform_impl_date, reform_replaced_date, abolition_date) IN (
                'C'
            )
            AND rs.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
                     --conditions for only the previous round
--            AND nvl(r.reform_impl_date, r.impl_date) < TO_DATE('01012018', 'DDMMYYYY')
        ORDER BY
            r.country_id,
            r.rule_no
    )
    SELECT
        t.rule_sid,
        t.rule_no,
        t.rule_version,
        t.country_id,
        t.sector_id,
        t.round_sid,
        CASE
            WHEN t.ex_ante_compliance >= 0 THEN
                to_char(t.ex_ante_compliance)
            ELSE
                'n/a'
        END AS ex_ante_compliance,
        CASE
            WHEN t.ex_post_compliance >= 0 THEN
                to_char(t.ex_post_compliance)
            ELSE
                'n/a'
        END AS ex_post_compliance,
        t.comp_bonus AS bonus,
        CASE
            WHEN t.compliance_scoring != 'n/a' THEN
                to_char(t.compliance_scoring + t.comp_bonus)
            WHEN t.ex_ante_compliance = 0
                 AND t.ex_post_compliance = 0 THEN
                to_char(0)
            ELSE
                'n/a'
        END AS compliancewithbonus,
        t.coverage,
        t.ranking,
        t.escape_clauses_triggered,
        CASE
            WHEN t.compliance_scoring != 'n/a' THEN
                to_char((t.compliance_scoring + t.comp_bonus) * t.coverage)
            ELSE
                'n/a'
        END AS compliancebycoverage,
        CASE
            WHEN t.compliance_scoring != 'n/a'
                 AND t.escape_clauses_triggered = 0 THEN
                round(t.coverage / t.ranking, 6)
            WHEN t.ex_ante_compliance = 0
                 AND t.ex_post_compliance = 0 THEN
                round(t.coverage / t.ranking, 6)
            ELSE
                0
        END AS ruleweight,
        CASE
            WHEN t.compliance_scoring != 'n/a' THEN
                to_char(round((t.compliance_scoring + t.comp_bonus) * t.coverage / t.ranking, 6))
            WHEN t.ex_ante_compliance = 0
                 AND t.ex_post_compliance = 0 THEN
                to_char(0)
            ELSE
                'n/a'
        END AS rulefrci_index,
        CASE
            WHEN t.compliance_scoring != 'n/a' THEN
                0
            WHEN t.ex_ante_compliance = 0
                 AND t.ex_post_compliance = 0 THEN
                0
            ELSE
                1
        END AS na
    FROM
        t
    ORDER BY
        t.rule_no;


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_IFI_DEFAULT_VINTAGE_VW" ("COUNTRY_ID", "ENG_NAME", "ESTAB_DATE", "L_REF_DATE", "LAW_TYPE_SID", "PREC_REF_ESTAB", "LEGAL_STATUS", "DRAFT_ACCESS_SID", "NPI_ACCESS_SID", "LBI_ACCESS_SID", "POLY_LEGAL_SID", "BASIS_EXAA", "BASIS_EXPA", "RULE_MON_INST_SID", "INST_CORR_MECH_SID", "ANBUD_BASIS_MACRO_SID", "ANBUD_TASK_MACRO_SID", "ANBUD_RECONC_SID", "EXP_EVAL_MACRO_SID", "FOREC_LNK_MACRO", "BASIS_BUDG_SID", "VARIABLE_SID", "TASK_BUDG_SID", "EXP_EVAL_BUDG_SID", "FOREC_LNK_BUDG", "BASIS_NORM_SID", "BASIS_SUSTAIN_SID", "BASIS_QUANTIF_SID", "BASIS_TRANSP_SID") AS 
  SELECT                                                 --r.institution_sid,
        r.country_id,
        r.eng_name,
        to_char(r.estab_date, 'YYYY-MM-DD') as estab_date,
        to_char(r.l_ref_date, 'YYYY-MM-DD') as l_ref_date,
        fgd_cfg_accessors.getattributevintagetext('LAW_TYPE_SID', r.institution_sid, 2)
        || ' ' AS law_type_sid,
        r.prec_ref_estab,
        fgd_cfg_accessors.getattributevintagetext('LEGAL_STATUS', r.institution_sid, 2)
        || ' ' AS legal_status,
        fgd_cfg_accessors.getattributevintagetext('DRAFT_ACCESS_SID', r.institution_sid, 2)
        || ' ' AS draft_access_sid,
        fgd_cfg_accessors.getattributevintagetext('NPI_ACCESS_SID', r.institution_sid, 2)
        || ' ' AS npi_access_sid,
        fgd_cfg_accessors.getattributevintagetext('LBI_ACCESS_SID', r.institution_sid, 2)
        || ' ' AS lbi_access_sid,
        fgd_cfg_accessors.getattributevintagetext('POLY_LEGAL_SID', r.institution_sid, 2)
        || ' ' AS poly_legal_sid,
        fgd_cfg_accessors.getattributevintagetext('BASIS_EXAA', r.institution_sid, 2)
        || ' ' AS basis_exaa,
        fgd_cfg_accessors.getattributevintagetext('BASIS_EXPA', r.institution_sid, 2)
        || ' ' AS basis_expa,
        fgd_cfg_accessors.getattributevintagetext('RULE_MON_INST_SID', r.institution_sid, 2)
        || ' ' AS rule_mon_inst_sid,
        fgd_cfg_accessors.getattributevintagetext('INST_CORR_MECH_SID', r.institution_sid, 2)
        || ' ' AS inst_corr_mech_sid,
        fgd_cfg_accessors.getattributevintagetext('ANBUD_BASIS_MACRO_SID', r.institution_sid, 2)
        || ' ' AS anbud_basis_macro_sid,
        fgd_cfg_accessors.getattributevintagetext('ANBUD_TASK_MACRO_SID', r.institution_sid, 2)
        || ' ' AS anbud_task_macro_sid,
        fgd_cfg_accessors.getattributevintagetext('ANBUD_RECONC_SID', r.institution_sid, 2)
        || ' ' AS anbud_reconc_sid,
        fgd_cfg_accessors.getattributevintagetext('EXP_EVAL_MACRO_SID', r.institution_sid, 2)
        || ' ' AS exp_eval_macro_sid,
        r.forec_lnk_macro,
        fgd_cfg_accessors.getattributevintagetext('BASIS_BUDG_SID', r.institution_sid, 2)
        || ' ' AS basis_budg_sid,
        fgd_cfg_accessors.getattributevintagetext('VARIABLE_SID', r.institution_sid, 2)
        || ' ' AS variable_sid,
        fgd_cfg_accessors.getattributevintagetext('TASK_BUDG_SID', r.institution_sid, 2)
        || ' ' AS task_budg_sid,
        fgd_cfg_accessors.getattributevintagetext('EXP_EVAL_BUDG_SID', r.institution_sid, 2)
        || ' ' AS exp_eval_budg_sid,
        r.forec_lnk_budg,
        fgd_cfg_accessors.getattributevintagetext('BASIS_NORM_SID', r.institution_sid, 2)
        || ' ' AS basis_norm_sid,
        fgd_cfg_accessors.getattributevintagetext('BASIS_SUSTAIN_SID', r.institution_sid, 2)
        || ' ' AS basis_sustain_sid,
        fgd_cfg_accessors.getattributevintagetext('BASIS_QUANTIF_SID', r.institution_sid, 2)
        || ' ' AS basis_quantif_sid,
        fgd_cfg_accessors.getattributevintagetext('BASIS_TRANSP_SID', r.institution_sid, 2)
        || ' ' AS basis_transp_sid
    FROM
        fgd_ifi_institutions       r
        JOIN fgd_ifi_inst_edit_steps    res ON r.institution_sid = res.institution_sid
        JOIN fgd_cfg_edit_steps         es ON res.edit_step_sid = es.edit_step_sid
        LEFT JOIN fgd_ifi_inst_assessments   ifa ON r.institution_sid = ifa.institution_sid
        LEFT JOIN fgd_cfg_edit_steps         ps ON ps.edit_step_sid = res.prev_step_sid
    WHERE res.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
      AND ifa.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1);


  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_CURRENT_VINTAGE_VW" ("RULE_NO", "RULE_VERSION", "COUNTRY_ID", "RULE_TYPE_SID", "SECTOR", "DESCR", "BUDG_AGG_SID", "TARGET_UNIT_SID", "ACCT_SYST_SID", "TIMEFRAME_SID", "LEGAL_BASE_SID", "EAM_INSTITUTION_SID", "EPM_INSTITUTION_SID", "DCQ_PREDEFINED_SID", "DCQ_TRG_SID", "DCQ_NATURE_SID", "REFORM_IMPL_DATE", "IN_FORCE_UNTIL", "COVERAGE", "IN_FORCE", "FRSI", "CR1", "CR2", "CR3A", "CR3B", "CR3C", "CR3D", "CR4", "CR5A", "CR5B", "CR5C", "CR5D", "LAW_NAME") AS 
  SELECT 
          --default columns
        v.rule_no,
        v.rule_version,
        v.country_id,
        fgd_cfg_accessors.getattributevintagetext('RULE_TYPE_SID', v.rule_sid, 1) AS rule_type_sid,
        sectors.descr   AS sector,
        fgd_cfg_accessors.getattributevintagetext('DESCR', v.rule_sid, 1) AS descr,
          --
        fgd_cfg_accessors.getattributevintagetext('BUDG_AGG_SID', v.rule_sid, 1) AS budg_agg_sid,
        fgd_cfg_accessors.getattributevintagetext('TARGET_UNIT_SID', v.rule_sid, 1) AS target_unit_sid,
        fgd_cfg_accessors.getattributevintagetext('ACCT_SYST_SID', v.rule_sid, 1) AS acct_syst_sid,
        fgd_cfg_accessors.getattributevintagetext('TIMEFRAME_SID', v.rule_sid, 1) AS timeframe_sid,                                 --attr_sid 56
        fgd_cfg_accessors.getattributevintagetext('LEGAL_BASE_SID', v.rule_sid, 1) AS legal_base_sid,                                --attr_sid 55
        fgd_cfg_accessors.getattributevintagetext('EAM_INSTITUTION_SID', v.rule_sid, 1) AS eam_institution_sid,
        fgd_cfg_accessors.getattributevintagetext('EPM_INSTITUTION_SID', v.rule_sid, 1) AS epm_institution_sid,
        fgd_cfg_accessors.getattributevintagetext('DCQ_PREDEFINED_SID', v.rule_sid, 1) AS dcq_predefined_sid,
        fgd_cfg_accessors.getattributevintagetext('DCQ_TRG_SID', v.rule_sid, 1) AS dcq_trg_sid,
        fgd_cfg_accessors.getattributevintagetext('DCQ_NATURE_SID', v.rule_sid, 1) AS dcq_nature_sid,
            --to_char(v.REFORM_IMPL_DATE, 'YYYY') as in_force_since,
        nvl(to_char(v.reform_impl_date, 'YYYY'), to_char(v.impl_date, 'YYYY')) AS reform_impl_date,
        to_char(sysdate, 'YYYY') - 2
        || '+' AS in_force_until,
        frsi.coverage,
        frsi.in_force,
        frsi.frsi       AS frsi,
            --scores
        rs."cr1"        AS cr1,
        rs."cr2"        AS cr2,
        rs."cr3a"       AS cr3a,
        rs."cr3b"       AS cr3b,
        rs."cr3c"       AS cr3c,
        rs."cr3d"       AS cr3d,
        rs."cr4"        AS cr4,
        rs."cr5a"       AS cr5a,
        rs."cr5b"       AS cr5b,
        rs."cr5c"       AS cr5c,
        rs."cr5d"       AS cr5d,
          --all the other attributes
          --     v.ESCC_DETAIL,
          --     v.ESCC_LAW,
          --     v.ESCC_LINK,
          --     v.EAM_PUB_RPT_NAME,
          --     v.EAM_PUB_RPT_LINK,
          --     v.EPM_PUB_RPT_NAME,
          --     v.EPM_PUB_RPT_LINK,
          --    v.LAW_LINK,
        v.law_name
     --     v.RTM_PERIOD,
     --   v.RTM_PUB_RPT_NAME
     --   v.RTM_PUB_RPT_LINK
     --    v.FC_INSTN_RESP,
     --   v.FC_ADD_INFO,
     --    v.MAIN_REASON,
     --    v.REFORM_REASON,
     --    v.ABOLITION_REASON
     --58, 59, 60 plus details
     --51
     --budg.descr as budgetary_aggregate,
     --targ.lov_descr as measurement_unit,

     --cyc.lov_descr as Cyclically_Adjusted_Target,
     --v.law_name,
     --v.law_link
    FROM
        fgd_nfr_rules               v,
        fgd_rule_scores_annual_arch   rc,
        fgd_rule_scores_vw          rs,
        (
            SELECT
                rule_sid,
                in_force,
                SUM(coverage) AS coverage,
                round(SUM(coverage * frsi * 10 / ranking), 3) AS frsi
            FROM
                fgd_idx_frsi_arch
               where round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1) 
            GROUP BY
                rule_sid,
                in_force
        ) frsi,
        (
            SELECT
                *
            FROM
                fgd_nfr_rule_assessments
            WHERE
                period_sid = 1
                AND round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
        ) exante,
        (
            SELECT
                *
            FROM
                fgd_nfr_rule_assessments
            WHERE
                period_sid = 2
                AND round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
        ) expost, ( (
            SELECT
                *
            FROM
                (
                    SELECT
                        rule_sid,
                        year,
                        value
                    FROM
                        fgd_nfr_target_rules
                ) PIVOT (
                    SUM ( value )
                    FOR year
                    IN ( 2017,
                    2018,
                    2019,
                    2020,
                    2021 )
                )
        ) ) y,
        (
            SELECT
                rsec.rule_sid,
                LISTAGG(sec.descr, ', ') WITHIN GROUP(
                    ORDER BY
                        sec.descr
                ) AS descr
            FROM
                fgd_nfr_rule_sectors   rsec,
                fgd_nfr_sectors        sec
            WHERE
                sec.sector_sid = rsec.sector_sid
            GROUP BY
                rsec.rule_sid
        ) sectors
    WHERE
        v.rule_sid = rc.rule_sid
        AND sectors.rule_sid = v.rule_sid
        AND v.rule_sid = rs.rule_sid
        AND v.rule_sid = frsi.rule_sid
        AND v.rule_sid = exante.rule_sid (+)
        AND v.rule_sid = expost.rule_sid (+)
        AND v.rule_sid = y.rule_sid (+)
        AND rc.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
    ORDER BY
        v.country_id;

/* Formatted on 17/12/2019 10:14:31 (QP5 v5.252.13127.32847) */

CREATE OR REPLACE FORCE VIEW mtbf_current_vintage_vw (
    country_id,
    dev_year,
    scp_con,
    timeframe,
    budg_obj_revs,
    revs_time,
    legal_base,
    med_term_coverage,
    coord_type,
    inv_institution,
    inv_body,
    inv_parl,
    m_annual_obj,
    disag_expend,
    disag_expend_level_obj,
    proj_expend,
    policy_scenario,
    disag_expend_level_policy,
    disag_revenue_level,
    policy_analysis,
    mtf_quant_impact,
    impact_analysis,
    mtf_adoption,
    budg_connectivity,
    budg_obj_def,
    monitoring_body,
    exa_assess,
    exa_assess_pres,
    exp_assess,
    exa_compliance_2017,
    exp_compliance_2017,
    exa_compliance_2018,
    budg_correction
) AS
    SELECT
        country_id,
        dev_year,
        scp_con,
        timeframe,
        budg_obj_revs,
        revs_time,
        legal_base,
        med_term_coverage,
        coord_type,
        inv_institution,
        inv_body,
        inv_parl,
        m_annual_obj,
        disag_expend,
        disag_expend_level_obj,
        proj_expend,
        policy_scenario,
        disag_expend_level_policy,
        disag_revenue_level,
        policy_analysis,
        mtf_quant_impact,
        impact_analysis,
        mtf_adoption,
        budg_connectivity,
        budg_obj_def,
        monitoring_body,
        exa_assess,
        exa_assess_pres,
        exp_assess,
        exa_compliance_2017,
        exp_compliance_2017,
        exa_compliance_2018,
        budg_correction
    FROM
        fgd_mtbf_attr_data_2017;

CREATE OR REPLACE FORCE VIEW "FGD_IFI_MONIT_RULES_VW" AS
    WITH t AS (
SELECT DISTINCT
            fii.lov_sid AS lov_sid,
            fnr.country_id,
            to_number(fnr.rule_sid
                      || fnr.rule_no
                      || v.sector_sid
                      || rtyp.lov_sid) AS sector_sid,
            'Rule '
            || fnr.rule_no
            || ': '
            || rtyp.lov_descr
            || ' - '
            || v.descr AS descr,
            null as provide_details
        FROM
            fgd_nfr_rules        fnr,
            fgd_ifi_lovs         fii,
            (
                SELECT
                    v.rule_no,                          --v.rule_sid,
                    MAX(v.rule_version) AS rule_version,
                    v.country_id
                FROM
                    fgd_nfr_rules v
                GROUP BY
                    v.rule_no,
                    v.country_id
            ) b,
            fgd_nfr_all_lov_vw   rtyp,
            (
                SELECT
                    b.rule_sid,
                    b.descr,
                    b.sector_sid,
                    b.order_by
                FROM
                    (
                        SELECT
                            fnrs.rule_sid,
                            fns.sector_sid,
                            fns.order_by,
                            fns.descr
                            || ' - Coverage of GG finances: '
                            || to_char(nvl(fnrs.coverage, 0), '0.000') AS descr
                        FROM
                            fgd_frsi_data_vw   fnrs,
                            fgd_nfr_sectors    fns
                        WHERE
                            fnrs.sector_id = fns.sector_id
                    ) b
            ) v
        WHERE
            fnr.rule_sid = v.rule_sid
            AND b.rule_no = fnr.rule_no
            AND b.rule_version = fnr.rule_version
            AND rtyp.lov_sid = fnr.rule_type_sid
            AND fii.descr = fnr.country_id
            AND fii.lov_type_sid = 47
    UNION
        SELECT DISTINCT
                fii.lov_sid AS lov_sid,
                fnr.country_id,
                to_number(fii.lov_sid) + 3000 AS sector_sid,
                'Other' as descr,
                1 as provide_details
            FROM (
                SELECT
                    distinct v.country_id
                FROM
                    fgd_nfr_rules v
                
            )        fnr,
            fgd_ifi_lovs         fii
            
        WHERE fii.descr = fnr.country_id
            AND fii.lov_type_sid = 47              
    )
    SELECT
        t.lov_sid,
        t.country_id,
        t.descr,
        t.sector_sid,
        ROW_NUMBER() OVER(
            PARTITION BY t.lov_sid
            ORDER BY
                descr desc
        ) AS order_by,
        t.provide_details
    FROM
        t;

CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_IFI_TRIG_ESCC_VW" AS 
WITH t AS (
SELECT DISTINCT
            fii.lov_sid AS lov_sid,
            fnr.country_id,
            to_number(fnr.rule_sid
                      || fnr.rule_no
                      || v.sector_sid
                      || rtyp.lov_sid) AS sector_sid,
            'Rule '
            || fnr.rule_no
            || ': '
            || rtyp.lov_descr
            || ' - '
            || v.descr AS descr,
            null as provide_details,
            1 as response_type_sid
        FROM
            fgd_nfr_rules        fnr,
            fgd_ifi_lovs         fii,
            (
                SELECT
                    v.rule_no,                          --v.rule_sid,
                    MAX(v.rule_version) AS rule_version,
                    v.country_id
                FROM
                    fgd_nfr_rules v
                GROUP BY
                    v.rule_no,
                    v.country_id
            ) b,
            fgd_nfr_all_lov_vw   rtyp,
            (
                SELECT
                    b.rule_sid,
                    b.descr,
                    b.sector_sid,
                    b.order_by
                FROM
                    (
                        SELECT
                            fnrs.rule_sid,
                            fns.sector_sid,
                            fns.order_by,
                            fns.descr
                            || ' - Coverage of GG finances: '
                            || to_char(nvl(fnrs.coverage, 0), '0.000') AS descr
                        FROM
                            fgd_frsi_data_vw   fnrs,
                            fgd_nfr_sectors    fns
                        WHERE
                            fnrs.sector_id = fns.sector_id
                    ) b
            ) v
        WHERE
            fnr.rule_sid = v.rule_sid
            AND b.rule_no = fnr.rule_no
            AND b.rule_version = fnr.rule_version
            AND rtyp.lov_sid = fnr.rule_type_sid
            AND fii.descr = fnr.country_id
            AND fii.lov_type_sid = 47
    UNION
         SELECT DISTINCT
                fii.lov_sid AS lov_sid,
                fnr.country_id,
                to_number(fii.lov_sid) + 4000 AS sector_sid,
                'None' as descr,
                null as provide_details,
                3 as response_type_sid
            FROM (
                SELECT
                    distinct v.country_id
                FROM
                    fgd_nfr_rules v
                
            )        fnr,
            fgd_ifi_lovs         fii
            
            
        WHERE
            fii.descr = fnr.country_id
            AND fii.lov_type_sid = 47              
    )
    SELECT
        t.lov_sid,
        t.country_id,
        t.descr,
        t.sector_sid,
        ROW_NUMBER() OVER(
            PARTITION BY t.lov_sid
            ORDER BY
                descr desc
        ) AS order_by,
        t.provide_details,
        t.response_type_sid
    FROM
        t;