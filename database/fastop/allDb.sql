/* Formatted on 12/19/2019 12:02:13 (QP5 v5.252.13127.32847) */
--migration tables (MIGR_*) should be ready before running this

--CREATE DATABASE LINK "SCOPAX"
--CONNECT TO "SCOPAX" IDENTIFIED BY "password"
--USING 'EX1UECFA';

WHENEVER SQLERROR EXIT WARNING
/
DECLARE
   l_schema   VARCHAR2 (32);
BEGIN
   SELECT SYS_CONTEXT ('userenv', 'current_schema') INTO l_schema FROM DUAL;

   IF 'FASTOP' != l_schema
   THEN
      raise_application_error (-20001, 'Invalid schema');
   END IF;
END;
/
WHENEVER SQLERROR CONTINUE
/
@migration/all.sql;
@core/all.sql;
@st/all.sql;
@um/all.sql;
@menu/all.sql;
@idr/all.sql;
@gd/all.sql;
@agg/all.sql;
@dfm/all.sql;
@dbp/all.sql;
@drm/all.sql;
@scp/all.sql;
@fdms/all.sql;
@fgd/all.sql;
@task/all.sql;
@auxtools/all.sql;
@ameco/all.sql;
@addin/all.sql;
@stats/all.sql;
@dwh/all.sql;
@fpadmin/all.sql;
@notification/all.sql;
@dsload/all.sql;

