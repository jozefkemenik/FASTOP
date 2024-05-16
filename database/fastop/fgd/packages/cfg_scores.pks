CREATE OR REPLACE PACKAGE CFG_SCORES
AS
    /***        
        NAME: CFG_SCORES
        USAGE: Functions used in SCORES
    ***/

    FUNCTION stageShared(p_index_sid         IN NUMBER
                        ,p_score_version_sid IN NUMBER)
    RETURN NUMBER;

    PROCEDURE clearAcceptedScore (p_entry_criteria_sid IN NUMBER);

    PROCEDURE fillStageBlanks (p_index_sid      IN     NUMBER
                              ,p_country_id     IN     VARCHAR2
                              ,p_round_sid      IN     NUMBER
                              ,p_stage_sid      IN     NUMBER
                              ,p_user           IN     VARCHAR2
                              ,p_organisation   IN     VARCHAR2
                              ,o_res            OUT    NUMBER);

    PROCEDURE getIndexCalculationStages (p_index_sid    IN NUMBER
                                        ,o_cur          OUT SYS_REFCURSOR);

    PROCEDURE getIndexCriteria (p_index_sid   IN     NUMBER
                               ,o_cur            OUT SYS_REFCURSOR);

    PROCEDURE getIndexDescription (p_index_sid      IN  NUMBER
                                  ,o_cur            OUT SYS_REFCURSOR);

    PROCEDURE getCountryIdxCalculationStages (p_index_sid       IN     NUMBER
                                             ,p_country_id      IN     VARCHAR2
                                             ,p_round_sid       IN     NUMBER
                                             ,o_cur             OUT SYS_REFCURSOR);

    PROCEDURE getEntryScores (p_entry_sid           IN     NUMBER
                             ,p_index_sid           IN     NUMBER
                             ,p_round_sid           IN     NUMBER
                             ,p_score_version_sid   IN     NUMBER
                             ,p_criterion_sid       IN     NUMBER
                             ,p_ms_only             IN     NUMBER
                             ,o_cur                 OUT    SYS_REFCURSOR);

    PROCEDURE getScoreComments (p_entry_criteria_sid    IN  NUMBER
                               ,p_is_ms                 IN  NUMBER
                               ,o_cur                   OUT SYS_REFCURSOR);

    PROCEDURE delCountryIdxCalculationStage (p_index_sid        IN      NUMBER
                                            ,p_country_id       IN      VARCHAR2
                                            ,p_round_sid        IN      NUMBER
                                            ,p_stage_sid        IN      NUMBER
                                            ,o_res             OUT      NUMBER);

    PROCEDURE getPreviousFinalScore(p_criterion_sid         IN  NUMBER
                                   ,p_round_sid             IN  NUMBER 
                                   ,o_cur                   OUT SYS_REFCURSOR);

    PROCEDURE getCriterionQuestions (p_criterion_sid        IN      NUMBER
                                    ,o_cur                  OUT     SYS_REFCURSOR);

    PROCEDURE getEntryScoreDetails (p_entry_sid       IN     NUMBER
                                   ,p_round_sid       IN     NUMBER
                                   ,p_criterion_sid   IN     NUMBER
                                   ,p_version_sid     IN     NUMBER
                                   ,p_ms_only         IN     NUMBER
                                   ,o_cur                OUT SYS_REFCURSOR);

    PROCEDURE setEntryCriterionScore (p_entry_sid       IN     NUMBER
                                     ,p_round_sid       IN     NUMBER
                                     ,p_criterion_sid   IN     NUMBER
                                     ,p_version_sid     IN     NUMBER
                                     ,p_score           IN     NUMBER
                                     ,p_user            IN     VARCHAR2
                                     ,p_organisation    IN     VARCHAR2
                                     ,o_res             OUT    NUMBER);

    PROCEDURE addScoreComment (p_entry_criteria_sid   IN     NUMBER
                              ,p_comment              IN     VARCHAR2
                              ,p_user                 IN     VARCHAR2
                              ,p_organisation         IN     VARCHAR2
                              ,o_res                  OUT    NUMBER);

    PROCEDURE deleteScoreComment (p_comment_sid   IN     NUMBER
                                 ,p_user          IN     VARCHAR2
                                 ,o_res           OUT    NUMBER);

    PROCEDURE updateScoreComment (p_comment_sid   IN     NUMBER
                                 ,p_comment       IN     VARCHAR2
                                 ,p_user          IN     VARCHAR2
                                 ,o_res           OUT    NUMBER);

    PROCEDURE acceptCriteriaScore (p_entry_criteria_sid  IN     NUMBER
                                  ,p_score               IN     NUMBER
                                  ,p_user                IN     VARCHAR2
                                  ,p_organisation        IN     VARCHAR2
                                  ,o_res                 OUT    NUMBER);

    PROCEDURE getDisagreedCriteria (p_entry_sid     IN     NUMBER
                                   ,p_round_sid     IN     NUMBER
                                   ,p_version_sid   IN     NUMBER
                                   ,p_index_sid     IN     NUMBER
                                   ,p_country_id    IN     VARCHAR2
                                   ,o_cur           OUT    SYS_REFCURSOR);

    PROCEDURE setCountryIdxCalculationStage (p_index_sid      IN     NUMBER
                                            ,p_country_id     IN     VARCHAR2
                                            ,p_round_sid      IN     NUMBER
                                            ,p_stage_sid      IN     NUMBER
                                            ,p_iteration      IN     VARCHAR2
                                            ,p_user           IN     VARCHAR2
                                            ,p_organisation   IN     VARCHAR2
                                            ,o_res            OUT    NUMBER);

    PROCEDURE getIndexCriteriaScoreTypes (p_index_sid    IN NUMBER
                                        ,o_cur          OUT SYS_REFCURSOR);

    PROCEDURE getCriteriaConditions (p_criterion_sid    IN NUMBER
                                    ,o_cur              OUT SYS_REFCURSOR);

    PROCEDURE calcSingleScore (p_entry_sid          IN  NUMBER
                              ,p_criterion_sid      IN  NUMBER
                              ,p_choice_score_sid   IN  NUMBER
                              ,o_res                OUT NUMBER);

    PROCEDURE calcMultiScore (p_entry_sid           IN  NUMBER
                             ,p_criterion_sid       IN  NUMBER
                             ,p_choice_score_sid    IN  NUMBER
                             ,o_res                 OUT NUMBER);

    PROCEDURE calcSumScore (p_entry_sid             IN  NUMBER
                           ,p_criterion_sid         IN  NUMBER
                           ,p_choice_score_sid      IN  NUMBER
                           ,o_res                   OUT NUMBER);

    PROCEDURE calcMeanScore (p_entry_sid            IN  NUMBER
                            ,p_criterion_sid        IN  NUMBER
                            ,p_choice_score_sid     IN  NUMBER
                            ,o_res                  OUT NUMBER);

    PROCEDURE calcCondSingleScore (p_entry_sid            IN  NUMBER
                                  ,p_criterion_sid        IN  NUMBER
                                  ,p_choice_score_sid     IN  NUMBER
                                  ,o_res                  OUT NUMBER);

    PROCEDURE calcCondMultiScore (p_entry_sid            IN  NUMBER
                                 ,p_criterion_sid        IN  NUMBER
                                 ,p_choice_score_sid     IN  NUMBER
                                 ,o_res                  OUT NUMBER);

    PROCEDURE getCriteriaChoices (p_criterion_sid   IN      NUMBER
                                 ,p_entry_sid       IN      NUMBER
                                 ,o_cur             OUT     SYS_REFCURSOR);

    PROCEDURE checkChoiceCondition(p_entry_sid              IN  NUMBER
                                  ,p_question_version_sid   IN  NUMBER
                                  ,p_custom_condition       IN  VARCHAR2
                                  ,p_round_year             IN  NUMBER
                                  ,o_res                    OUT NUMBER);

    PROCEDURE getIndiceTypes (o_cur         OUT SYS_REFCURSOR);                                  

    PROCEDURE getIndicesCfg(p_index_sid              IN  NUMBER
                           ,o_cur                    OUT SYS_REFCURSOR);

    PROCEDURE getIndicators(p_index_sid              IN  NUMBER
                           ,p_multi_entry            IN  NUMBER 
                           ,o_cur                    OUT SYS_REFCURSOR);

    PROCEDURE getLatestScores(p_entry_sid               IN  NUMBER
                             ,p_index_sid               IN  NUMBER
                             ,p_round_sid               IN  NUMBER
                             ,o_cur                    OUT  SYS_REFCURSOR);

    PROCEDURE getCoverages(p_entry_sid              IN  NUMBER
                          ,o_cur                    OUT  SYS_REFCURSOR);

    PROCEDURE getComplianceScoring(p_entry_sid              IN  NUMBER
                                  ,p_round_sid              IN  NUMBER
                                  ,o_ret                    OUT  NUMBER);

    PROCEDURE getComplianceBonus(p_country_id             IN  VARCHAR2
                                ,p_round_sid              IN  NUMBER  
                                ,p_start_year             IN  NUMBER 
                                ,p_vector                 IN  VARCHAR2
                                ,p_year                   IN  NUMBER
                                ,o_ret                    OUT  NUMBER);

    PROCEDURE isInForce(p_entry_sid             IN  NUMBER
                       ,o_ret                    OUT  NUMBER);
    
    PROCEDURE checkIndiceCreation(p_index_sid   IN NUMBER
                                 ,p_round_sid   IN NUMBER
                                 ,p_round_year  IN NUMBER
                                 ,o_ret         OUT NUMBER);

    PROCEDURE setIndiceValue(p_entry_sid            IN  NUMBER
                            ,p_index_sid            IN  NUMBER
                            ,p_dimension_sid        IN  NUMBER
                            ,p_dimension_value      IN  VARCHAR2
                            ,p_round_sid            IN  NUMBER
                            ,p_round_year           IN  NUMBER
                            ,p_country_id           IN  VARCHAR2
                            ,p_sector_id            IN  VARCHAR2
                            ,o_res                  OUT NUMBER);

    PROCEDURE setIndiceRankValue(p_entry_sid            IN  NUMBER
                            ,p_index_sid            IN  NUMBER
                            ,p_dimension_sid        IN  NUMBER
                            ,p_dimension_value      IN  VARCHAR2
                            ,p_round_sid            IN  NUMBER
                            ,p_round_year           IN  NUMBER
                            ,p_country_id           IN  VARCHAR2
                            ,p_sector               IN  VARCHAR2
                            ,o_res                  OUT NUMBER);

    PROCEDURE getIndiceValue(p_entry_sid            IN  NUMBER
                            ,p_index_sid            IN  NUMBER
                            ,p_dimension_sid        IN  NUMBER
                            ,p_round_sid            IN  NUMBER
                            ,p_round_year           IN  NUMBER
                            ,o_res                  OUT NUMBER);

    PROCEDURE setIndiceAttrValue(p_entry_sid            IN  NUMBER
                                ,p_index_sid            IN  NUMBER
                                ,p_attr_name            IN  VARCHAR2
                                ,p_attr_value           IN  NUMBER
                                ,p_round_sid            IN  NUMBER
                                ,p_round_year           IN  NUMBER
                                ,p_country_id           IN  VARCHAR2
                                ,o_res                  OUT NUMBER);

    PROCEDURE setIndiceMultiAttrValue(p_entry_sid            IN  NUMBER
                                     ,p_index_sid            IN  NUMBER
                                     ,p_attr_name            IN  VARCHAR2
                                     ,p_attr_value           IN  VARCHAR2
                                     ,p_round_sid            IN  NUMBER
                                     ,p_round_year           IN  NUMBER
                                     ,p_country_id           IN  VARCHAR2
                                     ,o_res                  OUT NUMBER);

    PROCEDURE getIndiceAddAttributes(p_index_sid     IN  NUMBER
                                    ,o_cur           OUT SYS_REFCURSOR);

    PROCEDURE getEntryAtrribute (p_entry_sid                IN  NUMBER
                                ,p_attr_name                IN  VARCHAR2
                                ,o_res                      OUT VARCHAR2);

    PROCEDURE setIndiceCoverage(p_entry_sid            IN  NUMBER
                               ,p_index_sid            IN  NUMBER
                               ,p_dimension_sid        IN  NUMBER
                               ,p_dimension_value      IN  VARCHAR2
                               ,p_sector_id            IN  VARCHAR2
                               ,p_round_sid            IN  NUMBER
                               ,p_round_year           IN  NUMBER 
                               ,o_res                  OUT NUMBER);

    PROCEDURE getIndiceData(p_index_sid            IN  NUMBER
                           ,p_round_sid            IN  NUMBER
                           ,p_round_year           IN  NUMBER
                           ,p_country_id           IN  VARCHAR2
                           ,o_cur                  OUT SYS_REFCURSOR);

    PROCEDURE sendEmail(p_user                  IN  VARCHAR2
                       ,p_index_sid             IN  NUMBER
                       ,p_criterion_sid         IN  NUMBER
                       ,p_entry_sid             IN  NUMBER
                       ,o_res                  OUT  NUMBER);                           

    PROCEDURE getEmailParams (p_entry_criteria_sid   IN     NUMBER
                              ,o_cur                  OUT    SYS_REFCURSOR);

    PROCEDURE getChoiceLov (p_choice_score_sid   IN     NUMBER
                           ,o_ret                  OUT    NUMBER);

    PROCEDURE getHorizontalIdxCalcStages (p_app_id      IN     VARCHAR2 
                                        ,p_index_sid   IN     NUMBER
                                        ,p_round_sid   IN     NUMBER
                                        ,p_round_year      IN  NUMBER
                                        ,o_cur            OUT SYS_REFCURSOR);
    
    PROCEDURE refreshHorizView (p_app_id      IN     VARCHAR2 
                        ,p_index_sid   IN     NUMBER
                        ,p_round_sid   IN     NUMBER
                        ,p_round_year       IN NUMBER
                        ,o_ret            OUT NUMBER);

    PROCEDURE refreshIndView (p_index_sid   IN     NUMBER
                        ,p_round_sid   IN     NUMBER
                        ,p_round_year       IN NUMBER
                        ,p_country_id      IN     VARCHAR2 
                        ,o_ret            OUT NUMBER);

    PROCEDURE getEntryRanking(p_entry_sid           IN  NUMBER,
                              p_sector_id           IN  VARCHAR2,
                              p_round_sid           IN  NUMBER,
                              p_round_year          IN  NUMBER,
                              o_ret                OUT  NUMBER);

    PROCEDURE checkFulfillChoice(p_entry_sid           IN  NUMBER,
                                 p_choice_score_sid    IN  NUMBER,
                                 o_res                OUT  NUMBER);

    PROCEDURE getIndicesEntries(p_questionnaire_sid    IN NUMBER
                               ,p_country_id           IN VARCHAR2
                               ,p_round_sid            IN NUMBER
                               ,p_year                 IN NUMBER
                               ,p_index_sid            IN NUMBER 
                               ,o_cur                 OUT SYS_REFCURSOR);

    PROCEDURE getIndiceEntryData(p_index_sid            IN  NUMBER
                                ,p_year                 IN  NUMBER
                                ,p_country_id           IN  VARCHAR2
                                ,o_cur                  OUT SYS_REFCURSOR);
END CFG_SCORES;