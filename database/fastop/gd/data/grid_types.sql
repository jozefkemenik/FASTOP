/* Formatted on 12/3/2019 16:05:19 (QP5 v5.252.13127.32847) */
SET DEFINE OFF;

INSERT INTO GD_GRID_TYPES (GRID_TYPE_SID, GRID_TYPE_ID, DESCR)
     VALUES (1, 'NORMAL', 'Standard grid');

INSERT INTO GD_GRID_TYPES (GRID_TYPE_SID, GRID_TYPE_ID, DESCR)
     VALUES (2, 'MEASURES', 'Measures grid');

INSERT INTO GD_GRID_TYPES (GRID_TYPE_SID, GRID_TYPE_ID, DESCR)
     VALUES (3, 'AGGREGATE', 'Aggregate grid - read only');

INSERT INTO GD_GRID_TYPES (GRID_TYPE_SID, GRID_TYPE_ID, DESCR)
        VALUES (
                  4
,                 'DIVERGENCE'
,                 'Divergence grid - read only, generated dynamically');

INSERT INTO GD_GRID_TYPES (GRID_TYPE_SID, GRID_TYPE_ID, DESCR)
     VALUES (5, 'GUARANTEES', 'Guarantees grid');

COMMIT;