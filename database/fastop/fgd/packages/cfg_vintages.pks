CREATE OR REPLACE PACKAGE CFG_VINTAGES
AS
    /***        
        NAME: CFG_VINTAGES
        USAGE: Functions used in Creating and Accessing Vintages
    ***/

    FUNCTION getAttributeVintageText(pi_attr_name IN VARCHAR2, pi_entry_sid IN NUMBER)
    RETURN VARCHAR2;

    PROCEDURE getQuestionVintageText(pi_question_version_sid IN NUMBER, pi_entry_sid IN NUMBER, pi_round_sid IN NUMBER, pi_year IN NUMBER, pi_is_archive IN NUMBER, o_res OUT VARCHAR2);

    PROCEDURE createVintageApp(p_app_id IN VARCHAR2, p_round_sid IN NUMBER, p_year  IN NUMBER, p_is_archive IN NUMBER);

    PROCEDURE getVintageData(p_app_id        IN  VARCHAR2
                            ,p_year          IN  NUMBER
                            ,o_cur           OUT SYS_REFCURSOR);

    PROCEDURE getVtAppAttrs(p_app_id        IN  VARCHAR2
                           ,o_cur           OUT SYS_REFCURSOR);                           

    TYPE ARRAY_N IS VARRAY(20) OF NUMBER;

END CFG_VINTAGES;