/* Formatted on 26-Sep-22 18:25:23 (QP5 v5.313) */
CREATE TABLE dfm_measures_hr_bck
AS
   SELECT *
     FROM dfm_measures
    WHERE country_id = 'HR';

UPDATE dfm_measures
   SET data = CORE_COMMONS.LISTAPPLYEXCHANGERATE(DATA, 1 / 7.5345, ',')
 WHERE country_id = 'HR';

UPDATE dfm_countries_info
   SET MULTI_DESCR = 'Billion EUR'
 WHERE country_id = 'HR';