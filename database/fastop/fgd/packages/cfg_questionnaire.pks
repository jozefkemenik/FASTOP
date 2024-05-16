create or replace PACKAGE CFG_QUESTIONNAIRE
AS
    /*** 
        NAME: CFG_QUESTIONNAIRE
        USAGE: Functions used in the questionnaire
    ***/

    FUNCTION assignYears(p_app_id IN VARCHAR2, p_text IN VARCHAR2, p_round_year IN NUMBER)
        RETURN VARCHAR2;     

    FUNCTION getStartDate(pi_year   IN VARCHAR2)
        RETURN DATE;

    FUNCTION getEndDate(pi_year   IN VARCHAR2)
        RETURN DATE;

    FUNCTION getAvailability(p_impl_date            DATE
                            ,p_reform_impl_date     DATE
                            ,p_reform_replaced_date DATE
                            ,p_abolition_date       DATE)
        RETURN VARCHAR2;
    
    FUNCTION getAvailability(p_impl_date            DATE
                            ,p_reform_impl_date     DATE
                            ,p_reform_replaced_date DATE
                            ,p_abolition_date       DATE
                            ,p_period_start         DATE
                            ,p_period_end           DATE)
        RETURN VARCHAR2;

    FUNCTION getPreviousStep(p_entry_sid            NUMBER
                            ,p_round_sid            NUMBER)
        RETURN VARCHAR2;

    FUNCTION getPreviousStep(p_entry_sid            NUMBER
                            ,p_round_sid            NUMBER
                            ,p_year                 NUMBER)
        RETURN VARCHAR2;
    
    FUNCTION getIsAmbitious(p_entry_sid NUMBER)                        
        RETURN NUMBER;
    
    FUNCTION getDescr(p_entry_sid NUMBER)
        RETURN VARCHAR2;

    FUNCTION getIfiAbrv(p_entry_sid NUMBER)
        RETURN VARCHAR2;

    FUNCTION getEditStep (p_edit_step_id IN VARCHAR2)
        RETURN NUMBER;
    
    PROCEDURE getQuestionnaires(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getQstnnrVersion(p_questionnaire_sid    IN NUMBER
                              ,p_country_id           IN VARCHAR2
                              ,l_ret                 OUT NUMBER);

    PROCEDURE getQuestionnaireEntries(p_questionnaire_sid    IN NUMBER
                                     ,p_country_id           IN VARCHAR2
                                     ,p_round_sid            IN NUMBER
                                     ,o_cur                 OUT SYS_REFCURSOR);

    PROCEDURE getQuestionnaireQuestions(p_qstnnr_version_sid  IN      NUMBER
                                      , o_cur                 OUT     SYS_REFCURSOR);

    PROCEDURE getQuestionnaireIndexes(p_questionnaire_id    IN VARCHAR2
                                     ,o_cur                 OUT SYS_REFCURSOR);

    PROCEDURE getSubmissionDate(p_questionnaire_sid IN     NUMBER
                              , p_country_id        IN     VARCHAR2
                              , p_round_sid         IN     NUMBER
                              , o_cur               OUT    SYS_REFCURSOR);

    PROCEDURE getQuestionnaireElements(p_qst_version_sid         IN NUMBER
                                      ,p_round_year              IN NUMBER
                                     , o_cur                    OUT SYS_REFCURSOR);

    PROCEDURE getQuestionnaireSections(p_questionnaire_version_sid IN      NUMBER
                                     , o_cur                      OUT     SYS_REFCURSOR);

    PROCEDURE getHeaderAttributes(p_qstnnr_version_sid  IN      NUMBER
                                , p_flag                IN      VARCHAR2
                                , o_cur                 OUT     SYS_REFCURSOR);

    PROCEDURE getSectionSubsections(p_qstnnr_section_sid IN NUMBER
                                   ,p_round_year         IN NUMBER 
                                  , o_cur OUT SYS_REFCURSOR);     

    PROCEDURE getSectionHdrAttributes(p_qstnnr_version_sid     IN NUMBER
                                    , p_section_version_sid    IN NUMBER
                                    , o_cur                   OUT SYS_REFCURSOR);            

    PROCEDURE getSectionQuestions(p_section_version_sid      IN NUMBER
                                , o_cur                     OUT SYS_REFCURSOR);

    PROCEDURE getConditionalQuestions(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getCondQuestionsByLvl(p_question_version_sid IN NUMBER
                                  , o_cur                 OUT SYS_REFCURSOR);

    PROCEDURE getDependentQuestions(p_question_version_sid   IN NUMBER
                                   ,o_cur                   OUT SYS_REFCURSOR);

    PROCEDURE getQuestion(p_question_version_sid     IN NUMBER
                        , p_cond_sid                 IN NUMBER
                        , p_round_year               IN NUMBER
                        , o_cur                     OUT SYS_REFCURSOR);

    PROCEDURE getQuestions(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getQuestionTypeAccessors(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getResponseChoices(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getEntry(p_entry_sid  IN  NUMBER
                      ,p_round_sid  IN  NUMBER
                      ,o_cur        OUT SYS_REFCURSOR);

    PROCEDURE checkSubmitCompletion(p_questionnaire_sid       IN NUMBER
                                   ,p_country_id            IN VARCHAR2
                                   ,p_round_sid             IN NUMBER
                                   ,o_res                  OUT NUMBER);

    PROCEDURE submitQuestionnaire(p_questionnaire_sid       IN NUMBER
                                 ,p_country_id              IN VARCHAR2
                                 ,p_round_sid               IN NUMBER
                                 ,p_status_sid              IN NUMBER
                                 ,p_user                    IN VARCHAR2
                                 ,p_ret                     OUT NUMBER);

    FUNCTION getSubmitDate(p_app_id            IN     VARCHAR2
                          ,p_country_id        IN     VARCHAR2
                          ,p_round_sid         IN     NUMBER)
        RETURN VARCHAR2; 

    PROCEDURE getQstCustomHeaders(p_qstnnr_version_sid  IN  NUMBER
                                 ,p_page                IN  VARCHAR2
                                 ,o_cur                 OUT SYS_REFCURSOR);

    PROCEDURE unsubmit(p_app_id     IN     VARCHAR2
                      ,p_country_id IN     VARCHAR2
                      ,p_round_sid  IN     NUMBER
                      ,p_user       IN     VARCHAR2
                      ,o_res        OUT    NUMBER);

    PROCEDURE submitLocked(p_questionnaire_sid              IN NUMBER
                          ,p_country_id                     IN VARCHAR2
                          ,p_round_sid                      IN NUMBER
                          ,p_user                           IN VARCHAR2
                          ,o_res                            OUT NUMBER
                          ,o_mess                           OUT VARCHAR2);

    PROCEDURE getIfis(o_cur OUT SYS_REFCURSOR);

    PROCEDURE getCountryIfi(p_country_id IN VARCHAR2
                           ,p_monitoring IN NUMBER
                           ,o_cur       OUT SYS_REFCURSOR);

    PROCEDURE setEntryEditStep(p_entry_sid      IN NUMBER
                              ,p_app_id         IN VARCHAR2
                              ,p_edit_step_id   IN VARCHAR2
                              ,p_round_sid      IN NUMBER
                              ,p_last_login     IN VARCHAR2 DEFAULT NULL
                              ,p_err            OUT NUMBER);                      

    PROCEDURE abolishEntry(p_entry_sid      IN NUMBER
                          ,p_reason         IN VARCHAR2
                          ,p_date           IN DATE
                          ,p_ret            OUT NUMBER);   

    PROCEDURE duplicateEntry(p_in_entry_sid         IN  NUMBER
                            ,p_round_sid            IN  NUMBER
                            ,p_reason               IN  VARCHAR2
                            ,p_date                 IN  DATE
                            ,p_date_force           IN  DATE
                            ,p_last_login           IN  VARCHAR2 DEFAULT NULL
                            ,p_out_entry_sid        OUT NUMBER
                            ,p_ret                  OUT NUMBER);

    PROCEDURE getEditSteps(o_cur        OUT     SYS_REFCURSOR);

    PROCEDURE createRule(p_country          IN  VARCHAR2
                        ,p_ruletype         IN  NUMBER
                        ,p_dateadopt        IN  DATE
                        ,p_date_impl        IN  DATE
                        ,p_description      IN  VARCHAR2
                        ,p_last_login       IN  VARCHAR2
                        ,p_round_sid        IN  NUMBER
                        ,o_sid              OUT NUMBER
                        ,p_ret              OUT NUMBER);

    PROCEDURE createIfi(p_country          IN  VARCHAR2
                       ,p_estabdate        IN  DATE
                       ,p_engname          IN  VARCHAR2
                       ,p_last_login       IN  VARCHAR2
                       ,p_round_sid        IN  NUMBER
                       ,o_sid              OUT NUMBER
                       ,p_ret              OUT NUMBER);

    PROCEDURE createGbd(p_country          IN  VARCHAR2
                       ,p_adoptdate        IN  DATE
                       ,p_entrydate        IN  DATE
                       ,p_engname          IN  VARCHAR2
                       ,p_last_login       IN  VARCHAR2
                       ,p_round_sid        IN  NUMBER
                       ,o_sid              OUT NUMBER
                       ,p_ret              OUT NUMBER);

    PROCEDURE createMtbf(p_country          IN  VARCHAR2
                       ,p_adoptdate        IN  DATE
                       ,p_entrydate        IN  DATE
                       ,p_engname          IN  VARCHAR2
                       ,p_last_login       IN  VARCHAR2
                       ,p_round_sid        IN  NUMBER
                       ,o_sid              OUT NUMBER
                       ,p_ret              OUT NUMBER) ;

    PROCEDURE generateSpecialLovs;

    PROCEDURE abortReform(p_entry_sid          IN  NUMBER
                         ,p_last_login         IN  VARCHAR2
                         ,p_qst_id             IN  VARCHAR2
                         ,p_err               OUT  NUMBER
                         ,p_mess              OUT  VARCHAR2);

    PROCEDURE getVintageYears(p_app_id     IN VARCHAR2
                             ,p_round_year IN NUMBER
                             ,o_cur       OUT SYS_REFCURSOR);
END CFG_QUESTIONNAIRE;
