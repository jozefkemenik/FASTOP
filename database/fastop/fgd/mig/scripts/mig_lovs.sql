DECLARE

CURSOR c_old_lov_types IS
    SELECT lov_type_sid, lov_type_id, descr, 'FGD_NFR_LOV_TYPES' as tab from fgd_nfr_lov_types
    UNION ALL
    SELECT 20100 + lov_type_sid, lov_type_id, descr, 'FGD_IFI_LOV_TYPES' as tab from fgd_ifi_lov_types
    UNION ALL
    SELECT distinct 30100 + lov_type_sid, lov_type_id, descr, 'FGD_MTBF_LOV_TYPES' as tab from fgd_mtbf_lov_types 
    UNION ALL
    SELECT 40100 + lov_type_sid, lov_type_id, descr, 'GBD_LOV_TYPES' as tab from gbd_lov_types
    UNION ALL
    SELECT 1000001, 'RTYPES', 'Rule Types', 'FGD_NFR_RULE_TYPES' AS tab FROM dual
    UNION ALL
    SELECT 1000002, 'RSECTORS', 'Rule Sectors', 'FGD_NFR_SECTORS' AS tab from dual
    union ALL
    SELECT 1010037, 'RBAGER','Rule Budgetary Aggregates ER', 'FGD_NFR_BUDG_AGGS_ER' as tab from dual
    union ALL
    SELECT 1010038, 'RBAGBBR','Rule Budgetary Aggregates BBR', 'FGD_NFR_BUDG_AGGS_BBR' as tab from dual
    union ALL
    SELECT 1010039, 'RBAGRR','Rule Budgetary Aggregates RR', 'FGD_NFR_BUDG_AGGS_RR' as tab from dual
    union ALL
    SELECT 1010040, 'RBAGDR','Rule Budgetary Aggregates DR', 'FGD_NFR_BUDG_AGGS_DR' as tab from dual
    UNION ALL
    SELECT distinct 1020000 + bau.budg_agg_sid, 'RTARGETUNITS'||bau.budg_agg_sid, agg.descr || ' Target Units', 'FGD_NFR_BUDG_AGG_UNITS'||bau.budg_agg_sid AS tab
    from fgd_nfr_budg_agg_units   bau
        JOIN fgd_nfr_lovs             l ON l.lov_sid = bau.unit_sid
        join fgd_nfr_budg_aggs agg on agg.budg_agg_sid = bau.budg_agg_sid
    ORDER BY 4 DESC, 1;
    
CURSOR c_old_lovs(pi_table_name varchar2, PI_LOV_TYPE_SID number) IS
    with t as (SELECT 
        lov_sid,
        NULL AS lov_id,
        lov_type_sid,
        descr,
        need_det,
        order_by,
        cfg_type,
        help_text,
        choice_limit,
        'FGD_NFR_LOV_TYPES' as tab
        FROM fgd_nfr_lovs
    UNION ALL
    SELECT 
        lov_sid,
        NULL AS lov_id,
        20100 + lov_type_sid,
        descr,
        need_det,
        order_by,
        cfg_type,
        help_text,
        choice_limit,
        'FGD_IFI_LOV_TYPES' as tab
        FROM fgd_ifi_lovs
    UNION ALL
    SELECT distinct
        lov_sid,
        NULL AS lov_id,
        30100 + lov_type_sid,
        descr,
        need_det,
        order_by,
        cfg_type,
        help_text,
        choice_limit,
        'FGD_MTBF_LOV_TYPES' as tab
        FROM fgd_mtbf_lovs
    UNION ALL
    SELECT 
        lov_sid,
        NULL AS lov_id,
        40100 + lov_type_sid,
        descr,
        need_det,
        order_by,
        cfg_type,
        help_text,
        choice_limit,
        'GBD_LOV_TYPES' as tab
        from gbd_lovs
    UNION ALL
    SELECT rule_type_sid AS lov_sid,
           rule_id as lov_id,
           1000001 as lov_type_sid,
           descr,
           null,
           order_by,
           null as cfg_type,
           null as help_text,
           null as choice_limit,
           'FGD_NFR_RULE_TYPES' as tab
        FROM fgd_nfr_rule_types
    union ALL
    SELECT s.sector_sid AS lov_sid,
        s.sector_id as lov_id,
        1000002 as lov_type_sid,
        s.descr,
        s.need_det,
        s.order_by,
        s.cfg_type,
        NULL as help_text,
        null as choice_limit,
        'FGD_NFR_SECTORS' AS tab
    FROM
        fgd_nfr_sectors s
    UNION ALL
    SELECT
        ba.budg_agg_sid as lov_sid,
        NULL as lov_id,
        1010000 + ba.rule_type_sid as lov_type_sid,
        ba.descr,
        ba.need_det,
        ba.order_by,
        NULL as cfg_type,
        NULL as help_text,
        null as choice_limit,
        'FGD_NFR_BUDG_AGGS_'||b.rule_id AS tab
    FROM
        fgd_nfr_budg_aggs ba, fgd_nfr_rule_types b where b.rule_type_sid = ba.rule_type_sid
    UNION ALL
    SELECT
        bau.unit_sid as lov_sid,
        NULL as lov_id,
        1020000 + bau.budg_agg_sid as lov_type_sid,
        l.descr,
        l.need_det,
        l.order_by,
        NULL as cfg_type,
        l.help_text,
        null as choice_limit,
        'FGD_NFR_BUDG_AGG_UNITS'||bau.budg_agg_sid AS tab
    FROM fgd_nfr_budg_agg_units   bau
        JOIN fgd_nfr_lovs             l ON l.lov_sid = bau.unit_sid
        join fgd_nfr_budg_aggs agg on agg.budg_agg_sid = bau.budg_agg_sid
	)
         SELECT t.lov_sid, t.lov_id, t.lov_type_sid, t.descr, t.need_det, t.order_by, t.cfg_type, t.help_text, t.choice_limit, t.tab
    FROM t WHERE t.tab = pi_table_name AND T.LOV_TYPE_SID = PI_LOV_TYPE_SID;
        
r_lov c_old_lovs%rowtype;        
l_lov_type_key NUMBER;
l_lov_key NUMBER;
l_err_key NUMBER;
l_target_key NUMBER;
begin
    FOR r_lov_type IN c_old_lov_types LOOP
        BEGIN
            l_err_key := 1;
            IF r_lov_type.TAB LIKE 'FGD_NFR_BUDG_AGG_UNITS%' THEN
                INSERT INTO CFG_LOV_TYPES (LOV_TYPE_ID, DESCR, DYN_SID)
                VALUES (r_lov_type.LOV_TYPE_ID, r_lov_type.DESCR, 1)
                RETURNING lov_type_sid INTO l_lov_type_key;
                COMMIT;
--                dbms_output.put_line('l_lov_type_key ' || l_lov_type_key);
            ELSE 
                INSERT INTO CFG_LOV_TYPES (LOV_TYPE_ID, DESCR, DYN_SID)
                VALUES (r_lov_type.LOV_TYPE_ID, r_lov_type.DESCR, 0)
                RETURNING lov_type_sid INTO l_lov_type_key;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                l_err_key := 12;
                LOG_FAIL('CFG_LOV_TYPES', sysdate, 'Skipping ' || sqlerrm(), l_lov_type_key);
        END;
        
        IF l_lov_type_key = 0 THEN
            SELECT distinct NEW_LOV_TYPE_SID INTO l_lov_type_key FROM LOV_TYPES_MIG WHERE LOV_TYPE_ID = r_lov_type.LOV_TYPE_ID;
        END IF;
           
        BEGIN    
            l_err_key := 2;
            INSERT INTO LOV_TYPES_MIG(OLD_LOV_TYPE_SID, NEW_LOV_TYPE_SID, LOV_TYPE_ID, OLD_TABLE)
            VALUES (r_lov_type.LOV_TYPE_SID, l_lov_type_key, r_lov_type.LOV_TYPE_ID, r_lov_type.tab );
        EXCEPTION
            WHEN OTHERS THEN 
                l_err_key := 22;
                LOG_FAIL('LOV_TYPES_MIG', sysdate, sqlerrm(), l_lov_type_key);
        END;
        LOG_INFO('LOV_TYPES_MIG', sysdate, 'Migrated with SUCC', l_lov_type_key);
        
        OPEN c_old_lovs(r_lov_type.tab, r_lov_type.LOV_TYPE_SID);
        LOOP
        FETCH c_old_lovs into r_lov;
        EXIT WHEN c_old_lovs%NOTFOUND;
            BEGIN
            l_err_key := 3;
                IF r_lov.TAB LIKE 'FGD_NFR_BUDG_AGG_UNITS%' THEN
                    l_target_key := get_new_lov_type(8);

                    begin
                        INSERT INTO CFG_DYNAMIC_LOVS(LOV_TYPE_SID, DYN_SID, USED_LOV_TYPE_SID, USED_LOV_SID)
                        VALUES (l_lov_type_key, 1, l_target_key, get_lov_sid(r_lov.lov_sid))
                        RETURNING USED_LOV_SID INTO l_lov_key;
                        commit;
                    exception
                        when others then
                            LOG_FAIL('CFG_DYNAMIC_LOVS', SYSDATE, 'Error ' || sqlerrm(), r_lov.lov_sid);
                    end;

                ELSE
                    INSERT INTO CFG_LOVS (LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, CHOICE_LIMIT, CFG_TYPE)
                    VALUES (l_lov_type_key, r_lov.DESCR, r_lov.NEED_DET, r_lov.ORDER_BY, r_lov.HELP_TEXT, r_lov.CHOICE_LIMIT, r_lov.CFG_TYPE)
                    RETURNING LOV_SID INTO l_lov_key;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                l_err_key := 31;
                    LOG_INFO('CFG_LOVS', sysdate, 'Skipping...' || r_lov.lov_sid,  l_lov_type_key);
                    
            END;
            IF l_lov_key = 0 THEN
            l_err_key := 4;
                BEGIN
                    SELECT DISTINCT NEW_LOV_SID INTO l_lov_key FROM LOVS_MIG WHERE LOV_TYPE_SID = l_lov_type_key AND DESCR = r_lov.DESCR AND (NEED_DET = nvl(r_lov.NEED_DET,0) or NEED_DET IS NULL);
                EXCEPTION
                WHEN OTHERS THEN 
                    LOG_FAIL('LOVS_MIG', SYSDATE, 'Error GETTING  l_lov_type_key ' || l_lov_type_key || ' DESCR ' || r_lov.DESCR || '  NEED_DET ' || r_lov.NEED_DET, r_lov.lov_sid);
                END;
            END IF;
            BEGIN
            l_err_key := 5;
                IF r_lov.TAB not LIKE 'FGD_NFR_BUDG_AGG_UNITS%' THEN
                    INSERT INTO LOVS_MIG (OLD_LOV_SID, NEW_LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, OLD_TABLE)
                    VALUES (r_lov.lov_sid, l_lov_key, l_lov_type_key, r_lov.DESCR, r_lov.NEED_DET, r_lov.TAB);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN 
                l_err_key := 51;
                    LOG_FAIL('LOVS_MIG', SYSDATE, 'Error migrating ' || r_lov.TAB, r_lov.lov_sid);
            END;
                LOG_info('LOVS_MIG', SYSDATE, 'Migrated with SUCC ' || r_lov.TAB, r_lov.lov_sid);
                
            l_lov_key := 0;
        END LOOP;
        CLOSE c_old_lovs;
        l_lov_type_key := 0;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN 
        LOG_FAIL('GEN ERR', null, sqlerrm(), l_err_key);
END;
/
DECLARE

    CURSOR c_institution_types IS
        SELECT institution_type_sid, institution_type_id, descr, help_text, null as need_det
          from fgd_nfr_institution_types order by 1;
    
l_lov_type_key NUMBER;
l_lov_key NUMBER;
BEGIN
    BEGIN
        INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID)
        VALUES ('NFRITYP', 'NFR Institution Types', 0)
        RETURNING LOV_TYPE_SID INTO l_lov_type_key;
    EXCEPTION
        WHEN OTHERS THEN
            LOG_FAIL('NFR Institution Types FAIL', sysdate, sqlerrm(), 0);
    END;
        INSERT INTO LOV_TYPES_MIG(NEW_LOV_TYPE_SID, LOV_TYPE_ID, OLD_TABLE)
        VALUES (l_lov_type_key, 'NFRITYP', 'FGD_NFR_INSTITUTION_TYPES');
    FOR r_lov IN c_institution_types LOOP
        BEGIN
            INSERT INTO CFG_LOVS(LOV_TYPE_SID, DESCR, NEED_DET, ORDER_BY, HELP_TEXT, CHOICE_LIMIT)
                VALUES (l_lov_type_key, r_lov.DESCR, null, null, r_lov.HELP_TEXT, null)
                RETURNING LOV_SID INTO l_lov_key;
            
        EXCEPTION
            WHEN OTHERS THEN
                LOG_FAIL('CFG_LOVS', sysdate, sqlerrm(), 1);
        END;
            INSERT INTO LOVS_MIG (OLD_LOV_SID, NEW_LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, OLD_TABLE)
                VALUES (r_lov.institution_type_sid, l_lov_key, l_lov_type_key, r_lov.DESCR, null, 'FGD_NFR_INSTITUTION_TYPES');
    END LOOP;
    
    
    
 EXCEPTION 
    WHEN OTHERS THEN
        LOG_FAIL('MIG ENTRIES FAIL', sysdate, sqlerrm(), 0);
END;
/


update LOVS_MIG
set old_lov_sid = 20006
where old_lov_sid = 20004 and new_lov_sid = 5;
commit;

DECLARE
    CURSOR c_data IS
        SELECT LM.NEW_LOV_SID,
               S.SECTOR_ID
          FROM LOVS_MIG LM,
               FGD_NFR_SECTORS S
         WHERE S.SECTOR_SID = LM.OLD_LOV_SID
           AND LM.OLD_TABLE = 'FGD_NFR_SECTORS';  

BEGIN
    FOR rec IN c_data LOOP
        UPDATE CFG_LOVS
           SET LOV_ID = rec.SECTOR_ID
         WHERE LOV_SID = rec.NEW_LOV_SID;  
    END LOOP;
END;
/ 

DECLARE
    CURSOR c_old_lovs(pi_table_name varchar2, PI_LOV_TYPE_SID number) IS
       with t as (SELECT
        imr.sector_sid as lov_sid,
        NULL as lov_id,
        21100 + imr.lov_sid as lov_type_sid,
        imr.descr,
        imr.provide_details as need_det,
        imr.order_by,
        NULL as cfg_type,
        NULL as help_text,
        null as choice_limit,
        'FGD_IFI_MONIT_RULES' AS TAB
    FROM
        fgd_ifi_monit_rules imr
    UNION ALL
    SELECT
        imr.sector_sid + 101010 as lov_sid,
        NULL as lov_id,
        22100 + imr.lov_sid as lov_type_sid,
        imr.descr,
        imr.provide_details as need_det,
        imr.order_by,
        imr.response_type_sid as cfg_type,
        NULL as help_text,
        null as choice_limit,
        'FGD_IFI_TRIG_ESCC' AS TAB
    FROM
        fgd_ifi_trig_escc imr)
        select t.lov_sid, t.lov_id, t.lov_type_sid, t.descr, t.need_det, t.order_by, t.cfg_type, t.help_text, t.choice_limit, t.tab
    FROM t WHERE t.tab = pi_table_name AND T.LOV_TYPE_SID = PI_LOV_TYPE_SID;
    
    CURSOR c_old_lov_types IS
    SELECT DISTINCT A.RESPONSE_GROUP_SID AS OLD_LOV_TYPE_SID , C.DESCR AS COUNTRY_ID, 'FGD_IFI_MONIT_RULES' AS TAB,  'MONITRULES' AS LOV_TYPE_ID, 'Rules monitored by IFI' AS lov_descr
        FROM  FGD_CFG_RESPONSE_CHOICES_VW A
            ,FGD_IFI_MONIT_RULES B
            ,FGD_CFG_RESPONSE_CHOICES_VW C
        WHERE A.RESPONSE_GROUP_SID  = 21100 + B.LOV_SID 
          AND C.RESPONSE_SID = B.LOV_SID
    UNION
    SELECT DISTINCT A.RESPONSE_GROUP_SID AS OLD_LOV_TYPE_SID , C.DESCR AS COUNTRY_ID, 'FGD_IFI_TRIG_ESCC' AS TAB, 'TRIGRULES' AS LOV_TYPE_ID, 'Triggering escapes clauses' AS LOV_DESCR
        FROM  FGD_CFG_RESPONSE_CHOICES_VW A
            ,FGD_IFI_TRIG_ESCC B
            ,FGD_CFG_RESPONSE_CHOICES_VW C
        WHERE A.RESPONSE_GROUP_SID  = 22100 + B.LOV_SID
           AND C.RESPONSE_SID = B.LOV_SID
    ORDER BY 3,2;
    
    r_lovs c_old_lovs%rowtype;    
    l_is_gg NUMBER;

    l_prefix_monit NUMBER := 600;
    l_prefix_escc NUMBER := 700;

    l_new_lov_type_sid NUMBER;
    l_country_rec CFG_LOVS%ROWTYPE;
    
    l_key NUMBER := 0;
BEGIN
    
    FOR r_old_lov_type IN c_old_lov_types LOOP
        BEGIN
            INSERT INTO CFG_LOV_TYPES(LOV_TYPE_ID, DESCR, DYN_SID)
            VALUES (r_old_lov_type.LOV_TYPE_ID || r_old_lov_type.COUNTRY_ID, r_old_lov_type.LOV_DESCR || r_old_lov_type.COUNTRY_ID, 2)
            RETURNING LOV_TYPE_SID INTO l_new_lov_type_sid;
        EXCEPTION
            WHEN OTHERS THEN 
                LOG_FAIL('CFG_LOV_TYPES', sysdate, sqlerrm(), -11);
        END;
        commit;
        l_key := 11;
        INSERT INTO LOV_TYPES_MIG(OLD_LOV_TYPE_SID, NEW_LOV_TYPE_SID, LOV_TYPE_ID, OLD_TABLE)
        VALUES (r_old_lov_type.OLD_LOV_TYPE_SID, l_new_lov_type_sid, r_old_lov_type.LOV_TYPE_ID || r_old_lov_type.COUNTRY_ID, r_old_lov_type.TAB);
        
        l_key := 12;
        SELECT * INTO l_country_rec FROM CFG_LOVS WHERE DESCR = r_old_lov_type.COUNTRY_ID;
        l_key := 13;
        INSERT INTO CFG_DYNAMIC_LOVS(LOV_TYPE_SID, DYN_SID, USED_LOV_TYPE_SID, USED_LOV_SID, APP_ID_DEP, COUNTRY_DEP, DESCR)
        VALUES (l_new_lov_type_sid, 2, l_country_rec.LOV_TYPE_SID, l_country_rec.LOV_SID, 'NFR', 1, 'Rule {ENTRY_NO}: {QV1} - {QV2} - Coverage of GG finances: {COVERAGE}');
        l_key := 14;
        OPEN c_old_lovs(r_old_lov_type.TAB, r_old_lov_type.OLD_LOV_TYPE_SID);
        LOOP
            FETCH c_old_lovs INTO r_lovs;
            EXIT WHEN c_old_lovs%NOTFOUND;
            l_key := 15;
            IF r_lovs.DESCR LIKE '%General Government%' THEN
                l_is_gg := 1;
            ELSE
                l_is_gg := 0;
            END IF;
            l_key := 16;
            IF r_old_lov_type.LOV_TYPE_ID = 'MONITRULES' THEN
                INSERT INTO CFG_SPECIAL_LOVS(LOV_TYPE_SID, LOV_SID, DESCR, ORDER_BY, IS_GG, CFG_TYPE, NEED_DET)
                VALUES (l_new_lov_type_sid, TO_NUMBER(l_prefix_monit ||l_country_rec.LOV_SID || r_lovs.ORDER_BY), r_lovs.DESCR, r_lovs.ORDER_BY, l_is_gg, r_lovs.CFG_TYPE, r_lovs.NEED_DET);
                l_key := 17;
                INSERT INTO LOVS_MIG(OLD_LOV_SID, NEW_LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, OLD_TABLE)
                VALUES (r_lovs.LOV_SID, TO_NUMBER(l_prefix_monit ||l_country_rec.LOV_SID || r_lovs.ORDER_BY), l_new_lov_type_sid, r_lovs.DESCR, r_lovs.NEED_DET, r_lovs.TAB);
            ELSE
                INSERT INTO CFG_SPECIAL_LOVS(LOV_TYPE_SID, LOV_SID, DESCR, ORDER_BY, IS_GG, CFG_TYPE, NEED_DET)
                VALUES (l_new_lov_type_sid, TO_NUMBER(l_prefix_escc ||l_country_rec.LOV_SID || r_lovs.ORDER_BY), r_lovs.DESCR, r_lovs.ORDER_BY, l_is_gg, r_lovs.CFG_TYPE, r_lovs.NEED_DET);
                l_key := 17;
                INSERT INTO LOVS_MIG(OLD_LOV_SID, NEW_LOV_SID, LOV_TYPE_SID, DESCR, NEED_DET, OLD_TABLE)
                VALUES (r_lovs.LOV_SID, TO_NUMBER(l_prefix_escc ||l_country_rec.LOV_SID || r_lovs.ORDER_BY), l_new_lov_type_sid, r_lovs.DESCR, r_lovs.NEED_DET, r_lovs.TAB);
            END IF;
            
        END LOOP;
        CLOSE c_old_lovs;
        
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN 
        LOG_FAIL('CFG_SPECIAL_LOVS', null, sqlerrm(), l_key);
END;    
/
