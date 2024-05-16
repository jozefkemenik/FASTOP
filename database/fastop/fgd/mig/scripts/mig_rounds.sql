DECLARE 
    CURSOR c_data IS
        SELECT old.round_sid as old_round_sid
              ,new.round_sid as new_round_sid
              ,old.year
          FROM vw_rounds@fastop old
              ,vw_rounds new
         WHERE old.period_sid = 1
           AND new.period_sid = 1
           AND old.year = new.year;
BEGIN
    FOR rec IN c_data LOOP
        INSERT INTO ROUNDS_MIG(OLD_ROUND_SID, NEW_ROUND_SID, YEAR)
        VALUES (rec.OLD_ROUND_SID, rec.NEW_ROUND_SID, rec.YEAR);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        LOG_FAIL('ROUNDS_MIG', sysdate, sqlerrm(), 0);
END;
