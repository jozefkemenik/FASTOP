DELIMITER //
DROP PROCEDURE IF EXISTS getAmecoSeries
//
CREATE PROCEDURE getAmecoSeries( IN p_indicator_ids     TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                               , IN p_country_ids       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                               , IN p_default_countries TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci)
BEGIN
    SELECT *
      FROM (
           SELECT
                  concat(S.code_serie, '.', S.num_trn, '.', S.ameco_agg, '.', S.num_unit, '.', S.num_ref) as indicator_id
                , N.nom_serie_transform as descr
                , S.unit_pays as unit
                , S.date_deb as start_year
                , S.serie as vector
                , A.name_nation as country_descr
                , A.code_ameco as country_id_iso3
                , '' as country_id_iso2
                , A.defaut_pays as default_country
                , S.num_ordre as order_by
             FROM serie S
       INNER JOIN nomserie N ON S.nom_serie_id = N.id
       INNER JOIN nation A ON A.code_ameco = S.code_pays
       ) A
     WHERE (p_indicator_ids IS NULL OR find_in_set(indicator_id collate utf8mb4_0900_ai_ci, p_indicator_ids collate utf8mb4_0900_ai_ci))
       AND (p_country_ids IS NULL OR find_in_set(country_id_iso3 collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
       AND (p_default_countries IS NULL OR default_country = p_default_countries)
  ORDER BY order_by ASC;
END
//
DROP PROCEDURE IF EXISTS getLastUpdateInfo
//
CREATE PROCEDURE getLastUpdateInfo()
BEGIN
    SELECT lastupdate FROM info;
END
//
DELIMITER ;
