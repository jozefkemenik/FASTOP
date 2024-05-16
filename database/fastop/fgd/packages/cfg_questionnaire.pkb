create or replace PACKAGE BODY CFG_QUESTIONNAIRE
AS
    /***
        NAME: CFG_QUESTIONNAIRE
        USAGE: Functions used in the questionnaire
    ***/
    t_availability CORE_TYPES.T_AVAILABILITY;

    ----------------------------------------------------------------------------
    -- @name assignYears
    -- @return string with assigned year values
    ---------------------------------------------------------------------------
    FUNCTION assignYears(p_app_id IN VARCHAR2, p_text IN VARCHAR2, p_round_year IN NUMBER)
        RETURN VARCHAR2
    IS
        l_year1 NUMBER;
        l_year2 NUMBER;
        l_year3 NUMBER;
    BEGIN
        l_year1 := p_round_year - 1;
        l_year2 := p_round_year - 2;
        l_year3 := p_round_year - 3;

        RETURN REPLACE(REPLACE(REPLACE(REPLACE(p_text, '{YEAR}', p_round_year), '{YEAR1}', l_year1)
                   , '{YEAR2}', l_year2)
                   , '{YEAR3}', l_year3);
    END;

    ----------------------------------------------------------------------------
    -- @name getStartDate
    -- @purpose return start date of the year passed as param
    ----------------------------------------------------------------------------
    FUNCTION getStartDate(pi_year   IN VARCHAR2)
        RETURN DATE
    IS
        l_ret DATE;
    BEGIN
        l_ret := ADD_MONTHS(TRUNC(TO_DATE(pi_year - 1, 'YYYY'), 'y'), 0);
        RETURN l_ret;
    END;

    ----------------------------------------------------------------------------
    -- @name getEndDate
    -- @purpose return end date of the year passed as param
    ----------------------------------------------------------------------------
    FUNCTION getEndDate(pi_year   IN VARCHAR2)
        RETURN DATE
    IS
        l_ret DATE;
    BEGIN
        l_ret := ADD_MONTHS(TRUNC(TO_DATE(pi_year - 1, 'YYYY'), 'y'), 12) - 1;
        RETURN l_ret;
    END;

    ----------------------------------------------------------------------------
    -- @name : getAvailability
    -- @return availabity of an entry
    ----------------------------------------------------------------------------
    FUNCTION getAvailability(p_impl_date            DATE
                            ,p_reform_impl_date     DATE
                            ,p_reform_replaced_date DATE
                            ,p_abolition_date       DATE)
        RETURN VARCHAR2
    IS
        l_ret VARCHAR2(20);
    BEGIN
        IF  NVL(p_reform_impl_date, p_impl_date) < SYSDATE
        AND NVL(p_abolition_date, NVL(p_reform_replaced_date, SYSDATE)) >= SYSDATE THEN
            l_ret := t_availability.C;
        ELSIF NVL(p_reform_impl_date, p_impl_date) > SYSDATE THEN
            l_ret := t_availability.F;
        ELSIF p_abolition_date IS NOT NULL AND p_abolition_date < SYSDATE THEN
            l_ret := t_availability.A;
        ELSE
            l_ret := t_availability.NA;
        END IF;

        RETURN l_ret;

    END;

    ----------------------------------------------------------------------------
    -- @name : getAvailability
    -- @return availabity of an entry
    ----------------------------------------------------------------------------
    FUNCTION getAvailability(p_impl_date            DATE
                            ,p_reform_impl_date     DATE
                            ,p_reform_replaced_date DATE
                            ,p_abolition_date       DATE
                            ,p_period_start         DATE
                            ,p_period_end           DATE)
        RETURN VARCHAR2
    IS
        l_ret VARCHAR2(20);
    BEGIN
        IF  NVL(p_reform_impl_date, p_impl_date) < p_period_end
            AND ( p_reform_replaced_date IS NULL AND p_reform_impl_date < p_period_start
                OR
                p_reform_replaced_date NOT BETWEEN p_period_start AND p_period_end AND p_reform_impl_date BETWEEN p_period_start AND p_period_end
                OR
                p_reform_replaced_date IS NULL AND p_reform_replaced_date IS NULL ) 
            AND p_abolition_date IS NULL THEN 

            l_ret := t_availability.C;
        ELSIF NVL(p_reform_impl_date, p_impl_date) > p_period_end THEN
            l_ret := t_availability.F;
        ELSIF p_abolition_date IS NOT NULL AND p_abolition_date BETWEEN p_period_start AND p_period_end THEN
            l_ret := t_availability.A;
        ELSE
            l_ret := t_availability.NA;
        END IF;

        RETURN l_ret;

    END;

    ----------------------------------------------------------------------------
    -- @name : getPreviousStep
    -- @return previous edit step of an entry
    ----------------------------------------------------------------------------
    FUNCTION getPreviousStep(p_entry_sid            NUMBER
                            ,p_round_sid            NUMBER)
        RETURN VARCHAR2
    IS
        l_ret VARCHAR2(2000 BYTE);
    BEGIN
        SELECT cfg_questionnaire.getAvailability(E.IMPL_DATE
                                ,E.REFORM_IMPL_DATE
                                ,E.REFORM_REPLACED_DATE
                                ,E.ABOLITION_DATE) || ' (' || CES.DESCR ||')' INTO l_ret
                            FROM ENTRIES E,
                            ENTRY_EDIT_STEPS EES,
                            CFG_EDIT_STEPS CES
                        WHERE E.ENTRY_SID = EES.ENTRY_SID
                          AND EES.PREV_STEP_SID = CES.EDIT_STEP_SID
                          AND E.ENTRY_SID = p_entry_sid
                          AND EES.ROUND_SID = p_round_sid;
        RETURN l_ret;

    END;

    ----------------------------------------------------------------------------
    -- @name : getPreviousStep
    -- @return previous edit step of an entry
    ----------------------------------------------------------------------------
    FUNCTION getPreviousStep(p_entry_sid            NUMBER
                            ,p_round_sid            NUMBER
                            ,p_year                 NUMBER)
        RETURN VARCHAR2
    IS
        l_ret VARCHAR2(2000 BYTE);
    BEGIN
        SELECT cfg_questionnaire.getAvailability(E.IMPL_DATE
                                ,E.REFORM_IMPL_DATE
                                ,E.REFORM_REPLACED_DATE
                                ,E.ABOLITION_DATE
                                ,cfg_questionnaire.getStartDate(p_year)
                                ,cfg_questionnaire.getEndDate(p_year)) || ' (' || CES.DESCR ||')' INTO l_ret
                            FROM ENTRIES E,
                            ENTRY_EDIT_STEPS EES,
                            CFG_EDIT_STEPS CES
                        WHERE E.ENTRY_SID = EES.ENTRY_SID
                          AND EES.PREV_STEP_SID = CES.EDIT_STEP_SID
                          AND E.ENTRY_SID = p_entry_sid
                          AND EES.ROUND_SID = p_round_sid;
        RETURN l_ret;

    END;

    ----------------------------------------------------------------------------
    -- @name : getIsAmbitious
    -- @return IS_AMBITIOUS of an entry
    ----------------------------------------------------------------------------
    FUNCTION getIsAmbitious(p_entry_sid NUMBER)
        RETURN NUMBER
    IS
        l_ret NUMBER;
    BEGIN
        SELECT NVL(IS_AMBITIOUS, 0)
          INTO l_ret
          FROM ENTRIES_ADD_CFG
         WHERE ENTRY_SID = p_entry_sid;

        RETURN l_ret;
    END;

    ----------------------------------------------------------------------------
    -- @name : getDescr
    -- @return DESCR of an entry
    ----------------------------------------------------------------------------
    FUNCTION getDescr(p_entry_sid NUMBER)
        RETURN VARCHAR2
    IS
        l_ret VARCHAR2(1000 BYTE);
    BEGIN
        SELECT NVL(DESCR, '')
          INTO l_ret
          FROM ENTRIES_ADD_CFG
         WHERE ENTRY_SID = p_entry_sid;

        RETURN l_ret;
    END;

    ----------------------------------------------------------------------------
    -- @name : getIfiAbrv
    -- @return ifi Abrv of an entry
    ----------------------------------------------------------------------------
    FUNCTION getIfiAbrv(p_entry_sid NUMBER)
        RETURN VARCHAR2
    IS
        l_ret VARCHAR2(1000 BYTE);
    BEGIN
        SELECT NVL(IFI_MAIN_ABRV, '')
          INTO l_ret
          FROM ENTRIES_ADD_CFG
         WHERE ENTRY_SID = p_entry_sid;

        RETURN l_ret;
    END;

    ----------------------------------------------------------------------------
    -- @name : getEditStep
    -- @return return EditStep Sid based on Id
    ----------------------------------------------------------------------------
    FUNCTION getEditStep (p_edit_step_id IN VARCHAR2)
        RETURN NUMBER
    IS
        CURSOR ccur IS
            SELECT edit_step_sid
              FROM cfg_edit_steps
             WHERE edit_step_id = p_edit_step_id;

        l_func            VARCHAR2(30) := 'getEditStep';
        l_edit_step_sid   NUMBER;
    BEGIN
        OPEN ccur;
        FETCH ccur INTO l_edit_step_sid;
        CLOSE ccur;
        RETURN l_edit_step_sid;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -1;
    END;
    ----------------------------------------------------------------------------
    -- @name getQuestionnaires
    -- @return list of questionnaires
    ----------------------------------------------------------------------------
    PROCEDURE getQuestionnaires(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR   SELECT QUESTIONNAIRE_SID, APP_ID, DESCR
                           FROM CFG_QUESTIONNAIRES
                       ORDER BY QUESTIONNAIRE_SID;
    END;

    ----------------------------------------------------------------------------
    -- @name getQstnnrVersion
    -- @return version of questionnaire defined for that country
    ----------------------------------------------------------------------------
    PROCEDURE getQstnnrVersion(p_questionnaire_sid    IN NUMBER
                              ,p_country_id           IN VARCHAR2
                              ,l_ret                 OUT NUMBER)
    IS
    BEGIN
        SELECT QV.QSTNNR_VERSION_SID
          INTO l_ret
          FROM CFG_QSTNNR_VERSIONS QV
         WHERE QV.QUESTIONNAIRE_SID = p_questionnaire_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getQuestionnaireEntries
    -- @return returns available entries for specific questionnaire and country
    ----------------------------------------------------------------------------
    PROCEDURE getQuestionnaireEntries(p_questionnaire_sid    IN NUMBER
                                     ,p_country_id           IN VARCHAR2
                                     ,p_round_sid            IN NUMBER
                                     ,o_cur                 OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR SELECT
                           E.ENTRY_SID,
                           E.ENTRY_VERSION,
                           EES.EDIT_STEP_SID,
                           CES.EDIT_STEP_ID,
                           PES.descr AS prev_step_id,
                           EES.LAST_MODIF_DATE,
                           getavailability(E.impl_date, E.reform_impl_date, E.reform_replaced_date, E.abolition_date
                           ) AS availability,
                           E.ENTRY_NO AS ENTRY_NUMBER,
                           getIsAmbitious(E.ENTRY_SID) AS IS_AMBITIOUS,
                           getDescr(E.ENTRY_SID) AS DESCR,
                           getIfiAbrv(E.ENTRY_SID) AS IFI_MAIN_ABRV
                       FROM ENTRIES  E
                           ,ENTRY_EDIT_STEPS EES
                           ,CFG_EDIT_STEPS CES
                           ,CFG_EDIT_STEPS PES
                           ,CFG_QUESTIONNAIRES Q
                       WHERE E.ENTRY_SID = EES.ENTRY_SID
                         AND EES.EDIT_STEP_SID = CES.EDIT_STEP_SID
                         AND EES.PREV_STEP_SID = PES.EDIT_STEP_SID(+)
                         AND Q.APP_ID = E.APP_ID
                         AND Q.QUESTIONNAIRE_SID = p_questionnaire_sid
                         AND E.COUNTRY_ID = p_country_id
                         AND EES.round_sid = p_round_sid
                         AND getavailability(E.IMPL_DATE, E.reform_impl_date, E.reform_replaced_date, E.abolition_date) IN (
                               t_availability.C,
                               t_availability.F
                           )
                       ORDER BY
                           ENTRY_NUMBER;
    END;

    --------------------------------------------------------------------------------------------------------------
    -- @name getQuestionnaireQuestions
    -- @return list of questionnaire questions order by section order, subsection order, section question order
    --------------------------------------------------------------------------------------------------------------
    PROCEDURE getQuestionnaireQuestions(p_qstnnr_version_sid      IN NUMBER
                                      , o_cur                     OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
        SELECT
            SECTION_SID
            , SECTION_DESCR
            , SECT_ORDER_BY
            , SUB_SECTION_SID
            , SUB_SECTION_DESCR
            , SUB_SECT_ORDER_BY
            , QUESTION_VERSION_SID
            , QUESTION
            , QUESTION_ORDER_BY
            , QUESTION_TYPE_SID
            , MANDATORY
            , ACCESSOR
            , ASSESSMENT_PERIOD
        FROM
            (
                SELECT
                    SV.SECTION_VERSION_SID SECTION_SID
                    , S.SECTION_ID SECTION_DESCR
                    , QVS.ORDER_BY SECT_ORDER_BY
                    , NULL SUB_SECTION_SID
                    , NULL SUB_SECTION_DESCR
                    , 0 SUB_SECT_ORDER_BY
                    , QV.QUESTION_VERSION_SID
                    , Q.DESCR QUESTION
                    , QSQ.ORDER_BY QUESTION_ORDER_BY
                    , QT.QUESTION_TYPE_SID
                    , QV.MANDATORY
                    , QT.ACCESSOR
                    , SV.ASSESSMENT_PERIOD
                FROM CFG_QUESTIONS Q
                    INNER JOIN CFG_QUESTION_VERSIONS QV ON Q.QUESTION_SID = QV.QUESTION_SID
                    INNER JOIN CFG_QUESTION_TYPES QT ON QV.QUESTION_TYPE_SID = QT.QUESTION_TYPE_SID
                    INNER JOIN CFG_QSTNNR_SECTION_QUESTIONS QSQ ON QV.QUESTION_VERSION_SID = QSQ.QUESTION_VERSION_SID
                    INNER JOIN CFG_SECTION_VERSIONS SV ON QSQ.SECTION_VERSION_SID = SV.SECTION_VERSION_SID
                    INNER JOIN CFG_QSTNNR_VER_SECTIONS QVS ON SV.SECTION_VERSION_SID = QVS.SECTION_VERSION_SID
                    INNER JOIN CFG_QSTNNR_VERSIONS QSV ON QVS.QSTNNR_VERSION_SID = QSV.QSTNNR_VERSION_SID
                    INNER JOIN CFG_SECTIONS S ON S.SECTION_SID = SV.SECTION_SID
                WHERE QVS.QSTNNR_VERSION_SID = p_qstnnr_version_sid

                UNION

                SELECT
                    (
                    SELECT DISTINCT SV3.SECTION_VERSION_SID
                    FROM CFG_QSTNNR_VER_SECTIONS QVS3
                        INNER JOIN CFG_SECTION_VERSIONS SV3 ON SV3.SECTION_VERSION_SID = QVS3.SECTION_VERSION_SID
                        INNER JOIN CFG_SECTIONS S3 ON S3.SECTION_SID = SV3.SECTION_SID
                    WHERE SV3.SECTION_VERSION_SID = QVSS.PARENT_SECTION_VERSION_SID
                    ) SECTION_SID
                    ,(
                    SELECT DISTINCT S3.SECTION_ID
                    FROM CFG_QSTNNR_VER_SECTIONS QVS3
                        INNER JOIN CFG_SECTION_VERSIONS SV3 ON SV3.SECTION_VERSION_SID = QVS3.SECTION_VERSION_SID
                        INNER JOIN CFG_SECTIONS S3 ON S3.SECTION_SID = SV3.SECTION_SID
                    WHERE SV3.SECTION_VERSION_SID = QVSS.PARENT_SECTION_VERSION_SID
                    ) SECTION_DESCR
                    ,(
                    SELECT DISTINCT QVS2.ORDER_BY
                    FROM CFG_QSTNNR_VER_SECTIONS QVS2
                        INNER JOIN CFG_SECTION_VERSIONS SV2 ON SV2.SECTION_VERSION_SID = QVS2.SECTION_VERSION_SID
                    WHERE SV2.SECTION_VERSION_SID = QVSS.PARENT_SECTION_VERSION_SID
                    ) SECT_ORDER_BY
                    , SV.SECTION_VERSION_SID SUB_SECTION_SID
                    , S.SECTION_ID SUB_SECTION_DESCR
                    , QVSS.ORDER_BY SUB_SECT_ORDER_BY
                    , QV.QUESTION_VERSION_SID
                    , Q.DESCR QUESTION
                    , QSQ.ORDER_BY QUESTION_ORDER_BY
                    , QT.QUESTION_TYPE_SID
                    , QV.MANDATORY
                    , QT.ACCESSOR
                    , SV.ASSESSMENT_PERIOD
                FROM CFG_QUESTIONS Q
                    INNER JOIN CFG_QUESTION_VERSIONS QV ON Q.QUESTION_SID = QV.QUESTION_SID
                    INNER JOIN CFG_QUESTION_TYPES QT ON QV.QUESTION_TYPE_SID = QT.QUESTION_TYPE_SID
                    INNER JOIN CFG_QSTNNR_SECTION_QUESTIONS QSQ ON QV.QUESTION_VERSION_SID = QSQ.QUESTION_VERSION_SID
                    INNER JOIN CFG_SECTION_VERSIONS SV ON QSQ.SECTION_VERSION_SID = SV.SECTION_VERSION_SID
                    INNER JOIN CFG_QSTNNR_VER_SUBSECTIONS QVSS ON SV.SECTION_VERSION_SID = QVSS.SUB_SECTION_VERSION_SID
                    INNER JOIN CFG_QSTNNR_VERSIONS QSV ON QVSS.QSTNNR_VERSION_SID = QSV.QSTNNR_VERSION_SID
                    INNER JOIN CFG_SECTIONS S ON S.SECTION_SID = SV.SECTION_SID
                WHERE QVSS.QSTNNR_VERSION_SID = p_qstnnr_version_sid
            ) Q
        ORDER BY SECT_ORDER_BY, SUB_SECT_ORDER_BY, QUESTION_ORDER_BY
        ;
    END;

    ----------------------------------------------------------------------------
    -- @name getQuestionnaireIndexes
    -- @return list of indexes for a questionnaire
    ----------------------------------------------------------------------------
    PROCEDURE getQuestionnaireIndexes(p_questionnaire_id    IN  VARCHAR2
                                     ,o_cur                 OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
           SELECT I.INDEX_SID, I.INDEX_ID
             FROM CFG_INDEXES I, CFG_QUESTIONNAIRES Q
            WHERE Q.QUESTIONNAIRE_SID = I.QUESTIONNAIRE_SID 
              AND Q.APP_ID  = UPPER(p_questionnaire_id)
         ORDER BY I.INDEX_SID;
    END;

    ----------------------------------------------------------------------------
    -- @name getQuestionnaireElements
    -- @return questionnaire elements
    ----------------------------------------------------------------------------
    PROCEDURE getQuestionnaireElements(p_qst_version_sid         IN NUMBER
                                      ,p_round_year              IN NUMBER
                                     , o_cur                    OUT SYS_REFCURSOR)
    IS
        l_app_id VARCHAR2(20 BYTE);
    BEGIN
        SELECT APP_ID INTO l_app_id FROM CFG_QUESTIONNAIRES WHERE QUESTIONNAIRE_SID = p_qst_version_sid;
        OPEN o_cur FOR
      SELECT T.ELEMENT_TYPE_ID
            ,assignYears(l_app_id, E.ELEMENT_TEXT, p_round_year) as ELEMENT_TEXT
            ,E.EDIT_STEP_ID
        FROM CFG_UI_QSTNNR_ELEMENTS E,
             CFG_UI_ELEMENT_TYPES T
       WHERE E.ELEMENT_TYPE_SID =  T.ELEMENT_TYPE_SID
         AND E.QSTNNR_VERSION_SID    = p_qst_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getQuestionnaireSections
    -- @return list of questionnaire sections
    ----------------------------------------------------------------------------
    PROCEDURE getQuestionnaireSections(p_questionnaire_version_sid IN      NUMBER
                                     , o_cur                      OUT     SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
           SELECT QVS.SECTION_VERSION_SID
                , CS.SECTION_ID
                , S.DESCR
                , S.ASSESSMENT_PERIOD
                , S.NO_HELP
                , S.INFO_MSG
                , LISTAGG(US.EDIT_STEP_SID, ',')
                     WITHIN GROUP (ORDER BY US.EDIT_STEP_SID)
                     WORKFLOW_STEPS
             FROM CFG_QSTNNR_VERSIONS QV
                 ,CFG_QSTNNR_VER_SECTIONS QVS
                 ,CFG_SECTION_VERSIONS S
                 ,CFG_SECTIONS CS
                 ,CFG_UPDATABLE_SECTION_VERSIONS US
            WHERE QV.QSTNNR_VERSION_SID = p_questionnaire_version_sid
              AND QVS.QSTNNR_VERSION_SID = QV.QSTNNR_VERSION_SID
              AND S.SECTION_VERSION_SID = QVS.SECTION_VERSION_SID
              AND CS.SECTION_SID = S.SECTION_SID
              AND US.SECTION_VERSION_SID = QVS.SECTION_VERSION_SID(+)
         GROUP BY QVS.SECTION_VERSION_SID, CS.SECTION_ID, S.DESCR, S.ASSESSMENT_PERIOD, S.NO_HELP, S.INFO_MSG,  QVS.ORDER_BY
         ORDER BY QVS.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getHeaderAttributes
    -- @return list of header attributes (depending on flags)
    ----------------------------------------------------------------------------
    PROCEDURE getHeaderAttributes(p_qstnnr_version_sid  IN      NUMBER
                                , p_flag                IN      VARCHAR2
                                , o_cur                 OUT     SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT H.QUESTION_VERSION_SID
                  ,H.SHORT
                  ,H.WIDTH
                  ,H.MAPPING_TYPE
                  ,QT.MAP_TO_RESP_CHOICES
                  ,QT.ACCESSOR
              FROM CFG_HEADERS H
                  ,CFG_QUESTIONS Q
                  ,CFG_QUESTION_TYPES QT
                  ,CFG_QUESTION_VERSIONS QV
             WHERE H.QUESTION_VERSION_SID = QV.QUESTION_VERSION_SID
               AND QV.QUESTION_SID = Q.QUESTION_SID
               AND QV.QUESTION_TYPE_SID = QT.QUESTION_TYPE_SID
               AND H.QSTNNR_VERSION_SID = p_qstnnr_version_sid
               AND DECODE(p_flag
                          , 'questionnaire', H.IN_QUESTIONNAIRE
                          , 'scores', H.IN_SCORES
                          , 'indices', H.IN_INDEXES) =
                     1
             ORDER BY H.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getSectionSubsections
    -- @return list of subsections
    ----------------------------------------------------------------------------
    PROCEDURE getSectionSubsections(p_qstnnr_section_sid IN NUMBER
                                   ,p_round_year         IN NUMBER 
                                  , o_cur OUT SYS_REFCURSOR)
    IS
        l_app_id VARCHAR2(20 BYTE);
    BEGIN
        SELECT DISTINCT APP_ID INTO l_app_id FROM CFG_QUESTIONNAIRES WHERE QUESTIONNAIRE_SID IN (SELECT QSTNNR_VERSION_SID FROM CFG_QSTNNR_VER_SUBSECTIONS WHERE PARENT_SECTION_VERSION_SID = p_qstnnr_section_sid)
        OR QUESTIONNAIRE_SID IN (SELECT QSTNNR_VERSION_SID FROM CFG_QSTNNR_VER_SECTIONS WHERE SECTION_VERSION_SID =p_qstnnr_section_sid );
        OPEN o_cur FOR
        SELECT SV.SECTION_VERSION_SID
              ,assignYears(l_app_id, SV.DESCR, p_round_year) as DESCR
              ,S.SECTION_ID
              ,COALESCE(SV.ASSESSMENT_PERIOD, 0) as ASSESSMENT_PERIOD
              ,COALESCE(NULL, 0) as NO_HELP
              ,SV.INFO_MSG
              ,LISTAGG(DISTINCT USV.EDIT_STEP_SID, ',')
                    WITHIN GROUP (ORDER BY USV.EDIT_STEP_SID) as WORKFLOW_STEPS
          FROM CFG_SECTIONS S
              ,CFG_SECTION_VERSIONS SV
              ,CFG_QSTNNR_VER_SUBSECTIONS QVSS
              ,CFG_UPDATABLE_SECTION_VERSIONS USV
         WHERE S.SECTION_SID = SV.SECTION_SID
           AND SV.SECTION_VERSION_SID = QVSS.SUB_SECTION_VERSION_SID
           AND QVSS.PARENT_SECTION_VERSION_SID = p_qstnnr_section_sid
           AND SV.SECTION_VERSION_SID(+) = USV.SECTION_VERSION_SID
      GROUP BY SV.SECTION_VERSION_SID, SV.DESCR, S.SECTION_ID, COALESCE(SV.ASSESSMENT_PERIOD, 0), COALESCE(NULL, 0), SV.INFO_MSG, QVSS.ORDER_BY
      ORDER BY QVSS.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getSectionHdrAttributes
    -- @return list of section header attributes
    ----------------------------------------------------------------------------
    PROCEDURE getSectionHdrAttributes(p_qstnnr_version_sid     IN NUMBER
                                    , p_section_version_sid    IN NUMBER
                                    , o_cur                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
        SELECT HA.QUESTION_VERSION_SID
                , HA.SHORT as DESCR
                , HA.WIDTH
                , HA.MAPPING_TYPE
                , QT.MAP_TO_RESP_CHOICES
             FROM CFG_HEADERS HA
                 ,CFG_QUESTIONS Q
                 ,CFG_QUESTION_VERSIONS QV
                 ,CFG_QUESTION_TYPES QT
           WHERE QT.QUESTION_TYPE_SID = QV.QUESTION_TYPE_SID
             AND QV.QUESTION_SID = Q.QUESTION_SID
             AND HA.QUESTION_VERSION_SID = QV.QUESTION_VERSION_SID
             AND HA.QSTNNR_VERSION_SID = p_qstnnr_version_sid
             AND HA.SECTION_VERSION_SID = p_section_version_sid
         ORDER BY HA.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name geSectionQuestions
    -- @return list of questions in specific section with their configuration
    ----------------------------------------------------------------------------
    PROCEDURE getSectionQuestions(p_section_version_sid      IN NUMBER
                                , o_cur                     OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT QSQ.QUESTION_VERSION_SID
                  ,QT.QUESTION_TYPE_SID
                  ,NULL AS UPD_ROLES
                  ,QV.ALWAYS_MODIFY
              FROM CFG_QSTNNR_SECTION_QUESTIONS QSQ
                  ,CFG_QUESTION_VERSIONS QV
                  ,CFG_QUESTION_TYPES QT
             WHERE QV.QUESTION_TYPE_SID = QT.QUESTION_TYPE_SID
               AND QV.QUESTION_VERSION_SID = QSQ.QUESTION_VERSION_SID
               AND QSQ.SECTION_VERSION_SID = p_section_version_sid
               ORDER BY QSQ.ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name getConditionalQuestions
    -- @return list of conditional questions with their conditions
    ----------------------------------------------------------------------------
    PROCEDURE getConditionalQuestions(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT COND_SID
                  ,QUESTION_VERSION_SID
                  ,COND_QUESTION_VERSION_SID
                  ,LOV_SID
              FROM CFG_QUESTION_CONDITIONS
              ORDER BY COND_QUESTION_VERSION_SID ASC;
    END;

    ----------------------------------------------------------------------------
    -- @name getCondQuestionsByLvl
    -- @return list of conditional questions by level of dependencies
    ----------------------------------------------------------------------------
    PROCEDURE getCondQuestionsByLvl(p_question_version_sid IN NUMBER
                                  , o_cur                 OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT * FROM (
                SELECT DISTINCT QUESTION_VERSION_SID
                               ,COND_QUESTION_VERSION_SID
                               ,LOV_SID
                               ,COND_SID
                               ,LEVEL AS LVL
                          FROM CFG_QUESTION_CONDITIONS
                    START WITH QUESTION_VERSION_SID =  p_question_version_sid
              CONNECT BY PRIOR COND_QUESTION_VERSION_SID = QUESTION_VERSION_SID
                      ORDER BY LEVEL, COND_QUESTION_VERSION_SID, LOV_SID
            ) WHERE LVL > 1 AND LOV_SID != -9;
    END;

    ----------------------------------------------------------------------------
    -- @name getDependentQuestions
    -- @return list of dependent questions from the same section
    ----------------------------------------------------------------------------
    PROCEDURE getDependentQuestions(p_question_version_sid   IN NUMBER
                                   ,o_cur                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT DISTINCT CA.QUESTION_VERSION_SID
              FROM CFG_QUESTION_CONDITIONS CA
                  ,CFG_QSTNNR_SECTION_QUESTIONS QSQ1
                  ,CFG_QSTNNR_SECTION_QUESTIONS QSQ2
             WHERE QSQ1.QUESTION_VERSION_SID = CA.COND_QUESTION_VERSION_SID
               AND QSQ2.QUESTION_VERSION_SID = CA.QUESTION_VERSION_SID
               AND QSQ1.SECTION_VERSION_SID = QSQ2.SECTION_VERSION_SID
               AND CA.COND_QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name geQuestion
    -- @return question configuration
    ----------------------------------------------------------------------------
    PROCEDURE getQuestion(p_question_version_sid     IN NUMBER
                        , p_cond_sid                 IN NUMBER
                        , p_round_year               IN NUMBER    
                        , o_cur                     OUT SYS_REFCURSOR)
    IS
        l_app_id VARCHAR2(20 BYTE);
        l_qstnnr_sid NUMBER;
    BEGIN
        SELECT QSTNNR_VERSION_SID INTO l_qstnnr_sid FROM (
            SELECT QVSS.QSTNNR_VERSION_SID FROM 
            CFG_QSTNNR_VER_SUBSECTIONS QVSS,
            CFG_QSTNNR_SECTION_QUESTIONS QSQ
            WHERE QSQ.QUESTION_VERSION_SID = p_question_version_sid
            AND QVSS.SUB_SECTION_VERSION_SID = QSQ.SECTION_VERSION_SID
            UNION
            SELECT QVS.QSTNNR_VERSION_SID FROM 
            CFG_QSTNNR_VER_SECTIONS QVS,
            CFG_QSTNNR_SECTION_QUESTIONS QSQ WHERE
                QVS.SECTION_VERSION_SID = QSQ.SECTION_VERSION_SID AND QSQ.QUESTION_VERSION_SID = p_question_version_sid)
                WHERE QSTNNR_VERSION_SID IS NOT NULL;
        SELECT APP_ID INTO l_app_id FROM CFG_QUESTIONNAIRES WHERE QUESTIONNAIRE_SID = l_qstnnr_sid;
        OPEN o_cur FOR
            SELECT QV.QUESTION_VERSION_SID
                  ,QV.MASTER_SID
                  ,Q.DESCR
                  ,QV.QUESTION_TYPE_SID
                  ,QT.MAP_TO_RESP_CHOICES
                  ,QLT.LOV_TYPE_SID
                  ,QV.ADD_INFO
                  ,QV.INDEX_ATTR
                  ,NVL(QV.MANDATORY, 0) AS MANDATORY
                  ,assignYears(l_app_id, QV.HELP_TEXT, p_round_year) AS HELP_TEXT
              FROM CFG_QUESTION_VERSIONS QV
                  ,CFG_QUESTIONS Q
                  ,CFG_QUESTION_TYPES QT
                  ,CFG_QUESTION_LOV_TYPES QLT
             WHERE QV.QUESTION_SID = Q.QUESTION_SID
               AND QV.QUESTION_TYPE_SID = QT.QUESTION_TYPE_SID
               AND QLT.QUESTION_VERSION_SID(+) = QV.QUESTION_VERSION_SID
               AND QV.QUESTION_VERSION_SID = p_question_version_sid
               AND (QLT.COND_SID = p_cond_sid OR QLT.COND_SID IS NULL);

    END;

    ----------------------------------------------------------------------------
    -- @name getQuestions
    -- @return list of questions with their types
    ----------------------------------------------------------------------------
    PROCEDURE getQuestions(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT QV.QUESTION_VERSION_SID
                  ,QV.QUESTION_TYPE_SID
                  ,QVS.QSTNNR_VERSION_SID
             FROM CFG_QUESTION_VERSIONS QV
                 ,CFG_QSTNNR_SECTION_QUESTIONS QSQ
                 ,cfg_qstnnr_ver_sections QVS
           WHERE QV.QUESTION_VERSION_SID = QSQ.QUESTION_VERSION_SID
             AND QSQ.SECTION_VERSION_SID = QVS.SECTION_VERSION_SID
            UNION
            SELECT QV.QUESTION_VERSION_SID
                  ,QV.QUESTION_TYPE_SID
                  ,QVSS.QSTNNR_VERSION_SID
             FROM CFG_QUESTION_VERSIONS QV
                 ,CFG_QSTNNR_SECTION_QUESTIONS QSQ
                 ,CFG_QSTNNR_VER_SUBSECTIONS QVSS
           WHERE QV.QUESTION_VERSION_SID = QSQ.QUESTION_VERSION_SID
             AND QSQ.SECTION_VERSION_SID = QVSS.SUB_SECTION_VERSION_SID
             ;
    END;

    ----------------------------------------------------------------------------
    -- @name getQuestionTypeAccessors
    -- @return list of question type accessors
    ----------------------------------------------------------------------------
    PROCEDURE getQuestionTypeAccessors(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT QUESTION_TYPE_SID
                  ,NVL(MAP_TO_RESP_CHOICES, 0) MAP_TO_RESP_CHOICES
                  ,NVL(MULTIPLE, 0)            MULTIPLE
                  ,ACCESSOR
                  ,OPTIONS
             FROM CFG_QUESTION_TYPES;
    END;

    ----------------------------------------------------------------------------
    -- @name getResponseChoices
    -- @return list of all response choices
    ----------------------------------------------------------------------------
    PROCEDURE getResponseChoices(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT L.LOV_SID        AS RESPONSE_SID
                  ,L.LOV_ID         AS RESPONSE_ID
                  ,L.LOV_TYPE_SID   AS RESPONSE_GROUP_SID
                  ,L.DESCR
                  ,L.NEED_DET       AS PROVIDE_DETAILS
                  ,L.ORDER_BY
                  ,L.CFG_TYPE       AS RESPONSE_TYPE_SID
                  ,L.HELP_TEXT
                  ,L.CHOICE_LIMIT
                  ,L.DETS_TXT
                  ,L.INFO_ICON
                  ,L.INFO_TXT
              FROM CFG_LOVS L
                  ,CFG_LOV_TYPES LT
             WHERE L.LOV_TYPE_SID = LT.LOV_TYPE_SID
               AND LT.DYN_SID = 0
               AND L.LOV_ID IS NULL
               AND LT.LOV_TYPE_ID != 'COUNTRY'
            UNION
            SELECT L.LOV_SID        AS RESPONSE_SID
                  ,L.LOV_ID         AS RESPONSE_ID
                  ,DL.LOV_TYPE_SID  AS RESPONSE_GROUP_SID
                  ,L.DESCR
                  ,L.NEED_DET       AS PROVIDE_DETAILS
                  ,L.ORDER_BY
                  ,L.CFG_TYPE       AS RESPONSE_TYPE_SID
                  ,L.HELP_TEXT
                  ,L.CHOICE_LIMIT
                  ,L.DETS_TXT
                  ,L.INFO_ICON
                  ,L.INFO_TXT
              FROM CFG_LOVS L
                  ,CFG_LOV_TYPES LT
                  ,CFG_DYNAMIC_LOVS DL
             WHERE DL.USED_LOV_TYPE_SID = L.LOV_TYPE_SID
               AND LT.LOV_TYPE_SID = DL.LOV_TYPE_SID
               AND LT.DYN_SID = DL.DYN_SID
               AND L.LOV_SID = DL.USED_LOV_SID
               AND LT.LOV_TYPE_ID != 'COUNTRY'
               AND LT.DYN_SID = 1
            UNION
            SELECT L.LOV_SID        AS RESPONSE_SID
                  ,L.LOV_ID         AS RESPONSE_ID
                  ,L.LOV_TYPE_SID   AS RESPONSE_GROUP_SID
                  ,L.DESCR
                  ,L.NEED_DET       AS PROVIDE_DETAILS
                  ,L.ORDER_BY
                  ,L.CFG_TYPE       AS RESPONSE_TYPE_SID
                  ,L.HELP_TEXT
                  ,L.CHOICE_LIMIT
                  ,L.DETS_TXT
                  ,L.INFO_ICON
                  ,L.INFO_TXT
              FROM CFG_LOVS L
                  ,CFG_LOV_TYPES LT
             WHERE L.LOV_TYPE_SID = LT.LOV_TYPE_SID
               AND LT.DYN_SID = 0
               AND L.LOV_ID IS NOT NULL
               AND LT.LOV_TYPE_ID != 'COUNTRY'
            UNION
            SELECT L.LOV_SID        AS RESPONSE_SID
                  ,L.LOV_ID         AS RESPONSE_ID
                  ,L.LOV_TYPE_SID   AS RESPONSE_GROUP_SID
                  ,L.DESCR
                  ,L.NEED_DET       AS PROVIDE_DETAILS
                  ,L.ORDER_BY
                  ,L.CFG_TYPE       AS RESPONSE_TYPE_SID
                  ,L.HELP_TEXT
                  ,L.CHOICE_LIMIT
                  ,L.DETS_TXT
                  ,L.INFO_ICON
                  ,L.INFO_TXT
              FROM CFG_SPECIAL_LOVS L
                  ,CFG_LOV_TYPES LT
             WHERE L.LOV_TYPE_SID = LT.LOV_TYPE_SID
               AND LT.LOV_TYPE_ID != 'COUNTRY'
            ORDER BY 3, 6;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntry
    -- @return entry number and version
    ----------------------------------------------------------------------------
    PROCEDURE getEntry(p_entry_sid  IN  NUMBER
                      ,p_round_sid  IN  NUMBER
                      ,o_cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT E.ENTRY_SID
                  ,E.ENTRY_VERSION
                  ,E.ENTRY_NO AS ENTRY_NUMBER
                  ,E.COUNTRY_ID
                  ,E.APP_ID
                  ,EES.EDIT_STEP_SID
                  ,CES1.EDIT_STEP_ID
                  ,EES.PREV_STEP_SID
                  ,EES.LAST_MODIF_DATE
              FROM ENTRIES E
                  ,ENTRY_EDIT_STEPS EES
                  ,CFG_EDIT_STEPS CES1
                  ,CFG_EDIT_STEPS CES2
             WHERE E.ENTRY_SID = EES.ENTRY_SID
               AND EES.EDIT_STEP_SID = CES1.EDIT_STEP_SID
               AND CES2.EDIT_STEP_SID(+) = EES.PREV_STEP_SID
               AND E.ENTRY_SID = p_entry_sid
               AND EES.ROUND_SID = p_round_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getSubmissionDate
    -- @return questionnaire submission date for a country
    ----------------------------------------------------------------------------
    PROCEDURE getSubmissionDate(p_questionnaire_sid     IN NUMBER
                               ,p_country_id            IN VARCHAR2
                               ,p_round_sid             IN NUMBER
                               ,o_cur                  OUT SYS_REFCURSOR)
    IS
        l_status VARCHAR2(100 BYTE) := 'Locked';
    BEGIN
        OPEN o_cur FOR
            SELECT CS.STATUS_SID
                  ,CS.SUBMIT_DATE
              FROM QSTNNR_CTY_STATUS CS
                  ,CFG_QSTNNR_STATUS S
             WHERE CS.STATUS_SID = S.STATUS_SID
               AND CS.QUESTIONNAIRE_SID = p_questionnaire_sid
               AND CS.COUNTRY_ID = p_country_id
               AND CS.ROUND_SID = p_round_sid
               AND S.DESCR = l_status;
    END;

    ----------------------------------------------------------------------------
    -- @name : checkSubmitCompletion
    -- @return check whether conditions are met to submit the questionnaire
    ----------------------------------------------------------------------------
    PROCEDURE checkSubmitCompletion(p_questionnaire_sid     IN NUMBER
                                   ,p_country_id            IN VARCHAR2
                                   ,p_round_sid             IN NUMBER
                                   ,o_res                  OUT NUMBER)
    IS
        l_ret   NUMBER;
        l_completed     VARCHAR2(20 BYTE) := 'CPL';
        l_current_entry VARCHAR2(20 BYTE) := t_availability.C;
    BEGIN
        SELECT COUNT(*)
          INTO l_ret
          FROM ENTRIES E
              ,ENTRY_EDIT_STEPS EDS
              ,CFG_EDIT_STEPS ES
              ,CFG_QUESTIONNAIRES QS
         WHERE E.ENTRY_SID          = EDS.ENTRY_SID
           AND EDS.EDIT_STEP_SID    = ES.EDIT_STEP_SID
           AND E.COUNTRY_ID         = p_country_id
           AND E.APP_ID             = QS.APP_ID
           AND QS.QUESTIONNAIRE_SID = p_questionnaire_sid
           AND EDS.ROUND_SID        = p_round_sid
           AND ES.EDIT_STEP_ID     != l_completed
           AND getAvailability(E.IMPL_DATE
                              ,E.REFORM_IMPL_DATE
                              ,E.REFORM_REPLACED_DATE
                              ,E.ABOLITION_DATE) = l_current_entry;
        IF l_ret = 0 THEN
            o_res := l_ret;
        ELSE
            o_res := -1;
        END IF;
    END;

    ----------------------------------------------------------------------------
    -- @name existCtyStatus
    -- @return whether a cty status is already there or not
    ---------------------------------------------------------------------------
    FUNCTION existCtyStatus(p_questionnaire_sid         IN NUMBER
                           ,p_country_id                IN VARCHAR2
                           ,p_round_sid                 IN NUMBER)
        RETURN NUMBER
    IS
        l_ret  NUMBER;
    BEGIN
        SELECT COUNT(*)
            INTO l_ret
            FROM QSTNNR_CTY_STATUS QS
           WHERE QS.QUESTIONNAIRE_SID = p_questionnaire_sid
             AND QS.COUNTRY_ID        = p_country_id
             AND QS.ROUND_SID         = p_round_sid;

        RETURN l_ret;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN -1;
    END;

    ----------------------------------------------------------------------------
    -- @name submitQuestionnaire
    -- @return status of questionnaire submission
    ----------------------------------------------------------------------------
    PROCEDURE submitQuestionnaire(p_questionnaire_sid       IN NUMBER
                                 ,p_country_id              IN VARCHAR2
                                 ,p_round_sid               IN NUMBER
                                 ,p_status_sid              IN NUMBER
                                 ,p_user                    IN VARCHAR2
                                 ,p_ret                     OUT NUMBER)
    IS
        l_ret       NUMBER;
        l_qst_sid   NUMBER;
    BEGIN
        checkSubmitCompletion(p_questionnaire_sid
                             ,p_country_id
                             ,p_round_sid
                             ,l_ret);

        IF l_ret = 0 THEN
            CASE existCtyStatus(p_questionnaire_sid, p_country_id, p_round_sid)
                WHEN -1 THEN
                    l_ret := -1;
                WHEN 0 THEN
                    INSERT INTO QSTNNR_CTY_STATUS(QUESTIONNAIRE_SID
                                                 ,ROUND_SID
                                                 ,COUNTRY_ID
                                                 ,STATUS_SID
                                                 ,SUBMIT_LOGIN
                                                 ,SUBMIT_DATE)
                         VALUES (p_questionnaire_sid
                                ,p_round_sid
                                ,p_country_id
                                ,p_status_sid
                                ,p_user
                                ,SYSDATE);
                ELSE
                    UPDATE QSTNNR_CTY_STATUS
                       SET STATUS_SID   = p_status_sid
                          ,SUBMIT_LOGIN = p_user
                          ,SUBMIT_DATE  = SYSDATE
                     WHERE QUESTIONNAIRE_SID = p_questionnaire_sid
                       AND COUNTRY_ID        = p_country_id
                       AND ROUND_SID         = p_round_sid;
            END CASE;
            l_ret  := SQLCODE;
        ELSE
            l_ret := -1;
        END IF;

        p_ret := l_ret;
    EXCEPTION
        WHEN OTHERS THEN
            p_ret  := SQLCODE;
    END;

    ----------------------------------------------------------------------------
    -- @name : submitLocked
    -- @return submits a questionnaire for a country
    ----------------------------------------------------------------------------
    PROCEDURE submitLocked(p_questionnaire_sid              IN NUMBER
                          ,p_country_id                     IN VARCHAR2
                          ,p_round_sid                      IN NUMBER
                          ,p_user                           IN VARCHAR2
                          ,o_res                            OUT NUMBER
                          ,o_mess                           OUT VARCHAR2)
    IS
        l_status_sid NUMBER;
    BEGIN
        SELECT S.STATUS_SID
          INTO l_status_sid
          FROM CFG_QSTNNR_STATUS S
         WHERE S.DESCR = 'Locked';

        IF l_status_sid IS NULL THEN
            o_res := -1;
        ELSE
            submitQuestionnaire(p_questionnaire_sid
                               ,p_country_id
                               ,p_round_sid
                               ,l_status_sid
                               ,p_user
                               ,o_res);
        END IF;
    END;

    ----------------------------------------------------------------------------
    -- @name : getSubmitDate
    -- @return submission date of a specific app/qst, country and round
    ----------------------------------------------------------------------------
    FUNCTION getSubmitDate(p_app_id            IN     VARCHAR2
                          ,p_country_id        IN     VARCHAR2
                          ,p_round_sid         IN     NUMBER)
    RETURN VARCHAR2
    IS
        l_locked VARCHAR2(100 BYTE) := 'Locked';
        l_na     VARCHAR2(100 BYTE) := 'N/A';
        l_out    VARCHAR2(100 BYTE);
    BEGIN

            SELECT CS.SUBMIT_DATE
              INTO l_out
              FROM QSTNNR_CTY_STATUS CS
                  ,CFG_QSTNNR_STATUS S
                  ,CFG_QUESTIONNAIRES Q
             WHERE CS.STATUS_SID = S.STATUS_SID
               AND CS.QUESTIONNAIRE_SID = Q.QUESTIONNAIRE_SID
               AND Q.APP_ID             = p_app_id
               AND CS.COUNTRY_ID        = p_country_id
               AND CS.ROUND_SID         = p_round_sid
               AND S.DESCR              = l_locked;

            RETURN NVL(l_out, l_na);
    END;

    ----------------------------------------------------------------------------
    -- @name : getQstCustomHeaders
    -- @return custom header text used in questionnaire
    ----------------------------------------------------------------------------
    PROCEDURE getQstCustomHeaders(p_qstnnr_version_sid  IN  NUMBER
                                 ,p_page                IN  VARCHAR2
                                 ,o_cur                 OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT CUSTOM_HEADER_ID
                  ,IN_QUESTIONNAIRE
                  ,IN_SCORES
                  ,IN_INDEXES
                  ,WIDTH
                  ,ORDER_BY
              FROM CFG_CUSTOM_HEADERS
             WHERE QSTNNR_VERSION_SID = p_qstnnr_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name : unsubmit
    -- @return : unsubmits a questionnaire for a country
    ----------------------------------------------------------------------------
    PROCEDURE unsubmit(p_app_id     IN     VARCHAR2
                      ,p_country_id IN     VARCHAR2
                      ,p_round_sid  IN     NUMBER
                      ,p_user       IN     VARCHAR2
                      ,o_res        OUT    NUMBER)
    IS
    BEGIN
        UPDATE QSTNNR_CTY_STATUS CS
           SET STATUS_SID = 7
         WHERE CS.QUESTIONNAIRE_SID IN (SELECT QUESTIONNAIRE_SID FROM CFG_QUESTIONNAIRES WHERE APP_ID = p_app_id)
           AND CS.COUNTRY_ID = p_country_id
           AND CS.ROUND_SID = p_round_sid;

        o_res := SQL%ROWCOUNT;
    END;

    ----------------------------------------------------------------------------
    -- @name : getIfis
    -- @return : list of all IFIs
    ----------------------------------------------------------------------------
    PROCEDURE getIfis(o_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR SELECT DISTINCT DESCR
                        FROM ENTRIES_ADD_CFG WHERE APP_ID = 'IFI';
    END;

    ----------------------------------------------------------------------------
    -- @name : getCountryIfi
    -- @return : Monitoring IFI for a certain country
    ----------------------------------------------------------------------------
    PROCEDURE getCountryIfi(p_country_id IN VARCHAR2
                           ,p_monitoring IN NUMBER
                           ,o_cur       OUT SYS_REFCURSOR)
    IS
        l_monitoring NUMBER := 3;
        l_country VARCHAR2(4000 BYTE) := 'SI';
    BEGIN
        IF p_country_id != l_country THEN
            OPEN o_cur FOR SELECT DISTINCT AC.DESCR
                             FROM ENTRIES E
                                 ,ENTRIES_ADD_CFG AC
                            WHERE E.ENTRY_SID = AC.ENTRY_SID
                              AND E.COUNTRY_ID = p_country_id AND AC.IS_MONITORING = 1;
        ELSE
            OPEN o_cur FOR SELECT DISTINCT AC.DESCR
                             FROM ENTRIES E
                                 ,ENTRIES_ADD_CFG AC
                            WHERE E.ENTRY_SID = AC.ENTRY_SID
                              AND E.COUNTRY_ID = p_country_id AND AC.IS_MONITORING = (l_monitoring - p_monitoring);
        END IF;
    END;

    ----------------------------------------------------------------------------
    -- @name : setEntryEditStep
    -- @purpose : to manage the update workflow of an entry
    ----------------------------------------------------------------------------
    PROCEDURE setEntryEditStep(p_entry_sid      IN NUMBER
                              ,p_app_id         IN VARCHAR2 
                              ,p_edit_step_id   IN VARCHAR2
                              ,p_round_sid      IN NUMBER
                              ,p_last_login     IN VARCHAR2 DEFAULT NULL
                              ,p_err            OUT NUMBER)
    IS
        l_edit_step_sid         NUMBER;
        l_exist                 NUMBER;
    BEGIN
        l_edit_step_sid := geteditstep(p_edit_step_id);

        IF l_edit_step_sid != -1 THEN
            SELECT COUNT(*)
              INTO l_exist
              FROM ENTRY_EDIT_STEPS
             WHERE ENTRY_SID = p_entry_sid
               AND ROUND_SID = p_round_sid;

            IF l_exist = 0 THEN
                INSERT INTO ENTRY_EDIT_STEPS(ENTRY_SID, EDIT_STEP_SID, ROUND_SID, LAST_LOGIN, LAST_MODIF_DATE )
                VALUES (p_entry_sid, l_edit_step_sid, p_round_sid, p_last_login, SYSDATE);
            ELSE
                UPDATE ENTRY_EDIT_STEPS
                   SET EDIT_STEP_SID   =  l_edit_step_sid
                      ,LAST_LOGIN      =  p_last_login
                      ,LAST_MODIF_DATE =  SYSDATE
                 WHERE ENTRY_SID = p_entry_sid
                   AND ROUND_SID = p_round_sid;
            END IF;
        END IF;

        p_err := sqlcode;
    END;

    ----------------------------------------------------------------------------
    -- @name : abolishEntry
    -- @return : status of abolishment of an entry
    ----------------------------------------------------------------------------
    PROCEDURE abolishEntry(p_entry_sid      IN NUMBER
                          ,p_reason         IN VARCHAR2
                          ,p_date           IN DATE
                          ,p_ret            OUT NUMBER)
    IS
    BEGIN
        UPDATE ENTRIES
           SET ABOLITION_DATE = p_date
              ,ABOLITION_REASON = p_reason
         WHERE ENTRY_SID = p_entry_sid;

         p_ret := SQLCODE;

    END;

    ----------------------------------------------------------------------------
    -- @name : duplicateEntry
    -- @return : duplicate an entry in case a reform is introduced
    ----------------------------------------------------------------------------
    PROCEDURE duplicateEntry(p_in_entry_sid         IN  NUMBER
                            ,p_round_sid            IN  NUMBER
                            ,p_reason               IN  VARCHAR2
                            ,p_date                 IN  DATE
                            ,p_date_force           IN  DATE
                            ,p_last_login           IN  VARCHAR2 DEFAULT NULL
                            ,p_out_entry_sid        OUT NUMBER
                            ,p_ret                  OUT NUMBER)
    IS
        l_new_entry_sid NUMBER;
        l_entry_rec     ENTRIES%ROWTYPE;
        l_app_id        VARCHAR2(4000);

        CURSOR c_entry IS
            SELECT * FROM ENTRIES WHERE ENTRY_SID = p_in_entry_sid;

        CURSOR c_choices IS
            SELECT * FROM ENTRY_CHOICES WHERE ENTRY_SID = p_in_entry_sid;

        CURSOR c_targets IS
            SELECT * FROM TARGET_ENTRIES WHERE ENTRY_SID = p_in_entry_sid;

        CURSOR c_infos IS
            SELECT * FROM ENTRY_CHOICES_ADD_INFOS WHERE ENTRY_SID = p_in_entry_sid;

        CURSOR c_addcfg IS
            SELECT * FROM ENTRIES_ADD_CFG WHERE ENTRY_SID = p_in_entry_sid;
    BEGIN
        OPEN c_entry;
        FETCH c_entry INTO l_entry_rec;
        CLOSE c_entry;

        SELECT APP_ID INTO l_app_id FROM ENTRIES WHERE ENTRY_SID = p_in_entry_sid;

        IF l_entry_rec.ENTRY_SID IS NOT NULL THEN
            l_entry_rec.ENTRY_VERSION     := l_entry_rec.ENTRY_VERSION + 1;
            l_entry_rec.REFORM_REASON     := p_reason;
            l_entry_rec.REFORM_ADOPT_DATE := p_date;
            l_entry_rec.REFORM_IMPL_DATE  := p_date_force;

            INSERT INTO ENTRIES VALUES l_entry_rec RETURNING ENTRY_SID INTO l_new_entry_sid;

            --Duplicate ENTRY_CHOICES
            FOR r_rec IN c_choices LOOP
                INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS, ASSESSMENT_PERIOD)
                VALUES (l_new_entry_sid, r_rec.QUESTION_VERSION_SID, r_rec.RESPONSE, r_rec.DETAILS, r_rec.ASSESSMENT_PERIOD);
            END LOOP;

            --Duplicate TARGET_ENTRIES
            FOR r_rec IN c_targets LOOP
                INSERT INTO TARGET_ENTRIES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE_SID, VALUE, NOT_APPLICABLE, DESCR)
                VALUES (l_new_entry_sid, r_rec.QUESTION_VERSION_SID, r_rec.RESPONSE_SID, r_rec.VALUE, r_rec.NOT_APPLICABLE, r_rec.DESCR);
            END LOOP;

            --Duplicate ENTRY_CHOICES_ADD_INFOS
            FOR r_rec IN c_infos LOOP
                INSERT INTO ENTRY_CHOICES_ADD_INFOS(ENTRY_SID, QUESTION_VERSION_SID, DESCR, PERIOD_SID)
                VALUES (l_new_entry_sid, r_rec.QUESTION_VERSION_SID, r_rec.DESCR, r_rec.PERIOD_SID);
            END LOOP;

            --Duplicate ENTRIES_ADD_CFG
            FOR r_rec IN c_addcfg LOOP
                INSERT INTO ENTRIES_ADD_CFG(ENTRY_SID, APP_ID, DESCR, IS_MONITORING, IFI_MAIN_ABRV, IS_AMBITIOUS)
                VALUES (l_new_entry_sid, r_rec.APP_ID, r_rec.DESCR, r_rec.IS_MONITORING, r_rec.IFI_MAIN_ABRV, r_rec.IS_AMBITIOUS);
            END LOOP;
        END IF;

        p_out_entry_sid := l_new_entry_sid;

        --Update reform_replace_date of old entry
        UPDATE ENTRIES
           SET REFORM_REPLACED_DATE = p_date_force
         WHERE ENTRY_SID = p_in_entry_sid;

        --Update the entry workflow step
        CASE getAvailability(l_entry_rec.IMPL_DATE, l_entry_rec.REFORM_IMPL_DATE, l_entry_rec.REFORM_REPLACED_DATE, l_entry_rec.ABOLITION_DATE)
            WHEN t_availability.C THEN
                setEntryEditStep(l_new_entry_sid, l_app_id, 'RFM', p_round_sid, p_last_login, p_ret);
            WHEN t_availability.F THEN
                setEntryEditStep(p_in_entry_sid, l_app_id,  'NOC', p_round_sid, p_last_login, p_ret);
                setEntryEditStep(l_new_entry_sid, l_app_id, 'RFF', p_round_sid, p_last_login, p_ret);
        END CASE;
    END;

    ----------------------------------------------------------------------------
    -- @name getEditSteps
    -- @return edit steps
    ----------------------------------------------------------------------------
    PROCEDURE getEditSteps(o_cur        OUT     SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT EDIT_STEP_SID, EDIT_STEP_ID, DESCR
              FROM CFG_EDIT_STEPS
          ORDER BY ORDER_BY;
    END;

    ----------------------------------------------------------------------------
    -- @name createRule
    -- @purpose create entry for NFR app
    ----------------------------------------------------------------------------
    PROCEDURE createRule(p_country          IN  VARCHAR2
                        ,p_ruletype         IN  NUMBER
                        ,p_dateadopt        IN  DATE
                        ,p_date_impl        IN  DATE
                        ,p_description      IN  VARCHAR2
                        ,p_last_login       IN  VARCHAR2
                        ,p_round_sid        IN  NUMBER
                        ,o_sid              OUT NUMBER
                        ,p_ret              OUT NUMBER)
    IS
    BEGIN
        INSERT INTO ENTRIES(COUNTRY_ID, APP_ID, ENTRY_NO, ENTRY_VERSION, APPRV_DATE, IMPL_DATE)
        VALUES (p_country, 'NFR', (SELECT MAX(ENTRY_NO) + 1 FROM ENTRIES WHERE APP_ID = 'NFR' AND COUNTRY_ID = p_country), 1, p_dateadopt, p_date_impl)
        RETURNING ENTRY_SID INTO o_sid;

        INSERT INTO ENTRIES_ADD_CFG(ENTRY_SID, APP_ID, IS_AMBITIOUS)
        VALUES (o_sid, 'NFR', 0);

        cfg_accessors.setEntryTextValue(o_sid, 3, p_description, NULL, p_ret);
        cfg_accessors.setEntryMultValue(o_sid, 1, p_ruletype, NULL, p_ret);
        setEntryEditStep(o_sid, 'NFR', 'NEW', p_round_sid, p_last_login, p_ret);

        COMMIT;
        generateSpecialLovs();
    END;

    ----------------------------------------------------------------------------
    -- @name createIfi
    -- @purpose create entry for IFI app
    ----------------------------------------------------------------------------
    PROCEDURE createIfi(p_country          IN  VARCHAR2
                       ,p_estabdate        IN  DATE
                       ,p_engname          IN  VARCHAR2
                       ,p_last_login       IN  VARCHAR2
                       ,p_round_sid        IN  NUMBER
                       ,o_sid              OUT NUMBER
                       ,p_ret              OUT NUMBER)
    IS
    BEGIN
        INSERT INTO ENTRIES(COUNTRY_ID, APP_ID, ENTRY_NO, ENTRY_VERSION, IMPL_DATE)
        VALUES (p_country, 'IFI', 1, 1, p_estabdate)
        RETURNING ENTRY_SID INTO o_sid;

        INSERT INTO ENTRIES_ADD_CFG(ENTRY_SID, APP_ID, DESCR, IS_MONITORING)
        VALUES (o_sid, 'IFI', p_engname, 0);

        cfg_accessors.setEntryTextValue(o_sid, 73, p_engname, NULL, p_ret);

        setEntryEditStep(o_sid, 'IFI', 'NEW', p_round_sid, p_last_login, p_ret);

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name createGbd
    -- @purpose create entry for GBD app
    ----------------------------------------------------------------------------
    PROCEDURE createGbd(p_country          IN  VARCHAR2
                       ,p_adoptdate        IN  DATE
                       ,p_entrydate        IN  DATE
                       ,p_engname          IN  VARCHAR2
                       ,p_last_login       IN  VARCHAR2
                       ,p_round_sid        IN  NUMBER
                       ,o_sid              OUT NUMBER
                       ,p_ret              OUT NUMBER)
    IS
    BEGIN
        INSERT INTO ENTRIES(COUNTRY_ID, APP_ID, ENTRY_NO, ENTRY_VERSION, APPRV_DATE, IMPL_DATE)
        VALUES (p_country, 'GBD', (SELECT MAX(ENTRY_NO) + 1 FROM ENTRIES WHERE APP_ID = 'GBD' AND COUNTRY_ID = p_country), 1, p_adoptdate, p_entrydate)
        RETURNING ENTRY_SID INTO o_sid;

        INSERT INTO ENTRIES_ADD_CFG(ENTRY_SID, APP_ID, DESCR)
        VALUES (o_sid, 'GBD', p_engname);

        setEntryEditStep(o_sid, 'GBD', 'NEW', p_round_sid, p_last_login, p_ret);

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name createMtbf
    -- @purpose create entry for MTBF app
    ----------------------------------------------------------------------------
    PROCEDURE createMtbf(p_country          IN  VARCHAR2
                       ,p_adoptdate        IN  DATE
                       ,p_entrydate        IN  DATE
                       ,p_engname          IN  VARCHAR2
                       ,p_last_login       IN  VARCHAR2
                       ,p_round_sid        IN  NUMBER
                       ,o_sid              OUT NUMBER
                       ,p_ret              OUT NUMBER)
    IS
    BEGIN
        INSERT INTO ENTRIES(COUNTRY_ID, APP_ID, ENTRY_NO, ENTRY_VERSION, APPRV_DATE, IMPL_DATE)
        VALUES (p_country, 'MTBF', ((SELECT MAX(ENTRY_NO) + 1 FROM ENTRIES WHERE APP_ID = 'MTBF' AND COUNTRY_ID = p_country)), 1, p_adoptdate, p_entrydate)
        RETURNING ENTRY_SID INTO o_sid;

        INSERT INTO ENTRIES_ADD_CFG(ENTRY_SID, APP_ID, DESCR)
        VALUES (o_sid, 'MTBF', p_engname);

        INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, ASSESSMENT_PERIOD)
        VALUES (o_sid, 216, p_engname, 0);

        setEntryEditStep(o_sid, 'MTBF', 'NEW', p_round_sid, p_last_login, p_ret);

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name generateSpecialLovs
    -- @purpose generates list of values for dynamic_lovs, dyn_sid = 2
    ----------------------------------------------------------------------------
    PROCEDURE generateSpecialLovs
    IS
        CURSOR c_dyn_lovs IS
            SELECT * FROM CFG_DYNAMIC_LOVS WHERE DYN_SID = 2;

        CURSOR c_entries (pi_app_id IN VARCHAR2, pi_lov_sid IN NUMBER) IS
            SELECT E.*, QV1.DESCR AS QV1, QV1.LOV_SID AS QV1_LOV, QV2.DESCR AS QV2, QV2.LOV_SID AS QV2_LOV,
                    QV3.DESCR AS QV3, QV3.LOV_SID AS QV3_LOV,
                    QV4.DESCR AS QV4, QV4.LOV_SID AS QV4_LOV
            FROM ENTRIES E
                ,(SELECT E.ENTRY_SID, L.DESCR, L.LOV_SID FROM ENTRY_CHOICES E, CFG_LOVS L WHERE  E.QUESTION_VERSION_SID = 1 AND E.RESPONSE = L.LOV_SID)  QV1
                ,(SELECT E.ENTRY_SID, L.DESCR, L.LOV_SID FROM ENTRY_CHOICES E, CFG_LOVS L WHERE  E.QUESTION_VERSION_SID = 2 AND E.RESPONSE = L.LOV_SID AND E.RESPONSE IN (
                    SELECT LOV_SID FROM CFG_COVERAGE_CONDITIONS))  QV2
                ,(SELECT E.ENTRY_SID, L.DESCR, L.LOV_SID FROM ENTRY_CHOICES E, CFG_LOVS L WHERE  E.QUESTION_VERSION_SID = 9 AND E.RESPONSE = L.LOV_SID)  QV3    
                ,(SELECT E.ENTRY_SID, L.DESCR, L.LOV_SID FROM ENTRY_CHOICES E, CFG_LOVS L WHERE  E.QUESTION_VERSION_SID = 10 AND E.RESPONSE = L.LOV_SID)  QV4 

            WHERE E.APP_ID = pi_app_id AND E.COUNTRY_ID = (SELECT DESCR FROM CFG_LOVS WHERE LOV_SID = pi_lov_sid)
            AND E.ENTRY_SID = QV1.ENTRY_SID
            AND E.ENTRY_SID = QV2.ENTRY_SID
            AND E.ENTRY_SID = QV3.ENTRY_SID
            AND E.ENTRY_SID = QV4.ENTRY_SID
            AND getAvailability(E.IMPL_DATE, E.reform_impl_date, E.reform_replaced_date, E.abolition_date) IN (
                                t_availability.C,
                                t_availability.F
                            )
            order by E.entry_no DESC;

        
        rec c_entries%ROWTYPE;
        l_text VARCHAR2(2000 BYTE);
        l_qv1_response  VARCHAR2(2000 byte);
        l_qv2_response VARCHAR2(2000 byte);
        l_qv3_response  VARCHAR2(2000 byte);
        l_qv4_response VARCHAR2(2000 byte);
        l_coverage  VARCHAR2(2000 byte);
        l_order_by  NUMBER;
        l_is_gg NUMBER;
        l_lov_type_id   VARCHAR2(300 BYTE);
        l_entry_descr VARCHAR2(4000 BYTE);

        l_prefix_sid NUMBER;
        l_prefix_monit NUMBER := 600;
        l_prefix_escc NUMBER := 700;

    BEGIN
        DELETE CFG_SPECIAL_LOVS;
        FOR r_lov IN c_dyn_lovs LOOP
            SELECT LOV_TYPE_ID
              INTO l_lov_type_id
              FROM CFG_LOV_TYPES
             WHERE LOV_TYPE_SID = r_lov.LOV_TYPE_SID;

            IF l_lov_type_id LIKE 'MONITRULES%' THEN
                l_prefix_sid := l_prefix_monit;
            ELSE
                l_prefix_sid := l_prefix_escc;
            END IF;
            l_order_by := 1;
            IF r_lov.COUNTRY_DEP = 1 THEN
                open c_entries(r_lov.APP_ID_DEP, r_lov.USED_LOV_SID);
                LOOP
                fetch c_entries INTO rec;
                EXIT WHEN c_entries%NOTFOUND;

                    l_qv1_response := rec.QV1;
                    l_qv2_response := rec.QV2;
                    l_qv3_response := rec.QV3;
                    l_qv4_response := rec.QV4;

                    SELECT RESPONSE INTO l_entry_descr FROM ENTRY_CHOICES WHERE QUESTION_VERSION_SID = 3 AND ENTRY_SID = rec.ENTRY_SID;

                    IF l_qv2_response LIKE '%General Government%' THEN
                        l_is_gg := 1;
                    END IF;

                    l_text := REPLACE(r_lov.DESCR, '{ENTRY_NO}', rec.ENTRY_NO);
                    l_text := REPLACE(l_text, '{QV1}', l_qv1_response);
                    l_text := REPLACE(l_text, '{QV2}', l_qv2_response);
                    l_text := REPLACE(l_text, '{COVERAGE}', CONCAT(TO_CHAR(ROUND(100 * getCoverage(rec.ENTRY_SID, rec.QV2_LOV), 1)), '%'));
                    l_text := REPLACE(l_text, '{QV3}', l_qv3_response);
                    l_text := REPLACE(l_text, '{QV4}', l_qv4_response);

                    INSERT INTO CFG_SPECIAL_LOVS(LOV_TYPE_SID, LOV_SID, DESCR, ORDER_BY, IS_GG, INFO_ICON, INFO_TXT)
                    VALUES (r_lov.LOV_TYPE_SID, TO_NUMBER(l_prefix_sid ||r_lov.USED_LOV_SID || l_order_by),  l_text, l_order_by, l_is_gg, 1, l_entry_descr);

                    l_order_by := l_order_by + 1;

                END LOOP;
                IF l_lov_type_id NOT LIKE 'MONITRULES%' THEN
                    INSERT INTO CFG_SPECIAL_LOVS(LOV_TYPE_SID, LOV_SID, DESCR, ORDER_BY, NEED_DET, CFG_TYPE, DETS_TXT)
                    values (r_lov.LOV_TYPE_SID, TO_NUMBER(l_prefix_sid ||r_lov.USED_LOV_SID|| l_order_by), 'Other involvement', l_order_by, 1, 3, 'Please specify your IFI`s role');
                    l_order_by := l_order_by + 1;
                    INSERT INTO CFG_SPECIAL_LOVS(LOV_TYPE_SID, LOV_SID, DESCR, ORDER_BY, NEED_DET, CFG_TYPE)
                    values (r_lov.LOV_TYPE_SID, TO_NUMBER(l_prefix_sid ||r_lov.USED_LOV_SID || l_order_by) , 'Not involved. The rules that the IFI monitors have escape clauses, but the IFI does not assess whether these should be triggered/extended/exited', l_order_by, NULL, 3);
                    l_order_by := l_order_by + 1;
                    INSERT INTO CFG_SPECIAL_LOVS(LOV_TYPE_SID, LOV_SID, DESCR, ORDER_BY, NEED_DET, CFG_TYPE)
                    values (r_lov.LOV_TYPE_SID, TO_NUMBER(l_prefix_sid ||r_lov.USED_LOV_SID || l_order_by), 'Not involved, as the rules that the IFI monitors do not have escape clauses', l_order_by, NULL, 3);
                ELSE
                    INSERT INTO CFG_SPECIAL_LOVS(LOV_TYPE_SID, LOV_SID, DESCR, ORDER_BY, NEED_DET, CFG_TYPE, DETS_TXT)
                    values (r_lov.LOV_TYPE_SID, TO_NUMBER(l_prefix_sid ||r_lov.USED_LOV_SID || l_order_by), 'Other', l_order_by, 1, 3, 'Please specify');
                    l_order_by := l_order_by + 1;
                    INSERT INTO CFG_SPECIAL_LOVS(LOV_TYPE_SID, LOV_SID, DESCR, ORDER_BY, NEED_DET, CFG_TYPE, DETS_TXT)
                    values (r_lov.LOV_TYPE_SID, TO_NUMBER(l_prefix_sid ||r_lov.USED_LOV_SID || l_order_by), 'Not involved', l_order_by, 4, 3, 'Please specify');
                END IF;
                CLOSE c_entries;
            END IF;
        END LOOP;
    END;

    ----------------------------------------------------------------------------
    -- @name abortReform
    -- @purpose abort created reform
    ----------------------------------------------------------------------------
    PROCEDURE abortReform(p_entry_sid          IN  NUMBER
                         ,p_last_login         IN  VARCHAR2
                         ,p_qst_id             IN  VARCHAR2
                         ,p_err               OUT  NUMBER
                         ,p_mess              OUT  VARCHAR2)
    IS
        l_ret               NUMBER;
        l_mess              VARCHAR2(4000);
        l_entry_no          NUMBER;
        l_parent_entry_sid  NUMBER;
        l_entry_version     NUMBER;
        l_country_id        VARCHAR2(2);
    BEGIN
        SELECT ENTRY_NO, ENTRY_VERSION, COUNTRY_ID
          INTO l_entry_no, l_entry_version, l_country_id
          FROM ENTRIES
         WHERE ENTRY_SID = p_entry_sid;

        IF l_entry_version > 1 THEN
            SELECT ENTRY_SID
              INTO l_parent_entry_sid
              FROM ENTRIES
             WHERE COUNTRY_ID = l_country_id
               AND ENTRY_NO = l_entry_no
               AND ENTRY_VERSION = l_entry_version - 1
               AND APP_ID = p_qst_id;
        END IF;

        DELETE ENTRY_EDIT_STEPS WHERE ENTRY_SID = p_entry_sid;
        DELETE ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid;
        DELETE ENTRIES_ADD_CFG WHERE ENTRY_SID = p_entry_sid;
        DELETE ENTRY_CHOICES_ADD_INFOS WHERE ENTRY_SID = p_entry_sid;
        DELETE TARGET_ENTRIES WHERE ENTRY_SID = p_entry_sid;
        DELETE ENTRIES WHERE ENTRY_SID = p_entry_sid;

        UPDATE ENTRIES
           SET REFORM_REPLACED_DATE = NULL
         WHERE ENTRY_SID = l_parent_entry_sid;

        UPDATE ENTRY_EDIT_STEPS
           SET EDIT_STEP_SID = 2
         WHERE ENTRY_SID = p_entry_sid;

        p_err := SQL%ROWCOUNT;
    END;

    PROCEDURE getVintageYears(p_app_id     IN VARCHAR2
                             ,p_round_year IN NUMBER
                             ,o_cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
         SELECT TO_NUMBER(SUBSTR(TABLE_NAME, -4))
           FROM USER_TABLES
          WHERE TABLE_NAME LIKE 'VINTAGE%'||p_app_id||'%'
            AND TO_NUMBER(SUBSTR(TABLE_NAME, -4)) != p_round_year
          ORDER BY SUBSTR(TABLE_NAME, -4) DESC;
    END;

END CFG_QUESTIONNAIRE;