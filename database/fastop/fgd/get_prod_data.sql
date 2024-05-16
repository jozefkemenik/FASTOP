DECLARE
    CURSOR c_tables_del IS
    SELECT * FROM (
    SELECT 'ENTRY_CHOICES' AS tab, 1 AS order_by FROM DUAL
    UNION
    SELECT 'TARGET_ENTRIES' AS tab, 2 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_ADD_INFOS' AS tab, 3 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CRITERIA_COMMENTS' AS tab, 4 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_ACCEPTED_CRITERIA' AS tab, 5 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CRITERIA' AS tab, 6 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRIES_ADD_CFG' AS tab, 7 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_ADD_INFOS_ARCH' AS tab, 8 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_ARCH' AS tab, 9 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_EDIT_STEPS' AS tab, 10 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRIES' AS tab, 11 AS order_by FROM DUAL)
    ORDER BY order_by;
    
    CURSOR c_trigs IS
    SELECT 'ENTRIES_TRG' AS trg FROM DUAL
    UNION
    SELECT 'ENTRY_CRITERIA_COMMENTS_TRG' AS trg FROM DUAL
    UNION
    SELECT 'ENTRY_CRITERIA_TRG' AS trg FROM DUAL
    UNION
    SELECT 'ENTRY_EDIT_STEPS_TRG1' AS trg FROM DUAL
    UNION
    SELECT 'ENTRY_EDIT_STEPS_TRG2' AS trg FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_TRG' AS trg FROM DUAL;
    
    CURSOR c_tables_ins IS
    SELECT * FROM (
    SELECT 'ENTRY_CHOICES' AS tab, 1 AS order_by FROM DUAL
    UNION
    SELECT 'TARGET_ENTRIES' AS tab, 2 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_ADD_INFOS' AS tab, 3 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CRITERIA_COMMENTS' AS tab, 4 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_ACCEPTED_CRITERIA' AS tab, 5 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CRITERIA' AS tab, 6 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRIES_ADD_CFG' AS tab, 7 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_ADD_INFOS_ARCH' AS tab, 8 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_ARCH' AS tab, 9 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRY_EDIT_STEPS' AS tab, 10 AS order_by FROM DUAL
    UNION
    SELECT 'ENTRIES' AS tab, 11 AS order_by FROM DUAL)
    ORDER BY order_by DESC;
    
    l_statement VARCHAR2(4000 BYTE);
    l_dif_val NUMBER;
    l_max_val NUMBER;
    
    CURSOR c_rounds IS
    SELECT DISTINCT ACC.ROUND_SID AS ACC_ROUND, PROD.ROUND_SID AS PROD_ROUND, ACC.YEAR, ACC.PERIOD_SID, ACC.PERIOD_ID FROM 
        VW_ROUNDS ACC, VW_ROUNDS@FASTOP PROD WHERE ACC.YEAR = PROD.YEAR AND ACC.PERIOD_SID = PROD.PERIOD_SID AND ACC.VERSION = PROD.VERSION
         AND PROD.PERIOD_SID IN (1, 4);
    
    CURSOR c_tab_rounds IS
    SELECT 'ENTRY_CRITERIA' AS tab FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_ARCH' AS tab FROM DUAL
    UNION
    SELECT 'ENTRY_CHOICES_ADD_INFOS_ARCH' AS tab FROM DUAL
    UNION
    SELECT 'ENTRY_EDIT_STEPS' AS tab FROM DUAL;
    
    CURSOR c_res_seq IS
    SELECT DISTINCT S.SEQUENCE_NAME, S.LAST_NUMBER, T.TABLE_NAME, T.COLUMN_NAME FROM USER_SEQUENCES S, user_cons_columns T, USER_CONSTRAINTS U WHERE T.TABLE_NAME = SUBSTR(SEQUENCE_NAME, 0, LENGTH(SEQUENCE_NAME)-4)
AND T.TABLE_NAME IN ('ENTRY_EDIT_STEPS', 'ENTRIES', 'ENTRY_CRITERIA_COMMENTS', 'ENTRY_CRITERIA', 'ENTRY_CHOICES')
AND U.CONSTRAINT_TYPE = 'P' AND U.CONSTRAINT_NAME = T.CONSTRAINT_NAME;
        
    
    
BEGIN
    SAVEPOINT SavePoint1;
    --DELETE STATEMENTS
    FOR rec IN c_tables_del LOOP
        l_statement := 'DELETE '||rec.tab;
        EXECUTE IMMEDIATE l_statement;
    END LOOP;
    
    --DISABLE TRIGGERS
    FOR rec IN c_trigs LOOP
        l_statement := 'ALTER TRIGGER ' || rec.trg || ' DISABLE';
        EXECUTE IMMEDIATE l_statement;
    END LOOP;
    
    --INSERT DATA
    FOR rec IN c_tables_ins LOOP
        l_statement := 'INSERT INTO '|| rec.tab || ' SELECT * FROM '|| rec.tab ||CHR(64) || 'FGD';
        EXECUTE IMMEDIATE l_statement;
    END LOOP;
    
    --RESET SEQUENCES
    FOR rec IN c_res_seq LOOP
        l_statement := 'SELECT MAX(' || rec.COLUMN_NAME || ')  FROM ' || rec.TABLE_NAME;
        EXECUTE IMMEDIATE l_statement INTO l_max_val;
        l_dif_val := l_max_val - rec.LAST_NUMBER;
        l_statement := 'ALTER SEQUENCE ' || rec.SEQUENCE_NAME || ' INCREMENT BY ' || l_dif_val;
        EXECUTE IMMEDIATE l_statement;
        l_statement := 'SELECT ' || rec.SEQUENCE_NAME || '.NEXTVAL FROM DUAL';
        EXECUTE IMMEDIATE l_statement;
        l_statement := 'ALTER SEQUENCE ' || rec.SEQUENCE_NAME || ' INCREMENT BY 1';
        EXECUTE IMMEDIATE l_statement;    
    END LOOP;
    
    --ENABLE TRIGGERS
    FOR rec IN c_trigs LOOP
        l_statement := 'ALTER TRIGGER ' || rec.trg || ' ENABLE';
        EXECUTE IMMEDIATE l_statement;
    END LOOP;
    
    --UPDATE ROUND INFO
    FOR tabRec IN c_tab_rounds LOOP
        FOR rec IN c_rounds LOOP
            l_statement := 'UPDATE '||tabRec.tab || ' SET ROUND_SID = ' || rec.ACC_ROUND || ' WHERE ROUND_SID = '|| rec.PROD_ROUND;
            EXECUTE IMMEDIATE l_statement;
        END LOOP;
    END LOOP;
exception
    when others then
    dbms_output.put_line(sqlerrm);
    rollback to SavePoint1;
END;
/