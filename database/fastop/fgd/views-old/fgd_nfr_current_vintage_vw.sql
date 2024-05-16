select * from fgd_cfg_questions where descr = 'Mandated Institution';

select * from fgd_cfg_attributes where question_sid = 22;


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_NFR_CURRENT_VINTAGE_VW" ("RULE_NO", "RULE_VERSION", "COUNTRY_ID", "RULE_TYPE_SID", "SECTOR", "DESCR", "BUDG_AGG_SID", "TARGET_UNIT_SID", "ACCT_SYST_SID", "TIMEFRAME_SID", "LEGAL_BASE_SID", "EAM_INSTITUTION_SID", "EPM_INSTITUTION_SID", "DCQ_PREDEFINED_SID", "DCQ_TRG_SID", "DCQ_NATURE_SID", "REFORM_IMPL_DATE", "IN_FORCE_UNTIL", "COVERAGE", "IN_FORCE", "FRSI", "CR1", "CR2", "CR3A", "CR3B", "CR3C", "CR3D", "CR4", "CR5A", "CR5B", "CR5C", "CR5D", "APPRV_DATE", "IMPL_DATE", "MAIN_REASON", "REFORM_ADOPT_DATE", "REFORM_REASON", "ABOLITION_DATE", "ABOLITION_REASON", "LAW_NAME", "LAW_LINK", "EXCL_ELEM_SID", "EST_SHARE_VALUE", "LNK_RULES", "OVERLAP_ITEM_SID", "IS_NUM_TARGET_SID", "YEAR_2017", "YEAR_2018", "YEAR_2019", "YEAR_2020", "YEAR_2021", "ADJUST_MARGIN_SID", "BUDG_MARGIN_SID", "IS_TARGET_CYCLE_SID", "IS_ESCC_TRIGGERED_SID", "ESCC_DETAIL", "ESCC_LAW", "ESCC_LINK", "ESC_INSTITUTION_SID", "IS_EAM_PUB_RPT_SID", "EAM_PUB_RPT_NAME", "EAM_PUB_RPT_LINK", "IS_EPM_PUB_RPT_SID", "EPM_PUB_RPT_NAME", "EPM_PUB_RPT_LINK", "IS_RTM_SID", "RTM_PERIOD", "RTM_PUB_RPT_NAME", "RTM_PUB_RPT_LINK", "IS_RTM_CORR_SID", "IS_FC_INSTN_SID", "FC_INSTN_RESP", "FC_INSTN_PROD_SID", "FC_ADD_INFO", "EXA_COMPLIANCE_SOURCE_SID", "EXA_IS_ESCC_TRIGGERED_SID", "EXA_IS_FLEX_PROV_SID", "EXA_PERCEIVED_CONSTR_SID", "EXA_REF_FMT_SID", "EXA_COMPLIANCE_SCORE", "EXA_ADD_INFO", "EXP_COMPLIANCE_SOURCE_SID", "EXP_IS_ESCC_TRIGGERED_SID", "EXP_IS_FLEX_PROV_SID", "EXP_REF_FMT_SID", "EXP_COMPLIANCE_SCORE", "EXP_ADD_INFO") AS 
  SELECT DISTINCT                                               --default columns
        v.rule_no,
            --  v.rule_sid,
        v.rule_version,
        v.country_id,
        fgd_cfg_accessors.getattributevintagetext('RULE_TYPE_SID', v.rule_sid, 1) AS rule_type_sid,
        sectors.descr        AS sector,
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
        frsi.frsi            AS frsi,
            --scores
        rs."cr1"             AS cr1,
        rs."cr2"             AS cr2,
        rs."cr3a"            AS cr3a,
        rs."cr3b"            AS cr3b,
        rs."cr3c"            AS cr3c,
        rs."cr3d"            AS cr3d,
        rs."cr4"             AS cr4,
        rs."cr5a"            AS cr5a,
        rs."cr5b"            AS cr5b,
        rs."cr5c"            AS cr5c,
        rs."cr5d"            AS cr5d,
            --all the other attributes
            --Legal base attributes
        to_char(v.apprv_date, 'MM/DD/YYYY') AS apprv_date,  --attr_sid 48
        to_char(v.impl_date, 'MM/DD/YYYY') AS impl_date,     --attr_sid 3
        v.main_reason        AS main_reason,                        --attr_sid 49
        to_char(v.reform_adopt_date, 'MM/DD/YYYY') AS reform_adopt_date, --attr_sid 50
        v.reform_reason      AS reform_reason,                    --attr_sid 52
        to_char(v.abolition_date, 'MM/DD/YYYY') AS abolition_date, --attr_sid 53
        v.abolition_reason   AS abolition_reason,              --attr_sid 54
        v.law_name           AS law_name,                              --attr_sid 27
        v.law_link           AS law_link,
            --Sector coverage attributes
        fgd_cfg_accessors.getattributevintagetext('EXCL_ELEM_SID', v.rule_sid, 1) AS excl_elem_sid,                                  --attr_sid 5
        sha.est_share_value AS est_share_value,                                --attr_sid 6
        nvl(fgd_cfg_accessors.getlnkrules(v.rule_sid), 'No ') AS lnk_rules, --attr_sid 7 DUMMY
        fgd_cfg_accessors.getattributevintagetext('OVERLAP_ITEM_SID', v.rule_sid, 1)
        || ' ' AS overlap_item_sid,                               --attr_sid 8
            --Target Attributes
        fgd_cfg_accessors.getattributevintagetext('IS_NUM_TARGET_SID', v.rule_sid, 1)
        || ' ' AS is_num_target_sid,                             --attr_sid 12
        y."2017"             AS year_2017,                               --attr_sid 13
        y."2018"             AS year_2018,                               --attr_sid 13
        y."2019"             AS year_2019,                               --attr_sid 13
        y."2020"             AS year_2020,                               --attr_sid 13
        y."2021"             AS year_2021,                               --attr_sid 13
        fgd_cfg_accessors.getattributevintagetext('ADJUST_MARGIN_SID', v.rule_sid, 1) AS adjust_margin_sid,                             --attr_sid 14
        fgd_cfg_accessors.getattributevintagetext('BUDG_MARGIN_SID', v.rule_sid, 1)
        || ' ' AS budg_margin_sid,                               --attr_sid 15
        fgd_cfg_accessors.getattributevintagetext('IS_TARGET_CYCLE_SID', v.rule_sid, 1)
        || ' ' AS is_target_cycle_sid,                           --attr_sid 17
            --Escape Clause Attributes
        fgd_cfg_accessors.getattributevintagetext('ESC_CLAUSE_SID', v.rule_sid, 1) AS ESC_CLAUSE_SID,                         --attr_sid 18
        v.escc_detail        AS escc_detail,                        --attr_sid 19
        v.escc_law           AS escc_law,                              --attr_sid 20
        v.escc_link          AS escc_link,                            --attr_sid 21
        fgd_cfg_accessors.getattributevintagetext('ESC_INSTITUTION_SID', v.rule_sid, 1) AS esc_institution_sid,                           --attr_sid 22
               --ExAnte Monitoring Attributes
        fgd_cfg_accessors.getattributevintagetext('IS_EAM_PUB_RPT_SID', v.rule_sid, 1)
        || ' ' AS is_eam_pub_rpt_sid,                            --attr_sid 24
        v.eam_pub_rpt_name   AS eam_pub_rpt_name,              --attr_sid 25
        v.eam_pub_rpt_link   AS eam_pub_rpt_link,              --attr_sid 26
               --ExPost Monitoring Attributes
        fgd_cfg_accessors.getattributevintagetext('IS_EPM_PUB_RPT_SID', v.rule_sid, 1)
        || ' ' AS is_epm_pub_rpt_sid,                            --attr_sid 30
        v.epm_pub_rpt_name   AS epm_pub_rpt_name,              --attr_sid 31
        v.epm_pub_rpt_link   AS epm_pub_rpt_link,              --attr_sid 32
            --Real Time Monitoring Attributes
        fgd_cfg_accessors.getattributevintagetext('IS_RTM_SID', v.rule_sid, 1)
        || ' ' AS is_rtm_sid,                                    --attr_sid 35
        v.rtm_period         AS rtm_period,                          --attr_sid 36
        v.rtm_pub_rpt_name   AS rtm_pub_rpt_name,              --attr_sid 37
        v.rtm_pub_rpt_link   AS rtm_pub_rpt_link,              --attr_sid 38
        fgd_cfg_accessors.getattributevintagetext('IS_RTM_CORR_SID', v.rule_sid, 1)
        || ' ' AS is_rtm_corr_sid,                               --attr_sid 39
            --forecast Attributes
        fgd_cfg_accessors.getattributevintagetext('IS_FC_INSTN_SID', v.rule_sid, 1)
        || ' ' AS is_fc_instn_sid,                               --attr_sid 40
        v.fc_instn_resp      AS fc_instn_resp,                    --attr_sid 41
        fgd_cfg_accessors.getattributevintagetext('FC_INSTN_PROD_SID', v.rule_sid, 1) AS fc_instn_prod_sid,                             --attr_sid 42
        v.fc_add_info        AS fc_add_info,                        --attr_sid 43
        fgd_cfg_accessors.getattributevintagetext('DCQ_INSTITUTION_SID', v.rule_sid, 1) AS DCQ_INSTITUTION_SID,
            --ExAnte Compliance Attributes
        fgd_cfg_accessors.getattributevintagetext('ASSESS_VAL', exante.rule_sid, 1) AS exa_compliance_source_sid,                     --attr_sid 61
        fgd_cfg_accessors.getattributevintagetext('IS_ESCC_TRIGGERED_SID', exante.rule_sid, 1)
        || ' ' AS exa_is_escc_triggered_sid,                     --attr_sid 66
        fgd_cfg_accessors.getattributevintagetext('IS_FLEX_PROV_SID', exante.rule_sid, 1)
        || ' ' AS exa_is_flex_prov_sid,                          --attr_sid 67
        fgd_cfg_accessors.getattributevintagetext('PERCEIVED_CONSTR_SID', exante.rule_sid, 1) AS exa_perceived_constr_sid,                      --attr_sid 69
        fgd_cfg_accessors.getattributevintagetext('REF_FMT_SID', exante.rule_sid, 1) AS exa_ref_fmt_sid,                               --attr_sid 72
        CASE
            WHEN rc.cr1 < 0 THEN
                'n/a'
            ELSE
                to_char(rc.cr1)
        END AS exa_compliance_score,                        --exa score cr1
        fgd_cfg_accessors.getattributevintagetext('ADD_INFO', exante.rule_sid, 1) AS exa_add_info,                                  --attr_sid 76
            --ExPost Compliance Attributes
        fgd_cfg_accessors.getattributevintagetext('ASSESS_VAL', expost.rule_sid, 1) AS exp_compliance_source_sid,                     --attr_sid 75
        fgd_cfg_accessors.getattributevintagetext('IS_ESCC_TRIGGERED_SID', expost.rule_sid, 1)
        || ' ' AS exp_is_escc_triggered_sid,                     --attr_sid 33
        fgd_cfg_accessors.getattributevintagetext('IS_FLEX_PROV_SID', expost.rule_sid, 1)
        || ' ' AS exp_is_flex_prov_sid,                          --attr_sid 34
        fgd_cfg_accessors.getattributevintagetext('REF_FMT_SID', expost.rule_sid, 1) AS exp_ref_fmt_sid,                               --attr_sid 72
        CASE
            WHEN rc.cr2 < 0 THEN
                'n/a'
            ELSE
                to_char(rc.cr2)
        END AS exp_compliance_score,                        --exp score cr2
        fgd_cfg_accessors.getattributevintagetext('ADD_INFO', expost.rule_sid, 1) AS exp_add_info                                   --attr_sid 76
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
        ) sectors,
        (select
        rsec.rule_sid,
        sec.descr || ' - ' || NVL(rsec.est_share_value, 0) || '%; ' || rsec.descr as est_share_value
FROM
                fgd_nfr_rule_sectors   rsec,
                fgd_nfr_sectors        sec
            WHERE
                sec.sector_sid = rsec.sector_sid) sha
    WHERE
        v.rule_sid = rc.rule_sid
        AND sectors.rule_sid = v.rule_sid
        AND v.rule_sid = rs.rule_sid
        AND v.rule_sid = frsi.rule_sid
        AND v.rule_sid = exante.rule_sid (+)
        AND v.rule_sid = expost.rule_sid (+)
        AND v.rule_sid = y.rule_sid (+)
        and v.rule_sid = sha.rule_sid(+)
        AND rc.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 1)
    ORDER BY
        v.country_id;
