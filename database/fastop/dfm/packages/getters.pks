/* Formatted on 18-08-2021 17:43:09 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE DFM_GETTERS
AS
   /******************************************************************************
      NAME:       DFM_GETTERS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        06/03/2019   lubiesz       1. Created this package.
   ******************************************************************************/

   /******************************************************************************
                               CONSTANTS
   ******************************************************************************/
   APP_ID CONSTANT VARCHAR2(3) := 'DFM';

   /****************************************************************************/

   FUNCTION getParameter(p_param_id IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION getRoundEsaInfoByRoundSid(p_round_sid IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION getRoundOOTypesInfoByRoundSid(p_round_sid IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   PROCEDURE getParameter(p_param_id IN VARCHAR2, o_res OUT VARCHAR2);

   PROCEDURE getRoundStorage(p_storage_id  IN     VARCHAR2
                           , o_round_sid      OUT NUMBER
                           , o_storage_sid    OUT NUMBER);

   PROCEDURE getCustomTextInfo(o_cust_storage_text_sid    OUT NUMBER
                             , o_title                    OUT VARCHAR2
                             , o_descr                    OUT VARCHAR2
                             , p_cust_storage_text_sid IN     NUMBER DEFAULT NULL);

   PROCEDURE getCustStorageTexts(p_round_sid IN NUMBER, o_cur OUT SYS_REFCURSOR);

   FUNCTION getCurrentAppSid
      RETURN NUMBER;

   FUNCTION getCurrentCustomTextSid
      RETURN NUMBER;

   PROCEDURE getEsaPeriod(p_round_sid IN NUMBER, o_res OUT VARCHAR2);

   PROCEDURE getOneOffTypesVersion(p_round_sid IN NUMBER, o_res OUT NUMBER);

   PROCEDURE getRevExp(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getESACodes(o_cur OUT SYS_REFCURSOR, p_esa_period IN VARCHAR2 DEFAULT NULL);

   PROCEDURE getEsaMultiOverviews(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getOneOff(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getOneOffPrinciples(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getOneOffTypes(p_version IN NUMBER, o_cur OUT SYS_REFCURSOR);

   PROCEDURE getOverviews(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getStatuses(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getCountryCurrency(p_country_id IN VARCHAR2, o_cur OUT SYS_REFCURSOR);

   FUNCTION getCurrentStorageSid
      RETURN NUMBER;

   FUNCTION isCurrentStorage(p_round_sid     IN NUMBER
                           , p_storage_sid   IN NUMBER
                           , p_cust_text_sid IN NUMBER)
      RETURN NUMBER;

   FUNCTION isCurrentStorageFinal
      RETURN NUMBER;

   PROCEDURE getLabels(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getEuFunds(o_cur OUT SYS_REFCURSOR);

   FUNCTION getOneOffYesSid
      RETURN NUMBER;
END DFM_GETTERS;
/