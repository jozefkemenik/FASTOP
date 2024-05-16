SET DEFINE OFF;

-- Ameco unemployment indicators
INSERT INTO AMECO_INDICATORS(INDICATOR_CODE_SID, PROVIDER_SID, PERIODICITY_ID)
    SELECT IC.INDICATOR_CODE_SID, P.PROVIDER_SID, 'A'
      FROM AMECO_INDICATOR_CODES IC FULL JOIN AMECO_PROVIDERS P ON 1 = 1
     WHERE P.PROVIDER_ID IN ('UEP_RSLTS', 'UEP_RAW')
       AND IC.INDICATOR_ID IN ('NUTN'
                             , 'NETN'
                             , 'NETD'
                             , 'NECN'
                             , 'ZUTN');

COMMIT;
