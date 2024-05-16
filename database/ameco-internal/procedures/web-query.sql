DELIMITER //
DROP PROCEDURE IF EXISTS getAmecoCurrent
//
CREATE PROCEDURE getAmecoCurrent( IN p_indicator_ids     TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                , IN p_country_ids       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                , IN p_default_countries TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci)
BEGIN
    SELECT indicator_id
         , descr
         , unit
         , start_year
         , vector
         , country_descr
         , country_id_iso3
         , country_id_iso2
      FROM (
           SELECT
                  concat(S.code_serie, '.', S.num_trn, '.', S.ameco_agg, '.', S.num_unit, '.', S.num_ref) as indicator_id
                , concat(S.num_trn, '.', S.ameco_agg, '.', S.num_unit, '.', S.num_ref, '.', S.code_serie) as ameco_indicator_id
                , N.nom_serie_transform as descr
                , N.nom_serie_allcodes as unit
                , S.date_deb as start_year
                , S.serie as vector
                , A.name_nation as country_descr
                , IF(A.code_ameco_iso3 = 'ROM', 'ROU', A.code_ameco_iso3) as country_id_iso3
                , A.code_ameco_iso2 as country_id_iso2
                , A.defaut_pays as default_country
                , A.order_ameco as order_ameco
             FROM serie S
       INNER JOIN nomserie N ON S.nom_serie_id = N.id
       INNER JOIN nationameco A ON A.code_ameco_iso3 = S.code_pays
       ) A
     WHERE (p_indicator_ids IS NULL OR find_in_set(indicator_id collate utf8mb4_0900_ai_ci, p_indicator_ids collate utf8mb4_0900_ai_ci))
       AND (p_country_ids IS NULL OR find_in_set(country_id_iso3 collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
       AND (p_default_countries IS NULL OR default_country = p_default_countries)
  ORDER BY ameco_indicator_id, order_ameco ASC;
END
//
DROP PROCEDURE IF EXISTS getAmecoPublic
//
CREATE PROCEDURE getAmecoPublic( IN p_indicator_ids     TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                               , IN p_country_ids       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                               , IN p_default_countries TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci)
BEGIN
    SELECT indicator_id
         , descr
         , unit
         , start_year
         , vector
         , country_descr
         , country_id_iso3
         , country_id_iso2
    FROM (
           SELECT
                  concat(S.code_serie, '.', S.num_trn, '.', S.ameco_agg, '.', S.num_unit, '.', S.num_ref) as indicator_id
                , concat(S.num_trn, '.', S.ameco_agg, '.', S.num_unit, '.', S.num_ref, '.', S.code_serie) as ameco_indicator_id
                , N.nom_serie_transform as descr
                , N.nom_serie_allcodes as unit
                , S.date_deb as start_year
                , S.serie as vector
                , A.name_nation as country_descr
                , IF(A.code_ameco_iso3 = 'ROM', 'ROU', A.code_ameco_iso3) as country_id_iso3
                , A.code_ameco_iso2 as country_id_iso2
                , A.defaut_pays as default_country
                , A.order_ameco as order_ameco
             FROM serie_a S
       INNER JOIN nomserie N ON S.nom_serie_id = N.id
       INNER JOIN nationameco A ON A.code_ameco_iso3 = S.code_pays
       ) A
     WHERE (p_indicator_ids IS NULL OR find_in_set(indicator_id collate utf8mb4_0900_ai_ci, p_indicator_ids collate utf8mb4_0900_ai_ci))
       AND (p_country_ids IS NULL OR find_in_set(country_id_iso3 collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
       AND (p_default_countries IS NULL OR default_country = p_default_countries)
  ORDER BY ameco_indicator_id, order_ameco ASC;
END
//
DROP PROCEDURE IF EXISTS getAmecoRestricted
//
CREATE PROCEDURE getAmecoRestricted( IN p_indicator_ids     TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                   , IN p_country_ids       TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                   , IN p_default_countries TEXT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci)
BEGIN
    SELECT indicator_id
         , descr
         , unit
         , start_year
         , vector
         , country_descr
         , country_id_iso3
         , country_id_iso2
      FROM (
           SELECT
                  concat(S.code_serie, '.', S.num_trn, '.', S.ameco_agg, '.', S.num_unit, '.', S.num_ref) as indicator_id
                , concat(S.num_trn, '.', S.ameco_agg, '.', S.num_unit, '.', S.num_ref, '.', S.code_serie) as ameco_indicator_id
                , N.nom_serie_transform as descr
                , N.nom_serie_allcodes as unit
                , S.date_deb as start_year
                , S.serie as vector
                , A.name_nation as country_descr
                , IF(A.code_ameco_iso3 = 'ROM', 'ROU', A.code_ameco_iso3) as country_id_iso3
                , A.code_ameco_iso2 as country_id_iso2
                , A.defaut_pays as default_country
                , A.order_ameco as order_ameco
             FROM serie_r S
       INNER JOIN nomserie N ON S.nom_serie_id = N.id
       INNER JOIN nationameco A ON A.code_ameco_iso3 = S.code_pays
       ) A
     WHERE (p_indicator_ids IS NULL OR find_in_set(indicator_id collate utf8mb4_0900_ai_ci, p_indicator_ids collate utf8mb4_0900_ai_ci))
       AND (p_country_ids IS NULL OR find_in_set(country_id_iso3 collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
       AND (p_default_countries IS NULL OR default_country = p_default_countries)
  ORDER BY ameco_indicator_id, order_ameco ASC;
END
//
DROP PROCEDURE IF EXISTS getLastUpdateInfo
//
CREATE PROCEDURE getLastUpdateInfo()
BEGIN
    SELECT lastupdate as current
         , lastupdate_a as annex
         , lastupdate_r as restricted
      FROM info;
END
//
DROP PROCEDURE IF EXISTS isForecastPeriod
//
CREATE PROCEDURE isForecastPeriod()
BEGIN
    SELECT forecastperiod as forecast_period
      FROM info;
END
//
DROP PROCEDURE IF EXISTS getMetadataCountries
//
CREATE PROCEDURE getMetadataCountries()
BEGIN
    SELECT
           IF(N.code_ameco_iso3 = 'ROM', 'ROU', N.code_ameco_iso3) as ctyIso3
         , N.code_ameco_iso2 as ctyIso2
         , N.name_nation as descr
         , N.order_ameco as orderBy
         , IF(N.defaut_pays = 'Y', 1, 0) as isDefault
      FROM nationameco N
  ORDER BY N.order_ameco;
END
//
DROP PROCEDURE IF EXISTS getMetadataTransformations
//
CREATE PROCEDURE getMetadataTransformations()
BEGIN
    SELECT
           T.num_trn as id
         , T.name_trn as descr
      FROM trn T
  ORDER BY T.num_trn;
END
//
DROP PROCEDURE IF EXISTS getMetadataAggregations
//
CREATE PROCEDURE getMetadataAggregations()
BEGIN
    SELECT
           A.ameco_agg as id
         , A.name_agg as descr
      FROM agg A
  ORDER BY A.ameco_agg;
END
//
DROP PROCEDURE IF EXISTS getMetadataUnits
//
CREATE PROCEDURE getMetadataUnits()
BEGIN
    SELECT
           U.num_unit as id
         , U.name_unit as descr
    FROM unit U
    ORDER BY U.num_unit;
END
//
DROP PROCEDURE IF EXISTS getMetadataSeries
//
CREATE PROCEDURE getMetadataSeries()
BEGIN
    SELECT
           concat(N.code_serie, '.', N.num_trn, '.', N.ameco_agg, '.', N.num_unit, '.', N.num_ref) as id
         , concat(N.nom_serie_transform, ' [', N.nom_serie_allcodes, ']') as descr
      FROM nomserie N
  ORDER BY N.code_serie;
END
//
DROP PROCEDURE IF EXISTS getMetadataTreeNodes
//
CREATE PROCEDURE getMetadataTreeNodes()
BEGIN
    SELECT
           A.code_serie as code
         , A.nom_serie as descr
         , A.niv_serie as level
         , A.num_ordre as orderBy
         , A.code_chap as parentCode
      FROM arbre A
  ORDER BY A.num_ordre;
END
//
DELIMITER ;
