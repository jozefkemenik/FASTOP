/* Formatted on 12/2/2019 13:31:53 (QP5 v5.252.13127.32847) */
SET DEFINE OFF;
ALTER TABLE HELP_MSGS DISABLE ALL TRIGGERS;
/
INSERT INTO HELP_MSGS (HELP_MSG_SID, DESCR, MESS)
SELECT HELP_MSG_SID, DESCR, MESS
FROM HELP_MSGS@SCOPAX
WHERE DESCR IS NOT NULL OR MESS IS NOT NULL;
/
COMMIT;
/
DROP SEQUENCE HELP_MSGS_SEQ;
/
DECLARE
    l_seq NUMBER;
BEGIN
    SELECT MAX(HELP_MSG_SID) + 1
    INTO l_seq
    FROM HELP_MSGS;

    EXECUTE IMMEDIATE 'CREATE SEQUENCE HELP_MSGS_SEQ START WITH ' || l_seq;
END;
/
CREATE OR REPLACE TRIGGER HELP_MSGS_TRG
   BEFORE INSERT
   ON HELP_MSGS
   FOR EACH ROW
BEGIN
   SELECT HELP_MSGS_SEQ.NEXTVAL INTO :NEW.HELP_MSG_SID FROM DUAL;
END;
/
ALTER TABLE HELP_MSGS ENABLE ALL TRIGGERS;