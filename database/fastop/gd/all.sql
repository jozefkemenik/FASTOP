@@../prerequisites.sql;

/* Formatted on 6/6/2019 15:47:31 (QP5 v5.252.13127.32847) */
@@tables/consistency_statuses.sql;
@@tables/grid_types.sql;
@@tables/grids.sql;
@@tables/round_grids.sql;
@@tables/cty_versions.sql;
@@tables/cty_grids.sql;
@@tables/line_types.sql;
@@tables/lines.sql;
@@tables/col_types.sql;
@@tables/data_types.sql;
@@tables/cols.sql;
@@tables/round_grid_lines.sql;
@@tables/round_grid_cols.sql;
@@tables/cells.sql;
@@tables/grid_version_types.sql;
@@tables/footnotes.sql;
@@tables/cell_ftns.sql;
@@tables/optional_cells.sql;
@@tables/cty_default_levels.sql;

@@views/vw_grids.sql;
@@views/vw_cty_grids.sql;
@@views/vw_lines.sql;
@@views/vw_round_grid_lines.sql;
@@views/vw_cols.sql;
@@views/vw_round_grid_cols.sql;
@@views/vw_footnotes.sql;
@@views/vw_cells.sql;

@@data/consistency_statuses.sql;
@@data/cty_versions.sql;
@@data/line_types.sql;
@@data/col_types.sql;
@@data/grid_types.sql;
@@data/data_types.sql;
@@data/grid_version_type.sql;
@@data/non_euro_cty_group.sql;

--@@data/test_data/grids.sql;
--@@data/test_data/round_grids.sql;
--@@data/test_data/cty_grids.sql;
--@@data/test_data/lines.sql;
--@@data/test_data/cols.sql;
--@@data/test_data/round_grid_lines.sql;
--@@data/test_data/round_grid_cols.sql;
--@@data/test_data/cells.sql;
--@@data/test_data/footnotes.sql;
--@@data/test_data/cell_ftns.sql;
--@@data/test_data/optional_cells.sql;

@@packages/commons.pks;
@@packages/commons.pkb;
@@packages/getters.pks;
@@packages/getters.pkb;
@@packages/uploads.pks;
@@packages/uploads.pkb;
@@packages/linked_tables.pks;
@@packages/linked_tables.pkb;
@@packages/country_status.pks;
@@packages/country_status.pkb;
@@packages/grid_data.pks;
@@packages/grid_data.pkb;
@@packages/round.pks;
@@packages/round.pkb;

@@migration/grids.sql;
@@migration/ameco_indic_data.sql;
@@migration/calculated_indic_data.sql;
@@migration/estat_indic_data.sql;
@@migration/line_calc_rules.sql;
@@migration/semi_elastics.sql;
@@migration/help_msg_type.sql;
