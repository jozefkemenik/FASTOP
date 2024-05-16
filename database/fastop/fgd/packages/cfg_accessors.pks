create or replace PACKAGE CFG_ACCESSORS
AS
    /*** 
        NAME: CFG_ACCESSORS
        USAGE: Getters and Setters
    ***/
    PROCEDURE getEntryTextValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     NUMBER
                               ,p_format_response       IN     NUMBER
                               ,p_round_year            IN     NUMBER
                               ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getEntryNumberValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     NUMBER
                               ,p_format_response       IN     NUMBER
                               ,p_round_year            IN     NUMBER
                               ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getEntrySidValue(p_entry_sid             IN     NUMBER
                              ,p_question_version_sid  IN     NUMBER
                              ,p_format_response       IN     NUMBER
                              ,p_round_year            IN     NUMBER
                              ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getEntryMultValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     NUMBER
                               ,p_format_response       IN     NUMBER
                               ,p_round_year            IN     NUMBER
                               ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getEntryDateValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     VARCHAR2
                               ,p_format_response       IN     NUMBER
                               ,p_round_year            IN     NUMBER
                               ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getEntryAssessmentTextValue(p_entry_sid             IN     NUMBER
                                         ,p_question_version_sid  IN     NUMBER
                                         ,p_period_sid            IN     NUMBER
                                         ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getEntryAssessmentNumberValue(p_entry_sid             IN     NUMBER
                                         ,p_question_version_sid  IN     NUMBER
                                         ,p_period_sid            IN     NUMBER
                                         ,o_cur                   OUT    SYS_REFCURSOR);                                         

    PROCEDURE getEntryAssessmentSidValue(p_entry_sid             IN     NUMBER
                                        ,p_question_version_sid  IN     NUMBER
                                        ,p_period_sid            IN     NUMBER DEFAULT 0
                                        ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getEntryAssessmentMultValue(p_entry_sid             IN     NUMBER
                                         ,p_question_version_sid  IN     NUMBER
                                         ,p_period_sid            IN     NUMBER DEFAULT 0
                                         ,o_cur                   OUT    SYS_REFCURSOR);  

    PROCEDURE getEntryResponseDetails(p_entry_sid            IN     NUMBER
                                     ,p_period_sid           IN     NUMBER
                                     ,p_question_version_sid IN     NUMBER
                                     ,o_cur                 OUT     SYS_REFCURSOR);

    PROCEDURE getEntryResponseValues(p_entry_sid            IN     NUMBER
                                    ,p_period_sid           IN     NUMBER
                                    ,p_question_version_sid IN     NUMBER
                                    ,o_cur                 OUT     SYS_REFCURSOR);

    PROCEDURE getCurrentTargetValue(p_entry_sid             IN     NUMBER
                                   ,p_question_version_sid  IN     NUMBER
                                   ,p_format_response       IN     NUMBER
                                   ,p_round_year            IN     NUMBER
                                   ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getTargetEntryConfig(p_app_id     IN  VARCHAR2
                                  ,o_cur        OUT SYS_REFCURSOR);

    PROCEDURE getTargetUnit(p_entry_sid     IN  NUMBER
                           ,o_target_unit   OUT VARCHAR2);

    PROCEDURE getEntryTargetNAYears(p_entry_sid             IN  NUMBER
                                   ,p_question_version_sid  IN  NUMBER
                                   ,o_cur                   OUT SYS_REFCURSOR);

    PROCEDURE getEntryQuestionAdditionalInfo(p_entry_sid            IN     NUMBER
                                            ,p_question_version_sid IN     NUMBER
                                            ,p_period_sid           IN     NUMBER
                                            ,o_cur                  OUT    SYS_REFCURSOR);

    PROCEDURE setEntryQuestionAdditionalInfo(p_entry_sid            IN     NUMBER
                                            ,p_question_version_sid IN     NUMBER
                                            ,p_info                 IN     VARCHAR2
                                            ,p_period_sid           IN     NUMBER
                                            ,o_res                  OUT    NUMBER);

    PROCEDURE getEntryComplianceValue(p_entry_sid             IN     NUMBER
                                     ,p_period_sid            IN     NUMBER
                                     ,o_cur                   OUT    SYS_REFCURSOR);

    PROCEDURE getEntryLinkableEntries(p_entry_sid IN  NUMBER
                                     ,o_cur       OUT SYS_REFCURSOR);

    PROCEDURE getLovId(p_lov_sid        IN  NUMBER,
                       o_res            OUT VARCHAR2);

    PROCEDURE deleteEntryQuestionValue(p_entry_sid            IN     NUMBER
                                      ,p_question_version_sid IN     NUMBER
                                      ,p_value                IN     VARCHAR2 DEFAULT NULL
                                      ,p_period_sid           IN     NUMBER DEFAULT 0  
                                      ,o_res                  OUT    NUMBER);

    PROCEDURE setEntryDateValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     NUMBER
                               ,p_value                 IN     VARCHAR2      
                               ,p_details               IN     VARCHAR2     
                               ,o_res                  OUT     NUMBER);

    PROCEDURE setEntrySidValue(p_entry_sid              IN     NUMBER
                              ,p_question_version_sid   IN     NUMBER
                              ,p_value                  IN     VARCHAR2
                              ,p_details                IN     VARCHAR2
                              ,o_res                    OUT    NUMBER);

    PROCEDURE setEntryTextValue(p_entry_sid              IN     NUMBER
                               ,p_question_version_sid   IN     NUMBER
                               ,p_value                  IN     VARCHAR2
                               ,p_details                IN     VARCHAR2
                               ,o_res                    OUT    NUMBER);

    PROCEDURE setEntryNumberValue(p_entry_sid              IN     NUMBER
                               ,p_question_version_sid   IN     NUMBER
                               ,p_value                  IN     VARCHAR2
                               ,p_details                IN     VARCHAR2
                               ,o_res                    OUT    NUMBER);

    PROCEDURE setEntryMultValue(p_entry_sid              IN     NUMBER
                               ,p_question_version_sid   IN     NUMBER
                               ,p_value                  IN     VARCHAR2
                               ,p_details                IN     VARCHAR2
                               ,o_res                    OUT    NUMBER);

    PROCEDURE setEntryAssessmentTextValue(p_entry_sid               IN      NUMBER
                                         ,p_question_version_sid    IN      NUMBER
                                         ,p_value                   IN      VARCHAR2
                                         ,p_period_sid              IN      NUMBER
                                         ,p_details                 IN      VARCHAR2
                                         ,o_res                     OUT     NUMBER);

    PROCEDURE setEntryAssessmentNumberValue(p_entry_sid               IN      NUMBER
                                         ,p_question_version_sid    IN      NUMBER
                                         ,p_value                   IN      VARCHAR2
                                         ,p_period_sid              IN      NUMBER
                                         ,p_details                 IN      VARCHAR2
                                         ,o_res                     OUT     NUMBER);

    PROCEDURE setEntryAssessmentSidValue(p_entry_sid               IN      NUMBER
                                        ,p_question_version_sid    IN      NUMBER
                                        ,p_value                   IN      VARCHAR2
                                        ,p_period_sid              IN      NUMBER
                                        ,p_details                 IN      VARCHAR2
                                        ,o_res                     OUT     NUMBER);

    PROCEDURE setEntryAssessmentMultValue(p_entry_sid               IN      NUMBER
                                         ,p_question_version_sid    IN      NUMBER
                                         ,p_value                   IN      VARCHAR2
                                         ,p_period_sid              IN      NUMBER
                                         ,p_details                 IN      VARCHAR2
                                         ,o_res                     OUT     NUMBER);

    PROCEDURE setEntryQuestionResponseValue(p_entry_sid               IN      NUMBER
                                           ,p_question_version_sid    IN      NUMBER
                                           ,p_value                   IN      VARCHAR2
                                           ,p_response_sid            IN      NUMBER
                                           ,o_res                     OUT     NUMBER);

    PROCEDURE setEntryComplianceValue(p_entry_sid            IN     NUMBER
                                     ,p_question_version_sid IN     NUMBER
                                     ,p_period_sid           IN     NUMBER
                                     ,p_value                IN     NUMBER
                                     ,o_res                  OUT    NUMBER);

    PROCEDURE setEntryTargetNAYear(p_entry_sid              IN     NUMBER
                                  ,p_question_version_sid   IN     NUMBER
                                  ,p_year                   IN     NUMBER
                                  ,p_na                     IN     NUMBER
                                  ,o_res                    OUT    NUMBER);

    PROCEDURE getComplianceOptions(p_entry_sid      IN     NUMBER
                                  ,p_period_sid     IN     NUMBER
                                  ,p_round_sid      IN     NUMBER
                                  ,p_year           IN     NUMBER
                                  ,p_period_descr   IN     VARCHAR2
                                  ,o_cur         OUT    SYS_REFCURSOR);

    -- PROCEDURE getComplianceValues(p_entry_sid       IN     NUMBER
    --                              ,p_period_sid      IN     NUMBER
    --                              ,p_round_sid       IN     NUMBER
    --                              ,p_year            IN     NUMBER
    --                              ,p_period_descr    IN     VARCHAR2
    --                              ,o_cur             OUT    SYS_REFCURSOR);

    PROCEDURE clearAssessmentValue(p_entry_sid              IN  NUMBER
                                  ,p_question_version_sid   IN  NUMBER
                                  ,p_period_sid             IN  NUMBER
                                  ,o_res                    OUT NUMBER);

    PROCEDURE deleteEntryTargetNAYear(p_entry_sid              IN     NUMBER
                                     ,p_question_version_sid   IN     NUMBER
                                     ,p_year                   IN     NUMBER
                                     ,o_res                    OUT    NUMBER);

    PROCEDURE getRuleTypes(o_cur        OUT SYS_REFCURSOR);

    PROCEDURE getQuestionPeriod (p_question_version_sid     IN  NUMBER
                                ,o_res                      OUT NUMBER);

    PROCEDURE setAmbitious (p_entry_sid     IN  NUMBER
                           ,p_ambitious     IN  NUMBER
                           ,o_res           OUT NUMBER);

    PROCEDURE clearQuestionValue (p_entry_sid                IN  NUMBER
                                 ,p_question_version_sid     IN  NUMBER
                                 ,o_res                      OUT NUMBER);

    PROCEDURE getQuestionLastUpdate (p_entry_sid                IN  NUMBER
                                    ,p_question_version_sid     IN  NUMBER
                                    ,o_res                      OUT VARCHAR2);

    PROCEDURE getComplianceConfiguration (p_entry_sid               IN  NUMBER
                                        ,o_cur                      OUT SYS_REFCURSOR);

    PROCEDURE getEurostatValues(p_entry_sid       IN     NUMBER
                               ,p_period_sid      IN     NUMBER
                               ,p_round_sid       IN     NUMBER
                               ,o_cur             OUT    SYS_REFCURSOR);
                                    
    -- FUNCTION getOG(pi_country_id VARCHAR2,
    --             pi_round_sid  NUMBER)
    --     RETURN number; 

    FUNCTION getValue( p_start_year IN NUMBER
                    , p_vector IN VARCHAR2 
                    , p_selected_year IN NUMBER
                    , p_selected_quarter IN NUMBER DEFAULT NULL
                    , p_per IN VARCHAR2 DEFAULT 'A') 
        RETURN NUMBER;

    FUNCTION convertToNumber ( p_val IN VARCHAR2 ) 
        RETURN NUMBER ; 

                                  
END CFG_ACCESSORS;
