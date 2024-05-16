/* Formatted on 24-02-2021 11:12:37 (QP5 v5.313) */
DECLARE
   TYPE t_array IS VARRAY(200) OF VARCHAR2(64);

   PROCEDURE createAmecoCountryGroup
   IS
      cf_array    t_array
                     := t_array('BE'
                              , 'DK'
                              , 'EL'
                              , 'ES'
                              , 'FR'
                              , 'IE'
                              , 'IT'
                              , 'LU'
                              , 'NL'
                              , 'PT'
                              , 'UK'
                              , 'DE'
                              , 'CH'
                              , 'AT'
                              , 'NO'
                              , 'SE'
                              , 'FI'
                              , 'PL'
                              , 'CZ'
                              , 'HU'
                              , 'LV'
                              , 'LT'
                              , 'EE'
                              , 'TR'
                              , 'CY'
                              , 'MT'
                              , 'IS'
                              , 'US'
                              , 'BG'
                              , 'RO'
                              , 'SK'
                              , 'SI'
                              , 'HR'
                              , 'MK'
                              , 'ME'
                              , 'JP'
                              , 'BA'
                              , 'RS'
                              , 'AL'
                              , 'UA'
                              , 'MD'
                              , 'GE'
                              , 'RU');
      brics_array t_array
                     := t_array('CA'
                              , 'MX'
                              , 'KR'
                              , 'AU'
                              , 'NZ'
                              , 'CN'
                              , 'HK'
                              , 'BR'
                              , 'IN'
                              , 'ID'
                              , 'AR'
                              , 'SA'
                              , 'ZA');
   BEGIN
      INSERT INTO GEO_AREAS(GEO_AREA_ID
                          , CODEISO3
                          , DESCR
                          , GEO_AREA_TYPE
                          , ORDER_BY)
           VALUES ('AMECOCF'
                 , 'AMECOCF'
                 , 'AMECO forecast transfer CF file'
                 , 'COUNTRY_GROUP'
                 , 9999);

      INSERT INTO GEO_AREAS(GEO_AREA_ID
                          , CODEISO3
                          , DESCR
                          , GEO_AREA_TYPE
                          , ORDER_BY)
           VALUES ('AMECOBRC'
                 , 'AMECOBRC'
                 , 'AMECO forecast transfer BRICS file'
                 , 'COUNTRY_GROUP'
                 , 9999);

      FOR i IN 1 .. cf_array.LAST LOOP
         INSERT INTO COUNTRY_GROUPS(COUNTRY_GROUP_ID, COUNTRY_ID, ORDER_BY)
              VALUES ('AMECOCF', cf_array(i), i);
      END LOOP;

      FOR i IN 1 .. brics_array.LAST LOOP
         INSERT INTO COUNTRY_GROUPS(COUNTRY_GROUP_ID, COUNTRY_ID, ORDER_BY)
              VALUES ('AMECOBRC', brics_array(i), i);
      END LOOP;
   END createAmecoCountryGroup;
BEGIN
   createAmecoCountryGroup();
END;
