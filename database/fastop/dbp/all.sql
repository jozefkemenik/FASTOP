@@../prerequisites.sql;

-- make sure SCALES table is created first: database/common/tables/scales.sql

@@Tables/esa.sql;
@@Tables/sources.sql;
@@Tables/acc_princip.sql;
@@Tables/adopt_status.sql
@@Tables/exercises.sql;
@@Tables/measures.sql;
@@Tables/cty_round_scales.sql;

@@Views/vw_measures.sql;

@@Data/esa.sql;
@@Data/sources.sql;
@@Data/acc_princip.sql;
@@Data/adopt_status.sql;
@@Data/exercises.sql;

@@Packages/getters.pks;
@@Packages/getters.pkb;
@@Packages/grid_data.pks;
@@Packages/grid_data.pkb;
@@Packages/measure.pks;
@@Packages/measure.pkb;

@@migration/measures.sql;
@@migration/cty_round_scales.sql;
