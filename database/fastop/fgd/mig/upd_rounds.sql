DECLARE
    l_stmt VARCHAR2(2000 BYTE);
    CURSOR c_rounds IS
        SELECT OLD_ROUND_SID, NEW_ROUND_SID FROM ROUNDS_MIG;
    r_rounds c_rounds%ROWTYPE;        
    CURSOR c_data IS
        SELECT table_name, column_name FROM USER_TAB_COLS WHERE COLUMN_NAME = 'ROUND_SID' AND TABLE_NAME NOT LIKE '%MIG';
BEGIN
    OPEN c_rounds;
    LOOP
        FETCH c_rounds INTO r_rounds;
        EXIT WHEN c_rounds%NOTFOUND;
            FOR rec IN c_data LOOP
                l_stmt := 'UPDATE ' || rec.TABLE_NAME || ' SET ' || rec.COLUMN_NAME || ' = ' || r_rounds.NEW_ROUND_SID || ' WHERE ' || rec.COLUMN_NAME || ' = ' || r_rounds.OLD_ROUND_SID;
                EXECUTE IMMEDIATE l_stmt;
                COMMIT;
            END LOOP;
    END LOOP;
    CLOSE c_rounds;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('ROUND_SID UPDATE FAILED', sysdate, sqlerrm(), 0);
END;