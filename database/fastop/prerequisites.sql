 -- This is to protect the db from accidental run of all.sql scripts on existing db
 -- all.sql script are for setting up a new database

WHENEVER SQLERROR EXIT WARNING;
/
DECLARE
BEGIN
   raise_application_error (-20000, 'Do not run all.sql on existing db!!!');
END;
/
WHENEVER SQLERROR CONTINUE;
/
