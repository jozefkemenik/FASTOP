create or replace PACKAGE BODY CFG_SCORES
AS
    t_availability CORE_TYPES.T_AVAILABILITY;
    ----------------------------------------------------------------------------
    -- @name stageShared
    -- @purpose check if scores from a scoring stage are MS shared
    ----------------------------------------------------------------------------
    FUNCTION stageShared(p_index_sid         IN NUMBER
                        ,p_score_version_sid IN NUMBER)
    RETURN NUMBER
    IS
        l_ret   NUMBER;
    BEGIN
        SELECT NVL(S.MS_SHARED, 0)
          INTO l_ret
          FROM CFG_INDEX_STAGE_VERSIONS SV
              ,CFG_INDEX_STAGES S
         WHERE S.SCORE_VERSION_SID = SV.SCORE_VERSION_SID
           AND S.SCORE_VERSION_SID = p_score_version_sid
           AND SV.INDEX_SID = p_index_sid;
        RETURN l_ret;
    END;

    ----------------------------------------------------------------------------
    -- @name clearAcceptedScore
    -- @purpose delete accepted Criteria
    ----------------------------------------------------------------------------
    PROCEDURE clearAcceptedScore (p_entry_criteria_sid IN NUMBER)
    IS
    BEGIN
        DELETE ENTRY_ACCEPTED_CRITERIA
         WHERE ENTRY_CRITERIA_SID = p_entry_criteria_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name fillStageBlanks - for selected index, country, round and version
    --                           fills empty scores based on previous versions
    -- @return number of rows inserted
    ----------------------------------------------------------------------------
    PROCEDURE fillStageBlanks (p_index_sid      IN     NUMBER
                              ,p_country_id     IN     VARCHAR2
                              ,p_round_sid      IN     NUMBER
                              ,p_stage_sid      IN     NUMBER
                              ,p_user           IN     VARCHAR2
                              ,p_organisation   IN     VARCHAR2
                              ,o_res            OUT    NUMBER)
    IS
    BEGIN
        INSERT INTO ENTRY_CRITERIA(ENTRY_SID, CRITERION_SID, ROUND_SID, SCORE, SCORE_VERSION_SID, LDAP_LOGIN, ORGANISATION, DATETIME)
        SELECT PREV.ENTRY_SID, PREV.CRITERION_SID, PREV.ROUND_SID, PREV.SCORE, p_stage_sid, p_user, p_organisation, SYSDATE FROM (
            SELECT EC.ENTRY_SID
                  ,EC.CRITERION_SID
                  ,EC.ROUND_SID
                  ,EC.SCORE
                  ,SV.ORDER_BY
                  ,MAX(SV.ORDER_BY) OVER (PARTITION BY EC.ENTRY_SID, EC.CRITERION_SID, EC.ROUND_SID) AS MAX_ORDER_BY
              FROM ENTRY_CRITERIA EC
                  ,ENTRIES E
                  ,CFG_INDEX_STAGES SV
                  ,CFG_INDEX_CRITERIA C
                  ,CFG_INDEXES I
             WHERE EC.ENTRY_SID = E.ENTRY_SID
               AND EC.SCORE_VERSION_SID = SV.SCORE_VERSION_SID
               AND EC.CRITERION_SID = C.CRITERION_SID
               AND I.INDEX_SID = C.INDEX_SID
               AND C.INDEX_SID = p_index_sid
               AND E.COUNTRY_ID = p_country_id
               AND (EC.ROUND_SID = p_round_sid OR EC.ROUND_SID IS NULL)
        ) PREV
         WHERE PREV.ORDER_BY = PREV.MAX_ORDER_BY
           AND PREV.MAX_ORDER_BY <= (SELECT ORDER_BY FROM CFG_INDEX_STAGES WHERE SCORE_VERSION_SID = p_stage_sid);

        o_res := SQL%ROWCOUNT;

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name getIndexCalculationStages
    -- @return index calculation stages
    ----------------------------------------------------------------------------
    PROCEDURE getIndexCalculationStages (p_index_sid    IN NUMBER
                                        ,o_cur          OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT S.SCORE_VERSION_SID
                  ,SV.DESCR
                  ,S.AUTOMATIC
                  ,S.ITERABLE
                  ,S.MS_SHARED
                  ,S.READ_ONLY
             FROM CFG_INDEX_STAGE_VERSIONS SV
                 ,CFG_INDEX_STAGES S
            WHERE SV.SCORE_VERSION_SID = S.SCORE_VERSION_SID
              AND SV.INDEX_SID = p_index_sid
            ORDER BY S.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getIndexCriteria
    -- @return index criteria
    ----------------------------------------------------------------------------
    PROCEDURE getIndexCriteria (p_index_sid   IN     NUMBER
                               ,o_cur            OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT C.CRITERION_SID
                  ,C.CRITERION_ID
                  ,C.SUB_CRITERION_ID
                  ,C.DESCR
                  ,C.HELP_TEXT
                  ,LISTAGG (CS.SCORE, ',') WITHIN GROUP (ORDER BY CS.SCORE) AS SCORES
              FROM CFG_INDEX_CRITERIA C
                  ,CFG_INDEX_CRITERIA_SCORES CS
             WHERE CS.CRITERION_SID = C.CRITERION_SID
               AND C.INDEX_SID = p_index_sid
            GROUP BY C.CRITERION_SID, C.CRITERION_ID, C.SUB_CRITERION_ID, C.DESCR, C.HELP_TEXT
            ORDER BY C.CRITERION_ID, C.SUB_CRITERION_ID;
    END;

    ----------------------------------------------------------------------------
    -- @name getIndexDescription
    -- @return questionnaire index information
    ----------------------------------------------------------------------------
    PROCEDURE getIndexDescription (p_index_sid      IN  NUMBER
                                  ,o_cur            OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT I.DESCR, I.QUESTIONNAIRE_SID, I.IS_ANNUAL
             FROM CFG_INDEXES I
            WHERE I.INDEX_SID = p_index_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getCountryIdxCalculationStage
    -- @return stage sid, user, organisation and update time
    ----------------------------------------------------------------------------
    PROCEDURE getCountryIdxCalculationStages (p_index_sid       IN     NUMBER
                                             ,p_country_id      IN     VARCHAR2
                                             ,p_round_sid       IN     NUMBER
                                             ,o_cur             OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT S.STAGE_SID
                  ,S.ITERATION
                  ,S.LDAP_LOGIN
                  ,S.ORGANISATION
                  ,S.DATETIME
              FROM INDEX_CALC_STAGES S
                  ,CFG_INDEXES I
             WHERE I.INDEX_SID = S.INDEX_SID
               AND S.INDEX_SID = p_index_sid
               AND S.COUNTRY_ID = p_country_id
               AND (S.ROUND_SID = p_round_sid OR I.IS_ANNUAL = 0);
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryScores
    -- @return scores for a certain index, entry and stage
    ----------------------------------------------------------------------------
    PROCEDURE getEntryScores (p_entry_sid           IN     NUMBER
                             ,p_index_sid           IN     NUMBER
                             ,p_round_sid           IN     NUMBER
                             ,p_score_version_sid   IN     NUMBER
                             ,p_criterion_sid       IN     NUMBER
                             ,p_ms_only             IN     NUMBER
                             ,o_cur                 OUT    SYS_REFCURSOR)
    IS
        l_allowed NUMBER := stageShared(p_index_sid, p_score_version_sid);
    BEGIN
        OPEN o_cur FOR
            SELECT EC.CRITERION_SID
                  ,EC.SCORE
                  ,EC.SCORE_VERSION_SID
                  ,EC.ENTRY_CRITERIA_SID
                  ,AC.LDAP_LOGIN AS ACC_LDAP_LOGIN
              FROM ENTRY_CRITERIA EC
                  ,CFG_INDEX_CRITERIA C
                  ,CFG_INDEXES I
                  ,CFG_INDEX_STAGE_VERSIONS SV
                  ,CFG_INDEX_STAGES S
                  ,ENTRY_ACCEPTED_CRITERIA AC
             WHERE EC.CRITERION_SID = C.CRITERION_SID
               AND SV.INDEX_SID = C.INDEX_SID
               AND SV.INDEX_SID = I.INDEX_SID
               AND SV.SCORE_VERSION_SID = EC.SCORE_VERSION_SID
               AND SV.SCORE_VERSION_SID = S.SCORE_VERSION_SID
               AND EC.ENTRY_CRITERIA_SID = AC.ENTRY_CRITERIA_SID(+)
               AND EC.ENTRY_SID = p_entry_sid
               AND C.INDEX_SID = p_index_sid
               AND (EC.ROUND_SID = p_round_sid OR I.IS_ANNUAL = 0)
               AND (p_criterion_sid = 0 OR EC.CRITERION_SID = p_criterion_sid)
               AND (p_ms_only = 0 OR NVL(S.MS_SHARED, 0) = l_allowed)
               AND S.ORDER_BY <= (SELECT ORDER_BY FROM CFG_INDEX_STAGES WHERE SCORE_VERSION_SID = p_score_version_sid)
            ORDER BY EC.CRITERION_SID, S.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getScoreComments
    -- @return entry score comments for selected criterion
    ----------------------------------------------------------------------------
    PROCEDURE getScoreComments (p_entry_criteria_sid    IN  NUMBER
                               ,p_is_ms                 IN  NUMBER
                               ,o_cur                   OUT SYS_REFCURSOR)
    IS
    BEGIN  
        OPEN o_cur FOR
            SELECT C.COMMENT_SID
                  ,C.DESCR
                  ,C.LDAP_LOGIN
                  ,C.ORGANISATION
                  ,C.DATETIME
              FROM ENTRY_CRITERIA_COMMENTS C
                  ,ENTRY_CRITERIA EC
                  ,CFG_INDEX_CRITERIA CIC
                  ,CFG_INDEX_STAGES ST
             WHERE C.ENTRY_CRITERIA_SID = EC.ENTRY_CRITERIA_SID
               AND EC.SCORE_VERSION_SID = ST.SCORE_VERSION_SID
               AND CIC.CRITERION_SID = EC.CRITERION_SID
               AND (p_is_ms = 0 OR NVL(ST.MS_SHARED, 0) = stageShared(CIC.INDEX_SID, ST.SCORE_VERSION_SID))
               AND EC.ENTRY_CRITERIA_SID = p_entry_criteria_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name delCountryIdxCalculationStage - used in order to reopen the stage
    -- @return number of rows updated
    ----------------------------------------------------------------------------
    PROCEDURE delCountryIdxCalculationStage (p_index_sid        IN      NUMBER
                                            ,p_country_id       IN      VARCHAR2
                                            ,p_round_sid        IN      NUMBER
                                            ,p_stage_sid        IN      NUMBER
                                            ,o_res             OUT      NUMBER)
    IS
    BEGIN
        DELETE FROM INDEX_CALC_STAGES
              WHERE INDEX_SID = p_index_sid
                AND COUNTRY_ID = p_country_id
                AND (ROUND_SID = p_round_sid OR (SELECT IS_ANNUAL FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid) = 0)  
                AND STAGE_SID = p_stage_sid;
        o_res := SQL%ROWCOUNT;

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name getPreviousFinalScore 
    -- @return score for last stage from previous round/initial stage curr round
    ----------------------------------------------------------------------------
    PROCEDURE getPreviousFinalScore(p_criterion_sid         IN  NUMBER
                                   ,p_round_sid             IN  NUMBER 
                                   ,o_cur                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT EC.ENTRY_CRITERIA_SID
                  ,EC.SCORE
                  ,EC.SCORE_VERSION_SID
                  ,EC.LDAP_LOGIN
                  ,EC.ORGANISATION
                  ,EC.DATETIME
                  ,AC.LDAP_LOGIN    ACC_LDAP_LOGIN
                  ,AC.DATETIME      ACC_DATETIME
                  ,AC.ORGANISATION  ACC_ORGANISATION
              FROM ENTRY_CRITERIA EC
                  ,CFG_INDEX_CRITERIA C
                  ,CFG_INDEXES I
                  ,CFG_INDEX_STAGES S
                  ,ENTRY_ACCEPTED_CRITERIA AC
             WHERE EC.CRITERION_SID = C.CRITERION_SID
               AND I.INDEX_SID = C.INDEX_SID
               AND S.SCORE_VERSION_SID = EC.SCORE_VERSION_SID
               AND EC.ENTRY_CRITERIA_SID = AC.ENTRY_CRITERIA_SID(+)
               AND EC.SCORE_VERSION_SID = 0
               AND EC.CRITERION_SID = p_criterion_sid
               AND EC.ROUND_SID = p_round_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getCriterionQuestions
    -- @return list of questions related to one criterion with their configuration
    ----------------------------------------------------------------------------
    PROCEDURE getCriterionQuestions (p_criterion_sid        IN      NUMBER
                                    ,o_cur                  OUT     SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT QV.QUESTION_VERSION_SID
                  ,QV.QUESTION_TYPE_SID
                  ,NULL     AS UPD_ROLES
                  ,COALESCE(CQ.PERIOD_SID, 0) AS PERIOD_SID
              FROM CFG_CRITERION_QUESTIONS CQ
                  ,CFG_QUESTION_VERSIONS QV
             WHERE CQ.QUESTION_VERSION_SID = QV.QUESTION_VERSION_SID
               AND CQ.CRITERION_SID = p_criterion_sid
            ORDER BY CQ.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryScoreDetails
    -- @return entry score details for 1 criteria across the stages
    ----------------------------------------------------------------------------
    PROCEDURE getEntryScoreDetails (p_entry_sid       IN     NUMBER
                                   ,p_round_sid       IN     NUMBER
                                   ,p_criterion_sid   IN     NUMBER
                                   ,p_version_sid     IN     NUMBER
                                   ,p_ms_only         IN     NUMBER
                                   ,o_cur                OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT EC.ENTRY_CRITERIA_SID
                  ,EC.SCORE
                  ,EC.SCORE_VERSION_SID
                  ,EC.LDAP_LOGIN
                  ,EC.ORGANISATION
                  ,EC.DATETIME
                  ,AC.LDAP_LOGIN    ACC_LDAP_LOGIN
                  ,AC.DATETIME      ACC_DATETIME
                  ,AC.ORGANISATION  ACC_ORGANISATION
              FROM ENTRY_CRITERIA EC
                  ,ENTRY_ACCEPTED_CRITERIA AC
                  ,CFG_INDEXES I
                  ,CFG_INDEX_CRITERIA C
                  ,CFG_INDEX_STAGES SV
             WHERE C.CRITERION_SID = EC.CRITERION_SID
               AND I.INDEX_SID = C.INDEX_SID
               AND SV.SCORE_VERSION_SID = EC.SCORE_VERSION_SID
               AND SV.ORDER_BY <= (SELECT ORDER_BY FROM CFG_INDEX_STAGES WHERE SCORE_VERSION_SID = p_version_sid)
               AND EC.ENTRY_CRITERIA_SID = AC.ENTRY_CRITERIA_SID(+)
               AND (EC.ROUND_SID = p_round_sid OR I.IS_ANNUAL = 0)
               AND EC.CRITERION_SID = p_criterion_sid
               AND EC.ENTRY_SID = p_entry_sid
               AND (p_ms_only = 0 OR NVL(SV.MS_SHARED, 0) = stageShared(I.INDEX_SID, p_version_sid))
            ORDER BY SV.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryCriterionScore
    -- @return entry_criteria_sid of updated/inserted record
    ----------------------------------------------------------------------------
    PROCEDURE setEntryCriterionScore (p_entry_sid       IN     NUMBER
                                     ,p_round_sid       IN     NUMBER
                                     ,p_criterion_sid   IN     NUMBER
                                     ,p_version_sid     IN     NUMBER
                                     ,p_score           IN     NUMBER
                                     ,p_user            IN     VARCHAR2
                                     ,p_organisation    IN     VARCHAR2
                                     ,o_res             OUT    NUMBER)
    IS
    BEGIN
        --Try to update the score
        UPDATE ENTRY_CRITERIA
           SET SCORE = p_score
              ,LDAP_LOGIN = p_user
              ,ORGANISATION = p_organisation
              ,DATETIME = SYSDATE
         WHERE ENTRY_SID = p_entry_sid
           AND CRITERION_SID = p_criterion_sid
           AND SCORE_VERSION_SID = p_version_sid
           AND (ROUND_SID = p_round_sid OR ROUND_SID IS NULL)
        RETURNING ENTRY_CRITERIA_SID INTO o_res;

        --If not found, insert new record
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO ENTRY_CRITERIA(ENTRY_SID, ROUND_SID, CRITERION_SID, SCORE_VERSION_SID, SCORE, LDAP_LOGIN, ORGANISATION, DATETIME)
            VALUES (p_entry_sid, p_round_sid, p_criterion_sid, p_version_sid, p_score, p_user, p_organisation, SYSDATE)
            RETURNING ENTRY_CRITERIA_SID INTO o_res;
        END IF;

        clearAcceptedScore(o_res);

        COMMIT;

    END;

    ----------------------------------------------------------------------------
    -- @name addScoreComment
    -- @return COMMENT_SID of added comment
    ----------------------------------------------------------------------------
    PROCEDURE addScoreComment (p_entry_criteria_sid   IN     NUMBER
                              ,p_comment              IN     VARCHAR2
                              ,p_user                 IN     VARCHAR2
                              ,p_organisation         IN     VARCHAR2
                              ,o_res                  OUT    NUMBER)
    IS
    BEGIN
        INSERT INTO ENTRY_CRITERIA_COMMENTS(ENTRY_CRITERIA_SID, DESCR, LDAP_LOGIN, ORGANISATION, DATETIME)
        VALUES (p_entry_criteria_sid, p_comment, p_user, p_organisation, SYSDATE)
        RETURNING COMMENT_SID INTO o_res;

        clearAcceptedScore(p_entry_criteria_sid);

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name deleteScoreComment
    --    user must be the same who entered the comment or null (which means admin)
    -- @return number of rows deleted
    ----------------------------------------------------------------------------
    PROCEDURE deleteScoreComment (p_comment_sid   IN     NUMBER
                                 ,p_user          IN     VARCHAR2
                                 ,o_res           OUT    NUMBER)
    IS
    BEGIN
        DELETE FROM ENTRY_CRITERIA_COMMENTS
              WHERE COMMENT_SID = p_comment_sid 
                AND (p_user IS NULL OR LDAP_LOGIN = p_user);
        o_res := SQL%ROWCOUNT;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name updateScoreComment
    -- @return number of rows updated
    ----------------------------------------------------------------------------
    PROCEDURE updateScoreComment (p_comment_sid   IN     NUMBER
                                 ,p_comment       IN     VARCHAR2
                                 ,p_user          IN     VARCHAR2
                                 ,o_res           OUT    NUMBER)
    IS
    BEGIN
        UPDATE ENTRY_CRITERIA_COMMENTS
           SET DESCR = p_comment
              ,DATETIME = SYSDATE
         WHERE COMMENT_SID = p_comment_sid AND LDAP_LOGIN = p_user;

        o_res := SQL%ROWCOUNT;

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name acceptCriteriaScore
    -- @return number of records inserted
    ----------------------------------------------------------------------------
    PROCEDURE acceptCriteriaScore (p_entry_criteria_sid  IN     NUMBER
                                  ,p_score               IN     NUMBER
                                  ,p_user                IN     VARCHAR2
                                  ,p_organisation        IN     VARCHAR2
                                  ,o_res                 OUT    NUMBER)
    IS
        l_score NUMBER;
    BEGIN
        SELECT SCORE
          INTO l_score
          FROM ENTRY_CRITERIA
         WHERE ENTRY_CRITERIA_SID = p_entry_criteria_sid;

        IF l_score = p_score THEN
            INSERT INTO ENTRY_ACCEPTED_CRITERIA(ENTRY_CRITERIA_SID, LDAP_LOGIN, ORGANISATION, DATETIME) 
            VALUES (p_entry_criteria_sid, p_user, p_organisation, SYSDATE);
            o_res := SQL%ROWCOUNT;
        ELSE
            o_res := -1;
        END IF;
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            o_res := 0;
    END;

    ----------------------------------------------------------------------------
    -- @name getDisagreedCriteria
    -- @return criteria for which there is no agreement yet
    ----------------------------------------------------------------------------
    PROCEDURE getDisagreedCriteria (p_entry_sid     IN     NUMBER
                                   ,p_round_sid     IN     NUMBER
                                   ,p_version_sid   IN     NUMBER
                                   ,p_index_sid     IN     NUMBER
                                   ,p_country_id    IN     VARCHAR2
                                   ,o_cur           OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT C.CRITERION_SID
                  ,C.CRITERION_ID || C.SUB_CRITERION_ID AS CRITERIA_NAME
              FROM ENTRY_CRITERIA EC
                  ,CFG_INDEX_CRITERIA C
                  ,CFG_INDEXES I
                  ,ENTRIES E
                  ,ENTRY_CRITERIA_COMMENTS CC
                  ,ENTRY_ACCEPTED_CRITERIA AC
             WHERE C.CRITERION_SID = EC.CRITERION_SID
               AND I.INDEX_SID = C.INDEX_SID
               AND E.ENTRY_SID = EC.ENTRY_SID
               AND CC.ENTRY_CRITERIA_SID = EC.ENTRY_CRITERIA_SID
               AND EC.ENTRY_CRITERIA_SID = AC.ENTRY_CRITERIA_SID(+)
               AND (p_entry_sid = 0 OR EC.ENTRY_SID = p_entry_sid)
               AND (EC.ROUND_SID = p_round_sid OR I.IS_ANNUAL = 0)
               AND EC.SCORE_VERSION_SID = p_version_sid
               AND AC.LDAP_LOGIN IS NULL
               AND E.COUNTRY_ID = p_country_id
            ORDER BY C.CRITERION_SID, C.CRITERION_ID;
    END;

    ----------------------------------------------------------------------------
    -- @name setCountryIdxCalculationStage
    -- @return number of rows updated
    ----------------------------------------------------------------------------
    PROCEDURE setCountryIdxCalculationStage (p_index_sid      IN     NUMBER
                                            ,p_country_id     IN     VARCHAR2
                                            ,p_round_sid      IN     NUMBER
                                            ,p_stage_sid      IN     NUMBER
                                            ,p_iteration      IN     VARCHAR2
                                            ,p_user           IN     VARCHAR2
                                            ,p_organisation   IN     VARCHAR2
                                            ,o_res            OUT    NUMBER)
    IS
        l_fill NUMBER;
    BEGIN
        -- Try to update record if it already exists
        UPDATE INDEX_CALC_STAGES
           SET LDAP_LOGIN = p_user
              ,ORGANISATION = p_organisation
              ,DATETIME = SYSDATE
              ,ITERATION = p_iteration
         WHERE INDEX_SID = p_index_sid
           AND COUNTRY_ID = p_country_id
           AND (ROUND_SID IS NULL OR ROUND_SID = p_round_sid)
           AND STAGE_SID = p_stage_sid;

        o_res := SQL%ROWCOUNT;

        -- If it does not exist, insert new record
        IF o_res = 0 THEN
            INSERT INTO INDEX_CALC_STAGES(INDEX_SID, COUNTRY_ID, ROUND_SID, STAGE_SID, ITERATION, LDAP_LOGIN, ORGANISATION, DATETIME)
            VALUES (p_index_sid, p_country_id, p_round_sid, p_stage_sid, p_iteration, p_user, p_organisation, SYSDATE);
            o_res := SQL%ROWCOUNT;

            SELECT FILL_BLANKS
              INTO l_fill
              FROM CFG_INDEX_STAGES
             WHERE SCORE_VERSION_SID = p_stage_sid;

            IF l_fill = 1 THEN
                fillStageBlanks(p_index_sid, p_country_id, p_round_sid, p_stage_sid, p_user, p_organisation, l_fill) ;
            END IF;
        END IF;

        -- IF p_iteration = 'MS' THEN
        --     sendInfoMail(p_country_id, p_index_sid, 1);
        -- END IF;

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name getIndexCriteriaScoreTypes
    -- @return criterion and it's accessor for certain index
    ----------------------------------------------------------------------------
    PROCEDURE getIndexCriteriaScoreTypes (p_index_sid    IN NUMBER
                                         ,o_cur          OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT IC.CRITERION_SID
                  ,IC.SCORE_TYPE_SID
                  ,ST.ACCESSOR
              FROM CFG_INDEX_CRITERIA IC
                  ,CFG_SCORE_TYPES ST
             WHERE IC.SCORE_TYPE_SID = ST.SCORE_TYPE_SID
               AND IC.INDEX_SID = p_index_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getCriteriaConditions
    -- @return conditions for calculating a score
    ----------------------------------------------------------------------------
    PROCEDURE getCriteriaConditions (p_criterion_sid    IN NUMBER
                                    ,o_cur              OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT CHOICE_SCORE_SID
                  ,COND_QUESTION_VERSION_SID
                  ,COND_LOV_SID
                  ,CUSTOM_CONDITION
                  ,AND_CHOICE_SCORE_SID
                  ,OR_CHOICE_SCORE_SID
              FROM CFG_SCORE_CONDITIONS
             WHERE CRITERION_SID =  p_criterion_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name calcSingleScore
    -- @purpose calculate score for single choice question
    ----------------------------------------------------------------------------
    PROCEDURE calcSingleScore (p_entry_sid          IN  NUMBER
                              ,p_criterion_sid      IN  NUMBER
                              ,p_choice_score_sid   IN  NUMBER
                              ,o_res                OUT NUMBER)
    IS
    BEGIN
        SELECT DISTINCT TO_NUMBER(ICS.SCORE) AS SCORE
          INTO o_res
          FROM CFG_INDEX_CHOICES_SCORES ICS
              ,ENTRY_CHOICES EC
         WHERE EC.QUESTION_VERSION_SID = ICS.QUESTION_VERSION_SID
           AND EC.RESPONSE = TO_CHAR(ICS.LOV_SID)
           AND ICS.CRITERION_SID = p_criterion_sid
           AND EC.ENTRY_SID = p_entry_sid
           AND ICS.CHOICE_SCORE_SID = p_choice_score_sid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_res := 0;           
    END;

    ----------------------------------------------------------------------------
    -- @name calcMultiScore
    -- @purpose calculate score for multi choice question
    ----------------------------------------------------------------------------
    PROCEDURE calcMultiScore (p_entry_sid           IN  NUMBER
                             ,p_criterion_sid       IN  NUMBER
                             ,p_choice_score_sid    IN  NUMBER
                             ,o_res                 OUT NUMBER)
    IS
    BEGIN
        SELECT MAX(NVL(ICS.SCORE, 0)) AS SCORE
          INTO o_res
          FROM CFG_INDEX_CHOICES_SCORES ICS
              ,ENTRY_CHOICES EC
         WHERE EC.QUESTION_VERSION_SID = ICS.QUESTION_VERSION_SID
           AND EC.RESPONSE = TO_CHAR(ICS.LOV_SID)
           AND ICS.CRITERION_SID = p_criterion_sid
           AND EC.ENTRY_SID = p_entry_sid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_res := 0; 
    END;

    ----------------------------------------------------------------------------
    -- @name calcSumScore
    -- @purpose calculate score for multi choice question
    ----------------------------------------------------------------------------
    PROCEDURE calcSumScore (p_entry_sid             IN  NUMBER
                           ,p_criterion_sid         IN  NUMBER
                           ,p_choice_score_sid      IN  NUMBER
                           ,o_res                   OUT NUMBER)
    IS
        l_q_score    NUMBER;
        l_t_score    NUMBER := 0;
        CURSOR c_questions IS
        SELECT DISTINCT QUESTION_VERSION_SID
          FROM CFG_INDEX_CHOICES_SCORES
         WHERE CRITERION_SID = p_criterion_sid;
    BEGIN
        FOR rec IN c_questions LOOP
            SELECT ICS.SCORE
              INTO l_q_score
              FROM CFG_INDEX_CHOICES_SCORES ICS
                  ,ENTRY_CHOICES EC
             WHERE EC.QUESTION_VERSION_SID = ICS.QUESTION_VERSION_SID
               AND ICS.QUESTION_VERSION_SID = rec.QUESTION_VERSION_SID
               AND EC.RESPONSE = TO_CHAR(ICS.LOV_SID)
               AND ICS.CRITERION_SID = p_criterion_sid
               AND EC.ENTRY_SID = p_entry_sid;

            l_t_score := l_t_score + l_q_score;
        END LOOP;
        o_res := l_t_score;  
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_res := 0;
    END;

    ----------------------------------------------------------------------------
    -- @name calcMeanScore
    -- @purpose calculate score for multi choice question
    ----------------------------------------------------------------------------
    PROCEDURE calcMeanScore (p_entry_sid            IN  NUMBER
                            ,p_criterion_sid        IN  NUMBER
                            ,p_choice_score_sid     IN  NUMBER
                            ,o_res                  OUT NUMBER)
    IS
        l_q_score    NUMBER;
        l_t_score    NUMBER := 0;
        l_question_count NUMBER;
        CURSOR c_questions IS
        SELECT DISTINCT QUESTION_VERSION_SID
          FROM CFG_INDEX_CHOICES_SCORES
         WHERE CRITERION_SID = p_criterion_sid;
    BEGIN
        SELECT COUNT(DISTINCT QUESTION_VERSION_SID) 
          INTO l_question_count
          FROM CFG_INDEX_CHOICES_SCORES
         WHERE CRITERION_SID = p_criterion_sid;
        FOR rec IN c_questions LOOP
            SELECT ICS.SCORE
              INTO l_q_score
              FROM CFG_INDEX_CHOICES_SCORES ICS
                  ,ENTRY_CHOICES EC
             WHERE EC.QUESTION_VERSION_SID = ICS.QUESTION_VERSION_SID
               AND ICS.QUESTION_VERSION_SID = rec.QUESTION_VERSION_SID
               AND EC.RESPONSE = TO_CHAR(ICS.LOV_SID)
               AND ICS.CRITERION_SID = p_criterion_sid
               AND EC.ENTRY_SID = p_entry_sid;

            l_t_score := l_t_score + l_q_score;
        END LOOP;
        o_res := l_t_score/l_question_count;    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_res := 0;        
    END;

    ----------------------------------------------------------------------------
    -- @name calcCondSingleScore
    -- @purpose calculate score for conditional single choice question
    ----------------------------------------------------------------------------
    PROCEDURE calcCondSingleScore (p_entry_sid            IN  NUMBER
                                  ,p_criterion_sid        IN  NUMBER
                                  ,p_choice_score_sid     IN  NUMBER
                                  ,o_res                  OUT NUMBER)
    IS
    BEGIN
        SELECT ICS.SCORE
          INTO o_res
          FROM CFG_INDEX_CHOICES_SCORES ICS
              ,ENTRY_CHOICES EC
         WHERE EC.QUESTION_VERSION_SID = ICS.QUESTION_VERSION_SID
           AND EC.RESPONSE = TO_CHAR(ICS.LOV_SID)
           AND ICS.CRITERION_SID = p_criterion_sid
           AND EC.ENTRY_SID = p_entry_sid
           AND ICS.CHOICE_SCORE_SID = p_choice_score_sid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_res := 0; 
    END;

    ----------------------------------------------------------------------------
    -- @name calcCondMultiScore
    -- @purpose calculate score for conditional multi choice question
    ----------------------------------------------------------------------------
    PROCEDURE calcCondMultiScore (p_entry_sid            IN  NUMBER
                                 ,p_criterion_sid        IN  NUMBER
                                 ,p_choice_score_sid     IN  NUMBER
                                 ,o_res                  OUT NUMBER)
    IS
        l_count     NUMBER;
    BEGIN
        SELECT COUNT(DISTINCT SCORE)
          INTO l_count
          FROM CFG_INDEX_CHOICES_SCORES
         WHERE CRITERION_SID = p_criterion_sid;

        IF l_count = 1 THEN
            SELECT DISTINCT (SCORE)
              INTO o_res
              FROM CFG_INDEX_CHOICES_SCORES
             WHERE CRITERION_SID = p_criterion_sid;
        ELSE
            SELECT DISTINCT (SCORE)
              INTO o_res
              FROM CFG_INDEX_CHOICES_SCORES
             WHERE CRITERION_SID = p_criterion_sid
               AND CHOICE_SCORE_SID = p_choice_score_sid;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_res := 0; 
    END;

    ----------------------------------------------------------------------------
    -- @name getCriteriaChoices
    -- @purpose return the choices which are fulfilled for the entry,criterion
    ----------------------------------------------------------------------------
    PROCEDURE getCriteriaChoices (p_criterion_sid   IN      NUMBER
                                 ,p_entry_sid       IN      NUMBER
                                 ,o_cur             OUT     SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT ICS.CHOICE_SCORE_SID
              FROM CFG_INDEX_CHOICES_SCORES ICS
                  ,ENTRY_CHOICES EC
             WHERE EC.QUESTION_VERSION_SID = ICS.QUESTION_VERSION_SID
               AND EC.RESPONSE = TO_CHAR(ICS.LOV_SID)
               AND ICS.CRITERION_SID = p_criterion_sid
               AND EC.ENTRY_SID = p_entry_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name checkChoiceCondition
    -- @purpose check if condition for a score is met
    ----------------------------------------------------------------------------
    PROCEDURE checkChoiceCondition(p_entry_sid              IN  NUMBER
                                  ,p_question_version_sid   IN  NUMBER
                                  ,p_custom_condition       IN  VARCHAR2
                                  ,p_round_year             IN  NUMBER
                                  ,o_res                    OUT NUMBER)
    IS
        TYPE t_curs IS REF CURSOR;
        l_sql_stmt    VARCHAR2(4000 BYTE);
        l_stmt      VARCHAR2(4000 BYTE);
        l_condition VARCHAR2(4000 BYTE);
        l_target    VARCHAR2(4000 BYTE);
        l_cursor    SYS_REFCURSOR;
        l_cursor_id INTEGER;
        l_rowcount  NUMBER;
        l_target_unit VARCHAR2(4000 BYTE);
    BEGIN

        l_sql_stmt := 'SELECT  to_char(NVL(VALUE, 0) )
              FROM TARGET_ENTRIES
             WHERE ENTRY_SID = ' || p_entry_sid || '
               AND RESPONSE_SID = '|| p_round_year || ' - 1';


        EXECUTE IMMEDIATE l_sql_stmt INTO l_target;
        IF l_target IS NOT NULL THEN
            l_stmt := REPLACE(
                        REPLACE(
                            REPLACE(p_custom_condition
                                    ,'{QUESTION_VERSION_SID}'
                                    ,p_question_version_sid)
                            ,'{ENTRY_SID}'
                            ,p_entry_sid)
                        ,'{TARGET}'
                        ,l_target) ;
        ELSE
            IF p_question_version_sid != 0 THEN
                l_stmt := REPLACE(
                            REPLACE(p_custom_condition
                                    ,'{QUESTION_VERSION_SID}'
                                    ,p_question_version_sid)
                            ,'{ENTRY_SID}'
                            ,p_entry_sid) ;
            ELSE
                l_stmt := REPLACE(p_custom_condition
                            ,'{ENTRY_SID}'
                            ,p_entry_sid);
            END IF;
        END IF;
        l_condition := 'SELECT CASE WHEN ' || l_stmt || ' THEN 1 ELSE 0 END FROM DUAL';

        EXECUTE IMMEDIATE l_condition INTO o_res;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_res := -1; 
        WHEN OTHERS THEN

            raise_application_error(-20011,'An error was encountered - entry_sid'|| p_entry_sid || '-'|| p_custom_condition || '-' || p_question_version_sid ||SQLCODE||' -ERROR- '||SQLERRM);
    
    END;

    ----------------------------------------------------------------------------
    -- @name getIndiceTypes
    -- @purpose getIndiceCfg based on index_sid
    ----------------------------------------------------------------------------
    PROCEDURE getIndiceTypes (o_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT INDICE_TYPE_SID
                  ,INDICE_ID
                  ,MULTI_ENTRY
              FROM CFG_INDICE_CRITERIA_TYPES;
    END;
    ----------------------------------------------------------------------------
    -- @name getIndicesCfg
    -- @return getIndiceCfg based on index_sid
    ----------------------------------------------------------------------------
    PROCEDURE getIndicesCfg(p_index_sid              IN  NUMBER
                           ,o_cur                    OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT IND_CRITERION_SID
                  ,INDICE_TYPE_SID
                  ,ACCESSOR
                  ,CRITERION_VALUE
                  ,DISPLAY_NAME
                  ,ORDER_BY
              FROM CFG_INDICE_CRITERIA
             WHERE INDEX_SID = p_index_sid
             ORDER BY INDICE_TYPE_SID, IND_CRITERION_SID;
    END;

    ----------------------------------------------------------------------------
    -- @name getIndicators
    -- @return indicators that are to be displayed
    ----------------------------------------------------------------------------
    PROCEDURE getIndicators(p_index_sid              IN  NUMBER
                           ,p_multi_entry            IN  NUMBER 
                           ,o_cur                    OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT IND_CRITERION_SID
                  ,DISPLAY_NAME
              FROM CFG_INDICE_CRITERIA
             WHERE INDEX_SID = p_index_sid
               AND INDICE_TYPE_SID IN (SELECT INDICE_TYPE_SID FROM CFG_INDICE_CRITERIA_TYPES WHERE MULTI_ENTRY = p_multi_entry)
             ORDER BY ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getLatestScores
    -- @return latest scores for an index and country
    ----------------------------------------------------------------------------
    PROCEDURE getLatestScores(p_entry_sid               IN  NUMBER
                             ,p_index_sid               IN  NUMBER
                             ,p_round_sid               IN  NUMBER
                             ,o_cur                    OUT  SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            WITH t AS (
                SELECT RC.ENTRY_SID
                      ,E.ENTRY_NO
                      ,E.ENTRY_VERSION
                      ,RC.ROUND_SID
                      ,C.CRITERION_SID
                      ,RC.SCORE
                      ,SV.ORDER_BY
                      ,MAX(SV.ORDER_BY) OVER (PARTITION BY RC.ENTRY_SID, C.CRITERION_SID) MAX_ORDER_BY
                  FROM ENTRY_CRITERIA RC
                      ,CFG_INDEX_CRITERIA C
                      ,CFG_INDEX_STAGES SV
                      ,ENTRIES E
                 WHERE RC.CRITERION_SID = C.CRITERION_SID
                   AND SV.SCORE_VERSION_SID = RC.SCORE_VERSION_SID
                   AND RC.ENTRY_SID = E.ENTRY_SID
                   AND E.ENTRY_SID = p_entry_sid
                   AND C.INDEX_SID  = p_index_sid
                   AND (RC.ROUND_SID IS NULL OR RC.ROUND_SID = p_round_sid)
                   AND cfg_questionnaire.getAvailability(E.IMPL_DATE
                                                             ,E.REFORM_IMPL_DATE
                                                             ,E.REFORM_REPLACED_DATE
                                                             ,E.ABOLITION_DATE) IN ( t_availability.C, t_availability.F )
            )
            SELECT DISTINCT ENTRY_SID,ENTRY_NO, ENTRY_VERSION, CRITERION_SID, SCORE FROM t WHERE t.ORDER_BY = t.MAX_ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getCoverages
    -- @return coverages of an entry
    ----------------------------------------------------------------------------
    PROCEDURE getCoverages(p_entry_sid              IN  NUMBER
                          ,o_cur                    OUT  SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
        SELECT E.ENTRY_SID, getCoverage(E.ENTRY_SID, E.RESPONSE) AS COVERAGE, C.LOV_ID AS RESPONSE_ID
          FROM ENTRY_CHOICES E, CFG_LOVS C
         WHERE E.ENTRY_SID = p_entry_sid
           AND TO_NUMBER(E.RESPONSE) = C.LOV_SID
           AND E.QUESTION_VERSION_SID = 2; 
    END;

    ----------------------------------------------------------------------------
    -- @name getComplianceScoring
    -- @return compliance scoring of an entry
    ----------------------------------------------------------------------------
    PROCEDURE getComplianceScoring(p_entry_sid              IN  NUMBER
                                  ,p_round_sid              IN  NUMBER
                                  ,o_ret                    OUT  NUMBER)
    IS
        l_cr1 NUMBER;
        l_cr2 NUMBER;
        l_cr3 NUMBER;
        l_is_ambitious NUMBER;
    BEGIN
        SELECT IS_AMBITIOUS
          INTO l_is_ambitious
          FROM ENTRIES_ADD_CFG
         WHERE ENTRY_SID = p_entry_sid;

        WITH t AS (
                SELECT RC.ENTRY_SID
                      ,RC.ROUND_SID
                      ,C.CRITERION_SID
                      ,RC.SCORE
                      ,SV.ORDER_BY
                      ,MAX(SV.ORDER_BY) OVER (PARTITION BY RC.ENTRY_SID, C.CRITERION_SID) MAX_ORDER_BY
                  FROM ENTRY_CRITERIA RC
                      ,CFG_INDEX_CRITERIA C
                      ,CFG_INDEX_STAGES SV
                      ,ENTRIES E
                 WHERE RC.CRITERION_SID = C.CRITERION_SID
                   AND SV.SCORE_VERSION_SID = RC.SCORE_VERSION_SID
                   AND E.ENTRY_SID = RC.ENTRY_SID
                   AND RC.ROUND_SID = p_round_sid
                   AND cfg_questionnaire.getAvailability(E.IMPL_DATE
                                                             ,E.REFORM_IMPL_DATE
                                                             ,E.REFORM_REPLACED_DATE
                                                             ,E.ABOLITION_DATE) = t_availability.C
                   AND RC.ENTRY_SID  = p_entry_sid
            )
            SELECT DISTINCT SCORE INTO l_cr1 FROM t WHERE t.ORDER_BY = t.MAX_ORDER_BY AND CRITERION_SID = 12;
        WITH t AS (
                SELECT RC.ENTRY_SID
                      ,RC.ROUND_SID
                      ,C.CRITERION_SID
                      ,RC.SCORE
                      ,SV.ORDER_BY
                      ,MAX(SV.ORDER_BY) OVER (PARTITION BY RC.ENTRY_SID, C.CRITERION_SID) MAX_ORDER_BY
                  FROM ENTRY_CRITERIA RC
                      ,CFG_INDEX_CRITERIA C
                      ,CFG_INDEX_STAGES SV
                      ,ENTRIES E
                 WHERE RC.CRITERION_SID = C.CRITERION_SID
                   AND SV.SCORE_VERSION_SID = RC.SCORE_VERSION_SID
                   AND E.ENTRY_SID = RC.ENTRY_SID
                   AND RC.ROUND_SID = p_round_sid
                   AND cfg_questionnaire.getAvailability(E.IMPL_DATE
                                                             ,E.REFORM_IMPL_DATE
                                                             ,E.REFORM_REPLACED_DATE
                                                             ,E.ABOLITION_DATE) = t_availability.C
                   AND RC.ENTRY_SID  = p_entry_sid
            )
            SELECT DISTINCT SCORE INTO l_cr2 FROM t WHERE t.ORDER_BY = t.MAX_ORDER_BY AND CRITERION_SID = 13;
        WITH t AS (
                SELECT RC.ENTRY_SID
                      ,RC.ROUND_SID
                      ,C.CRITERION_SID
                      ,RC.SCORE
                      ,SV.ORDER_BY
                      ,MAX(SV.ORDER_BY) OVER (PARTITION BY RC.ENTRY_SID, C.CRITERION_SID) MAX_ORDER_BY
                  FROM ENTRY_CRITERIA RC
                      ,CFG_INDEX_CRITERIA C
                      ,CFG_INDEX_STAGES SV
                      ,ENTRIES E
                 WHERE RC.CRITERION_SID = C.CRITERION_SID
                   AND SV.SCORE_VERSION_SID = RC.SCORE_VERSION_SID
                   AND E.ENTRY_SID = RC.ENTRY_SID
                   AND RC.ROUND_SID = p_round_sid
                   AND cfg_questionnaire.getAvailability(E.IMPL_DATE
                                                             ,E.REFORM_IMPL_DATE
                                                             ,E.REFORM_REPLACED_DATE
                                                             ,E.ABOLITION_DATE) = t_availability.C
                   AND RC.ENTRY_SID  = p_entry_sid
            )
            SELECT DISTINCT SCORE INTO l_cr3 FROM t WHERE t.ORDER_BY = t.MAX_ORDER_BY AND CRITERION_SID = 14;

        IF (l_cr1 = 1 AND l_cr2 = 1 AND  l_is_ambitious = 1 AND l_cr3 = 0) THEN
            o_ret := 2;
        ELSIF ((l_cr1 = 1 AND l_cr2 = 0 AND l_cr3 = 0) OR
            (l_cr1 = 1 AND l_cr2 = 1 AND l_is_ambitious != 1 AND l_cr3 = 0)) THEN
            o_ret := 1;
        ELSIF ((l_cr2 = 1 AND l_cr1 = 0 AND l_cr3 = 0) OR 
            (l_cr1 = 0 AND l_cr2 = 1 AND l_is_ambitious = 0 AND l_cr3 = 0)) THEN
            o_ret := 0;
        ELSE
            o_ret := -1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            o_ret := -1;
    END;

    ----------------------------------------------------------------------------
    -- @name getComplianceBonus
    -- @return compliance bonus for a country
    ----------------------------------------------------------------------------
    PROCEDURE getComplianceBonus(p_country_id             IN  VARCHAR2
                                ,p_round_sid              IN  NUMBER  
                                ,p_start_year             IN  NUMBER 
                                ,p_vector                 IN  VARCHAR2
                                ,p_year                   IN  NUMBER 
                                ,o_ret                    OUT  NUMBER)
    IS
        l_output_gap NUMBER;
    BEGIN
        l_output_gap := cfg_accessors.getValue(p_start_year, p_vector, p_year);
        IF l_output_gap < ( - 3 ) THEN
            o_ret := 1;
        ELSIF ( - 1.45 ) < l_output_gap AND l_output_gap < -3 THEN
            o_ret := 0.5;
        ELSE
            o_ret := 0;
        END IF;

    END;

    ----------------------------------------------------------------------------
    -- @name isInForce
    -- @purpose verifies if an entry is in force at the moment of checking
    ----------------------------------------------------------------------------
    PROCEDURE isInForce(p_entry_sid             IN  NUMBER
                       ,o_ret                    OUT  NUMBER)
    IS
        l_ret VARCHAR2(30);
    BEGIN
        SELECT cfg_questionnaire.getAvailability(IMPL_DATE
                                                             ,REFORM_IMPL_DATE
                                                             ,REFORM_REPLACED_DATE
                                                             ,ABOLITION_DATE)  INTO l_ret FROM ENTRIES WHERE ENTRY_SID = p_entry_sid;

        IF l_ret = t_availability.C THEN
            o_ret := 1;
        ELSE
            o_ret := 0;
        END IF;  
    END;

    ----------------------------------------------------------------------------
    -- @name checkIndiceCreation
    -- @purpose verifies if indices data table was created for the specific round
    -- and if not, creates it
    ----------------------------------------------------------------------------
    PROCEDURE checkIndiceCreation(p_index_sid   IN NUMBER
                                 ,p_round_sid   IN NUMBER
                                 ,p_round_year  IN NUMBER
                                 ,o_ret         OUT NUMBER)
    IS
        l_exists NUMBER;
        l_index_abrv VARCHAR2(300 BYTE);
        l_has_criteria NUMBER;

        l_tab_name VARCHAR2(500 BYTE);
        l_statement VARCHAR2(2000 BYTE);
        l_table_statement VARCHAR2(2000 BYTE);
        l_add_row_statement VARCHAR2(2000 BYTE);
        l_upd_row_statement VARCHAR2(2000 BYTE);
        l_result NUMBER;
        l_other_attrs NUMBER;

        l_cursor_id INTEGER;

        CURSOR c_indice_cols IS
            SELECT * FROM CFG_INDICE_CRITERIA WHERE INDEX_SID = p_index_sid ORDER BY IND_CRITERION_SID;

        CURSOR c_indice_attrs IS
            SELECT INDICE_ATTRIBUTE_SID, ACCESSOR, ATTR_ID FROM CFG_INDICES_ATTRIBUTES WHERE INDEX_SID = p_index_sid ORDER BY 1;
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;
        SELECT COUNT(*) INTO l_has_criteria FROM CFG_INDEX_CRITERIA WHERE INDEX_SID = p_index_sid;
        
        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;

        IF l_has_criteria = 0 THEN
        -- if the index has no criteria defined, skip the check
            o_ret := 0;
        ELSE
            BEGIN
                l_statement := 'SELECT COUNT(*) FROM '|| l_tab_name;
                EXECUTE IMMEDIATE l_statement INTO l_result;
            EXCEPTION
                WHEN OTHERS THEN
                    l_result := NULL;
            END;

            IF l_result IS NULL THEN
                --table has to be created so that data can be inserted
                l_cursor_id := DBMS_SQL.OPEN_CURSOR;
                l_table_statement := 'CREATE TABLE ' || l_tab_name || '(COUNTRY_ID VARCHAR2(200 BYTE), ENTRY_SID NUMBER)';
                --create the table by parsing the cursor
                DBMS_SQL.PARSE(l_cursor_id, l_table_statement, DBMS_SQL.NATIVE);

                --insert row for headers
                l_table_statement := 'INSERT INTO ' || l_tab_name || '(COUNTRY_ID , ENTRY_SID ) VALUES ('||CHR(39)|| 'HEADER' || CHR(39) ||', 0)';
                --create the table by parsing the cursor
                EXECUTE IMMEDIATE l_table_statement;

                --Check if other attributes are needed for the indices
                SELECT COUNT(*) INTO l_other_attrs FROM CFG_INDICES_ATTRIBUTES WHERE INDEX_SID = p_index_sid;
                IF l_other_attrs > 0 THEN
                    FOR rec_attr IN c_indice_attrs LOOP
                        --Compose alter table statement
                        l_add_row_statement := 'ALTER TABLE ' || l_tab_name || ' ADD (' || rec_attr.ATTR_ID || ' VARCHAR2(200 BYTE) )';
                        --alter the table by parsing the cursor
                        DBMS_SQL.PARSE(l_cursor_id, l_add_row_statement, DBMS_SQL.NATIVE);
                        --update header row
                        l_upd_row_statement := 'UPDATE '|| l_tab_name || ' SET ' || rec_attr.ATTR_ID || ' = '||CHR(39)|| 'Sector'||CHR(39)|| ' WHERE COUNTRY_ID = ' ||CHR(39)|| 'HEADER' || CHR(39) || ' AND ENTRY_SID = 0';
                        EXECUTE IMMEDIATE l_upd_row_statement;
                    END LOOP;
                END IF;
                --after the table is created add the columns for the table
                FOR rec_col IN c_indice_cols LOOP
                    --Compose alter table statement
                    l_add_row_statement := 'ALTER TABLE ' || l_tab_name || ' ADD (SDIM' || rec_col.IND_CRITERION_SID || ' VARCHAR2(200 BYTE) )';
                    --alter the table by parsing the cursor
                    DBMS_SQL.PARSE(l_cursor_id, l_add_row_statement, DBMS_SQL.NATIVE);
                    --update header row
                    l_upd_row_statement := 'UPDATE '|| l_tab_name || ' SET SDIM' || rec_col.IND_CRITERION_SID || ' = '||CHR(39)|| rec_col.DISPLAY_NAME||CHR(39)|| ' WHERE COUNTRY_ID = ' ||CHR(39)|| 'HEADER' || CHR(39) || ' AND ENTRY_SID = 0';
                    EXECUTE IMMEDIATE  l_upd_row_statement;
                END LOOP;
                --close the cursor
                DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
                o_ret := 2;
            ELSE
                o_ret := 1;
            END IF;

        END IF;

    END;

    ----------------------------------------------------------------------------
    -- @name setIndiceValue
    -- @purpose update the calculated indice value
    ----------------------------------------------------------------------------
    PROCEDURE setIndiceValue(p_entry_sid            IN  NUMBER
                            ,p_index_sid            IN  NUMBER
                            ,p_dimension_sid        IN  NUMBER
                            ,p_dimension_value      IN  VARCHAR2
                            ,p_round_sid            IN  NUMBER
                            ,p_round_year           IN  NUMBER
                            ,p_country_id           IN  VARCHAR2
                            ,p_sector_id            IN  VARCHAR2
                            ,o_res                  OUT NUMBER)
    IS
        l_cursor_id     INTEGER;
        l_index_abrv    VARCHAR2(100 BYTE);
        l_tab_name      VARCHAR2(500 BYTE);
        l_statement     VARCHAR2(2000 BYTE);
        l_check         VARCHAR2(2000 BYTE);
        l_rowcount      NUMBER;
        l_out           NUMBER;
        l_dim_value     VARCHAR2(100 BYTE);

    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;
        
        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;

        IF p_dimension_value = 'undefined' THEN
            l_dim_value := NULL;
        ELSE
            l_dim_value := p_dimension_value;
        END IF;

        --Create the statement for checking if there is already a record
        l_check := 'SELECT COUNT(*) FROM ' || l_tab_name || ' WHERE ENTRY_SID = '|| p_entry_sid || ' AND COUNTRY_ID = ' ||CHR(39)|| p_country_id || CHR(39);
        EXECUTE IMMEDIATE l_check into l_out;
        IF l_out != 0 THEN
            IF p_sector_id IS NOT NULL THEN
                l_statement := 'UPDATE ' || l_tab_name || ' SET SDIM'|| p_dimension_sid || ' = nvl(round('|| l_dim_value || ',4),0) WHERE ENTRY_SID = ' || p_entry_sid || ' AND COUNTRY_ID = '|| CHR(39) || p_country_id || CHR(39) ||
                ' AND SECTOR = ' || chr(39) || p_sector_id || chr(39) ;
            ELSE 
                l_statement := 'UPDATE ' || l_tab_name || ' SET SDIM'|| p_dimension_sid || ' = nvl(round('|| l_dim_value || ',4),0) WHERE ENTRY_SID = ' || p_entry_sid || ' AND COUNTRY_ID = '|| CHR(39) || p_country_id || CHR(39);
            END IF;
            EXECUTE IMMEDIATE l_statement;
            o_res := SQL%ROWCOUNT;
        ELSE
            IF p_sector_id IS NOT NULL THEN
                --Entry not present, insert it
                l_statement := ' BEGIN INSERT INTO ' ||l_tab_name|| ' (COUNTRY_ID, ENTRY_SID, SECTOR, SDIM'|| p_dimension_sid||') VALUES ('||  CHR(39) || p_country_id || CHR(39) ||', :entrySid, '|| chr(39) || p_sector_id || chr(39)  ||', nvl(round(:dimValue, 4),0)); :res := SQL%ROWCOUNT; END;';
            ELSE
                l_statement := ' BEGIN INSERT INTO ' ||l_tab_name|| ' (COUNTRY_ID, ENTRY_SID, SDIM'|| p_dimension_sid||') VALUES ('||  CHR(39) || p_country_id || CHR(39) ||', :entrySid,  nvl(round(:dimValue, 4),0)); :res := SQL%ROWCOUNT; END;';
            END IF;
            BEGIN
                EXECUTE IMMEDIATE l_statement USING IN  p_entry_sid, l_dim_value,  OUT l_out;
                o_res := SQL%ROWCOUNT;
            EXCEPTION
                WHEN OTHERS THEN

                    raise_application_error(-20011,'An error was encountered - '|| l_statement ||SQLCODE||' -ERROR- '||SQLERRM);
            END;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN
        core_jobs.LOG_INFO_FAIL('setIndiceValue', 'An error was encountered for statement - ' || l_statement, SQLERRM, trunc(sysdate));
            raise_application_error(-20022,'An error was encountered when updating '||l_statement || ' dimension: '|| p_dimension_sid ||' with value: '|| l_dim_value||' -ERROR- '||SQLERRM);
    END;

    ----------------------------------------------------------------------------
    -- @name setIndiceRankValue
    -- @purpose update the calculated rank value
    ----------------------------------------------------------------------------
    PROCEDURE setIndiceRankValue(p_entry_sid            IN  NUMBER
                            ,p_index_sid            IN  NUMBER
                            ,p_dimension_sid        IN  NUMBER
                            ,p_dimension_value      IN  VARCHAR2
                            ,p_round_sid            IN  NUMBER
                            ,p_round_year           IN  NUMBER
                            ,p_country_id           IN  VARCHAR2
                            ,p_sector               IN  VARCHAR2
                            ,o_res                  OUT NUMBER)
    IS
        l_cursor_id     INTEGER;
        l_index_abrv    VARCHAR2(100 BYTE);
        l_tab_name      VARCHAR2(500 BYTE);
        l_statement     VARCHAR2(2000 BYTE);
        l_check         VARCHAR2(2000 BYTE);
        l_rowcount      NUMBER;
        l_out           NUMBER;

    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;

        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;

        --Create the statement for checking if there is already a record
        l_check := 'SELECT COUNT(*) FROM ' || l_tab_name || ' WHERE ENTRY_SID = '|| p_entry_sid || ' AND SECTOR = '|| CHR(39)|| p_sector|| CHR(39); 
        EXECUTE IMMEDIATE l_check into l_out;
        IF p_sector IS NOT NULL THEN
            IF l_out != 0 THEN
                l_statement := 'UPDATE ' || l_tab_name || ' SET SDIM'|| p_dimension_sid || ' = nvl('|| p_dimension_value || ',0) WHERE ENTRY_SID = ' || p_entry_sid || ' AND COUNTRY_ID = '|| CHR(39) || p_country_id || CHR(39) || ' AND SECTOR = '|| CHR(39) ||p_sector || CHR(39);
                EXECUTE IMMEDIATE l_statement;
                o_res := SQL%ROWCOUNT;
            ELSE
                --Entry not present, insert it
                l_statement := ' BEGIN INSERT INTO ' ||l_tab_name|| ' (COUNTRY_ID, ENTRY_SID, SDIM'|| p_dimension_sid||', SECTOR) VALUES ('||  CHR(39) || p_country_id || CHR(39) ||', :entrySid, nvl(:dimValue,0), '|| CHR(39)|| p_sector || CHR(39) ||'); :res := SQL%ROWCOUNT; END;';
                BEGIN
                    EXECUTE IMMEDIATE l_statement USING IN  p_entry_sid, p_dimension_value,  OUT l_out;
                    o_res := SQL%ROWCOUNT;
                EXCEPTION
                    WHEN OTHERS THEN
                        raise_application_error(-20011,'An error was encountered - '|| l_statement ||SQLCODE||' -ERROR- '||SQLERRM);
                END;
            END IF;
        END IF;

        -- l_statement := 'UPDATE ' || l_tab_name || ' SET SDIM'|| p_dimension_sid || ' = '|| p_dimension_value || ' WHERE ENTRY_SID = ' || p_entry_sid;
        -- EXECUTE IMMEDIATE l_statement;
        -- o_res := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20022,'An error was encountered when updating '||l_statement || ' dimension: '|| p_dimension_sid ||' with value: '|| p_dimension_value||' -ERROR- '||SQLERRM);
    END;

    ----------------------------------------------------------------------------
    -- @name getIndiceValue
    -- @return value of a calculated indice 
    ----------------------------------------------------------------------------
    PROCEDURE getIndiceValue(p_entry_sid            IN  NUMBER
                            ,p_index_sid            IN  NUMBER
                            ,p_dimension_sid        IN  NUMBER
                            ,p_round_sid            IN  NUMBER
                            ,p_round_year           IN  NUMBER
                            ,o_res                  OUT NUMBER)
    IS
        l_cursor_id     INTEGER;
        l_index_abrv    VARCHAR2(100 BYTE);
        l_tab_name      VARCHAR2(500 BYTE);
        l_statement     VARCHAR2(2000 BYTE);
        l_rowcount      NUMBER;
        l_dimValue      NUMBER;
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;
        
        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;
        l_cursor_id := DBMS_SQL.OPEN_CURSOR;

        --Create the select statement
        l_statement := 'SELECT SDIM'|| p_dimension_sid || ' INTO :dimValue FROM '|| l_tab_name || ' WHERE ENTRY_SID = :entrySid';
        --parse the statement
        DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);
        --bind the variables
        DBMS_SQL.BIND_VARIABLE(l_cursor_id,':entrySid', p_entry_sid);
        --execute statement
        l_rowcount := DBMS_SQL.EXECUTE(l_cursor_id);
        --bind the returned value
        DBMS_SQL.VARIABLE_VALUE(l_cursor_id, ':dimValue', l_dimValue);

        DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
        IF l_rowcount = 1 THEN
            o_res := l_dimValue;
        ELSE
            --If more than 1 row was updated, there is an issue
            o_res := -1;
        END IF;
    END;

    ----------------------------------------------------------------------------
    -- @name setIndiceAttrValue
    -- @purpose update attribute of an indice
    ----------------------------------------------------------------------------
    PROCEDURE setIndiceAttrValue(p_entry_sid            IN  NUMBER
                                ,p_index_sid            IN  NUMBER
                                ,p_attr_name            IN  VARCHAR2
                                ,p_attr_value           IN  NUMBER
                                ,p_round_sid            IN  NUMBER
                                ,p_round_year           IN  NUMBER
                                ,p_country_id           IN  VARCHAR2
                                ,o_res                  OUT NUMBER)
    IS
        l_cursor_id     INTEGER;
        l_index_abrv    VARCHAR2(100 BYTE);
        l_tab_name      VARCHAR2(500 BYTE);
        l_statement     VARCHAR2(2000 BYTE);
        l_check         VARCHAR2(2000 BYTE);
        l_value         NUMBER;
        l_rowcount      NUMBER;
        l_exists        NUMBER;
        l_out           NUMBER;
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;

        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;
        l_cursor_id := DBMS_SQL.OPEN_CURSOR;


        BEGIN
            l_statement := 'UPDATE ' || l_tab_name ||
                ' SET ' ||p_attr_name ||' = nvl(round(' || p_attr_value ||
                ',4), 0) WHERE ENTRY_SID = ' || p_entry_sid || ' AND COUNTRY_ID = ' || CHR(39) || p_country_id || CHR(39);
            EXECUTE IMMEDIATE l_statement ;

        EXCEPTION
            WHEN OTHERS THEN
                raise_application_error(-20022,'An error was encountered - '|| l_check ||SQLCODE||' -ERROR- '||SQLERRM);
        END;
        
        COMMIT;
    EXCEPTION
                    WHEN OTHERS THEN
                        raise_application_error(-20011,'An error was encountered - '|| l_statement ||SQLCODE||' -ERROR- '||SQLERRM);    
    END;

    ----------------------------------------------------------------------------
    -- @name setIndiceAttrValue
    -- @purpose update attribute of an indice
    ----------------------------------------------------------------------------
    PROCEDURE setIndiceMultiAttrValue(p_entry_sid            IN  NUMBER
                                     ,p_index_sid            IN  NUMBER
                                     ,p_attr_name            IN  VARCHAR2
                                     ,p_attr_value           IN  VARCHAR2
                                     ,p_round_sid            IN  NUMBER
                                     ,p_round_year           IN  NUMBER
                                     ,p_country_id           IN  VARCHAR2
                                     ,o_res                  OUT NUMBER)
    IS
        l_index_abrv    VARCHAR2(100 BYTE);
        l_tab_name      VARCHAR2(500 BYTE);
        l_statement     VARCHAR2(2000 BYTE);
        l_check         VARCHAR2(2000 BYTE);
        l_count         NUMBER;
        l_cursor_data   SYS_REFCURSOR;
        l_entry_no      VARCHAR2(200 BYTE);
        l_entry_ve      VARCHAR2(200 BYTE);
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;
        
        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;

        l_statement := 'SELECT COUNT(*) FROM ' || l_tab_name || ' WHERE ENTRY_SID = ' || p_entry_sid || ' AND ' || p_attr_name || ' = ' || chr(39) || p_attr_value || chr(39) ;
        EXECUTE IMMEDIATE l_statement INTO l_count;

        IF l_count = 1 THEN
            o_res := 1;
        ELSE
            l_statement := ' SELECT ENTRY_NO, ENTRY_VERSION FROM ENTRIES WHERE ENTRY_SID = ' || p_entry_sid;
            EXECUTE IMMEDIATE l_statement INTO l_entry_no, l_entry_ve;

            l_statement := 'INSERT INTO ' || l_tab_name || '(COUNTRY_ID, ENTRY_SID, SECTOR) VALUES (' ||
                            CHR(39) || p_country_id || CHR(39) || ', ' || p_entry_sid ||  ', ' || chr(39) || p_attr_value || chr(39) ||')';
            EXECUTE IMMEDIATE l_statement;
            o_res := SQL%ROWCOUNT;

        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20011,'Error on updating/inserting sector - '|| l_statement ||SQLCODE||' -ERROR- '||SQLERRM);
    END;

    ----------------------------------------------------------------------------
    -- @name getIndiceAddAttributes
    -- @returnS attributes for indices tables
    ----------------------------------------------------------------------------
    PROCEDURE getIndiceAddAttributes(p_index_sid     IN  NUMBER
                                    ,o_cur           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
        SELECT ACCESSOR, ATTR_ID
          FROM CFG_INDICES_ATTRIBUTES
         WHERE INDEX_SID = p_index_sid
         ORDER BY ACCESSOR DESC; 
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryAtrribute
    -- @return value of the entry's attribute
    ----------------------------------------------------------------------------
    PROCEDURE getEntryAtrribute (p_entry_sid                IN  NUMBER
                                ,p_attr_name                IN  VARCHAR2
                                ,o_res                      OUT VARCHAR2)
    IS
        l_statement     VARCHAR2(2000 BYTE);
        l_rowcount      NUMBER;
    BEGIN
        --Create statement
        l_statement := 'SELECT '|| p_attr_name || ' FROM ENTRIES WHERE ENTRY_SID = ' || p_entry_sid;
        EXECUTE IMMEDIATE l_statement INTO o_res;
    END;

    ----------------------------------------------------------------------------
    -- @name setIndiceCoverage
    -- @purpose update the calculated coverage value
    ----------------------------------------------------------------------------
    PROCEDURE setIndiceCoverage(p_entry_sid            IN  NUMBER
                               ,p_index_sid            IN  NUMBER
                               ,p_dimension_sid        IN  NUMBER
                               ,p_dimension_value      IN  VARCHAR2
                               ,p_sector_id            IN  VARCHAR2
                               ,p_round_sid            IN  NUMBER
                               ,p_round_year           IN  NUMBER 
                               ,o_res                  OUT NUMBER)
    IS
        l_cursor_id     INTEGER;
        l_index_abrv    VARCHAR2(100 BYTE);
        l_tab_name      VARCHAR2(500 BYTE);
        l_statement     VARCHAR2(2000 BYTE);
        l_check         VARCHAR2(2000 BYTE);
        l_rowcount      NUMBER;
        l_out           NUMBER;
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;

        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;
        --Create the update statement
        l_statement := 'UPDATE ' || l_tab_name || ' SET SDIM'|| p_dimension_sid || ' = '|| p_dimension_value ||' WHERE ENTRY_SID = '|| p_entry_sid || ' AND SECTOR = '|| chr(39)  || p_sector_id || chr(39) ;
        EXECUTE IMMEDIATE l_statement;

        o_res := SQL%ROWCOUNT;
        IF o_res = 0 THEN
            l_statement := 'INSERT INTO '|| l_tab_name || '(ENTRY_SID, SECTOR, SDIM'||p_dimension_sid ||') VALUES (' ||p_entry_sid|| ', '|| chr(39) || p_sector_id || chr(39)  || ', '|| p_dimension_value || ')';
            EXECUTE IMMEDIATE l_statement;
            o_res := SQL%ROWCOUNT;
        END IF;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20011,'Error on updating COVERAGE - '|| l_statement ||SQLCODE||' -ERROR- '||SQLERRM);
    END;

    ----------------------------------------------------------------------------
    -- @name getIndiceData
    -- @return calculated indice values
    ----------------------------------------------------------------------------
    PROCEDURE getIndiceData(p_index_sid            IN  NUMBER
                           ,p_round_sid            IN  NUMBER
                           ,p_round_year           IN  NUMBER
                           ,p_country_id           IN  VARCHAR2
                           ,o_cur                  OUT SYS_REFCURSOR)
    IS
        l_cursor_id     INTEGER;
        l_index_abrv    VARCHAR2(100 BYTE);
        l_tab_name      VARCHAR2(500 BYTE);
        l_statement     VARCHAR2(2000 BYTE);
        l_rowcount      NUMBER;
        l_dimValue      NUMBER;
        l_cursor        SYS_REFCURSOR;
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;
        
        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;

        OPEN o_cur FOR 'SELECT * FROM ' || l_tab_name || ' WHERE COUNTRY_ID = ' || CHR(39) || p_country_id || CHR(39) ;
    END;

    ----------------------------------------------------------------------------
    -- @name sendEmail
    -- @purpose send email to C4 whenever score is updated by MS/IFI
    ----------------------------------------------------------------------------
    PROCEDURE sendEmail(p_user                  IN  VARCHAR2
                       ,p_index_sid             IN  NUMBER
                       ,p_criterion_sid         IN  NUMBER
                       ,p_entry_sid             IN  NUMBER
                       ,o_res                  OUT  NUMBER)
    IS
        mailhost VARCHAR2(30) := 'smtpmail.cec.eu.int';
        l_sender VARCHAR2(200) := 'automated-notifications@nomail.ec.europa.eu';
        l_recipient VARCHAR2(200) := 'ECFIN-FiscalFramework@ec.europa.eu';
        -- l_recipient VARCHAR2(200) := 'constantin-mihai.stefan@ext.ec.europa.eu';
        l_base_subj VARCHAR2(200) := 'Follow-up: ';
        l_subject   VARCHAR2(200);
        l_message   VARCHAR2(2000);
        l_index_id   VARCHAR2(20);
        l_criteria_id VARCHAR2(20);
        l_country_id VARCHAR2(20);
        l_app VARCHAR2(20);

        mail_conn utl_smtp.connection;
        crlf VARCHAR2(2) := CHR(13)||CHR(10);
        msg VARCHAR2(4000);
    BEGIN
        SELECT INDEX_ID INTO l_index_id FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;
        SELECT APP_ID INTO l_app FROM CFG_QUESTIONNAIRES WHERE QUESTIONNAIRE_SID IN (SELECT QUESTIONNAIRE_SID FROM CFG_INDEXES  WHERE  INDEX_SID = p_index_sid);
        SELECT CRITERION_ID || SUB_CRITERION_ID INTO l_criteria_id FROM CFG_INDEX_CRITERIA WHERE CRITERION_SID = p_criterion_sid;
        SELECT COUNTRY_ID INTO l_country_id FROM ENTRIES WHERE ENTRY_SID = p_entry_sid;

        l_subject := l_base_subj || l_country_id || ' - ' || l_app || ' update - Scoring cross-check for the ' || l_index_id;
        l_message := 'Dear '|| l_app || ' user,

This email is an automated notification to inform you that the user ' || p_user || ' has made a score update for criteria ' || l_criteria_id || '

You can check the update on the platform ( https://intragate.ec.europa.eu/fastop/' || LOWER(l_app) ||')

Kind regards,
  ECFIN.R.3 - FGD team'; 
        mail_conn := utl_smtp.open_connection(mailhost,25);
        msg := 'Date: '||to_char(sysdate,'dd Mon yy hh24:mi:ss' )||crlf||
               'From: '||l_sender||'>'||crlf||'Subject: '||l_subject||crlf||
               'To: '||l_recipient||crlf||crlf||l_message;
        utl_smtp.helo(mail_conn,mailhost);
        utl_smtp.mail(mail_conn,l_sender);
        utl_smtp.rcpt(mail_conn,l_recipient);
        utl_smtp.data(mail_conn,msg);
        utl_smtp.quit(mail_conn);
        null;
        o_res := 0;
    EXCEPTION
        WHEN OTHERS THEN
            o_res := 1;
    END;

    ----------------------------------------------------------------------------
    -- @name getEmailParams
    -- @return data needed for sending Email
    ----------------------------------------------------------------------------
    PROCEDURE getEmailParams (p_entry_criteria_sid   IN     NUMBER
                              ,o_cur                  OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
        SELECT EC.ENTRY_SID,
               EC.CRITERION_SID,
               CI.INDEX_SID
          FROM ENTRY_CRITERIA EC,
               CFG_INDEX_CRITERIA CI
         WHERE EC.CRITERION_SID = CI.CRITERION_SID
           AND EC.ENTRY_CRITERIA_SID =   p_entry_criteria_sid; 
    END;

    ----------------------------------------------------------------------------
    -- @name getChoiceLov
    -- @return lov value
    ----------------------------------------------------------------------------
    PROCEDURE getChoiceLov (p_choice_score_sid   IN     NUMBER
                           ,o_ret                  OUT    NUMBER)
    IS
    BEGIN
        SELECT NVL(LOV_SID, 0) INTO o_ret FROM CFG_INDEX_CHOICES_SCORES WHERE CHOICE_SCORE_SID = p_choice_score_sid; 
    END;

    ----------------------------------------------------------------------------
    -- @name getHorizontalIdxCalcStages
    -- @return current index calculation stage  for selected index
    ----------------------------------------------------------------------------
    PROCEDURE getHorizontalIdxCalcStages (p_app_id      IN     VARCHAR2 
                                        ,p_index_sid   IN     NUMBER
                                        ,p_round_sid   IN     NUMBER
                                        ,p_round_year      IN  NUMBER
                                        ,o_cur            OUT SYS_REFCURSOR)
    IS

        CURSOR c_idx_attrs IS
            SELECT * FROM CFG_HORIZONTAL_ELEMENTS
                WHERE INDEX_SID = p_index_sid; 
        CURSOR c_entries IS
            SELECT E.* FROM ENTRIES E, ENTRY_EDIT_STEPS S WHERE E.ENTRY_SID = S.ENTRY_SID and E.APP_ID = p_app_id AND S.ROUND_SID = p_round_sid
            AND cfg_questionnaire.getAvailability(E.IMPL_DATE
                                ,E.REFORM_IMPL_DATE
                                ,E.REFORM_REPLACED_DATE
                                ,E.ABOLITION_DATE) IN (t_availability.C, t_availability.F)
                ORDER BY E.COUNTRY_ID, E.ENTRY_NO, E.ENTRY_VERSION;
        l_tab_name  VARCHAR2(500 BYTE);
        l_idx       VARCHAR2(500 BYTE);
        l_check     NUMBER;
        l_statement VARCHAR2(2000 BYTE);
        l_attr_val  VARCHAR2(2000 BYTE);
        l_cursor_id INTEGER;
        l_questionnaire_sid NUMBER;
        l_country_id VARCHAR2(100 BYTE);

        T_QUESTION_TYPES CORE_TYPES.T_QUESTION_TYPES;
        T_HORIZ_ELEMENTS CORE_TYPES.T_HORIZ_ELEMENTS;
    BEGIN
        --GET THE THE INDEX ABBRV
        SELECT INDEX_ID INTO l_idx FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;
        --CREATE TABLE NAME
        l_tab_name := 'HORIZ_'||l_idx || '_'||p_round_year;

        l_statement := 'SELECT COUNT(*) FROM '||l_tab_name;

        --GET QUESTIONNAIRE_SID
        SELECT QUESTIONNAIRE_SID INTO l_questionnaire_sid FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;


        BEGIN
            EXECUTE IMMEDIATE l_statement INTO l_check;
        EXCEPTION
            WHEN OTHERS THEN
            --table does not exist
                l_check := 0;
        END;

        --table exists
        IF l_check != 0 THEN
            OPEN o_cur FOR 'SELECT * FROM '||l_tab_name;
        ELSE
        --create the table
            --table statement creation
            l_statement := 'CREATE TABLE '||l_tab_name||' (ENTRY_SID NUMBER)';
            --open cursor
            l_cursor_id := DBMS_SQL.OPEN_CURSOR;
            --PARSE THE CURSOR SO THAT TABLE WILL BE CREATED
            DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);
            --insert reference entry_sid = 0 which will have header display names
            l_statement := 'INSERT INTO '|| l_tab_name || '(ENTRY_SID) VALUES (0)';
            EXECUTE IMMEDIATE l_statement;

            --loop the configuration in order to add the columns to the table
            FOR rec_attr IN c_idx_attrs LOOP
                --Compose alter table statement
                l_statement := 'ALTER TABLE ' || l_tab_name || ' ADD (COL' || rec_attr.HORIZ_ELEM_SID || ' VARCHAR2(4000 BYTE) )';
                --PARSE THE CURSOR SO THAT COLUMN IS ADDED
                DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);
            END LOOP;

            --loop the cfg in order to update the header display names
            FOR rec_header IN c_idx_attrs LOOP
                l_statement := 'UPDATE '|| l_tab_name || ' SET COL'|| rec_header.HORIZ_ELEM_SID || ' = ' || CHR(39) || rec_header.DISPLAY_NAME || CHR(39);
                EXECUTE IMMEDIATE l_statement;
            END LOOP;

            --loop the entries in order the start adding data
            FOR rec_entry IN c_entries LOOP
                l_statement := 'INSERT INTO '||l_tab_name|| ' (ENTRY_SID) VALUES ('||rec_entry.ENTRY_SID||')';
                EXECUTE IMMEDIATE l_statement;
                commit;
                --GET COUNTRY_ID
                SELECT COUNTRY_ID INTO l_country_id FROM ENTRIES WHERE ENTRY_SID = rec_entry.ENTRY_SID;
                --loop the cfg and start adding data for that entry_sid
                FOR rec_attr IN c_idx_attrs LOOP
                    --get the values according to the element type
                    IF rec_attr.ELEM_TYPE_SID = T_HORIZ_ELEMENTS.ATTRIBUTE THEN
                        l_statement := 'SELECT '||rec_attr.ACCESSOR|| ' FROM '|| rec_attr.TAB_NAME || ' WHERE ENTRY_SID = ' || rec_entry.ENTRY_SID;
                    ELSIF rec_attr.ELEM_TYPE_SID = T_HORIZ_ELEMENTS.QUESTION THEN
                        l_statement := 'SELECT LISTAGG(CHOICE ,'||chr(39)|| ' ,'||chr(39)||') WITHIN GROUP (ORDER BY CHOICE) FROM '||
                        '( SELECT V.DESCR AS CHOICE'||
                        ' FROM ENTRY_CHOICES E, RESPONSE_CHOICES_VW V WHERE E.ENTRY_SID = '||rec_entry.ENTRY_SID ||
                        ' AND E.'||rec_attr.ACCESSOR||' = '||rec_attr.ACCESSOR_VALUE ||
                        ' AND E.RESPONSE = V.RESPONSE_SID)';
                    ELSIF rec_attr.ELEM_TYPE_SID = T_HORIZ_ELEMENTS.SCORE THEN
                        l_statement := 'WITH t AS (
                                        SELECT RC.ENTRY_SID
                                            ,E.ENTRY_NO
                                            ,E.ENTRY_VERSION
                                            ,RC.ROUND_SID
                                            ,RC.'||rec_attr.ACCESSOR ||'
                                            ,SV.ORDER_BY
                                            ,MAX(SV.ORDER_BY) OVER (PARTITION BY RC.ENTRY_SID, RC.CRITERION_SID) MAX_ORDER_BY
                                        FROM '|| rec_attr.TAB_NAME ||' RC
                                            ,CFG_INDEX_STAGES SV
                                            ,ENTRIES E
                                        WHERE SV.SCORE_VERSION_SID = RC.SCORE_VERSION_SID
                                        AND RC.ENTRY_SID = E.ENTRY_SID
                                        AND E.ENTRY_SID = ' || rec_entry.ENTRY_SID || '
                                        AND RC.CRITERION_SID = ' || rec_attr.ACCESSOR_VALUE || '
                                        AND (RC.ROUND_SID IS NULL OR RC.ROUND_SID = ' || p_round_sid || ')
                                        AND cfg_questionnaire.getAvailability(E.IMPL_DATE
                                                                                    ,E.REFORM_IMPL_DATE
                                                                                    ,E.REFORM_REPLACED_DATE
                                                                                    ,E.ABOLITION_DATE) = '|| CHR(39) || t_availability.C || CHR(39) || '
                                    )
                                    SELECT DISTINCT SCORE FROM t WHERE t.ORDER_BY = t.MAX_ORDER_BY AND ROWNUM = 1';
                    ELSIF rec_attr.ELEM_TYPE_SID = T_HORIZ_ELEMENTS.STAGE THEN 
                        l_statement := 'WITH t AS (
                              SELECT DISTINCT 
                                     MAX(CS.ORDER_BY) OVER (PARTITION BY SV.INDEX_SID) AS MAX_ORDER_BY
                                FROM INDEX_CALC_STAGES SV
                                    ,'|| rec_attr.TAB_NAME ||' CS
                                WHERE SV.STAGE_SID = CS.'|| rec_attr.ACCESSOR ||'
                                  AND SV.INDEX_SID = '|| p_index_sid || '
                                  AND SV.ROUND_SID = '|| p_round_sid ||'
                                  and SV.STAGE_SID != 0)

                                    SELECT svi.descr FROM t , CFG_INDEX_STAGE_versions svi
                                    WHERE svi.score_version_sid = t.MAX_ORDER_BY - 1
                                     AND SVI.INDEX_SID = '|| p_index_sid;         
                    ELSIF rec_attr.ELEM_TYPE_SID IN (T_HORIZ_ELEMENTS.CUSTOM, T_HORIZ_ELEMENTS.ADD_ATTRIBUTE)  THEN
                        l_statement := ' SELECT '|| rec_attr.ACCESSOR || ' FROM '|| rec_attr.TAB_NAME ||' WHERE ENTRY_SID = ' || rec_entry.ENTRY_SID;
                    ELSIF rec_attr.ELEM_TYPE_SID = T_HORIZ_ELEMENTS.SUBMIT THEN
                        l_statement := ' SELECT MAX('||rec_attr.ACCESSOR || ') FROM '|| rec_attr.TAB_NAME || ' WHERE QUESTIONNAIRE_SID = '|| l_questionnaire_sid ||' AND ROUND_SID = ' ||
                        p_round_sid || ' AND COUNTRY_ID = '||CHR(39)|| l_country_id || CHR(39);
                    END IF;
                    BEGIN
                        EXECUTE IMMEDIATE l_statement INTO l_attr_val;
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_attr_val := 'N/A';
                    END;
                    --update the table with the new value
                    l_statement := 'UPDATE '||l_tab_name||' SET COL'||rec_attr.HORIZ_ELEM_SID|| ' = '|| CHR(39) ||l_attr_val || chr(39)|| ' WHERE ENTRY_SID = '|| rec_entry.ENTRY_SID;
                    EXECUTE IMMEDIATE l_statement;
                    commit;
                END LOOP;
            END LOOP;
            --All data was filled, so we can return the data
             OPEN o_cur FOR 'SELECT * FROM '||l_tab_name;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20011,'An error was encountered - entry_sid'||  l_statement || '-' ||SQLCODE||' -ERROR- '||SQLERRM);
    END;   

    ----------------------------------------------------------------------------
    -- @name refreshHorizView
    -- @purpose drop horizontal views to trigger a refresh
    ----------------------------------------------------------------------------
    PROCEDURE refreshHorizView (p_app_id      IN     VARCHAR2 
                        ,p_index_sid   IN     NUMBER
                        ,p_round_sid   IN     NUMBER
                        ,p_round_year       IN NUMBER
                        ,o_ret            OUT NUMBER)
    IS
        l_tab_name  VARCHAR2(500 BYTE);
        l_idx       VARCHAR2(500 BYTE);
        l_check     NUMBER;
        l_statement VARCHAR2(2000 BYTE);
    BEGIN
        --GET THE THE INDEX ABBRV
        SELECT INDEX_ID INTO l_idx FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;
        --CREATE TABLE NAME
        l_tab_name := 'HORIZ_'||l_idx || '_'||p_round_year;

        l_statement := 'DROP TABLE '||l_tab_name;

        BEGIN
            EXECUTE IMMEDIATE l_statement;
            o_ret := 0;
        EXCEPTION
          WHEN OTHERS THEN
            o_ret := -1;
        END;

    END;

    PROCEDURE refreshIndView (p_index_sid   IN     NUMBER
                        ,p_round_sid   IN     NUMBER
                        ,p_round_year      IN  NUMBER
                        ,p_country_id      IN     VARCHAR2 
                        ,o_ret            OUT NUMBER)
    IS
        l_index_abrv VARCHAR2(300 BYTE);
        l_tab_name VARCHAR2(500 BYTE);
        l_statement VARCHAR2(2000 BYTE);
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;

        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;
        l_statement := 'DELETE FROM '|| l_tab_name || ' WHERE COUNTRY_ID = '|| CHR(39) || p_country_id || CHR(39);

        BEGIN
            EXECUTE IMMEDIATE l_statement;
            o_ret := SQL%ROWCOUNT;
        EXCEPTION
            WHEN OTHERS THEN
                o_ret := -1;
        END;
    END;

    PROCEDURE getEntryRanking(p_entry_sid           IN  NUMBER,
                              p_sector_id           IN  VARCHAR2,
                              p_round_sid           IN  NUMBER,
                              p_round_year          IN  NUMBER,
                              o_ret                OUT  NUMBER)
    IS
        l_index_abrv VARCHAR2(300 BYTE);
        l_tab_name VARCHAR2(500 BYTE);
        l_statement VARCHAR2(2000 BYTE);
        l_dim_no NUMBER;
        l_sdim VARCHAR2(300 BYTE);
        l_res NUMBER;
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = 1;
        SELECT IND_CRITERION_SID INTO l_dim_no FROM CFG_INDICE_CRITERIA WHERE ACCESSOR = 'RANKING';
        l_sdim := 'SDIM'||l_dim_no;

        l_tab_name := 'INDICES_'||l_index_abrv||'_'||p_round_year;
        l_statement := 'SELECT  '|| l_sdim || ' FROM '|| l_tab_name || ' WHERE ENTRY_SID = ' || p_entry_sid || ' AND SECTOR = ' ||chr(39) || p_sector_id || chr(39) ;

        EXECUTE IMMEDIATE l_statement INTO l_res;
        o_ret := NVL(l_res, 1);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                o_ret := 1;
    END;

    PROCEDURE checkFulfillChoice(p_entry_sid           IN  NUMBER,
                                 p_choice_score_sid    IN  NUMBER,
                                 o_res                OUT  NUMBER)
    IS
    BEGIN
        SELECT COUNT(*)
          INTO o_res
          FROM CFG_INDEX_CHOICES_SCORES ICS
              ,ENTRY_CHOICES EC
         WHERE EC.QUESTION_VERSION_SID = ICS.QUESTION_VERSION_SID
           AND EC.RESPONSE = TO_CHAR(ICS.LOV_SID)
           AND EC.ENTRY_SID = p_entry_sid
           AND ICS.CHOICE_SCORE_SID = p_choice_score_sid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_res := 0;        
    END;

    PROCEDURE getIndicesEntries(p_questionnaire_sid    IN NUMBER
                               ,p_country_id           IN VARCHAR2
                               ,p_round_sid            IN NUMBER
                               ,p_year                 IN NUMBER
                               ,p_index_sid            IN NUMBER 
                               ,o_cur                 OUT SYS_REFCURSOR)
    IS
        l_index_abrv VARCHAR2(100 BYTE);
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;

    IF p_index_sid IN (1,2) THEN
        OPEN o_cur FOR 'SELECT
                            T.ENTRY_SID,
                            T.ENTRY_VERSION,
                            EES.EDIT_STEP_SID,
                            CES.EDIT_STEP_ID,
                            PES.descr AS prev_step_id,
                            EES.LAST_MODIF_DATE,
                            E.ENTRY_NO AS ENTRY_NUMBER,
                            T.SECTOR
                        FROM ENTRIES  E
                            ,ENTRY_EDIT_STEPS EES
                            ,CFG_EDIT_STEPS CES
                            ,CFG_EDIT_STEPS PES
                            ,CFG_QUESTIONNAIRES Q
                            ,INDICES_'|| l_index_abrv ||'_'|| p_year ||'
                        WHERE E.ENTRY_SID = EES.ENTRY_SID
                            AND T.ENTRY_SID = E.ENTRY_SID
                            AND EES.EDIT_STEP_SID = CES.EDIT_STEP_SID
                            AND EES.PREV_STEP_SID = PES.EDIT_STEP_SID(+)
                            AND Q.APP_ID = E.APP_ID
                            AND Q.QUESTIONNAIRE_SID = '|| p_questionnaire_sid || '
                            AND E.COUNTRY_ID = ' || CHR(39) || p_country_id || CHR(39) ||'
                            AND EES.round_sid = ' || p_round_sid|| '
                        ORDER BY
                            ENTRY_NUMBER';
    ELSE
            OPEN o_cur FOR 'SELECT
                            T.ENTRY_SID,
                            T.ENTRY_VERSION,
                            EES.EDIT_STEP_SID,
                            CES.EDIT_STEP_ID,
                            PES.descr AS prev_step_id,
                            EES.LAST_MODIF_DATE,
                            E.ENTRY_NO AS ENTRY_NUMBER
                        FROM ENTRIES  E
                            ,ENTRY_EDIT_STEPS EES
                            ,CFG_EDIT_STEPS CES
                            ,CFG_EDIT_STEPS PES
                            ,CFG_QUESTIONNAIRES Q
                            ,INDICES_'|| l_index_abrv ||'_'|| p_year ||'
                        WHERE E.ENTRY_SID = EES.ENTRY_SID
                            AND T.ENTRY_SID = E.ENTRY_SID
                            AND EES.EDIT_STEP_SID = CES.EDIT_STEP_SID
                            AND EES.PREV_STEP_SID = PES.EDIT_STEP_SID(+)
                            AND Q.APP_ID = E.APP_ID
                            AND Q.QUESTIONNAIRE_SID = '|| p_questionnaire_sid || '
                            AND E.COUNTRY_ID = ' || CHR(39) || p_country_id || CHR(39) ||'
                            AND EES.round_sid = ' || p_round_sid|| '
                        ORDER BY
                            ENTRY_NUMBER';
    END IF; 
    END;


    ----------------------------------------------------------------------------
    -- @name getIndiceEntryData
    -- @return data and headers for indices
    ----------------------------------------------------------------------------
    PROCEDURE getIndiceEntryData(p_index_sid            IN  NUMBER
                                ,p_year                 IN  NUMBER
                                ,p_country_id           IN  VARCHAR2
                                ,o_cur                  OUT SYS_REFCURSOR)
    IS
        l_index_abrv VARCHAR2(100 BYTE);
    BEGIN
        SELECT INDEX_ID INTO l_index_abrv FROM CFG_INDEXES WHERE INDEX_SID = p_index_sid;

        OPEN o_cur FOR 'SELECT * FROM INDICES_'|| l_index_abrv || '_'|| p_year || ' WHERE COUNTRY_ID = '|| CHR(39) || 'HEADER'|| CHR(39) || ' UNION ALL '||
        'SELECT * FROM INDICES_'|| l_index_abrv || '_'|| p_year || ' WHERE COUNTRY_ID = '|| CHR(39) || p_country_id|| CHR(39);

    END;
END CFG_SCORES;