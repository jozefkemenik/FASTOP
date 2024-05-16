/* Formatted on 20-11-2020 11:38:04 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY UM_USER_ACCESSORS
AS
   /******************************************************************************
      NAME:       UM_USER_ACCESSORS
      PURPOSE:    UM users data accessors: getters and setters
   ******************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getUserAuthzs
   -- @return user authorisations for all authorised applications
   ----------------------------------------------------------------------------
   PROCEDURE getUserAuthzs(p_user_id       IN     VARCHAR2
                         , p_unit_id       IN     VARCHAR2
                         , o_cur              OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT APP.APP_ID
                , S.ROLE_ID
                , U.LDAP_LOGIN
                , LISTAGG(DISTINCT COALESCE(A.COUNTRY_ID, CG.COUNTRY_ID), ',') WITHIN GROUP (ORDER BY COALESCE(A.COUNTRY_ID, CG.COUNTRY_ID)) COUNTRIES
             FROM UM_AUTHZS A
                  JOIN APPLICATIONS APP ON APP.APP_SID = A.APP_SID
                  JOIN SECUNDA_ROLES S ON S.ROLE_SID = A.ROLE_SID
                  JOIN UM_USERS U ON U.USER_SID = A.USER_SID
                  LEFT JOIN UM_AUTHZ_CTY_GRP CG ON CG.CTY_GRP_ID = A.CTY_GRP_ID
            WHERE (U.LDAP_LOGIN = p_user_id OR U.LDAP_LOGIN = p_unit_id)
         GROUP BY APP.APP_ID, S.ROLE_ID, U.LDAP_LOGIN;
   END;
END;
