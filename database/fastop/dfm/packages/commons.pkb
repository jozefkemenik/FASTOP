/* Formatted on 14-05-2020 16:24:29 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY DFM_COMMONS
AS
   /******************************************************************************
      NAME:       DFM_COMMONS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       06/03/2019    lubiesz        1. Created this package body.
   ******************************************************************************/

   PROCEDURE addvector(p_total     IN OUT NUMBERSVECTOR
                     , p_vector    IN     VARCHAR2
                     , p_delimiter IN     VARCHAR2 DEFAULT ',')
   IS
      l_string       VARCHAR2(1024) := p_vector || p_delimiter;
      l_comma_index  PLS_INTEGER;
      l_index        PLS_INTEGER := 1;
      l_vector_index PLS_INTEGER := 1;
      l_string_value VARCHAR2(64);
      l_value        NUMBER;
   BEGIN
      LOOP
         l_comma_index  := INSTR(l_string, p_delimiter, l_index);
         EXIT WHEN (l_comma_index = 0 OR l_vector_index > p_total.LIMIT);
         l_string_value := SUBSTR(l_string, l_index, l_comma_index - l_index);

         IF l_string_value IS NOT NULL THEN
            BEGIN
               l_value := TO_NUMBER(l_string_value);
            EXCEPTION
               WHEN VALUE_ERROR THEN
                  l_value := 0;
            END;

            p_total(l_vector_index) := p_total(l_vector_index) + l_value;
         END IF;

         l_index        := l_comma_index + 1;
         l_vector_index := l_vector_index + 1;
      END LOOP;
   END addvector;

   FUNCTION tabagg(p_varchar2_tab IN VARCHARLIST, p_delimiter IN VARCHAR2 DEFAULT ',')
      RETURN VARCHAR2
   IS
      l_string VARCHAR2(1024) := NULL;
      l_vector NUMBERSVECTOR := NUMBERSVECTOR(0);
   BEGIN
      -- initialize vector to all zeros
      l_vector.EXTEND(l_vector.LIMIT - 1, 1);

      IF p_varchar2_tab.FIRST IS NOT NULL THEN
         FOR i IN p_varchar2_tab.FIRST .. p_varchar2_tab.LAST LOOP
            addvector(l_vector, p_varchar2_tab(i), p_delimiter);
         END LOOP;
      END IF;

      FOR i IN l_vector.FIRST .. l_vector.LAST LOOP
         l_string :=
               l_string
            || p_delimiter
            || TO_CHAR(l_vector(i), 'FM999999999999999999999999999990.0999999999999999');
      END LOOP;

      RETURN LTRIM(l_string, p_delimiter);
   END tabagg;
END DFM_COMMONS;
/