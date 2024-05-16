CREATE OR REPLACE PACKAGE BODY CORE_INDICATOR
AS
   ----------------------------------------------------------------------------
   -- @name getIndicatorsSTRUCTURE
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsSTRUCTURE(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , NULL AS PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSSTRUCTURE ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'STRUCTURE'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsSTRUCTURE;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsCOMPETITION
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsCOMPETITION(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , NULL AS PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSCOMPETITION ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'COMPETITION'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsCOMPETITION;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsCOUNTRY
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsCOUNTRY(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , NULL AS PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSCOUNTRY ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'COUNTRY'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsCOUNTRY;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsDOMESTIC
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsDOMESTIC(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , NULL AS PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSDOMESTIC ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'DOMESTIC'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsDOMESTIC;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsEXTERNAL
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsEXTERNAL(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , NULL AS PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSEXTERNAL ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'EXTERNAL'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsEXTERNAL;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsEXTERNALGEO
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsEXTERNALGEO(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_destor_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_destor_ids);
      l_destor_count   NUMBER(3) := l_destor_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , ID.PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSEXTERNALGEO ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'EXTERNALGEO'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_destor_count = 0 OR ID.PARTNER IN (SELECT * FROM TABLE(l_destor_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsEXTERNALGEO;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsKNOWLEDGE
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsKNOWLEDGE(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , NULL AS PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSKNOWLEDGE ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'KNOWLEDGE'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsKNOWLEDGE;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsSKILLTECH
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsSKILLTECH(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , NULL AS PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSSKILLTECH ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'SKILLTECH'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsSKILLTECH;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsTRADE
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsTRADE(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , NULL AS PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSTRADE ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'TRADE'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsTRADE;

   ----------------------------------------------------------------------------
   -- @name getIndicatorsTRADEGEO
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorsTRADEGEO(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_ids       IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                        NULL AS CORE_COMMONS.VARCHARARRAY
                                                                     )
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_destor_ids          IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature_codes  IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_nomenclature        IN     VARCHAR2)
   IS
      l_country_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count   NUMBER(3) := l_country_ids.COUNT;
      l_destor_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_destor_ids);
      l_destor_count   NUMBER(3) := l_destor_ids.COUNT;
      l_indicator_ids   VARCHARLIST := CORE_COMMONS.arrayToList(p_indicator_ids);
      l_indicator_count NUMBER(3) := l_indicator_ids.COUNT;
      l_nomenclature_codes   VARCHARLIST := CORE_COMMONS.arrayToList(p_nomenclature_codes);
      l_nomenclature_codes_count NUMBER(3) := l_nomenclature_codes.COUNT;
   BEGIN
      OPEN o_cur FOR
         SELECT
               INDICATOR
             , INDICATORS.LABEL AS INDICATOR_LABEL
             , COUNTRY
             , ID.PARTNER
             , TYPEPROD
             , CODEPROD AS NOMENCLATURE
             , NM.LABEL AS NOMENCLATURE_LABEL
             , YYYY AS START_YEAR
             , VECTOR
         FROM  INDICATORSTRADEGEO ID
               LEFT OUTER JOIN INDICATORS
                          ON ID.INDICATOR = INDICATORS.ID_INDICATOR AND upper(INDICATORS.ID_DOMAIN) = 'TRADEGEO'
               LEFT OUTER JOIN VW_NOMENCLATURES NM
                          ON NM.CODE = ID.CODEPROD AND upper(NM.NOMENCLATURE_TYPE) = upper(p_nomenclature)
               LEFT OUTER JOIN NATION N
                          ON N.CODE_ISO2 = ID.COUNTRY
         WHERE (l_indicator_count = 0 OR INDICATOR IN (SELECT * FROM TABLE(l_indicator_ids)))
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_destor_count = 0 OR ID.PARTNER IN (SELECT * FROM TABLE(l_destor_ids)))
           AND (l_nomenclature_codes_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_nomenclature_codes)))
           AND upper(TYPEPROD) = upper(p_nomenclature)
         ORDER BY INDICATOR, CODEPROD, N.ORDRE;
   END getIndicatorsTRADEGEO;

   ----------------------------------------------------------------------------
   -- @name getIndicatorDownloadDate
   ----------------------------------------------------------------------------
   PROCEDURE getIndicatorDownloadDate(
     o_res                    OUT DATE
   , p_domain              IN     VARCHAR2)
   IS
   BEGIN
      SELECT UPDATE_DATE
        INTO o_res
        FROM UPDATE_INFO
       WHERE upper(DOMAIN) = upper(p_domain);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        o_res := NULL;
   END getIndicatorDownloadDate;

   ----------------------------------------------------------------------------
   -- @name getMatrix
   ----------------------------------------------------------------------------
   PROCEDURE getMatrix(
      o_cur                    OUT SYS_REFCURSOR
    , p_indicator_id        IN     VARCHAR2
    , p_country_ids         IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_products_ids        IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_years               IN     CORE_COMMONS.VARCHARARRAY DEFAULT CAST(
                                                                  NULL AS CORE_COMMONS.VARCHARARRAY
                                                               )
    , p_start_year          IN     NUMBER
    , p_end_year            IN     NUMBER
   )
   IS
      l_country_ids      VARCHARLIST := CORE_COMMONS.arrayToList(p_country_ids);
      l_country_count    NUMBER(3)   := l_country_ids.COUNT;
      l_products_ids     VARCHARLIST := CORE_COMMONS.arrayToList(p_products_ids);
      l_products_count   NUMBER(3)   := l_products_ids.COUNT;
      l_years            VARCHARLIST := CORE_COMMONS.arrayToList(p_years);
      l_years_count      NUMBER(3)   := l_years.COUNT;
   BEGIN
      OPEN o_cur FOR
        SELECT COUNTRY
             , YYYY AS YEAR
             , CODEPROD AS PRODUCT
             , INDICATOR
             , VECTOR
          FROM MATRIX
         WHERE INDICATOR = p_indicator_id
           AND (l_country_count = 0 OR COUNTRY IN (SELECT * FROM TABLE(l_country_ids)))
           AND (l_products_count = 0 OR CODEPROD IN (SELECT * FROM TABLE(l_products_ids)) OR CODEPROD = 'Code')
           AND ( (l_years_count > 0 AND TO_CHAR(YYYY) IN (SELECT * FROM TABLE(l_years))) OR
                 (l_years_count = 0 AND YYYY >= p_start_year AND YYYY <= p_end_year))
      ORDER BY COUNTRY, YYYY, CODEPROD;
   END getMatrix;

END CORE_INDICATOR;
/
