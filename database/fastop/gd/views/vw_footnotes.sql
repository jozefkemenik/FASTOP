/* Formatted on 12/3/2019 15:59:24 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW VW_GD_FOOTNOTES
AS
   SELECT *
     FROM (SELECT CF.CELL_SID, F.*
             FROM GD_CELL_FTNS CF
                  JOIN GD_FOOTNOTES F ON F.FOOTNOTE_SID = CF.FOOTNOTE_SID) PIVOT (MIN (
                                                                                     DESCR) footnote,
                                                                                 MIN (
                                                                                    FOOTNOTE_SID) ftn_sid
                                                                           FOR version_type_id
                                                                           IN  ('N' N
,                                                                              'P' P
,                                                                              'CD' CD));