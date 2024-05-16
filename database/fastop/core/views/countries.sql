/* Formatted on 11/28/2019 19:07:36 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW COUNTRIES
(
   COUNTRY_ID
,  DESCR
,  CODEISO3
,  CODE_FGD
,  ORDER_BY
)
AS
   SELECT geo_area_id
,         descr
,         codeiso3
,         code_fgd
,         order_by
     FROM geo_areas
    WHERE geo_area_type = 'COUNTRY'
    ORDER BY order_by;