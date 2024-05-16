CREATE OR REPLACE PACKAGE BODY CORE_COMMONS
AS
   ----------------------------------------------------------------------------
   -- @name arrayToList
   ----------------------------------------------------------------------------
   FUNCTION arrayToList(p_array IN VARCHARARRAY)
      RETURN VARCHARLIST
   AS
      l_list VARCHARLIST := VARCHARLIST();
   BEGIN
      IF p_array IS NOT NULL THEN
         l_list.EXTEND(p_array.COUNT);

         FOR i IN 1 .. p_array.COUNT LOOP
            l_list(i) := p_array(i);
         END LOOP;
      END IF;

      RETURN l_list;
   END arrayToList;

   ----------------------------------------------------------------------------
   -- @name getCountries
   ----------------------------------------------------------------------------
   PROCEDURE getCountries(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT CODE_ISO2 AS CODE
              , NAME_NATION AS LABEL
           FROM NATION;
   END getCountries;


   ----------------------------------------------------------------------------
   -- @name getProducts
   ----------------------------------------------------------------------------
   PROCEDURE getProducts(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT CODE
              , LABEL
           FROM CPA2008_MATRIX;
   END getProducts;

   ----------------------------------------------------------------------------
   -- @name getIndustries
   ----------------------------------------------------------------------------
   PROCEDURE getIndustries(o_cur OUT SYS_REFCURSOR)
   IS
   BEGIN
      OPEN o_cur FOR
         SELECT CODE
              , LABEL
           FROM INDUSTRIES2008;
   END getIndustries;

END CORE_COMMONS;
