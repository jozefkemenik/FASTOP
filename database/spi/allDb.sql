WHENEVER SQLERROR EXIT WARNING
/
DECLARE
   l_schema   VARCHAR2 (32);
BEGIN
   SELECT SYS_CONTEXT ('userenv', 'current_schema') INTO l_schema FROM DUAL;

   IF 'SPI' != l_schema
   THEN
      raise_application_error (-20001, 'Invalid schema');
   END IF;
END;
/
WHENEVER SQLERROR CONTINUE
/
@core/all.sql;