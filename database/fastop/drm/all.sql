@@../prerequisites.sql;

-- make sure SCALES table is created first: database/common/tables/scales.sql

@@Tables/cty_scales.sql;
@@Tables/measures.sql;
@@Tables/archived_measures.sql;
@@Tables/archived_cty_scales.sql;

@@Packages/getters.pks;
@@Packages/getters.pkb;
@@Packages/country_status.pks;
@@Packages/country_status.pkb;
@@Packages/app_status.pks;
@@Packages/app_status.pkb;
@@Packages/measure.pks;
@@Packages/measure.pkb;

@@migration/archived_measures.sql;
@@migration/archived_cty_scales.sql;
@@migration/cty_scales.sql;
@@migration/measures.sql;
