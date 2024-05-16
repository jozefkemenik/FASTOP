/* Formatted on 26-05-2020 12:39:39 (QP5 v5.313) */
SET DEFINE OFF;

DECLARE
   TYPE r_data IS VARRAY(16) OF VARCHAR2(128);

   TYPE v_data IS VARRAY(512) OF r_data;

   l_type_sid CYCLICAL_ADJUSTMENT_TYPES.CYCLICAL_ADJUSTMENT_TYPE_SID%TYPE;
   l_data     v_data
      := v_data(
            r_data('BE', 'Indirect taxes', 'Units', '1')
          , r_data('BG', 'Indirect taxes', 'Units', '1')
          , r_data('CZ', 'Indirect taxes', 'Units', '1')
          , r_data('DK', 'Indirect taxes', 'Units', '1')
          , r_data('DE', 'Indirect taxes', 'Units', '1')
          , r_data('EE', 'Indirect taxes', 'Units', '1')
          , r_data('IE', 'Indirect taxes', 'Units', '1')
          , r_data('EL', 'Indirect taxes', 'Units', '1')
          , r_data('ES', 'Indirect taxes', 'Units', '1')
          , r_data('FR', 'Indirect taxes', 'Units', '1')
          , r_data('HR', 'Indirect taxes', 'Units', '1')
          , r_data('IT', 'Indirect taxes', 'Units', '1.1')
          , r_data('CY', 'Indirect taxes', 'Units', '1')
          , r_data('LV', 'Indirect taxes', 'Units', '1')
          , r_data('LT', 'Indirect taxes', 'Units', '1')
          , r_data('LU', 'Indirect taxes', 'Units', '1')
          , r_data('HU', 'Indirect taxes', 'Units', '1')
          , r_data('MT', 'Indirect taxes', 'Units', '1')
          , r_data('NL', 'Indirect taxes', 'Units', '1')
          , r_data('AT', 'Indirect taxes', 'Units', '1')
          , r_data('PL', 'Indirect taxes', 'Units', '1')
          , r_data('PT', 'Indirect taxes', 'Units', '1')
          , r_data('RO', 'Indirect taxes', 'Units', '1')
          , r_data('SI', 'Indirect taxes', 'Units', '1')
          , r_data('SK', 'Indirect taxes', 'Units', '1')
          , r_data('FI', 'Indirect taxes', 'Units', '1')
          , r_data('SE', 'Indirect taxes', 'Units', '1')
          , r_data('UK', 'Indirect taxes', 'Units', '1')
          , r_data('BE', 'Direct taxes', 'Units', '1.61635791')
          , r_data('BG', 'Direct taxes', 'Units', '1.432539197')
          , r_data('CZ', 'Direct taxes', 'Units', '1.73814419')
          , r_data('DK', 'Direct taxes', 'Units', '1.503994124')
          , r_data('DE', 'Direct taxes', 'Units', '1.81485206')
          , r_data('EE', 'Direct taxes', 'Units', '1.524310447')
          , r_data('IE', 'Direct taxes', 'Units', '1.741788975')
          , r_data('EL', 'Direct taxes', 'Units', '2.054669561')
          , r_data('ES', 'Direct taxes', 'Units', '1.709832678')
          , r_data('FR', 'Direct taxes', 'Units', '1.755318373')
          , r_data('HR', 'Direct taxes', 'Units', '1.782113246')
          , r_data('IT', 'Direct taxes', 'Units', '1.896643297')
          , r_data('CY', 'Direct taxes', 'Units', '2.064422782')
          , r_data('LV', 'Direct taxes', 'Units', '1.447803028')
          , r_data('LT', 'Direct taxes', 'Units', '1.509701377')
          , r_data('LU', 'Direct taxes', 'Units', '2.027994206')
          , r_data('HU', 'Direct taxes', 'Units', '1.8032378')
          , r_data('MT', 'Direct taxes', 'Units', '2.001098281')
          , r_data('NL', 'Direct taxes', 'Units', '2.220543155')
          , r_data('AT', 'Direct taxes', 'Units', '1.955799704')
          , r_data('PL', 'Direct taxes', 'Units', '2.051681908')
          , r_data('PT', 'Direct taxes', 'Units', '1.761820488')
          , r_data('RO', 'Direct taxes', 'Units', '1.564755402')
          , r_data('SI', 'Direct taxes', 'Units', '2.290406834')
          , r_data('SK', 'Direct taxes', 'Units', '1.872648073')
          , r_data('FI', 'Direct taxes', 'Units', '1.510120681')
          , r_data('SE', 'Direct taxes', 'Units', '1.382598439')
          , r_data('UK', 'Direct taxes', 'Units', '1.781582888')
          , r_data('BE', 'Social contributions', 'Units', '1.150619946')
          , r_data('BG', 'Social contributions', 'Units', '0.934433808')
          , r_data('CZ', 'Social contributions', 'Units', '0.99')
          , r_data('DK', 'Social contributions', 'Units', '0.697714034')
          , r_data('DE', 'Social contributions', 'Units', '0.860045971')
          , r_data('EE', 'Social contributions', 'Units', '1.357343345')
          , r_data('IE', 'Social contributions', 'Units', '1.50518721')
          , r_data('EL', 'Social contributions', 'Units', '0.83968158')
          , r_data('ES', 'Social contributions', 'Units', '0.819016054')
          , r_data('FR', 'Social contributions', 'Units', '0.948244313')
          , r_data('HR', 'Social contributions', 'Units', '0.997363484')
          , r_data('IT', 'Social contributions', 'Units', '0.967059069')
          , r_data('CY', 'Social contributions', 'Units', '1')
          , r_data('LV', 'Social contributions', 'Units', '0.999997981')
          , r_data('LT', 'Social contributions', 'Units', '0.999999449')
          , r_data('LU', 'Social contributions', 'Units', '0.890729256')
          , r_data('HU', 'Social contributions', 'Units', '0.988822449')
          , r_data('MT', 'Social contributions', 'Units', '0.924068087')
          , r_data('NL', 'Social contributions', 'Units', '0.856415637')
          , r_data('AT', 'Social contributions', 'Units', '0.923222062')
          , r_data('PL', 'Social contributions', 'Units', '0.973700716')
          , r_data('PT', 'Social contributions', 'Units', '1.000001079')
          , r_data('RO', 'Social contributions', 'Units', '0.99334352')
          , r_data('SI', 'Social contributions', 'Units', '1.00000031')
          , r_data('SK', 'Social contributions', 'Units', '1.188882897')
          , r_data('FI', 'Social contributions', 'Units', '1.004995081')
          , r_data('SE', 'Social contributions', 'Units', '0.947888075')
          , r_data('UK', 'Social contributions', 'Units', '1.197450245')
          , r_data('BE', 'Elasticity of revenue', 'Units', '0.987517267')
          , r_data('BG', 'Elasticity of revenue', 'Units', '0.784476164')
          , r_data('CZ', 'Elasticity of revenue', 'Units', '0.918936376')
          , r_data('DK', 'Elasticity of revenue', 'Units', '0.967810149')
          , r_data('DE', 'Elasticity of revenue', 'Units', '0.97496788')
          , r_data('EE', 'Elasticity of revenue', 'Units', '1.062169852')
          , r_data('IE', 'Elasticity of revenue', 'Units', '1.064892481')
          , r_data('EL', 'Elasticity of revenue', 'Units', '0.934388378')
          , r_data('ES', 'Elasticity of revenue', 'Units', '1.016582074')
          , r_data('FR', 'Elasticity of revenue', 'Units', '1.007389711')
          , r_data('HR', 'Elasticity of revenue', 'Units', '0.902162888')
          , r_data('IT', 'Elasticity of revenue', 'Units', '1.04663146')
          , r_data('CY', 'Elasticity of revenue', 'Units', '1.168926966')
          , r_data('LV', 'Elasticity of revenue', 'Units', '0.895177481')
          , r_data('LT', 'Elasticity of revenue', 'Units', '0.977260021')
          , r_data('LU', 'Elasticity of revenue', 'Units', '0.973190711')
          , r_data('HU', 'Elasticity of revenue', 'Units', '0.909175341')
          , r_data('MT', 'Elasticity of revenue', 'Units', '1.162526411')
          , r_data('NL', 'Elasticity of revenue', 'Units', '1.124211')
          , r_data('AT', 'Elasticity of revenue', 'Units', '0.988183534')
          , r_data('PL', 'Elasticity of revenue', 'Units', '1.0662534')
          , r_data('PT', 'Elasticity of revenue', 'Units', '0.951351284')
          , r_data('RO', 'Elasticity of revenue', 'Units', '0.834608043')
          , r_data('SI', 'Elasticity of revenue', 'Units', '0.91812028')
          , r_data('SK', 'Elasticity of revenue', 'Units', '0.891466798')
          , r_data('FI', 'Elasticity of revenue', 'Units', '0.899255425')
          , r_data('SE', 'Elasticity of revenue', 'Units', '0.973213695')
          , r_data('UK', 'Elasticity of revenue', 'Units', '1.243947376')
          , r_data('BE', 'Current tax burden as % of GDP', 'Units', '50.73846736')
          , r_data('BG', 'Current tax burden as % of GDP', 'Units', '35.72911443')
          , r_data('CZ', 'Current tax burden as % of GDP', 'Units', '40.09420212')
          , r_data('DK', 'Current tax burden as % of GDP', 'Units', '54.04438866')
          , r_data('DE', 'Current tax burden as % of GDP', 'Units', '44.26118627')
          , r_data('EE', 'Current tax burden as % of GDP', 'Units', '39.72223615')
          , r_data('IE', 'Current tax burden as % of GDP', 'Units', '31.60374665')
          , r_data('EL', 'Current tax burden as % of GDP', 'Units', '45.44630785')
          , r_data('ES', 'Current tax burden as % of GDP', 'Units', '37.31782349')
          , r_data('FR', 'Current tax burden as % of GDP', 'Units', '51.99272593')
          , r_data('HR', 'Current tax burden as % of GDP', 'Units', '43.08628892')
          , r_data('IT', 'Current tax burden as % of GDP', 'Units', '46.75917646')
          , r_data('CY', 'Current tax burden as % of GDP', 'Units', '38.09990025')
          , r_data('LV', 'Current tax burden as % of GDP', 'Units', '36.30222009')
          , r_data('LT', 'Current tax burden as % of GDP', 'Units', '34.24943665')
          , r_data('LU', 'Current tax burden as % of GDP', 'Units', '43.66949752')
          , r_data('HU', 'Current tax burden as % of GDP', 'Units', '45.66589245')
          , r_data('MT', 'Current tax burden as % of GDP', 'Units', '39.05203155')
          , r_data('NL', 'Current tax burden as % of GDP', 'Units', '43.36944174')
          , r_data('AT', 'Current tax burden as % of GDP', 'Units', '48.9630161')
          , r_data('PL', 'Current tax burden as % of GDP', 'Units', '38.95277317')
          , r_data('PT', 'Current tax burden as % of GDP', 'Units', '42.75142459')
          , r_data('RO', 'Current tax burden as % of GDP', 'Units', '32.72870661')
          , r_data('SI', 'Current tax burden as % of GDP', 'Units', '43.67868893')
          , r_data('SK', 'Current tax burden as % of GDP', 'Units', '37.75106205')
          , r_data('FI', 'Current tax burden as % of GDP', 'Units', '53.56928976')
          , r_data('SE', 'Current tax burden as % of GDP', 'Units', '50.62427072')
          , r_data('UK', 'Current tax burden as % of GDP', 'Units', '38.40919106')
          , r_data('BE', 'Elasticity of expenditure', 'Units', '-0.153850776')
          , r_data('BG', 'Elasticity of expenditure', 'Units', '-0.009500099')
          , r_data('CZ', 'Elasticity of expenditure', 'Units', '-0.015967764')
          , r_data('DK', 'Elasticity of expenditure', 'Units', '-0.102884106')
          , r_data('DE', 'Elasticity of expenditure', 'Units', '-0.150308509')
          , r_data('EE', 'Elasticity of expenditure', 'Units', '-0.150499262')
          , r_data('IE', 'Elasticity of expenditure', 'Units', '-0.246255604')
          , r_data('EL', 'Elasticity of expenditure', 'Units', '-0.04335221')
          , r_data('ES', 'Elasticity of expenditure', 'Units', '-0.331404457')
          , r_data('FR', 'Elasticity of expenditure', 'Units', '-0.10785322')
          , r_data('HR', 'Elasticity of expenditure', 'Units', '-0.025186903')
          , r_data('IT', 'Elasticity of expenditure', 'Units', '-0.045826506')
          , r_data('CY', 'Elasticity of expenditure', 'Units', '-0.059703719')
          , r_data('LV', 'Elasticity of expenditure', 'Units', '-0.054289338')
          , r_data('LT', 'Elasticity of expenditure', 'Units', '-0.082230053')
          , r_data('LU', 'Elasticity of expenditure', 'Units', '-0.109786472')
          , r_data('HU', 'Elasticity of expenditure', 'Units', '-0.013386037')
          , r_data('MT', 'Elasticity of expenditure', 'Units', '-0.022267486')
          , r_data('NL', 'Elasticity of expenditure', 'Units', '-0.205485957')
          , r_data('AT', 'Elasticity of expenditure', 'Units', '-0.124069687')
          , r_data('PL', 'Elasticity of expenditure', 'Units', '-0.097550447')
          , r_data('PT', 'Elasticity of expenditure', 'Units', '-0.14837822')
          , r_data('RO', 'Elasticity of expenditure', 'Units', '-0.019112483')
          , r_data('SI', 'Elasticity of expenditure', 'Units', '-0.038979352')
          , r_data('SK', 'Elasticity of expenditure', 'Units', '-0.015405336')
          , r_data('FI', 'Elasticity of expenditure', 'Units', '-0.154534175')
          , r_data('SE', 'Elasticity of expenditure', 'Units', '-0.118943671')
          , r_data('UK', 'Elasticity of expenditure', 'Units', '-0.025981863')
          , r_data('BE'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '53.84440011')
          , r_data('BG'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '37.14225298')
          , r_data('CZ'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '42.08499367')
          , r_data('DK'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '54.9295125')
          , r_data('DE'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '44.77347316')
          , r_data('EE'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '40.09837797')
          , r_data('IE'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '40.20795866')
          , r_data('EL'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '53.11126248')
          , r_data('ES'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '44.38989417')
          , r_data('FR'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '56.49937582')
          , r_data('HR'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '47.31351761')
          , r_data('IT'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '49.95517267')
          , r_data('CY'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '41.48402678')
          , r_data('LV'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '39.49851621')
          , r_data('LT'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '37.634625')
          , r_data('LU'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '42.70562566')
          , r_data('HU'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '48.79064321')
          , r_data('MT'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '40.65882555')
          , r_data('NL'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '45.72991965')
          , r_data('AT'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '51.36571712')
          , r_data('PL'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '43.06572395')
          , r_data('PT'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '48.66430008')
          , r_data('RO'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '36.80276047')
          , r_data('SI'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '48.53411907')
          , r_data('SK'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '41.52450218')
          , r_data('FI'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '55.08256099')
          , r_data('SE'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '50.65666873')
          , r_data('UK'
                 , 'Current expenditure excl. Interest (EDP definition) as % of GDP'
                 , 'Units'
                 , '44.44430463')
         );
BEGIN
   FOR i IN 1 .. l_data.COUNT LOOP
      BEGIN
         SELECT CYCLICAL_ADJUSTMENT_TYPE_SID
           INTO l_type_sid
           FROM CYCLICAL_ADJUSTMENT_TYPES
          WHERE DESCR = l_data(i)(2);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            INSERT INTO CYCLICAL_ADJUSTMENT_TYPES(DESCR)
                 VALUES (l_data(i)(2))
              RETURNING CYCLICAL_ADJUSTMENT_TYPE_SID
                   INTO l_type_sid;
      END;

      INSERT INTO CYCLICAL_ADJUSTMENTS(ROUND_SID
                                     , COUNTRY_ID
                                     , CYCLICAL_ADJUSTMENT_TYPE_SID
                                     , START_YEAR
                                     , VECTOR)
           VALUES (89
                 , l_data(i)(1)
                 , l_type_sid
                 , 2000
                 , l_data(i)(4));
   END LOOP;
END;
/
COMMIT;
