/* Formatted on 07/Dec/22 10:13:42 (QP5 v5.313) */
DECLARE
   l_ord         NUMBER(4) := 1;
   l_source_sid  NUMBER(8);

   PROCEDURE addSection(p_ord         IN OUT NUMBER
                      , p_section     IN     VARCHAR2
                      , p_descr       IN     VARCHAR2 DEFAULT NULL
                      , p_variable    IN     VARCHAR2 DEFAULT NULL
                      , p_source_sid  IN     NUMBER DEFAULT NULL
                      , p_from_year   IN     NUMBER DEFAULT 2020
                      , p_to_year     IN     NUMBER DEFAULT 2024)
   IS
      l_indicator_sid  NUMBER(8);
      l_worksheet_sid  NUMBER(8);
      l_glossary_sid   NUMBER(8);
   BEGIN
      UPDATE FP_TPL_WORKSHEET
         SET ORDER_BY = p_ord
       WHERE NAME = p_section;

      IF p_ord = 0 THEN
         DELETE FROM INDICATOR_LISTS
               WHERE WORKBOOK_GROUP_SID = (SELECT WORKBOOK_GROUP_SID
                                             FROM WORKBOOK_GROUPS
                                            WHERE WORKBOOK_GROUP_ID = 'linked_tables')
                 AND INDICATOR_SID = (SELECT INDICATOR_SID
                                        FROM INDICATORS
                                       WHERE INDICATOR_ID = p_variable || '.ecfin' AND SOURCE = 'uploaded');

         RETURN;
      END IF;

      IF SQL%ROWCOUNT = 0 THEN
         INSERT INTO INDICATORS(INDICATOR_ID, SOURCE, DESCR, IN_LT, SOURCE_SID)
              VALUES (p_variable || '.ecfin', 'uploaded', '', p_variable, p_source_sid)
           RETURNING INDICATOR_SID
                INTO l_indicator_sid;

         INSERT INTO FP_TPL_WORKSHEET(NAME, TITLE, START_YEAR, END_YEAR, ORDER_BY)
              VALUES (p_section, p_section, p_from_year, p_to_year, p_ord)
           RETURNING WORKSHEET_SID
                INTO l_worksheet_sid;

         INSERT INTO FP_TPL_GLOSSARY(DESCR, SECTION_NAME, EXPLANATION)
              VALUES (p_descr, p_section, p_descr)
           RETURNING GLOSSARY_SID
                INTO l_glossary_sid;

         INSERT INTO FP_TPL_INDICATORS(WORKSHEET_SID, INDICATOR_SID, GLOSSARY_SID, ORDER_BY)
              VALUES (l_worksheet_sid, l_indicator_sid, l_glossary_sid, 1);

         INSERT INTO INDICATOR_LISTS(INDICATOR_SID, WORKBOOK_GROUP_SID)
            SELECT l_indicator_sid, WORKBOOK_GROUP_SID
              FROM WORKBOOK_GROUPS
             WHERE WORKBOOK_GROUP_ID = 'linked_tables';
      ELSIF p_descr IS NOT NULL THEN
         UPDATE FP_TPL_GLOSSARY
            SET DESCR = p_descr, EXPLANATION = p_descr
          WHERE SECTION_NAME = p_section;
      END IF;

      p_ord := p_ord + 1;
   END;
BEGIN
   SELECT SOURCE_SID
     INTO l_source_sid
     FROM SOURCES
    WHERE SOURCE_ID = 'C1';

   addSection(
      l_ord
    , 'NFCPEcontr'
    , 'Nationally financed current primary expenditure (contribution to the fiscal stance) based on COM forecast'
    , 'nfcpecontr'
    , l_source_sid
   );
   addSection(l_ord
            , 'OCEcontr'
            , 'Other capital expenditure (contribution to the fiscal stance) based on COM forecast'
            , 'ocecontr'
            , l_source_sid);
   addSection(l_ord, 'RRF_EUcontr', 'RRF and EU (contribution to the FI) based on COM forecast', 'rrfeu', l_source_sid);
   addSection(l_ord
            , 'NFIcontr'
            , 'Nationally financed investment (contribution to the FI) based on COM forecast'
            , 'nfi'
            , l_source_sid);
   addSection(l_ord, 'EB', 'Expenditure benchmark based on COM forecast', 'eb', l_source_sid);
   addSection(l_ord, 'EBSCP', 'Expenditure benchmark based on SCP', 'ebscp', l_source_sid);
   addSection(l_ord, 'EBDBP', 'Expenditure benchmark based on DBP', 'ebdbp', l_source_sid);
   addSection(
      l_ord
    , 'FICORR'
    , 'Fiscal impulse (including EU-financed expenditure, EXCLUDING crisis-related temporary measures) based on COM forecast'
    , 'ficorr'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'FI'
    , 'Fiscal impulse (including EU-financed expenditure, INCLUDING crisis-related temporary measures) based on COM forecast'
    , 'fi'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'FISCP'
    , 'Fiscal impulse (including EU-financed expenditure, INCLUDING crisis-related temporary measures) based on SCP'
    , 'fiscp'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'FIDBP'
    , 'Fiscal impulse (including EU-financed expenditure, INCLUDING crisis-related temporary measures) based on DBP'
    , 'fidbp'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPE'
    , 'Nationally financed primary expenditure, net of discretionary revenue measures (based on COM forecast) - growth rate'
    , 'nfpe'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPESCP'
    , 'Nationally financed primary expenditure, net of discretionary revenue measures (based on SCP) - growth rate'
    , 'nfpescp'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPEDBP'
    , 'Nationally financed primary expenditure, net of discretionary revenue measures (based on DBP) - growth rate'
    , 'nfpedbp'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPECorr'
    , 'Nationally financed primary expenditure (net of discretionary revenue measures excluding crisis-related temporary measures) - based on COM forecast - growth rate'
    , 'nfpecorr'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPCECorr'
    , 'Nationally financed primary current expenditure (net of discretionary revenue measures and crisis-related temporary measures) - based on COM forecast - growth rate'
    , 'nfpcecorr'
    , l_source_sid
   );
   addSection(l_ord
            , 'NFPCE'
            , 'Nationally financed primary current expenditure (net of discretionary revenue measures) - growth rate'
            , 'nfpce'
            , l_source_sid);
   addSection(
      l_ord
    , 'NFPCESCP'
    , 'Nationally financed primary current expenditure (net of discretionary revenue measures) - based on SCP - growth rate'
    , 'nfpcescp'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPCEDBP'
    , 'Nationally financed primary current expenditure (net of discretionary revenue measures) - based on DBP - growth rate'
    , 'nfpcedbp'
    , l_source_sid
   );
   addSection(l_ord, 'AVPOTGWTH', '10-year average potential growth based on COM forecast', 'avpotgwth', l_source_sid);
   addSection(l_ord, 'EML', 'Total budgetary cost of energy measures (level)', 'eml', l_source_sid);
   addSection(l_ord, 'EMC', 'Change in total budgetary cost of energy measures', 'emc', l_source_sid);
   addSection(l_ord
            , 'TTSEP'
            , 'Temporary and targeted support to households and firms most vulnerable to energy price hikes'
            , 'ttsep'
            , l_source_sid);
   addSection(l_ord, 'REFUA', 'Support to persons fleeing Ukraine', 'refUA', l_source_sid);
   addSection(l_ord, 'CRISMEA', 'Crisis-related temporary measures based on COM forecast', 'crismea', l_source_sid);
   addSection(l_ord, 'GAPSCP');
   addSection(l_ord, 'GAPDBP');
   addSection(l_ord, 'GAP');
   addSection(l_ord, 'MLSASCP');
   addSection(l_ord, 'MLSADBP');
   addSection(l_ord, 'MLSA');
   addSection(l_ord, 'GDP deflators');
   addSection(l_ord, 'MTO');
   addSection(l_ord, 'Benchmark Rate');
   addSection(l_ord, 'Cycunempl');
   addSection(l_ord, 'SBfrozen');
   addSection(l_ord, 'Preventive');
   addSection(l_ord, 'Auxiliary');
   addSection(l_ord, 'Corrective');


   -- the below sections are not used any more
   l_ord := 0;
   addSection(l_ord
            , 'NFCPESCPcontr'
            , 'Nationally financed current primary expenditure (contribution to the fiscal stance) based on SCP'
            , 'nfcpescpcontr'
            , l_source_sid);
   addSection(l_ord
            , 'NFCPEDBPcontr'
            , 'Nationally financed current primary expenditure (contribution to the fiscal stance) based on DBP'
            , 'nfcpedbpcontr'
            , l_source_sid);
   addSection(l_ord
            , 'OCESCPcontr'
            , 'Other capital expenditure (contribution to the fiscal stance) based on SCP'
            , 'ocescpcontr'
            , l_source_sid);
   addSection(l_ord
            , 'OCEDBPcontr'
            , 'Other capital expenditure (contribution to the fiscal stance) based on DBP'
            , 'ocedbpcontr'
            , l_source_sid);
   addSection(l_ord, 'RRF_EUSCPcontr', 'RRF and EU (contribution to the FI) based on SCP', 'rrfeuscp', l_source_sid);
   addSection(l_ord, 'RRF_EUDBPcontr', 'RRF and EU (contribution to the FI) based on DBP', 'rrfeudbp', l_source_sid);
   addSection(l_ord
            , 'NFISCPcontr'
            , 'Nationally financed investment (contribution to the FI) based on SCP'
            , 'nfiscp'
            , l_source_sid);
   addSection(l_ord
            , 'NFIDBPcontr'
            , 'Nationally financed investment (contribution to the FI) based on DBP'
            , 'nfidbp'
            , l_source_sid);
   addSection(
      l_ord
    , 'FISCPCORR'
    , 'Fiscal impulse (including EU-financed expenditure, EXCLUDING crisis-related temporary measures) based on SCP'
    , 'fiscpcorr'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'FIDBPCORR'
    , 'Fiscal impulse (including EU-financed expenditure, EXCLUDING crisis-related temporary measures) based on DBP'
    , 'fidbpcorr'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPESCPCorr'
    , 'Nationally financed primary expenditure (net of discretionary revenue measures excluding crisis-related temporary measures) - based on SCP - growth rate'
    , 'nfpescpcorr'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPEDBPCorr'
    , 'Nationally financed primary expenditure (net of discretionary revenue measures excluding crisis-related temporary measures) - based on DBP - growth rate'
    , 'nfpedbpcorr'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPCESCPCorr'
    , 'Nationally financed primary current expenditure (net of discretionary revenue measures and crisis-related temporary measures) - based on SCP - growth rate'
    , 'nfpcescpcorr'
    , l_source_sid
   );
   addSection(
      l_ord
    , 'NFPCEDBPCorr'
    , 'Nationally financed primary current expenditure (net of discretionary revenue measures and crisis-related temporary measures) - based on DBP - growth rate'
    , 'nfpcedbpcorr'
    , l_source_sid
   );
   addSection(l_ord, 'FADJ', 'Fiscal adj based on COM forecast', 'fadj', l_source_sid);
   addSection(l_ord, 'FESCP', 'Fiscal effort EB based on SCP', 'fescp', l_source_sid);
   addSection(l_ord, 'FADJSCP', 'Fiscal adj based on SCP', 'fadjscp', l_source_sid);
   addSection(l_ord, 'FE', 'Fiscal effort EB based on COM forecast', 'fe', l_source_sid);
   addSection(l_ord, 'CRISMEASCP', 'Crisis-related temporary measures based on SCP', 'crismeascp', l_source_sid);
   addSection(l_ord, 'EM', 'Change in total budgetary cost of energy measures', 'em', l_source_sid);
END;
/