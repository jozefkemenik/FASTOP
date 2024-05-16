-- AC
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('AC', 'AC', 'Acceding Countries', 'COUNTRY_GROUP', 9999);

Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Acceding Countries', 'AC');

-- ACC
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('ACC', 'ACC', 'Acceding and Candidate Countries', 'COUNTRY_GROUP', 9999);

Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Acceding and Candidate Countries', 'ACC');

-- AEEXEU28
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('AEEXEU28', 'AEEXEU28', 'Advanced economies excluding EU(before Brexit)', 'COUNTRY_GROUP', 9999);

Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Advanced economies excluding EU(before Brexit)', 'AEEXEU28');

-- ADEC
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Advanced economies', 'ADEC');

-- AEEXEUAC
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('AEEXEUAC', 'AEEXEUAC', 'Advanced economies, excluding EU, acceding and candidate countries', 'COUNTRY_GROUP', 9999);

Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Advanced economies, non-EU, non-ACC', 'AEEXEUAC');

-- ADECEXEU
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('AdvancedEconomiesExclEU', 'ADECEXEU');

-- EMDA
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Asia', 'EMDA');

-- EMDAEXC
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('AsiaExclChina', 'EMDAEXCN');

-- CC
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Candidate Countries', 'CC');

-- EA12
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('EA12', 'EA12', 'Euro area (12 countries)', 'COUNTRY_GROUP', 9999);

-- EA13
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('EA13', 'EA13', 'Euro area (13 countries)', 'COUNTRY_GROUP', 9999);

-- EA15
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('EA15', 'EA15', 'Euro area (15 countries)', 'COUNTRY_GROUP', 9999);

-- EA16
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('EA16', 'EA16', 'Euro area (16 countries)', 'COUNTRY_GROUP', 9999);

-- EU_ADJ
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('EU, adjusted', 'EU_ADJ');

-- EU12
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('EU12', 'EU12', 'European Union (composition in 1986-1994)', 'COUNTRY_GROUP', 9999);

-- EU25
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('EU25', 'EU25', 'European Union 25 members (years 2004-2006)', 'COUNTRY_GROUP', 9999);

-- EMDE
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Emerging and developing economies', 'EMDE');

-- EMDEEXCN
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('EmergingExclChina', 'EMDEEXCN');

-- EA_ADJ
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Euro area, adjusted', 'EA_ADJ');

-- FU35
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('FU35', 'FU35', 'Double exports 35 industrial countries: EU-27 CH NR TR US CA MX JP AU NZ', 'COUNTRY_GROUP', 9999);

-- KR
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('KO', 'KR');

-- LATAM
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Latin America', 'LATAM');

-- MENA
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('MENA (Middle East and Northern Africa)', 'MENA');

-- OASIA
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Other Asia', 'OASIA');

-- OCIS
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Other CIS', 'OCIS');

-- OLATAM
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Other Latin America', 'OLATAM');

-- POTCAND
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('POTCAND', 'POTCAND', 'Potential Candidates', 'COUNTRY_GROUP', 9999);

Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('Potential Candidates', 'POTCAND');

-- TCE_OADE
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('TCE_OADE', 'TCE_OADE', 'TCE: Other Advanced Economies', 'COUNTRY_GROUP', 9999);

Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('TCE: Other Advanced Economies', 'TCE_OADE');

-- TCE_OASI
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('TCE_OASI', 'TCE_OASI', 'TCE: Rest of Asia', 'COUNTRY_GROUP', 9999);

Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('TCE: Rest of Asia', 'TCE_OASI');

-- WRLDEXEU
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('World excluding EU', 'WRLDEXEU');

-- WOEXEU28
Insert into GEO_AREAS(GEO_AREA_ID, CODEISO3, DESCR, GEO_AREA_TYPE, ORDER_BY)
Values('WOEXEU28', 'WOEXEU28', 'World excluding EU(before Brexit)', 'COUNTRY_GROUP', 9999);

Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('World excluding EU(before Brexit)', 'WOEXEU28');

-- WRLDEXEA
Insert into GEO_AREA_MAPPINGS(SOURCE_DESCR, GEO_AREA_ID)
Values('World excluding euro area', 'WRLDEXEA');

