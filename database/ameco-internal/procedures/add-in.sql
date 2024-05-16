DELIMITER //
DROP PROCEDURE IF EXISTS getCountries
//
CREATE PROCEDURE getCountries()
BEGIN
    SELECT
           N.code_ameco AS COUNTRY_ID
         , N.name_nation AS NAME
      FROM nation N
     WHERE N.code_ameco IN (
               SELECT DISTINCT S.code_pays FROM serie S
           )
  ORDER BY N.defaut_pays DESC, N.name_nation;
END
//
DROP PROCEDURE IF EXISTS getNomSeries
//
CREATE PROCEDURE getNomSeries()
BEGIN
    SELECT
           N.id as SERIE_SID
         , concat(N.code_serie, '.', N.num_trn, '.', N.ameco_agg, '.', N.num_unit, '.', N.num_ref) as SERIE_ID
         , concat(N.nom_serie_transform, ' [', N.nom_serie_allcodes, ']') as DESCR
      FROM nomserie N;
END
//
DROP PROCEDURE IF EXISTS getChapters
//
CREATE PROCEDURE getChapters()
BEGIN
    SELECT
           A.id         as SID
         , A.code_serie as CODE
         , A.nom_serie  as DESCR
         , A.niv_serie  as LEVEL
         , A.node_type  as NODE_TYPE
         , A.num_ordre  as ORDER_BY
         , A.code_chap  as PARENT_CODE
    FROM arbre A
    ORDER BY A.niv_serie, A.num_ordre;
END
//
DROP PROCEDURE IF EXISTS getCurrentSeriesData
//
CREATE PROCEDURE getCurrentSeriesData( IN p_country_ids TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                     , IN p_serie_ids   TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci)
BEGIN
    SELECT
           S.code_pays as COUNTRY_ID
         , S.nom_serie_id as SERIE_SID
         , S.unit_pays as UNIT
         , S.serie as TIME_SERIE
         , S.date_deb as START_YEAR
      FROM serie S
     WHERE (p_country_ids IS NULL OR find_in_set(S.code_pays collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
       AND (p_serie_ids IS NULL OR find_in_set(S.nom_serie_id collate utf8mb4_0900_ai_ci, p_serie_ids collate utf8mb4_0900_ai_ci));
END
//
DROP PROCEDURE IF EXISTS getAnnexSeriesData
//
CREATE PROCEDURE getAnnexSeriesData( IN p_country_ids TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                   , IN p_serie_ids   TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci)
BEGIN
    SELECT
           S.code_pays as COUNTRY_ID
         , S.nom_serie_id as SERIE_SID
         , S.unit_pays as UNIT
         , S.serie as TIME_SERIE
         , S.date_deb as START_YEAR
      FROM serie_a S
     WHERE (p_country_ids IS NULL OR find_in_set(S.code_pays collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
       AND (p_serie_ids IS NULL OR find_in_set(S.nom_serie_id collate utf8mb4_0900_ai_ci, p_serie_ids collate utf8mb4_0900_ai_ci));
END
//
DROP PROCEDURE IF EXISTS getRestrictedSeriesData
//
CREATE PROCEDURE getRestrictedSeriesData( IN p_country_ids TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
                                        , IN p_serie_ids   TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci)
BEGIN
    SELECT
           S.code_pays as COUNTRY_ID
         , S.nom_serie_id as SERIE_SID
         , S.unit_pays as UNIT
         , S.serie as TIME_SERIE
         , S.date_deb as START_YEAR
      FROM serie_r S
     WHERE (p_country_ids IS NULL OR find_in_set(S.code_pays collate utf8mb4_0900_ai_ci, p_country_ids collate utf8mb4_0900_ai_ci))
       AND (p_serie_ids IS NULL OR find_in_set(S.nom_serie_id collate utf8mb4_0900_ai_ci, p_serie_ids collate utf8mb4_0900_ai_ci));
END
//
DELIMITER ;
