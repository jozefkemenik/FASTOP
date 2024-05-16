CREATE OR REPLACE PACKAGE AUXTOOLS_EER_PUBLICATION
AS
   PROCEDURE getWeights(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getNeer(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getReer(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getEerGeoColumns(o_cur OUT SYS_REFCURSOR);

   PROCEDURE getWeightGeoColumns(o_cur OUT SYS_REFCURSOR);

END;
