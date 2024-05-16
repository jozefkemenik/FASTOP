 CREATE OR REPLACE FORCE EDITIONABLE VIEW "FGD_CFG_RESPONSE_CHOICES_VW" ("RESPONSE_SID", "RESPONSE_ID", "RESPONSE_GROUP_SID", "DESCR", "PROVIDE_DETAILS", "ORDER_BY", "RESPONSE_TYPE_SID", "HELP_TEXT", "CHOICE_LIMIT", "QUESTIONNAIRE_SID") AS 
  SELECT
        l.lov_sid,
        NULL,
        l.lov_type_sid,
        l.descr,
        l.need_det,
        l.order_by,
        l.cfg_type,
        l.help_text,
        l.choice_limit,
        1
    FROM
        fgd_nfr_lovs l
    UNION ALL
    SELECT
        l.lov_sid,
        NULL,
        20100 + l.lov_type_sid,
        l.descr,
        l.need_det,
        l.order_by,
        l.cfg_type,
        l.help_text,
        l.choice_limit,
        2
    FROM
        fgd_ifi_lovs l
    UNION ALL
    SELECT
        l.lov_sid,
        NULL,
        30100 + l.lov_type_sid,
        l.descr,
        l.need_det,
        l.order_by,
        l.cfg_type,
        l.help_text,
        l.choice_limit,
        3
    FROM
        fgd_mtbf_lovs l
    UNION ALL
    SELECT
        l.lov_sid,
        NULL,
        40100 + l.lov_type_sid,
        l.descr,
        l.need_det,
        l.order_by,
        l.cfg_type,
        l.help_text,
        l.choice_limit,
        4
    FROM
        gbd_lovs l
    UNION ALL
    SELECT
        imr.sector_sid,
        NULL,
        21100 + imr.lov_sid,
        imr.descr,
        imr.provide_details,
        imr.order_by,
        NULL,
        NULL,
        null,
        2
    FROM
        fgd_ifi_monit_rules imr
    UNION ALL
    SELECT
        imr.sector_sid + 101010,
        NULL,
        22100 + imr.lov_sid,
        imr.descr,
        imr.provide_details,
        imr.order_by,
        imr.response_type_sid,
        NULL,
        null,
        2
    FROM
        fgd_ifi_trig_escc imr
    UNION ALL
    SELECT
        rt.rule_type_sid,
        rt.rule_id,
        1000001,
        rt.descr,
        NULL,
        rt.order_by,
        NULL,
        NULL,
        null,
        1
    FROM
        fgd_nfr_rule_types rt
    UNION ALL
    SELECT
        s.sector_sid,
        s.sector_id,
        1000002,
        s.descr,
        s.need_det,
        s.order_by,
        s.cfg_type,
        NULL,
        null,
        1
    FROM
        fgd_nfr_sectors s
    UNION ALL
    SELECT
        ba.budg_agg_sid,
        NULL,
        1010000 + ba.rule_type_sid,
        ba.descr,
        ba.need_det,
        ba.order_by,
        NULL,
        NULL,
        null,
        1
    FROM
        fgd_nfr_budg_aggs ba
    UNION ALL
    SELECT
        bau.unit_sid,
        NULL,
        1020000 + bau.budg_agg_sid,
        l.descr,
        l.need_det,
        l.order_by,
        NULL,
        l.help_text,
        null,
        1
    FROM
        fgd_nfr_budg_agg_units   bau
        JOIN fgd_nfr_lovs             l ON l.lov_sid = bau.unit_sid;