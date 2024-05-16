/* Formatted on 1/8/2019 17:01:09 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE UM_AUTHZ_ACCESSORS
AS
   /******************************************************************************
      NAME:       UM_AUTHZ_ACCESSORS
      PURPOSE:    UM authorisation data accessors: getters and setters

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       08/01/2019   rokosra          Created this package.
   ******************************************************************************/

   PROCEDURE getAuthzCountries (o_cur OUT SYS_REFCURSOR);

   PROCEDURE getLdapUser(p_ldap_host    IN    VARCHAR2,
                         p_ldap_port    IN    VARCHAR2,
                         p_ldap_user    IN    VARCHAR2,
                         p_ldap_passwd  IN    VARCHAR2,
                         p_ldap_base    IN    VARCHAR2,
                         p_email        IN    VARCHAR2,
                         o_cur          OUT   SYS_REFCURSOR);

   PROCEDURE getAuthzGroups (o_cur OUT SYS_REFCURSOR);
END;
