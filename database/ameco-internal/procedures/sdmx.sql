DELIMITER //
DROP PROCEDURE IF EXISTS getAnnexSeriesDataSdmx
//
CREATE PROCEDURE getAnnexSeriesDataSdmx( IN p_country_ids TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                       , IN p_codes       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                       , IN p_trns        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                       , IN p_aggs        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                       , IN p_units       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                       , IN p_refs        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci)
BEGIN
    SELECT
           S.code_pays as GEO
         , S.code_serie as INDICATOR
         , S.num_trn as TRN
         , S.ameco_agg as AGG
         , S.num_unit as UNIT
         , S.num_ref as REF
         , S.serie as TIME_SERIE
         , S.date_deb as START_YEAR
    FROM serie_a S
    WHERE (p_country_ids IS NULL OR find_in_set(S.code_pays collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
      AND (p_codes IS NULL OR find_in_set(S.code_serie collate utf8mb4_0900_ai_ci, p_codes collate utf8mb4_0900_ai_ci))
      AND (p_trns IS NULL OR find_in_set(S.num_trn collate utf8mb4_0900_ai_ci, p_trns collate utf8mb4_0900_ai_ci))
      AND (p_aggs IS NULL OR find_in_set(S.ameco_agg collate utf8mb4_0900_ai_ci, p_aggs collate utf8mb4_0900_ai_ci))
      AND (p_units IS NULL OR find_in_set(S.num_unit collate utf8mb4_0900_ai_ci, p_units collate utf8mb4_0900_ai_ci))
      AND (p_refs IS NULL OR find_in_set(S.num_ref collate utf8mb4_0900_ai_ci, p_refs collate utf8mb4_0900_ai_ci));
END
//
DROP PROCEDURE IF EXISTS getCurrentSeriesDataSdmx
//
CREATE PROCEDURE getCurrentSeriesDataSdmx( IN p_country_ids TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                         , IN p_codes       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                         , IN p_trns        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                         , IN p_aggs        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                         , IN p_units       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                         , IN p_refs        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci)
BEGIN
    SELECT
        S.code_pays as GEO
         , S.code_serie as INDICATOR
         , S.num_trn as TRN
         , S.ameco_agg as AGG
         , S.num_unit as UNIT
         , S.num_ref as REF
         , S.serie as TIME_SERIE
         , S.date_deb as START_YEAR
    FROM serie S
    WHERE (p_country_ids IS NULL OR find_in_set(S.code_pays collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
      AND (p_codes IS NULL OR find_in_set(S.code_serie collate utf8mb4_0900_ai_ci, p_codes collate utf8mb4_0900_ai_ci))
      AND (p_trns IS NULL OR find_in_set(S.num_trn collate utf8mb4_0900_ai_ci, p_trns collate utf8mb4_0900_ai_ci))
      AND (p_aggs IS NULL OR find_in_set(S.ameco_agg collate utf8mb4_0900_ai_ci, p_aggs collate utf8mb4_0900_ai_ci))
      AND (p_units IS NULL OR find_in_set(S.num_unit collate utf8mb4_0900_ai_ci, p_units collate utf8mb4_0900_ai_ci))
      AND (p_refs IS NULL OR find_in_set(S.num_ref collate utf8mb4_0900_ai_ci, p_refs collate utf8mb4_0900_ai_ci));
END
//
DROP PROCEDURE IF EXISTS getRestrictedSeriesDataSdmx
//
CREATE PROCEDURE getRestrictedSeriesDataSdmx( IN p_country_ids TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                            , IN p_codes       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                            , IN p_trns        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                            , IN p_aggs        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                            , IN p_units       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                            , IN p_refs        TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci)
BEGIN
    SELECT
        S.code_pays as GEO
         , S.code_serie as INDICATOR
         , S.num_trn as TRN
         , S.ameco_agg as AGG
         , S.num_unit as UNIT
         , S.num_ref as REF
         , S.serie as TIME_SERIE
         , S.date_deb as START_YEAR
    FROM serie_r S
    WHERE (p_country_ids IS NULL OR find_in_set(S.code_pays collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
      AND (p_codes IS NULL OR find_in_set(S.code_serie collate utf8mb4_0900_ai_ci, p_codes collate utf8mb4_0900_ai_ci))
      AND (p_trns IS NULL OR find_in_set(S.num_trn collate utf8mb4_0900_ai_ci, p_trns collate utf8mb4_0900_ai_ci))
      AND (p_aggs IS NULL OR find_in_set(S.ameco_agg collate utf8mb4_0900_ai_ci, p_aggs collate utf8mb4_0900_ai_ci))
      AND (p_units IS NULL OR find_in_set(S.num_unit collate utf8mb4_0900_ai_ci, p_units collate utf8mb4_0900_ai_ci))
      AND (p_refs IS NULL OR find_in_set(S.num_ref collate utf8mb4_0900_ai_ci, p_refs collate utf8mb4_0900_ai_ci));
END
//
DELIMITER ;
