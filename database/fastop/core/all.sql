@@../prerequisites.sql;

-- @@Types/sidslist.sql; --will throw an error if recreated since it has dependencies
@@Types/varcharlist.sql;
@@Types/numbersvector.sql;
@@Types/varcharobject.sql;
@@Types/measureobject.sql;
@@Types/vectorobject.sql;
@@Types/cloblist.sql;

@@Tables/help_msg_type.sql;
@@Tables/help_msgs.sql;
@@Tables/geo_areas.sql;
@@Tables/country_groups.sql;
@@Tables/st_status_repo.sql;
@@Tables/params.sql;
@@Tables/periods.sql;
@@Tables/rounds.sql;
@@Tables/storages.sql;
@@Tables/cust_storage_texts.sql;
@@Tables/applications.sql;
@@Tables/round_applications.sql;
@@Tables/period_applications.sql;
@@Tables/scales.sql;
@@Tables/template_types.sql;
@@Tables/template_files.sql;
@@Tables/storage_applications.sql;
@@Tables/geo_area_mappings.sql;

@@Views/rounds.sql;
@@Views/countries.sql;
@@Views/eu27_countries.sql;

@@Data/help_msg_type.sql;
@@Data/geo_areas.sql;
@@Data/country_groups.sql;
@@Data/st_status_repo.sql;
@@Data/periods.sql;
@@Data/rounds.sql;
@@Data/storages.sql;
@@Data/params.sql;
@@Data/cust_storage_texts.sql;
@@Data/applications.sql;
@@Data/round_applications.sql;
@@Data/period_applications.sql;
@@Data/scales.sql;
@@Data/template_types.sql;
@@Data/storage_applications.sql;
@@Data/geo_area_mappings.sql;
@@Data/neer_country_groups_order.sql;
@@Data/geo_areas_imf_codes.sql;
@@Data/geo_areas_currency.sql;
@@Data/help_msgs.sql --use this to put help_msgs

@@Packages/getters.pks;
@@Packages/getters.pkb;
@@Packages/commons.pks;
@@Packages/commons.pkb;
@@Packages/app_status.pks;
@@Packages/app_status.pkb;
@@Packages/templates.pks;
@@Packages/templates.pkb;
@@Packages/help.pks;
@@Packages/help.pkb;
@@Packages/error.pks;
@@Packages/error.pkb;

-- @@migration/help_msgs.sql; --CST db_link not available

