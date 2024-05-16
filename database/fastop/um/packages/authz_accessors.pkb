create or replace PACKAGE BODY UM_AUTHZ_ACCESSORS
AS
   /******************************************************************************
      NAME:       UM_AUTHZ_ACCESSORS
      PURPOSE:    UM authorisation data accessors: getters and setters

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       08/01/2019   rokosra          Created this package body.
   ******************************************************************************/

   ----------------------------------------------------------------------------
   -- @name getAuthzCountries
   -- @return UM countries
   ----------------------------------------------------------------------------
   PROCEDURE getAuthzCountries (o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT C.COUNTRY_ID, C.DESCR
             FROM COUNTRIES C
         ORDER BY C.COUNTRY_ID;
   END;

   ----------------------------------------------------------------------------
   -- @name getAuthzGroups
   -- @return UM authorisation groups
   ----------------------------------------------------------------------------
   PROCEDURE getAuthzGroups (o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
           SELECT R.ROLE_ID GROUP_ID, R.DESCR
             FROM SECUNDA_ROLES R
         ORDER BY R.ROLE_SID;
   END;

   PROCEDURE getLdapUser(p_ldap_host    IN    VARCHAR2,
                         p_ldap_port    IN    VARCHAR2,
                         p_ldap_user    IN    VARCHAR2,
                         p_ldap_passwd  IN    VARCHAR2,
                         p_ldap_base    IN    VARCHAR2,
                         p_email        IN    VARCHAR2,
                         o_cur          OUT   SYS_REFCURSOR)
    IS
        v_searchEmail              VARCHAR2 (256);
        v_ldapsession              DBMS_LDAP.session;
        v_ldapattributequerylist   DBMS_LDAP.string_collection;
        v_ldapqueryresults         DBMS_LDAP.MESSAGE;
        v_berelement               DBMS_LDAP.ber_element;
        v_functionreturnvalue      PLS_INTEGER;
         ldap_host                  VARCHAR2 (256);
         ldap_port                  VARCHAR2 (256);
         ldap_user                  VARCHAR2 (256);
         ldap_passwd                VARCHAR2 (256);
         ldap_base                  VARCHAR2 (256);
        result                     VARCHAR2 (32000);

        attr_index                 NUMBER := 1;
        my_vals                    DBMS_LDAP.STRING_COLLECTION;
        my_entry                   VARCHAR2 (32000);
        my_attr_name               VARCHAR2 (32000);
        my_uid                     VARCHAR2 (256);
        my_cn                      VARCHAR2 (256);
        my_firstName               VARCHAR2 (256);
        my_lastName                VARCHAR2 (256);
        my_country                 VARCHAR2 (256);
        o_uid                      VARCHAR2(256);
        o_fullN                    VARCHAR2(256);
        o_firstName                VARCHAR2(256);
        o_lastName                 VARCHAR2(256);
        o_country                  VARCHAR2(256);
        o_cn                       VARCHAR2(256);
    BEGIN
        v_searchEmail                 := lower(p_email);
        -- Please customize the following variables as needed
        ldap_host                    := p_ldap_host;
        ldap_port                    := p_ldap_port;
        ldap_user                    := p_ldap_user; -- For instance 'uid=DIGIT_MY_APPLICATION,ou=TrustedApps,o=cec.eu.int'
        ldap_passwd                  := p_ldap_passwd; -- Dont forget the password
        ldap_base                    := p_ldap_base;
        -- end of customizable settings
        -- Choosing exceptions to be raised by DBMS_LDAP library.
        DBMS_LDAP.use_exception      := TRUE;
        result                       := '';
        v_ldapsession                := DBMS_LDAP.init
                                        (
                                        p_ldap_host, p_ldap_port
                                        );
        v_functionreturnvalue        := DBMS_LDAP.simple_bind_s
                                        (
                                        v_ldapsession, p_ldap_user, p_ldap_passwd
                                        );
        v_ldapattributequerylist (1) := 'uid';          --EU Login
        v_ldapattributequerylist (2) := 'cn';           --Fullname
        v_ldapattributequerylist (3) := 'givenName';    --FirstName
        v_ldapattributequerylist (4) := 'sn';           --LastName
        v_functionreturnvalue        := DBMS_LDAP.search_s
                                        (
                                        ld => v_ldapsession,
                                        base => p_ldap_base,
                                        scope => DBMS_LDAP.scope_subtree,
                                        filter => 'mail=' || v_searchEmail,
                                        attrs => v_ldapattributequerylist,
                                        attronly => 0,
                                        res => v_ldapqueryresults
                                        );
        v_functionreturnvalue        := DBMS_LDAP.count_entries
                                        (
                                        v_ldapsession, v_ldapqueryresults
                                        );

        o_country                    := UPPER(SUBSTR(TRIM(v_searchEmail), LENGTH(TRIM(v_searchEmail)) - 1, LENGTH(TRIM(v_searchEmail))));

        -- ----------------------------------------------------------------------
        IF v_functionreturnvalue > 0 THEN
            IF DBMS_LDAP.first_entry(v_ldapsession, v_ldapqueryresults) IS NOT NULL THEN
                my_entry := DBMS_LDAP.first_entry
                            (
                                v_ldapsession, v_ldapqueryresults
                            );
                my_attr_name := DBMS_LDAP.first_attribute(v_ldapsession,my_entry,v_berelement);

                FOR attr_index in 1..4 LOOP
                    my_vals := DBMS_LDAP.get_values (v_ldapsession, my_entry, my_attr_name);
                    dbms_output.put_line(' attr_index ' || attr_index);
                    IF my_vals.COUNT > 0 THEN
                        FOR idx IN my_vals.FIRST..my_vals.LAST LOOP
                            CASE my_attr_name
                                WHEN 'uid' THEN
                                    o_uid := SUBSTR(my_vals(idx),1,10);
                                WHEN 'cn' THEN
                                    o_cn := SUBSTR(my_vals(idx),1,35);
                                WHEN 'givenName' THEN
                                    o_firstName := SUBSTR(my_vals(idx),1,20);
                                WHEN 'sn' THEN
                                    o_lastName := SUBSTR(my_vals(idx),1,35);
                                ELSE
                                    NULL;
                            END CASE;
                        END LOOP;
                    END IF;
                    my_attr_name := DBMS_LDAP.next_attribute(v_ldapsession,my_entry,v_berelement);
                END LOOP;
                result := 'my_uid = ' || o_uid || '; cn = ' || o_cn || '; firstName = ' || o_firstName || '; lastName = ' || o_lastName ||
                            '; COUNTRY_ID = '  || o_country;
            END IF;
            dbms_output.put_line('result' || result);

        ELSE
            o_uid := -2;
        END IF;

        -- unbind from the directory
        v_functionreturnvalue        := DBMS_LDAP.unbind_s (v_ldapsession);
        OPEN o_cur FOR
            SELECT TRIM(v_searchEmail) as "email",
                   o_firstName as "firstName",
                   o_lastName as "lastName",
                   o_country as "country",
                   o_uid as "ecasUid",
                   o_cn as "fullName"
               FROM dual;
    -- Handle Exceptions
    EXCEPTION
        WHEN OTHERS
        THEN
        DBMS_OUTPUT.put_line (SQLERRM);
        DBMS_OUTPUT.put_line (' Exception encountered .. exiting');


    END;
END;