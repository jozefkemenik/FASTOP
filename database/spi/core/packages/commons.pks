CREATE OR REPLACE PACKAGE CORE_COMMONS
AS
   /******************************************************************************
         NAME:       CORE_COMMONS
         PURPOSE: Common global functionality
    ******************************************************************************/
   TYPE VARCHARARRAY IS TABLE OF VARCHAR2(4000 BYTE)
      INDEX BY PLS_INTEGER;

   FUNCTION arrayToList(p_array IN VARCHARARRAY)
      RETURN VARCHARLIST;

   PROCEDURE getCountries(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getProducts(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getIndustries(o_cur OUT SYS_REFCURSOR);

END CORE_COMMONS;
