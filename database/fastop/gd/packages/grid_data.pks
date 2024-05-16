/* Formatted on 10/9/2019 18:02:58 (QP5 v5.252.13127.32847) */
CREATE OR REPLACE PACKAGE GD_GRID_DATA
AS
   /**************************************************************************
      NAME:       GD_GRID_DATA
      PURPOSE:    Grid data accessors
    **************************************************************************/

   FUNCTION convertGridVersionType (p_value          IN VARCHAR2
,                                   p_version_from   IN VARCHAR2
,                                   p_version_to     IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION convertToVarcharObjectList (
      p_list        IN CLOB
,     p_delimiter   IN VARCHAR2 DEFAULT ',')
      RETURN VARCHAROBJECT_LIST
      PIPELINED;

   PROCEDURE copyAllGridsFromVersion (p_app_id         IN     VARCHAR2
,                                     p_country_id     IN     VARCHAR2
,                                     p_version_from   IN     VARCHAR2
,                                     p_version_to     IN     VARCHAR2
,                                     o_res               OUT NUMBER);

   PROCEDURE copyCtyGridVersion (p_app_id         IN     VARCHAR2
,                                p_country_id     IN     VARCHAR2
,                                p_cty_grid_sid   IN     NUMBER
,                                p_version_from   IN     VARCHAR2
,                                p_version_to     IN     VARCHAR2
,                                o_res               OUT NUMBER);

   PROCEDURE deleteCtyVersion (p_country_id   IN     VARCHAR2
,                              p_round_sid    IN     NUMBER
,                              p_version      IN     NUMBER
,                              o_res             OUT NUMBER);

   PROCEDURE getApplicationCtyGridCells (
      p_app_id              IN     VARCHAR2
,     p_round_sid           IN     NUMBER
,     p_grid_id             IN     VARCHAR2
,     p_country_id          IN     VARCHAR2
,     p_version             IN     NUMBER
,     p_grid_version_type   IN     VARCHAR2
,     o_cur                    OUT SYS_REFCURSOR);

   PROCEDURE getCtyGridCells (p_round_sid           IN     NUMBER
,                             p_grid_id             IN     VARCHAR2
,                             p_country_id          IN     VARCHAR2
,                             p_version             IN     NUMBER
,                             p_grid_version_type   IN     VARCHAR2
,                             o_cur                    OUT SYS_REFCURSOR);

   PROCEDURE getCtyGridData (p_country_id          IN     VARCHAR2
,                            p_cty_grid_sid        IN     NUMBER
,                            p_grid_version_type   IN     VARCHAR2
,                            o_cur                    OUT SYS_REFCURSOR);

   PROCEDURE getLineDataNoLevel (o_cur             OUT SYS_REFCURSOR
,                                p_app_id       IN     VARCHAR2
,                                p_line_id      IN     VARCHAR2
,                                p_country_id   IN     VARCHAR2
,                                p_round_sid    IN     NUMBER DEFAULT NULL
,                                p_version      IN     NUMBER DEFAULT NULL);

   PROCEDURE getLinesData (o_cur              OUT SYS_REFCURSOR
,                          p_round_sids    IN     CORE_COMMONS.SIDSARRAY
,                          p_country_ids   IN     CORE_COMMONS.VARCHARARRAY
,                          p_line_ids      IN     CORE_COMMONS.VARCHARARRAY);

   PROCEDURE newCtyVersion (p_country_id   IN     VARCHAR2
,                           p_app_id       IN     VARCHAR2
,                           o_res             OUT NUMBER);

   PROCEDURE patchCtyGridData (
      p_app_id              IN     VARCHAR2
,     p_country_id          IN     VARCHAR2
,     p_cty_grid_sid        IN     NUMBER
,     p_grid_version_type   IN     VARCHAR2
,     p_lines               IN     CORE_COMMONS.SIDSARRAY
,     p_cols                IN     CORE_COMMONS.SIDSARRAY
,     p_data                IN     CORE_COMMONS.VARCHARARRAY
,     o_res                    OUT NUMBER);

   PROCEDURE saveCtyRoundScale (
      p_cty_id             IN      VARCHAR2,
      p_round_sid          IN      NUMBER,
      p_scale_id           IN      VARCHAR2,
      o_res                   OUT  NUMBER);

   FUNCTION publicValue(p_value IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION formatValue(p_value IN VARCHAR2)
      RETURN VARCHAR2;

END GD_GRID_DATA;
/
