/* Formatted on 18-08-2021 17:41:17 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DFM_GETTERS
AS
   /******************************************************************************
      NAME:       DFM_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        06/03/2019   lubiesz       1. Created this package.
   ******************************************************************************/

   FUNCTION getParameter(p_param_id IN VARCHAR2)
      RETURN VARCHAR2
   IS
      c1rec DFM_PARAMS%ROWTYPE;

      CURSOR c1
      IS
         SELECT *
           FROM DFM_PARAMS
          WHERE LOWER(param_id) = LOWER(p_param_id);
   BEGIN
      OPEN c1;

      FETCH c1 INTO c1Rec;

      CLOSE c1;

      RETURN c1Rec.VALUE;
   END getParameter;

   FUNCTION getRoundEsaInfoByRoundSid(p_round_sid IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2
   IS
      l_round_sid         NUMBER := CORE_GETTERS.getCurrentRoundSid();
      l_period_id         VARCHAR2(3) := NULL;
      l_year              NUMBER := NULL;

      l_esa2010_round_sid NUMBER := DFM_GETTERS.getParameter('ESA2010_ROUND');
   BEGIN
      IF (p_round_sid IS NOT NULL AND p_round_sid != -1) THEN
         l_round_sid := p_round_sid;
      END IF;

      SELECT period_id, year
        INTO l_period_id, l_year
        FROM vw_rounds
       WHERE round_sid = l_round_sid;

      IF (l_year >= 2017 AND l_round_sid >= l_esa2010_round_sid) THEN
         RETURN 'esa2010';
      ELSE
         RETURN 'esa95';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END getRoundEsaInfoByRoundSid;

   FUNCTION getRoundOOTypesInfoByRoundSid(p_round_sid IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      l_round_sid             NUMBER := CORE_GETTERS.getCurrentRoundSid();
      l_period_id             VARCHAR2(3) := NULL;
      l_year                  NUMBER := NULL;

      l_oot_enabled_round_sid NUMBER := DFM_GETTERS.getParameter('ONE_OFF_TYPES_ENABLED_ROUND');
   BEGIN
      IF (p_round_sid IS NOT NULL AND p_round_sid != -1) THEN
         l_round_sid := p_round_sid;
      END IF;

      SELECT period_id, year
        INTO l_period_id, l_year
        FROM vw_rounds
       WHERE round_sid = l_round_sid;

      IF (l_year >= 2017 AND l_round_sid >= l_oot_enabled_round_sid) THEN
         RETURN 2;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END getRoundOOTypesInfoByRoundSid;

   ----------------------------------------------------------------------------
   -- @name getParameter
   -- @return parameter value
   ----------------------------------------------------------------------------
   PROCEDURE getParameter(p_param_id IN VARCHAR2, o_res OUT VARCHAR2)
   AS
   BEGIN
      SELECT getParameter(p_param_id) INTO o_res FROM DUAL;
   END getParameter;

   ----------------------------------------------------------------------------
   -- @name getRoundStorage
   -- @return current round sid and storage sid
   ----------------------------------------------------------------------------
   PROCEDURE getRoundStorage(p_storage_id  IN     VARCHAR2
                           , o_round_sid      OUT NUMBER
                           , o_storage_sid    OUT NUMBER)
   IS
   BEGIN
      o_round_sid   := CORE_GETTERS.GETCURRENTROUNDSID();
      o_storage_sid := CORE_GETTERS.GETSTORAGESID(p_storage_id);
   END getRoundStorage;


   PROCEDURE getCustomTextInfo(o_cust_storage_text_sid    OUT NUMBER
                             , o_title                    OUT VARCHAR2
                             , o_descr                    OUT VARCHAR2
                             , p_cust_storage_text_sid IN     NUMBER DEFAULT NULL)
   AS
      l_cust_storage_text_sid CUST_STORAGE_TEXTS.CUST_STORAGE_TEXT_SID%TYPE;
   BEGIN
      IF p_cust_storage_text_sid IS NULL THEN
         l_cust_storage_text_sid := DFM_GETTERS.GETCURRENTCUSTOMTEXTSID();
      ELSE
         l_cust_storage_text_sid := p_cust_storage_text_sid;
      END IF;

      SELECT CST.CUST_STORAGE_TEXT_SID, CST.TITLE, CST.DESCR
        INTO o_cust_storage_text_sid, o_title, o_descr
        FROM CUST_STORAGE_TEXTS CST
       WHERE CST.CUST_STORAGE_TEXT_SID = l_cust_storage_text_sid;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         o_cust_storage_text_sid := NULL;
         o_descr                 := NULL;
   END;

   PROCEDURE getCustStorageTexts(p_round_sid IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR   SELECT T.CUST_STORAGE_TEXT_SID, T.TITLE, T.DESCR
                         FROM cust_storage_texts T
                        WHERE T.ROUND_SID = p_round_sid
                     ORDER BY T.CUST_STORAGE_TEXT_SID DESC;
   END;

   FUNCTION getCurrentAppSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getApplicationSid(DFM_GETTERS.APP_ID);
   END getCurrentAppSid;

   FUNCTION getCurrentCustomTextSid
      RETURN NUMBER
   IS
      l_count NUMBER;
      l_ret   NUMBER := NULL;
   BEGIN
      BEGIN
         SELECT COUNT(*)
           INTO l_count
           FROM STORAGES S
          WHERE S.STORAGE_SID = DFM_GETTERS.getCurrentStorageSid()
            AND S.IS_CUSTOM = 'Y'
            AND S.STORAGE_ID = 'CUST';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_count := 0;
      END;

      IF l_count > 0 THEN
         l_ret := DFM_GETTERS.getParameter('CURRENT_CUST_STORAGE');
      END IF;

      RETURN l_ret;
   END getCurrentCustomTextSid;

   PROCEDURE getEsaPeriod(p_round_sid IN NUMBER, o_res OUT VARCHAR2)
   IS
   BEGIN
      SELECT dfm_getters.getRoundEsaInfoByRoundSid(p_round_sid) AS esaPeriod INTO o_res FROM DUAL;
   END;

   PROCEDURE getOneOffTypesVersion(p_round_sid IN NUMBER, o_res OUT NUMBER)
   IS
   BEGIN
      SELECT COALESCE(dfm_getters.getRoundOOTypesInfoByRoundSid(p_round_sid), -1) AS version
        INTO o_res
        FROM DUAL;
   END;

   PROCEDURE getRevExp(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT rev_exp_sid, descr FROM dfm_rev_exp
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END;

   PROCEDURE getESACodes(o_cur OUT SYS_REFCURSOR, p_esa_period IN VARCHAR2 DEFAULT NULL)
   IS
      l_esa_period VARCHAR2(10);
   BEGIN
      IF p_esa_period IS NULL THEN
         l_esa_period := dfm_getters.getRoundEsaInfoByRoundSid();
      ELSE
         l_esa_period := p_esa_period;
      END IF;

      OPEN o_cur FOR SELECT esa95_sid esa_sid
                          , esa95_id  esa_id
                          , descr
                          , rev_exp_sid
                          , overview_sid
                       FROM VW_DFM_ALL_ESA
                      WHERE esa_period = l_esa_period
                     UNION ALL
                     SELECT -1
                          , NULL
                          , '< not set >'
                          , -1
                          , -1
                       FROM DUAL;
   END;

   PROCEDURE getEsaMultiOverviews(o_cur OUT SYS_REFCURSOR)
   IS 
   BEGIN
        OPEN o_cur FOR 
            SELECT e.esa2010_sid esa_sid,
                   e.esa2010_id  esa_id,
                   e.descr,
                   e.rev_exp_sid,
                   o.overview_sid
              FROM DFM_OVERVIEW_ESA o
              JOIN DFM_ESA2010 e ON e.esa2010_sid = o.esa2010_sid;
   END;
 

   PROCEDURE getOneOff(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT one_off_sid, descr FROM dfm_one_off
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END;

   PROCEDURE getOneOffPrinciples(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT oo_principle_sid, oo_principle_id, descr FROM dfm_oo_principles
                     UNION ALL
                     SELECT -1, NULL, '< not set >'
                       FROM DUAL;
   END;

   PROCEDURE getOneOffTypes(p_version IN NUMBER, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT one_off_type_sid, descr
                       FROM dfm_one_off_types
                      WHERE version = p_version
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END;

   PROCEDURE getOverviews(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT overview_sid, descr, codes, operator, order_by, is_filter FROM DFM_OVERVIEW
                     UNION ALL
                     SELECT -1, '< not set >', NULL, NULL, -1, 1
                       FROM DUAL
                     ORDER BY order_by;
   END;

   PROCEDURE getStatuses(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT status_sid, descr FROM dfm_status
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END;

   PROCEDURE getCountryCurrency(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT 0 AS "sid", MULTI_DESCR AS "descr"
                       FROM DFM_COUNTRIES_INFO
                      WHERE COUNTRY_ID = p_country_id;
   END getCountryCurrency;

   ----------------------------------------------------------------------------
   -- @name getCurrentStorageSid
   ----------------------------------------------------------------------------
   FUNCTION getCurrentStorageSid
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.getCurrentStorageSid(DFM_GETTERS.APP_ID);
   END getCurrentStorageSid;

   ----------------------------------------------------------------------------
   -- @name isCurrentStorage - function used to verify if passed in
   --    parameters correspond to the current storage
   -- @return 1 if ok, 0 if failed
   ----------------------------------------------------------------------------
   FUNCTION isCurrentStorage(p_round_sid     IN NUMBER
                           , p_storage_sid   IN NUMBER
                           , p_cust_text_sid IN NUMBER)
      RETURN NUMBER
   IS
      l_cur_text_sid NUMBER := DFM_GETTERS.GETCURRENTCUSTOMTEXTSID();
      l_ret          NUMBER := 1;
   BEGIN
      IF CORE_GETTERS.isCurrentStorage(DFM_GETTERS.APP_ID, p_round_sid, p_storage_sid) = 0
      OR (p_cust_text_sid IS NULL AND l_cur_text_sid IS NOT NULL)
      OR (p_cust_text_sid IS NOT NULL AND p_cust_text_sid != l_cur_text_sid) THEN
         l_ret := 0;
      END IF;

      RETURN l_ret;
   END isCurrentStorage;

   ----------------------------------------------------------------------------
   -- @name isCurrentStorageFinal
   ----------------------------------------------------------------------------
   FUNCTION isCurrentStorageFinal
      RETURN NUMBER
   IS
   BEGIN
      RETURN CORE_GETTERS.isCurrentStorageFinal(DFM_GETTERS.APP_ID);
   END isCurrentStorageFinal;

   ----------------------------------------------------------------------------
   -- @name getLabels
   ----------------------------------------------------------------------------
   PROCEDURE getLabels(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT LABEL_SID AS SID, DESCR AS DESCRIPTION FROM DFM_LABELS
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END getLabels;

   ----------------------------------------------------------------------------
   -- @name getEuFunds
   ----------------------------------------------------------------------------
   PROCEDURE getEuFunds(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR SELECT EU_FUND_SID sid, DESCR description FROM DFM_EU_FUNDS
                     UNION ALL
                     SELECT -1, '< not set >'
                       FROM DUAL;
   END getEuFunds;

   ----------------------------------------------------------------------------
   -- @name getOneOffYesSid
   ----------------------------------------------------------------------------
   FUNCTION getOneOffYesSid
      RETURN NUMBER
   IS
      l_sid DFM_ONE_OFF.ONE_OFF_SID%TYPE;
   BEGIN
      SELECT o.ONE_OFF_SID
        INTO l_sid
        FROM DFM_ONE_OFF o
       WHERE o.DESCR = 'Yes';

      RETURN l_sid;
   END getOneOffYesSid;
END DFM_GETTERS;
/