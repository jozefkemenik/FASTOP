CREATE OR REPLACE PACKAGE IDR_OG_PARAMS
AS
   /******************************************************************************
      NAME:    IDR_OG_PARAMS
      PURPOSE: Output gap params functions
   ******************************************************************************/

   PROCEDURE getBaselineVariables(o_cur  OUT  SYS_REFCURSOR);

   PROCEDURE getBaselineData(o_cur         OUT  SYS_REFCURSOR
,                            p_round_sid   IN   NUMBER
,                            p_country_ids IN   CORE_COMMONS.VARCHARARRAY);

   PROCEDURE hasBaselineData(p_round_sid   IN   NUMBER
,                            p_country_id  IN   VARCHAR2
,                            o_res         OUT  NUMBER);

   PROCEDURE getCountryParams(o_cur  OUT  SYS_REFCURSOR);

   PROCEDURE getCountryParamsData(o_cur         OUT  SYS_REFCURSOR
,                                 p_round_sid   IN   NUMBER
,                                 p_country_ids IN   CORE_COMMONS.VARCHARARRAY);

   PROCEDURE hasCountryParamsData(p_round_sid   IN   NUMBER
,                                 p_country_id  IN   VARCHAR2
,                                 o_res         OUT  NUMBER);

   PROCEDURE uploadBaselineData(p_round_sid         IN      NUMBER
,                               p_variable_sids     IN  OUT CORE_COMMONS.SIDSARRAY
,                               p_country_ids       IN  OUT CORE_COMMONS.VARCHARARRAY
,                               p_years             IN  OUT CORE_COMMONS.SIDSARRAY
,                               p_values            IN  OUT CORE_COMMONS.VARCHARARRAY
,                               o_res               OUT     NUMBER);

   PROCEDURE uploadCountryParameters(p_round_sid         IN      NUMBER
,                                    p_parameter_sids    IN  OUT CORE_COMMONS.SIDSARRAY
,                                    p_country_ids       IN  OUT CORE_COMMONS.VARCHARARRAY
,                                    p_values            IN  OUT CORE_COMMONS.VARCHARARRAY
,                                    o_res               OUT     NUMBER);

   PROCEDURE updateYearsRange(p_years_range   IN   NUMBER
,                             p_app_id        IN   VARCHAR2
,                             o_res           OUT  NUMBER);

   PROCEDURE getParameter(p_round_sid     IN   NUMBER
,                         p_parameter_id  IN   VARCHAR2
,                         o_res           OUT  VARCHAR2);

   PROCEDURE updateParameter(p_round_sid        IN   NUMBER
,                            p_parameter_id     IN   VARCHAR2
,                            p_parameter_value  IN   VARCHAR2
,                            o_res              OUT  NUMBER);


   PROCEDURE getParameters(p_round_sid     IN   NUMBER
,                          o_cur           OUT  SYS_REFCURSOR);

   PROCEDURE updateParameters(p_round_sid         IN   NUMBER
,                             p_parameter_ids     IN   CORE_COMMONS.VARCHARARRAY
,                             p_parameter_values  IN   CORE_COMMONS.VARCHARARRAY
,                             o_res               OUT  NUMBER);
END IDR_OG_PARAMS;
/
