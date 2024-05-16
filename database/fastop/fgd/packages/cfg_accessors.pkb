create or replace PACKAGE BODY CFG_ACCESSORS
AS
    /***
        NAME: CFG_ACCESSORS
        USAGE: Getters and Setters
    ***/
    t_availability CORE_TYPES.T_AVAILABILITY;

    FUNCTION convertToNumber ( p_val IN VARCHAR2 ) 
        RETURN NUMBER 
    IS
        l_ret NUMBER ;
        lc_ret VARCHAR2(100);
    BEGIN
    -- ne marche pas toujours
    --return(  vector.to_number( l_ret,'999999999999999D999999999','NLS_NUMERIC_CHARACTERS = ''.,''' ));
        lc_ret := p_val;
        lc_ret := trim( lc_ret );
        --lc_ret := replace( lc_ret, '.',',' ); ------- Commented by lefinsy for DFM - 2012/09/19
        lc_ret := replace( lc_ret, ',','.' ); ------- Added by lefinsy for DFM - 2012/09/19
        l_ret := to_number( lc_ret);
        return l_ret ;
    END convertToNumber;

    FUNCTION getValue( p_start_year IN NUMBER
                    , p_vector IN VARCHAR2 
                    , p_selected_year IN NUMBER
                    , p_selected_quarter IN NUMBER DEFAULT NULL
                    , p_per IN VARCHAR2 DEFAULT 'A') 
        RETURN NUMBER 
    IS
        l_ret VARCHAR2(100);
        l_delimiter VARCHAR2(10) := ',';
        l_comma_index  PLS_INTEGER;
        l_index        PLS_INTEGER := 1;
        l_selected_pos NUMBER := p_selected_year - p_start_year + 1;
    BEGIN
        dbms_output.put_line( 'sy='||p_start_year||'v:<'||p_vector||'>' );

        IF l_selected_pos >= 1 THEN

            IF l_selected_pos - l_index > 0 THEN
                l_index := INSTR(p_vector, l_delimiter, l_index, l_selected_pos - 1) + 1;
            END IF;

            IF l_index = 1 AND INSTR(p_vector, l_delimiter, l_index, l_selected_pos) = 0 AND l_selected_pos != 1 THEN
            l_ret := NULL;
            ELSE
                l_comma_index := INSTR(p_vector, l_delimiter, l_index, 1);

                IF l_comma_index = 0 THEN
                    l_comma_index := LENGTH(p_vector) + 1;
                END IF;

                l_ret := SUBSTR(p_vector, l_index, l_comma_index - l_index);
            END IF;

        ELSE
            l_ret := NULL;
        END IF;

        RETURN(  NVL(ROUND(convertToNumber( l_ret ), 2), 0));
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line( 'l_ret:'||l_ret||'sqlcode:'||sqlcode ); 
            RETURN NULL; -- lefinsy

    END getValue;



    -- FUNCTION getOG(pi_country_id VARCHAR2,
    --             pi_round_sid  NUMBER)
    --     RETURN number
    -- IS
    --     po_output_gap NUMBER;

    --     CURSOR c_values IS
    --     SELECT a.start_year 
    --         ,a.vector
    --         ,a.year
    --     FROM vw_ameco_indic_data a
    --                     JOIN indicators i
    --                     ON     a.indicator_sid = i.indicator_sid
    --                         AND i.indicator_id = '1.0.0.0.AVGDGP'
    --             WHERE     1 = 1
    --                     AND country_id = pi_country_id
    --                     AND round_sid = pi_round_sid;      

    --     l_ret NUMBER(9);
    -- BEGIN


    --     FOR r_values in c_values

    --     LOOP
    --     --dbms_output.put_line('Calculating OG value for start_year' || r_values.start_year);
    --     po_output_gap := getValue(r_values.start_year, r_values.vector, r_values.year );

    --     --dbms_output.put_line(l_ret);

    --     END LOOP;

    -- RETURN NVL(ROUND(po_output_gap, 2), 0);

    -- EXCEPTION
    --     WHEN OTHERS
    --     THEN
    --         dbms_output.put_line(SQLERRM);
    -- END;

    ----------------------------------------------------------------------------
    -- @name setEntrySingleValue - updates single question value(design/compliance)
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntrySingleValue(p_entry_sid             IN    NUMBER
                                 ,p_question_version_sid  IN    NUMBER
                                 ,p_value                 IN    VARCHAR2
                                 ,p_period_sid            IN    NUMBER DEFAULT 0
                                 ,o_res                   OUT   NUMBER)
    IS
        l_stmt VARCHAR2(2000 BYTE);
    BEGIN
        -- Try to update record if it already exists
        l_stmt := 'BEGIN UPDATE ENTRY_CHOICES ' ||
                  ' SET RESPONSE = :p_response' ||
                  ', LAST_UPDATE = TRUNC(SYSDATE)' ||
                  ' WHERE ENTRY_SID = :p_entry' ||
                  ' AND ASSESSMENT_PERIOD = :p_assessment' ||
                  ' AND QUESTION_VERSION_SID = :p_question; :res := SQL%ROWCOUNT; END;';

        EXECUTE IMMEDIATE l_stmt USING IN p_value, p_entry_sid, p_period_sid, p_question_version_sid, OUT o_res;
        -- If it does not exist, insert new record
        IF o_res = 0 THEN
            l_stmt := 'BEGIN INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, ASSESSMENT_PERIOD) ' ||
                      ' VALUES (:p_entry, :p_question, :p_response, :p_assessment); :res := SQL%ROWCOUNT; END;';

            EXECUTE IMMEDIATE l_stmt USING IN p_entry_sid, p_question_version_sid, p_value, p_period_sid, OUT o_res;
        END IF;
    END;

    ----------------------------------------------------------------------------
    -- @name deleteEntrySingleValue - deletes single question value(design/compliance)
    -- @return number of records deleted
    ----------------------------------------------------------------------------
    PROCEDURE deleteEntrySingleValue(p_entry_sid             IN    NUMBER
                                    ,p_question_version_sid  IN    NUMBER
                                    ,p_period_sid            IN    NUMBER DEFAULT 0
                                    ,o_res                   OUT   NUMBER)
    IS
        l_stmt VARCHAR2(2000 BYTE);
    BEGIN
        DELETE ENTRY_CHOICES
         WHERE ENTRY_SID = p_entry_sid
            AND QUESTION_VERSION_SID =  p_question_version_sid
            AND ASSESSMENT_PERIOD = p_period_sid;
        o_res := SQL%ROWCOUNT;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryQuestionDetail - set detail for a question
    ----------------------------------------------------------------------------
    PROCEDURE setEntryQuestionDetail(p_entry_sid              IN NUMBER
                                    ,p_question_version_sid   IN NUMBER
                                   , p_response               IN NUMBER
                                   , p_details                IN VARCHAR2
                                   , p_period_sid             IN NUMBER DEFAULT 0)
    IS
        l_stmt VARCHAR2(2000 BYTE);
        l_res NUMBER;
    BEGIN
        l_stmt := ' BEGIN UPDATE ENTRY_CHOICES ' ||
                  ' SET DETAILS = :dets ' ||
                  ', LAST_UPDATE = TRUNC(SYSDATE)' ||
                  ' WHERE ENTRY_SID = :entry ' ||
                  ' AND QUESTION_VERSION_SID = :question ' ||
                  ' AND RESPONSE = :response' ||
                  ' AND ASSESSMENT_PERIOD = :period; :res := SQL%ROWCOUNT; END;';
        dbms_output.put_line('l_stmt'||l_stmt);
        EXECUTE IMMEDIATE l_stmt USING IN p_details, p_entry_sid, p_question_version_sid, p_response, p_period_sid, OUT l_res;
        --If not updated then the table for details is target_entries
        IF l_res = 0 THEN
            l_stmt := ' BEGIN UPDATE TARGET_ENTRIES ' ||
                      ' SET DETAILS = :dets'  ||
                      ' WHERE ENTRY_SID = :entry ' ||
                      ' AND QUESTION_VERSION_SID = :question ' ||
                      ' AND RESPONSE_SID = :response; :res := SQL%ROWCOUNT; END;';
            EXECUTE IMMEDIATE l_stmt USING IN p_details, p_entry_sid, p_question_version_sid, p_response, OUT l_res;
        END IF;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryTextValue
    -- @return text value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntryTextValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     NUMBER
                               ,p_format_response       IN     NUMBER
                               ,p_round_year            IN     NUMBER
                               ,o_cur                   OUT    SYS_REFCURSOR)
    IS
        l_stmt VARCHAR2(1000 BYTE);
        l_accessor VARCHAR2(200 BYTE);
        l_response VARCHAR2(4000 BYTE);
    BEGIN
        BEGIN
         SELECT ACCESSOR
          INTO l_accessor
          FROM CFG_QUESTION_VERSIONS
         WHERE QUESTION_VERSION_SID = p_question_version_sid;
        EXCEPTION
          WHEN no_data_found THEN
            l_accessor := NULL;
        END;

        IF l_accessor IS NOT NULL THEN
            l_stmt := ' SELECT '|| l_accessor || ' AS RESPONSE FROM ENTRIES ' ||
                      ' WHERE ENTRY_SID = ' || p_entry_sid;
            EXECUTE IMMEDIATE l_stmt INTO l_response;
            OPEN o_cur FOR
                SELECT l_response AS RESPONSE FROM DUAL;
        ELSE
            OPEN o_cur FOR
                SELECT RESPONSE
                  FROM ENTRY_CHOICES
                 WHERE ENTRY_SID = p_entry_sid
                   AND ASSESSMENT_PERIOD = 0
                   AND QUESTION_VERSION_SID = p_question_version_sid;
        END IF;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryNumberValue
    -- @return number value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntryNumberValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     NUMBER
                               ,p_format_response       IN     NUMBER
                               ,p_round_year            IN     NUMBER
                               ,o_cur                   OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
                SELECT RESPONSE
                  FROM ENTRY_CHOICES
                 WHERE ENTRY_SID = p_entry_sid
                   AND ASSESSMENT_PERIOD = 0
                   AND QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntrySidValue
    -- @return text value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntrySidValue(p_entry_sid             IN     NUMBER
                              ,p_question_version_sid  IN     NUMBER
                              ,p_format_response       IN     NUMBER
                              ,p_round_year            IN     NUMBER
                              ,o_cur                   OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT TO_NUMBER(RESPONSE) AS RESPONSE
              FROM ENTRY_CHOICES
             WHERE ENTRY_SID = p_entry_sid
            --    AND ASSESSMENT_PERIOD = 0
               AND QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryMultValue
    -- @return text value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntryMultValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     NUMBER
                               ,p_format_response       IN     NUMBER
                               ,p_round_year            IN     NUMBER
                               ,o_cur                   OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT TO_NUMBER(RESPONSE_SID) AS RESPONSE
              FROM TARGET_ENTRIES
             WHERE ENTRY_SID = p_entry_sid
               AND QUESTION_VERSION_SID = p_question_version_sid
            UNION ALL
            SELECT TO_NUMBER(RESPONSE) AS RESPONSE
              FROM ENTRY_CHOICES
             WHERE ENTRY_SID = p_entry_sid
               AND ASSESSMENT_PERIOD = 0
               AND QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryDateValue
    -- @return date value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntryDateValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     VARCHAR2
                               ,p_format_response       IN     NUMBER
                               ,p_round_year            IN     NUMBER
                               ,o_cur                   OUT    SYS_REFCURSOR)
    IS
        l_stmt   VARCHAR2(2000 BYTE);
        l_format VARCHAR2(50 BYTE);
        l_accessor VARCHAR2(50 BYTE);
        l_value DATE;
    BEGIN
        IF p_format_response = 0 THEN
            l_format := 'YYYY-MM-DD';
        ELSE
            l_format := 'DD/MM/YYYY';
        END IF;

        SELECT ACCESSOR
          INTO l_accessor
          FROM CFG_QUESTION_VERSIONS
         WHERE QUESTION_VERSION_SID = p_question_version_sid;

        l_stmt := ' SELECT ' || l_accessor ||' AS RESPONSE ' ||
                  ' FROM ENTRIES ' ||
                  ' WHERE ENTRY_SID = ' || p_entry_sid;
        EXECUTE IMMEDIATE l_stmt INTO l_value;
        OPEN o_cur FOR
            SELECT TO_CHAR(l_value,l_format) AS RESPONSE FROM DUAL;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryAssessmentTextValue
    -- @return text value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntryAssessmentTextValue(p_entry_sid             IN     NUMBER
                                         ,p_question_version_sid  IN     NUMBER
                                         ,p_period_sid            IN     NUMBER
                                         ,o_cur                   OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT RESPONSE
              FROM ENTRY_CHOICES
             WHERE ENTRY_SID = p_entry_sid
               AND ASSESSMENT_PERIOD = NVL(p_period_sid, 0)
               AND QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryAssessmentNumberValue
    -- @return number value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntryAssessmentNumberValue(p_entry_sid             IN     NUMBER
                                         ,p_question_version_sid  IN     NUMBER
                                         ,p_period_sid            IN     NUMBER
                                         ,o_cur                   OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT RESPONSE
              FROM ENTRY_CHOICES
             WHERE ENTRY_SID = p_entry_sid
               AND ASSESSMENT_PERIOD = NVL(p_period_sid, 0)
               AND QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryAssessmentSidValue
    -- @return text value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntryAssessmentSidValue(p_entry_sid             IN     NUMBER
                                        ,p_question_version_sid  IN     NUMBER
                                        ,p_period_sid            IN     NUMBER DEFAULT 0
                                        ,o_cur                   OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT TO_NUMBER(RESPONSE) AS RESPONSE
              FROM ENTRY_CHOICES
             WHERE ENTRY_SID = p_entry_sid
               AND ASSESSMENT_PERIOD = NVL(p_period_sid, 0)
               AND QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryAssessmentMultValue
    -- @return text value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE getEntryAssessmentMultValue(p_entry_sid             IN     NUMBER
                                         ,p_question_version_sid  IN     NUMBER
                                         ,p_period_sid            IN     NUMBER DEFAULT 0
                                         ,o_cur                   OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT TO_NUMBER(RESPONSE) AS RESPONSE
              FROM ENTRY_CHOICES
             WHERE ENTRY_SID = p_entry_sid
               AND ASSESSMENT_PERIOD = NVL(p_period_sid, 0)
               AND QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getCurrentTargetValue
    -- @return current target value
    ----------------------------------------------------------------------------
    PROCEDURE getCurrentTargetValue(p_entry_sid             IN     NUMBER
                                   ,p_question_version_sid  IN     NUMBER
                                   ,p_format_response       IN     NUMBER
                                   ,p_round_year            IN     NUMBER
                                   ,o_cur                   OUT    SYS_REFCURSOR)
    IS
        l_target_unit VARCHAR2(4000 BYTE);
    BEGIN
        getTargetUnit(p_entry_sid, l_target_unit);

        OPEN o_cur FOR
            SELECT ' ' || to_char(VALUE) AS RESPONSE
              FROM TARGET_ENTRIES
             WHERE ENTRY_SID = p_entry_sid
               AND RESPONSE_SID = p_round_year - 1
            UNION ALL
            SELECT l_target_unit FROM DUAL;
    END;

    ----------------------------------------------------------------------------
    -- @name getTargetEntryConfig
    -- @return entry target configuration
    ----------------------------------------------------------------------------
    PROCEDURE getTargetEntryConfig(p_app_id     IN  VARCHAR2
                                  ,o_cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT APP_ID, DEPENDENT_QUESTION, YEARS_PREV_COUNT, YEAR_CURR_ROUND, YEARS_FORW_COUNT
            FROM TARGET_ENTRIES_CFG
            WHERE APP_ID = p_app_id;
    END;

    ----------------------------------------------------------------------------
    -- @name getTargetUnit
    -- @return entry target measurement unit
    ----------------------------------------------------------------------------
    PROCEDURE getTargetUnit(p_entry_sid     IN  NUMBER
                           ,o_target_unit   OUT VARCHAR2)
    IS
    BEGIN
        SELECT DECODE(L.DESCR, 'Other', EC.DETAILS, L.DESCR)
          INTO o_target_unit
          FROM ENTRY_CHOICES EC
              ,CFG_LOVS L
              ,ENTRIES E
         WHERE E.ENTRY_SID = EC.ENTRY_SID
           AND EC.ENTRY_SID = p_entry_sid
           AND EC.QUESTION_VERSION_SID = 10
           AND EC.RESPONSE = L.LOV_SID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_target_unit := NULL;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryTargetNAYears
    -- @return entry target not applicable years
    ----------------------------------------------------------------------------
    PROCEDURE getEntryTargetNAYears(p_entry_sid             IN  NUMBER
                                   ,p_question_version_sid  IN  NUMBER
                                   ,o_cur                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT RESPONSE_SID AS YEAR
              FROM TARGET_ENTRIES
             WHERE ENTRY_SID = p_entry_sid
               AND QUESTION_VERSION_SID = p_question_version_sid
               AND NOT_APPLICABLE = 1;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryResponseDetails
    -- @return response details for the responses which require details
    ----------------------------------------------------------------------------
    PROCEDURE getEntryResponseDetails(p_entry_sid            IN     NUMBER
                                     ,p_period_sid           IN     NUMBER
                                     ,p_question_version_sid IN     NUMBER
                                     ,o_cur                 OUT     SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT RESPONSE AS RESPONSE_SID, DETAILS as DESCR
              FROM ENTRY_CHOICES
             WHERE ENTRY_SID           = p_entry_sid
               AND QUESTION_VERSION_SID = p_question_version_sid
               AND ASSESSMENT_PERIOD = p_period_sid
               AND DETAILS IS NOT NULL;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryResponseValues
    -- @return response numeric values for the responses
    ----------------------------------------------------------------------------
    PROCEDURE getEntryResponseValues(p_entry_sid            IN     NUMBER
                                    ,p_period_sid           IN     NUMBER
                                    ,p_question_version_sid IN     NUMBER
                                    ,o_cur                 OUT     SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT RESPONSE_SID, VALUE AS NUMERIC_VALUE, NOT_APPLICABLE
              FROM TARGET_ENTRIES
             WHERE ENTRY_SID            = p_entry_sid
               AND QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryQuestionAdditionalInfo
    -- @return entry question additional info
    ----------------------------------------------------------------------------
    PROCEDURE getEntryQuestionAdditionalInfo(p_entry_sid            IN     NUMBER
                                            ,p_question_version_sid IN     NUMBER
                                            ,p_period_sid           IN     NUMBER
                                            ,o_cur                  OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT DESCR
              FROM ENTRY_CHOICES_ADD_INFOS
             WHERE ENTRY_SID = p_entry_sid
               AND QUESTION_VERSION_SID = p_question_version_sid
               AND PERIOD_SID = p_period_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryQuestionAdditionalInfo
    -- @return info about updated record
    ----------------------------------------------------------------------------
    PROCEDURE setEntryQuestionAdditionalInfo(p_entry_sid            IN     NUMBER
                                            ,p_question_version_sid IN     NUMBER
                                            ,p_info                 IN     VARCHAR2
                                            ,p_period_sid           IN     NUMBER
                                            ,o_res                  OUT    NUMBER)
    IS
    BEGIN
        IF LENGTH(p_info) = 0 THEN
            DELETE ENTRY_CHOICES_ADD_INFOS
             WHERE ENTRY_SID = p_entry_sid
               AND QUESTION_VERSION_SID = p_question_version_sid
               AND PERIOD_SID = p_period_sid;
            o_res := SQL%ROWCOUNT;
        ELSE
            -- Try to update record if it already exists
            UPDATE ENTRY_CHOICES_ADD_INFOS
               SET DESCR = p_info
             WHERE ENTRY_SID = p_entry_sid
               AND QUESTION_VERSION_SID = p_question_version_sid
               AND PERIOD_SID = p_period_sid;
            o_res := SQL%ROWCOUNT;
            -- If it does not exist, insert new record
            IF o_res = 0 THEN
                INSERT INTO ENTRY_CHOICES_ADD_INFOS(ENTRY_SID, QUESTION_VERSION_SID, DESCR, PERIOD_SID)
                VALUES (p_entry_sid, p_question_version_sid, p_info, p_period_sid);
                o_res := SQL%ROWCOUNT;
            END IF;
        END IF;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryComplianceValue
    -- @return compliance value of specific entry
    ----------------------------------------------------------------------------
    PROCEDURE getEntryComplianceValue(p_entry_sid             IN     NUMBER
                                     ,p_period_sid            IN     NUMBER
                                     ,o_cur                   OUT    SYS_REFCURSOR)
    IS
        l_comp_assessment NUMBER := 17;
    BEGIN
        OPEN o_cur FOR
            SELECT DETAILS AS VALUE
              FROM ENTRY_CHOICES
             WHERE ENTRY_SID = p_entry_sid
               AND QUESTION_VERSION_SID IN (SELECT QUESTION_VERSION_SID FROM CFG_QUESTION_VERSIONS WHERE QUESTION_TYPE_SID = l_comp_assessment)
               AND ASSESSMENT_PERIOD = p_period_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name getEntryLinkableEntries
    -- @return linkable entries: SIDs and labels
    ----------------------------------------------------------------------------
    PROCEDURE getEntryLinkableEntries(p_entry_sid IN  NUMBER
                                     ,o_cur       OUT SYS_REFCURSOR)
    IS
        l_sectors_type VARCHAR2(200 BYTE) := 'RSECTORS';
    BEGIN
        OPEN o_cur FOR
            WITH
                ENTRY_SECTORS
                AS
                    (SELECT R.ENTRY_SID
                          , R.ENTRY_VERSION
                          , R.ENTRY_NO as ENTRY_NUMBER
                          , R.COUNTRY_ID
                          , RS.RESPONSE_SID AS SECTOR_SID
                          , S.CFG_TYPE
                       FROM ENTRIES  R
                           ,ENTRIES R2
                           ,TARGET_ENTRIES RS
                           ,CFG_LOVS S
                      WHERE R2.ENTRY_SID = p_entry_sid
                        AND R2.COUNTRY_ID = R.COUNTRY_ID
                        AND RS.ENTRY_SID = R.ENTRY_SID
                        AND S.LOV_SID = RS.RESPONSE_SID
                        AND S.LOV_ID IS NOT NULL
                        AND cfg_questionnaire.getAvailability(R.IMPL_DATE
                                                             ,R.REFORM_IMPL_DATE
                                                             ,R.REFORM_REPLACED_DATE
                                                             ,R.ABOLITION_DATE) =
                            t_availability.C)
                SELECT DISTINCT RS2.ENTRY_SID
                               ,RS2.ENTRY_VERSION
                               ,RS2.ENTRY_NUMBER
                               ,RS2.ENTRY_SID VALUE
                           FROM ENTRY_SECTORS RS1
                               ,ENTRY_SECTORS RS2
                          WHERE RS1.SECTOR_SID = RS2.SECTOR_SID
                            AND RS1.ENTRY_SID  = p_entry_sid
                            AND RS2.ENTRY_SID != p_entry_sid
                ORDER BY RS2.ENTRY_NUMBER;


    END;

    ----------------------------------------------------------------------------
    -- @name getLovId
    -- @return lovId based on lov_sid
    ----------------------------------------------------------------------------
    PROCEDURE getLovId(p_lov_sid        IN  NUMBER,
                       o_res            OUT VARCHAR2)
    IS
    BEGIN
        SELECT LOV_ID INTO o_res FROM CFG_LOVS WHERE LOV_SID =  p_lov_sid;               
    END;

    ----------------------------------------------------------------------------
    -- @name deleteEntryQuestionValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE deleteEntryQuestionValue(p_entry_sid            IN     NUMBER
                                      ,p_question_version_sid IN     NUMBER
                                      ,p_value                IN     VARCHAR2 DEFAULT NULL
                                      ,p_period_sid           IN     NUMBER DEFAULT 0
                                      ,o_res                  OUT    NUMBER)
    IS
        l_stmt      VARCHAR2(1024);
        l_target    NUMBER;
    BEGIN

        IF p_value IS NOT NULL THEN
            -- Find associated target question if exists
            BEGIN
                SELECT QV.QUESTION_VERSION_SID
                    INTO l_target
                    FROM CFG_QUESTION_VERSIONS QV
                    WHERE QV.MASTER_SID = p_question_version_sid;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            l_stmt := ' BEGIN DELETE FROM ENTRY_CHOICES ' ||
                        ' WHERE ENTRY_SID = :p_entry ' ||
                        ' AND QUESTION_VERSION_SID = :p_question ' ||
                        ' AND RESPONSE = :p_response ' ||
                        ' AND ASSESSMENT_PERIOD = :p_period' ||
                        '; :res := SQL%ROWCOUNT; END;';
            EXECUTE IMMEDIATE l_stmt USING IN p_entry_sid, p_question_version_sid, p_value, p_period_sid, OUT o_res;

            IF l_target IS NOT NULL THEN
                DELETE FROM TARGET_ENTRIES
                WHERE ENTRY_SID = p_entry_sid
                    AND QUESTION_VERSION_SID = l_target
                    AND RESPONSE_SID = p_value;
            END IF;

            COMMIT;
        ELSE
            l_stmt := ' BEGIN DELETE FROM ENTRY_CHOICES ' ||
                        ' WHERE ENTRY_SID = :p_entry ' ||
                        ' AND QUESTION_VERSION_SID = :p_question ' ||
                        ' AND ASSESSMENT_PERIOD = :p_period' ||
                        '; :res := SQL%ROWCOUNT; END;';
            EXECUTE IMMEDIATE l_stmt USING IN p_entry_sid, p_question_version_sid, p_period_sid, OUT o_res;
            COMMIT;
        END IF;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryDateValue
    -- @return date value of specific entry question
    ----------------------------------------------------------------------------
    PROCEDURE setEntryDateValue(p_entry_sid             IN     NUMBER
                               ,p_question_version_sid  IN     NUMBER
                               ,p_value                 IN     VARCHAR2
                               ,p_details               IN     VARCHAR2
                               ,o_res                  OUT     NUMBER)
    IS
        l_stmt VARCHAR2(2000 BYTE);
        l_accessor VARCHAR2(500 BYTE);
    BEGIN
        SELECT ACCESSOR
          INTO l_accessor
          FROM CFG_QUESTION_VERSIONS
         WHERE QUESTION_VERSION_SID = p_question_version_sid;
        l_stmt := ' BEGIN UPDATE ENTRIES ' ||
                  ' SET ' || l_accessor || ' =  TO_DATE(' || CHR(39)  || p_value || chr(39) || ',' || chr(39) || 'yyyy-mm-dd' || chr(39) || ')' ||
                  ' WHERE ENTRY_SID = ' || p_entry_sid || '; :res := SQL%ROWCOUNT; END;';
        EXECUTE IMMEDIATE l_stmt USING OUT o_res;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntrySidValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntrySidValue(p_entry_sid              IN     NUMBER
                              ,p_question_version_sid   IN     NUMBER
                              ,p_value                  IN     VARCHAR2
                              ,p_details                IN     VARCHAR2
                              ,o_res                    OUT    NUMBER)
    IS
    BEGIN
        setEntrySingleValue(p_entry_sid
                           ,p_question_version_sid
                           ,p_value
                           ,0
                           ,o_res);


        setEntryQuestionDetail(p_entry_sid
                            ,p_question_version_sid
                            ,p_value
                            ,p_details);

    END;

    ----------------------------------------------------------------------------
    -- @name setEntryTextValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryTextValue(p_entry_sid              IN     NUMBER
                               ,p_question_version_sid   IN     NUMBER
                               ,p_value                  IN     VARCHAR2
                               ,p_details                IN     VARCHAR2
                               ,o_res                    OUT    NUMBER)
    IS
        l_stmt VARCHAR2(2000 BYTE);
        l_accessor VARCHAR2(200 BYTE);
    BEGIN
        SELECT ACCESSOR
          INTO l_accessor
          FROM CFG_QUESTION_VERSIONS
         WHERE QUESTION_VERSION_SID = p_question_version_sid;

        IF l_accessor IS NULL THEN
            IF p_value IS NULL THEN
                deleteEntrySingleValue(p_entry_sid
                                      ,p_question_version_sid
                                      ,0
                                      ,o_res);
            ELSE
                setEntrySingleValue(p_entry_sid
                                   ,p_question_version_sid
                                   ,p_value
                                   ,0
                                   ,o_res);

            END IF;
        ELSE
            l_stmt := ' BEGIN UPDATE ENTRIES ' ||
                      ' SET ' || l_accessor || ' = :val' ||
                      ' WHERE ENTRY_SID = :entry' ||
                      '; :res := SQL%ROWCOUNT; END;';
            EXECUTE IMMEDIATE l_stmt USING IN p_value, p_entry_sid, OUT o_res;

        END IF;

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryNumberValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryNumberValue(p_entry_sid              IN     NUMBER
                               ,p_question_version_sid   IN     NUMBER
                               ,p_value                  IN     VARCHAR2
                               ,p_details                IN     VARCHAR2
                               ,o_res                    OUT    NUMBER)
    IS
        l_stmt VARCHAR2(2000 BYTE);
        l_accessor VARCHAR2(200 BYTE);
    BEGIN
        SELECT ACCESSOR
          INTO l_accessor
          FROM CFG_QUESTION_VERSIONS
         WHERE QUESTION_VERSION_SID = p_question_version_sid;

        IF l_accessor IS NULL THEN
            IF p_value IS NULL THEN
                deleteEntrySingleValue(p_entry_sid
                                      ,p_question_version_sid
                                      ,0
                                      ,o_res);
            ELSE
                setEntrySingleValue(p_entry_sid
                                   ,p_question_version_sid
                                   ,p_value
                                   ,0
                                   ,o_res);

            END IF;
        END IF;

        COMMIT;
    END;                               

    ----------------------------------------------------------------------------
    -- @name setEntryMultValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryMultValue(p_entry_sid              IN     NUMBER
                               ,p_question_version_sid   IN     NUMBER
                               ,p_value                  IN     VARCHAR2
                               ,p_details                IN     VARCHAR2
                               ,o_res                    OUT    NUMBER)
    IS
        l_stmt          VARCHAR2(1024);
        l_response_all  NUMBER;
        l_response_exc  NUMBER;
        l_response_type NUMBER;
        l_target        NUMBER;

    BEGIN
        -- Try to update record if it already exists
        l_stmt := 'BEGIN UPDATE ENTRY_CHOICES ' ||
                  ' SET DETAILS = :dets' ||
                  ', LAST_UPDATE = TRUNC(SYSDATE)' ||
                  ' WHERE ENTRY_SID = :entry' ||
                  ' AND QUESTION_VERSION_SID = :question ' ||
                  ' AND TO_NUMBER(RESPONSE) = :val' ||
                  ' AND ASSESSMENT_PERIOD = 0 ' ||
                  '; :res := SQL%ROWCOUNT; END;';

        EXECUTE IMMEDIATE l_stmt USING IN p_details, p_entry_sid, p_question_version_sid, p_value, OUT o_res;
        -- If it does not exist, insert new record
        IF o_res = 0 THEN
            l_stmt := ' BEGIN INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS, ASSESSMENT_PERIOD) VALUES ' ||
                      ' (:entry , :question, :val, :dets, 0)' ||
                      '; :res := SQL%ROWCOUNT; END;';
            EXECUTE IMMEDIATE l_stmt USING IN p_entry_sid, p_question_version_sid, p_value, p_details, OUT o_res;
        END IF;

            -- Find associated target question if exists
            BEGIN
                SELECT QV.QUESTION_VERSION_SID
                    INTO l_target
                    FROM CFG_QUESTION_VERSIONS QV
                    WHERE QV.MASTER_SID = p_question_version_sid;
            EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
            END;

            -- Get response type 'All' value
            SELECT RT.CFG_TYPE
                INTO l_response_all
                FROM CFG_RESPONSE_TYPES RT
                WHERE RT.DESCR = 'All';

            -- Get response type 'Exclusion' value
            SELECT RT.CFG_TYPE
                INTO l_response_exc
                FROM CFG_RESPONSE_TYPES RT
                WHERE RT.DESCR = 'Exclusion';

            -- Get response type of inserted response
            BEGIN
                SELECT RC.CFG_TYPE
                  INTO l_response_type
                  FROM CFG_LOVS RC
                 WHERE RC.LOV_SID = TO_NUMBER(p_value);
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
            IF l_response_type IS NULL THEN
                BEGIN
                SELECT DISTINCT RC.CFG_TYPE
                  INTO l_response_type
                  FROM CFG_SPECIAL_LOVS RC
                 WHERE RC.LOV_SID = TO_NUMBER(p_value);
                EXCEPTION
                    WHEN OTHERS THEN
                        l_response_type := NULL;
                END;
            END IF;

            IF l_response_type = l_response_all THEN
            -- If response type is 'All' delete other responses
                DELETE FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                        AND QUESTION_VERSION_SID = p_question_version_sid
                        AND TO_NUMBER(RESPONSE) != p_value;
                IF l_target IS NOT NULL THEN
                    DELETE FROM TARGET_ENTRIES
                        WHERE ENTRY_SID = p_entry_sid
                          AND QUESTION_VERSION_SID = l_target;
                END IF;
                COMMIT;
            ELSIF l_response_type = l_response_exc THEN
            -- If response type is 'Exclusion' delete only the exclusions and the All if it exists
                DELETE FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                        AND QUESTION_VERSION_SID = p_question_version_sid
                        AND (TO_NUMBER(RESPONSE) IN (SELECT COND_LOV_SID FROM CFG_CHOICES_CONDITIONS WHERE LOV_SID = p_value)
                         OR TO_NUMBER(RESPONSE) IN (SELECT LOV_SID FROM CFG_LOVS WHERE CFG_TYPE = l_response_all));
            ELSE
            -- Otherwise delete response type 'All' if it exists
                DELETE FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                        AND QUESTION_VERSION_SID = p_question_version_sid
                        AND (TO_NUMBER(RESPONSE) IN (SELECT LOV_SID FROM CFG_LOVS WHERE CFG_TYPE = l_response_all)
                         OR TO_NUMBER(RESPONSE) IN (SELECT TO_NUMBER(LOV_SID) FROM CFG_SPECIAL_LOVS WHERE CFG_TYPE = l_response_all));
                IF l_target IS NOT NULL THEN
                    DELETE FROM TARGET_ENTRIES
                        WHERE ENTRY_SID = p_entry_sid
                          AND QUESTION_VERSION_SID = l_target
                          AND (RESPONSE_SID IN (SELECT LOV_SID FROM CFG_LOVS WHERE CFG_TYPE = l_response_all)
                            OR RESPONSE_SID IN (SELECT TO_NUMBER(LOV_SID) FROM CFG_SPECIAL_LOVS WHERE CFG_TYPE = l_response_all));
                END IF;
            END IF;
            COMMIT;

    END;

    ---------------------------------------------------------------------------
    -- @name setEntryAssessmentTextValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryAssessmentTextValue(p_entry_sid               IN      NUMBER
                                         ,p_question_version_sid    IN      NUMBER
                                         ,p_value                   IN      VARCHAR2
                                         ,p_period_sid              IN      NUMBER
                                         ,p_details                 IN      VARCHAR2
                                         ,o_res                     OUT     NUMBER)
    IS
    BEGIN
        IF p_value IS NULL THEN
            deleteEntrySingleValue(p_entry_sid
                                  ,p_question_version_sid
                                  ,p_period_sid
                                  ,o_res);
        ELSE
            setEntrySingleValue(p_entry_sid
                               ,p_question_version_sid
                               ,p_value
                               ,p_period_sid
                               ,o_res);
        END IF;

        COMMIT;
    END;

    ---------------------------------------------------------------------------
    -- @name setEntryAssessmentNumberValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryAssessmentNumberValue(p_entry_sid               IN      NUMBER
                                         ,p_question_version_sid    IN      NUMBER
                                         ,p_value                   IN      VARCHAR2
                                         ,p_period_sid              IN      NUMBER
                                         ,p_details                 IN      VARCHAR2
                                         ,o_res                     OUT     NUMBER)
    IS
    BEGIN
        IF p_value IS NULL THEN
            deleteEntrySingleValue(p_entry_sid
                                  ,p_question_version_sid
                                  ,p_period_sid
                                  ,o_res);
        ELSE
            setEntrySingleValue(p_entry_sid
                               ,p_question_version_sid
                               ,p_value
                               ,p_period_sid
                               ,o_res);
        END IF;

        COMMIT;
    END;                                         

    ----------------------------------------------------------------------------
    -- @name setEntryAssessmentSidValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryAssessmentSidValue(p_entry_sid               IN      NUMBER
                                        ,p_question_version_sid    IN      NUMBER
                                        ,p_value                   IN      VARCHAR2
                                        ,p_period_sid              IN      NUMBER
                                        ,p_details                 IN      VARCHAR2
                                        ,o_res                     OUT     NUMBER)
    IS
    BEGIN
        setEntrySingleValue(p_entry_sid
                           ,p_question_version_sid
                           ,p_value
                           ,p_period_sid
                           ,o_res);


        setEntryQuestionDetail(p_entry_sid
                                ,p_question_version_sid
                                ,p_value
                                ,p_details
                                ,p_period_sid);

        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryAssessmentMultValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryAssessmentMultValue(p_entry_sid               IN      NUMBER
                                         ,p_question_version_sid    IN      NUMBER
                                         ,p_value                   IN      VARCHAR2
                                         ,p_period_sid              IN      NUMBER
                                         ,p_details                 IN      VARCHAR2
                                         ,o_res                     OUT     NUMBER)
    IS
        l_stmt          VARCHAR2(4000 BYTE);
        l_response_all  NUMBER;
        l_response_type NUMBER;
        l_response_exc  NUMBER;
    BEGIN
        -- Try to update record if it already exists
        l_stmt := 'BEGIN UPDATE ENTRY_CHOICES ' ||
                  ' SET DETAILS = :dets' ||
                  ', LAST_UPDATE = TRUNC(SYSDATE)' ||
                  ' WHERE ENTRY_SID = :entry' ||
                  ' AND QUESTION_VERSION_SID = :question ' ||
                  ' AND TO_NUMBER(RESPONSE) = :val' ||
                  ' AND ASSESSMENT_PERIOD = :per ' ||
                  '; :res := SQL%ROWCOUNT; END;';
        EXECUTE IMMEDIATE l_stmt USING IN p_details, p_entry_sid, p_question_version_sid, p_value, p_period_sid, OUT o_res;
        -- If it does not exist, insert new record
        IF o_res = 0 THEN
            l_stmt := ' BEGIN INSERT INTO ENTRY_CHOICES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE, DETAILS, ASSESSMENT_PERIOD) VALUES ' ||
                      ' (:entry , :question, :val, :dets, :per)' ||
                      '; :res := SQL%ROWCOUNT; END;';
            EXECUTE IMMEDIATE l_stmt USING IN p_entry_sid, p_question_version_sid, p_value, p_details, p_period_sid, OUT o_res;
        END IF;
        -- Get response type 'All' value
            SELECT RT.CFG_TYPE
                INTO l_response_all
                FROM CFG_RESPONSE_TYPES RT
                WHERE RT.DESCR = 'All';

            -- Get response type 'Exclusion' value
            SELECT RT.CFG_TYPE
                INTO l_response_exc
                FROM CFG_RESPONSE_TYPES RT
                WHERE RT.DESCR = 'Exclusion';

            -- Get response type of inserted response
            BEGIN
                SELECT RC.CFG_TYPE
                  INTO l_response_type
                  FROM CFG_LOVS RC
                  WHERE RC.LOV_SID = TO_NUMBER(p_value);
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
            IF l_response_type IS NULL THEN
                BEGIN
                SELECT DISTINCT RC.CFG_TYPE
                  INTO l_response_type
                  FROM CFG_SPECIAL_LOVS RC
                 WHERE RC.LOV_SID = TO_NUMBER(p_value);
                EXCEPTION
                    WHEN OTHERS THEN
                        l_response_type := NULL;
                END;
            END IF;

            IF l_response_type = l_response_all THEN
            -- If response type is 'All' delete other responses
                DELETE FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                        AND QUESTION_VERSION_SID = p_question_version_sid
                        AND ASSESSMENT_PERIOD = p_period_sid
                        AND TO_NUMBER(RESPONSE) != p_value;
            ELSIF l_response_type = l_response_exc THEN
            -- If response type is 'Exclusion' delete only the exclusions
                DELETE FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                        AND QUESTION_VERSION_SID = p_question_version_sid
                        AND ASSESSMENT_PERIOD = p_period_sid
                        AND (TO_NUMBER(RESPONSE) IN (SELECT COND_LOV_SID FROM CFG_CHOICES_CONDITIONS WHERE LOV_SID = p_value)
                         OR TO_NUMBER(RESPONSE) IN (SELECT LOV_SID FROM CFG_LOVS WHERE CFG_TYPE = l_response_all));
            ELSE
            -- Otherwise delete response type 'All' if it exists
                DELETE FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                        AND QUESTION_VERSION_SID = p_question_version_sid
                        AND ASSESSMENT_PERIOD = p_period_sid
                        AND (TO_NUMBER(RESPONSE) IN (SELECT LOV_SID FROM CFG_LOVS WHERE CFG_TYPE = l_response_all)
                         OR TO_NUMBER(RESPONSE) IN (SELECT TO_NUMBER(LOV_SID) FROM CFG_SPECIAL_LOVS WHERE CFG_TYPE = l_response_all));
            END IF;
            COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryQuestionResponseValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryQuestionResponseValue(p_entry_sid               IN      NUMBER
                                           ,p_question_version_sid    IN      NUMBER
                                           ,p_value                   IN      VARCHAR2
                                           ,p_response_sid            IN      NUMBER
                                           ,o_res                     OUT     NUMBER)
    IS
        l_stmt VARCHAR2(1000 BYTE);
    BEGIN
        -- Try to update record if it already exists
        l_stmt := ' BEGIN UPDATE TARGET_ENTRIES '            ||
                  '  SET VALUE = :val'                       ||
                  ' WHERE QUESTION_VERSION_SID = :question'  ||
                  ' AND ENTRY_SID = :entry'                  ||
                  ' AND RESPONSE_SID = :resp; :res := SQL%ROWCOUNT; END;';
        EXECUTE IMMEDIATE  l_stmt USING IN p_value, p_question_version_sid, p_entry_sid, p_response_sid, OUT o_res;

        -- If it does not exist, insert new record
        IF o_res = 0 THEN
            l_stmt := ' BEGIN INSERT INTO TARGET_ENTRIES (ENTRY_SID, QUESTION_VERSION_SID, RESPONSE_SID, VALUE) ' ||
                        ' VALUES (:entry, :question, :resp, :val); :res := SQL%ROWCOUNT; END;';
            EXECUTE IMMEDIATE l_stmt USING p_entry_sid, p_question_version_sid, p_response_sid, p_value, OUT o_res;
        END IF;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryComplianceValue - sets entry compliance value
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryComplianceValue(p_entry_sid            IN     NUMBER
                                     ,p_question_version_sid IN     NUMBER
                                     ,p_period_sid           IN     NUMBER
                                     ,p_value                IN     NUMBER
                                     ,o_res                  OUT    NUMBER)
    IS
    BEGIN
        UPDATE ENTRY_CHOICES
           SET DETAILS = NVL(p_value, 0)
         WHERE ENTRY_SID = p_entry_sid
           AND QUESTION_VERSION_SID = p_question_version_sid
           AND ASSESSMENT_PERIOD = p_period_sid;
        o_res := SQL%ROWCOUNT;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name setEntryTargetNAYear - sets entry target NA years
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE setEntryTargetNAYear(p_entry_sid              IN     NUMBER
                                  ,p_question_version_sid   IN     NUMBER
                                  ,p_year                   IN     NUMBER
                                  ,p_na                     IN     NUMBER
                                  ,o_res                    OUT    NUMBER)
    IS
        l_na NUMBER;
    BEGIN
        IF p_na = 1 THEN
            l_na := 1;
        ELSE
            l_na := NULL;
        END IF;

        UPDATE TARGET_ENTRIES
           SET NOT_APPLICABLE = l_na
              ,VALUE = NULL
         WHERE ENTRY_SID = p_entry_sid
           AND QUESTION_VERSION_SID = p_question_version_sid
           AND RESPONSE_SID = p_year;
        o_res := SQL%ROWCOUNT;

        IF o_res = 0 THEN
            INSERT INTO TARGET_ENTRIES(ENTRY_SID, QUESTION_VERSION_SID, RESPONSE_SID, NOT_APPLICABLE)
            VALUES (p_entry_sid, p_question_version_sid, p_year, l_na);

            o_res := SQL%ROWCOUNT;
        END IF;

        COMMIT;

    END;

    ----------------------------------------------------------------------------
    -- @name getComplianceOptions - gets compliant options for the entry
    -- @return compiance options
    ----------------------------------------------------------------------------
    PROCEDURE getComplianceOptions(p_entry_sid   IN     NUMBER
                                  ,p_period_sid  IN     NUMBER
                                  ,p_round_sid      IN     NUMBER
                                  ,p_year           IN     NUMBER
                                  ,p_period_descr   IN     VARCHAR2
                                  ,o_cur         OUT    SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT DISTINCT C.COMPLIANCE_SOURCE_SID, CS.DESCR
              FROM CFG_COMPLIANCE_REFS C
                  ,CFG_COMPLIANCE_SOURCES CS
             WHERE CS.COMPLIANCE_SOURCE_SID = C.COMPLIANCE_SOURCE_SID
               AND C.BUDG_AGG_SID = (
                   SELECT DISTINCT RESPONSE
                     FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                      AND QUESTION_VERSION_SID = (
                            SELECT QUESTION_VERSION_SID
                              FROM CFG_COMPLIANCE_QUESTIONS
                             WHERE COMPLIANCE_ATTR = 'BUDG_AGG_SID'
                              )
               )
               AND C.TARGET_UNIT_SID = (
                   SELECT DISTINCT  RESPONSE
                     FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                      AND QUESTION_VERSION_SID = (
                            SELECT QUESTION_VERSION_SID
                              FROM CFG_COMPLIANCE_QUESTIONS
                             WHERE COMPLIANCE_ATTR = 'TARGET_UNIT_SID'
                              )
               )
               AND C.COVERAGE_SID IN (
                    SELECT DISTINCT RESPONSE
                     FROM ENTRY_CHOICES
                    WHERE ENTRY_SID = p_entry_sid
                      AND QUESTION_VERSION_SID = (
                            SELECT QUESTION_VERSION_SID
                              FROM CFG_COMPLIANCE_QUESTIONS
                             WHERE COMPLIANCE_ATTR = 'COVERAGE_SID'
                              )
               )
               AND C.PERIOD_SID = p_period_sid
               ;
    END;

    ----------------------------------------------------------------------------
    -- @name getComplianceValues - gets compliance option values for the entry
    -- @return compiance options
    ----------------------------------------------------------------------------
    -- PROCEDURE getComplianceValues(p_entry_sid       IN     NUMBER
    --                              ,p_period_sid      IN     NUMBER
    --                              ,p_round_sid       IN     NUMBER
    --                              ,p_year            IN     NUMBER
    --                              ,p_period_descr    IN     VARCHAR2
    --                              ,o_cur             OUT    SYS_REFCURSOR)
    -- IS
    --     l_year NUMBER(4);
    --     l_budg_question NUMBER;
    --     l_entry_type_question NUMBER;
    --     l_target_question NUMBER;
    --     l_coverage_question NUMBER;
    -- BEGIN
    --     CORE_GETTERS.getRoundYear(CORE_GETTERS.getLatestApplicationRound('DBP', CORE_GETTERS.getCurrentRoundSid('FGD')), l_year);

    --     SELECT QUESTION_VERSION_SID
    --       INTO l_entry_type_question
    --       FROM CFG_COMPLIANCE_QUESTIONS
    --      WHERE COMPLIANCE_ATTR = 'ENTRY_TYPE_SID';

    --     SELECT QUESTION_VERSION_SID
    --       INTO l_budg_question
    --       FROM CFG_COMPLIANCE_QUESTIONS
    --      WHERE COMPLIANCE_ATTR = 'BUDG_AGG_SID';

    --     SELECT QUESTION_VERSION_SID
    --       INTO l_target_question
    --       FROM CFG_COMPLIANCE_QUESTIONS
    --      WHERE COMPLIANCE_ATTR = 'TARGET_UNIT_SID';

    --     SELECT QUESTION_VERSION_SID
    --       INTO l_coverage_question
    --       FROM CFG_COMPLIANCE_QUESTIONS
    --      WHERE COMPLIANCE_ATTR = 'COVERAGE_SID';
    --     OPEN o_cur FOR
    --         SELECT COMPLIANCE_SOURCE_SID,
    --                ROUND(SUM(TO_NUMBER(REGEXP_SUBSTR(VALUE_N, '^-?\d*(\.\d*)?$'))), 2) AS VALUE
    --         FROM (
    --           SELECT CR.COMPLIANCE_SOURCE_SID
    --                 ,C.VALUE_N
    --                 ,RANK() OVER (ORDER BY C.VERSION desc) version_rank
    --             FROM CFG_COMPLIANCE_REFS CR
    --                  JOIN CFG_COMPLIANCE_SOURCES CS
    --                      ON CS.COMPLIANCE_SOURCE_SID = CR.COMPLIANCE_SOURCE_SID
    --                  JOIN VW_GD_CELLS C
    --                      ON C.LINE_ID = CR.LINE_ID
    --                  JOIN CFG_LOVS L ON L.LOV_SID = CR.TARGET_UNIT_SID
    --                  JOIN ENTRIES R
    --                     ON R.COUNTRY_ID = C.COUNTRY_ID
    --                  JOIN APPLICATIONS A ON A.APP_SID = CS.APP_SID
    --                  JOIN VW_GD_CTY_GRIDS CG ON CG.CTY_GRID_SID = C.CTY_GRID_SID
    --            WHERE C.ROUND_SID = p_round_sid
    --              AND C.DATA_TYPE_ID =
    --                  (CASE
    --                       WHEN L.DESCR LIKE '%Absolute%' THEN 'LEVELS'
    --                       WHEN L.DESCR LIKE '%\%%GDP%' THEN 'GDP'
    --                       ELSE 'GDP'
    --                   END)
    --              AND C.YEAR_VALUE =
    --                  (CASE
    --                       WHEN A.APP_ID = 'FGD' THEN -1
    --                       WHEN A.APP_ID = 'DBP' THEN 1
    --                       ELSE -1
    --                   END)
    --              AND p_year = l_year + CS.YEAR
    --              AND p_period_descr = (CASE
    --                                         WHEN A.APP_ID = 'SCP' THEN 'Spring'
    --                                         WHEN A.APP_ID = 'DBP' THEN 'Autumn'
    --                                         ELSE 'Spring'
    --                                      END)
    --              AND CS.COMPLIANCE_SOURCE_ID = (
    --                             CASE
    --                                 WHEN CR.PERIOD_SID = 1 THEN 'DBP'
    --                                 ELSE 'SCP1'
    --                             END)     --FOR EX-ANTE, SHOW ONLY DBP, FOR EX-POST, SHOW ONLY SCP
    --              AND CR.ENTRY_TYPE_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_entry_type_question)
    --              AND CR.BUDG_AGG_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_budg_question)
    --              AND CR.TARGET_UNIT_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_target_question)
    --              AND CR.COVERAGE_SID IN (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_coverage_question)
    --              AND R.ENTRY_SID = p_entry_sid
    --              AND CR.PERIOD_SID = p_period_sid
    --              AND CS.IS_PRIVATE = 0
    --              ) WHERE VERSION_RANK = 1
    --             GROUP BY COMPLIANCE_SOURCE_SID
    --         UNION ALL
    --         -- ESTAT Selection
    --           SELECT CR.COMPLIANCE_SOURCE_SID, ROUND(SUM(E.VALUE), 2) AS VALUE
    --             FROM CFG_COMPLIANCE_REFS CR
    --                  JOIN CFG_COMPLIANCE_SOURCES CS
    --                      ON CS.COMPLIANCE_SOURCE_SID = CR.COMPLIANCE_SOURCE_SID
    --                  JOIN ESTAT_INDIC_DATA E ON E.INDICATOR_SID = CR.INDICATOR_SID
    --                  JOIN ENTRIES R
    --                      ON R.COUNTRY_ID = E.COUNTRY_ID
    --                  JOIN APPLICATIONS A ON A.APP_SID = CS.APP_SID
    --            WHERE CS.COMPLIANCE_SOURCE_ID = 'ESTA1'
    --              AND E.ROUND_SID = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), CS.YEAR)
    --              AND CR.ENTRY_TYPE_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_entry_type_question)
    --              AND CR.BUDG_AGG_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_budg_question)
    --              AND CR.TARGET_UNIT_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_target_question)
    --              AND CR.COVERAGE_SID IN (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_coverage_question)
    --              AND R.ENTRY_SID = p_entry_sid
    --              AND CR.PERIOD_SID = p_period_sid
    --              AND CS.IS_PRIVATE = 1
    --              GROUP BY CR.COMPLIANCE_SOURCE_SID
    --         UNION ALL
    --         --AMECO
    --         SELECT CR.COMPLIANCE_SOURCE_SID, 
    --                 ROUND(TO_NUMBER(REGEXP_SUBSTR(E.TIMESERIE_DATA, '[^,]+', 1, l_year - E.START_YEAR)), 2) AS VALUE
    --             FROM CFG_COMPLIANCE_REFS CR
    --                 ,CFG_COMPLIANCE_SOURCES CS
    --                 ,ENTRIES R
    --                 ,APPLICATIONS A
    --                 ,VW_FDMS_INDICATOR_DATA E
    --            WHERE CS.COMPLIANCE_SOURCE_ID IN ( 'AMEC1', 'AMECO')
    --              AND CS.COMPLIANCE_SOURCE_SID = CR.COMPLIANCE_SOURCE_SID
    --              AND E.PROVIDER_ID = 'PRE_PROD' 
    --              AND E.INDICATOR_ID = CR.DESCR
    --              AND R.COUNTRY_ID = E.COUNTRY_ID
    --              AND A.APP_SID = CS.APP_SID
    --              AND E.ROUND_SID = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), CS.YEAR)
    --              AND CR.ENTRY_TYPE_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_entry_type_question)
    --              AND CR.BUDG_AGG_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_budg_question)
    --              AND CR.TARGET_UNIT_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_target_question)
    --              AND CR.COVERAGE_SID IN (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_coverage_question)
    --              AND E.STORAGE_SID = 6
    --              AND R.ENTRY_SID = p_entry_sid
    --              AND CR.PERIOD_SID = p_period_sid

    --     ORDER BY COMPLIANCE_SOURCE_SID
    --         ;
    -- END;

    ----------------------------------------------------------------------------
    -- @name getComplianceConfiguration
    -- @return compliance cfg for a specific entry
    ----------------------------------------------------------------------------
    PROCEDURE getComplianceConfiguration(p_entry_sid               IN  NUMBER
                                        ,o_cur                      OUT SYS_REFCURSOR)
    IS
        l_budg_question NUMBER;
        l_entry_type_question NUMBER;
        l_target_question NUMBER;
        l_coverage_question NUMBER;
    BEGIN
        SELECT QUESTION_VERSION_SID
          INTO l_entry_type_question
          FROM CFG_COMPLIANCE_QUESTIONS
         WHERE COMPLIANCE_ATTR = 'ENTRY_TYPE_SID';

        SELECT QUESTION_VERSION_SID
          INTO l_budg_question
          FROM CFG_COMPLIANCE_QUESTIONS
         WHERE COMPLIANCE_ATTR = 'BUDG_AGG_SID';

        SELECT QUESTION_VERSION_SID
          INTO l_target_question
          FROM CFG_COMPLIANCE_QUESTIONS
         WHERE COMPLIANCE_ATTR = 'TARGET_UNIT_SID';

        SELECT QUESTION_VERSION_SID
          INTO l_coverage_question
          FROM CFG_COMPLIANCE_QUESTIONS
         WHERE COMPLIANCE_ATTR = 'COVERAGE_SID';
        
        OPEN o_cur FOR
            SELECT  CS.COMPLIANCE_SOURCE_SID, CS.COMPLIANCE_SOURCE_ID,
                    CS.YEAR,
                    CS.APP_SID,
                    CR.PERIOD_SID,
                    CR.ENTRY_TYPE_SID,
                    CR.BUDG_AGG_SID,
                    CR.TARGET_UNIT_SID, 
                    CR.COVERAGE_SID,
                    CR.INDICATOR_SID,
                    CR.LINE_ID,
                    CASE
                          WHEN L.DESCR LIKE '%Absolute%' THEN 1 --for DATA_TYPE_ID = 'LEVELS'
                          ELSE 0 --for DATA_TYPE_ID = 'GDP'
                      END as IS_LEVEL,
                    CASE
                        WHEN CS.COMPLIANCE_SOURCE_ID = 'DBP' THEN 1
                        ELSE -1
                    END AS YEAR_VALUE
               FROM CFG_COMPLIANCE_REFS CR
                   ,CFG_COMPLIANCE_SOURCES CS
                   ,CFG_LOVS L
              WHERE CS.COMPLIANCE_SOURCE_SID = CR.COMPLIANCE_SOURCE_SID
                AND L.LOV_SID = CR.TARGET_UNIT_SID
                AND CR.ENTRY_TYPE_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_entry_type_question)
                AND CR.BUDG_AGG_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_budg_question)
                AND CR.TARGET_UNIT_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_target_question)
                AND CR.COVERAGE_SID IN (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_coverage_question)
            ORDER BY COMPLIANCE_SOURCE_SID;
    END;

    PROCEDURE getEurostatValues(p_entry_sid       IN     NUMBER
                               ,p_period_sid      IN     NUMBER
                               ,p_round_sid       IN     NUMBER
                               ,o_cur             OUT    SYS_REFCURSOR)
    IS
        l_budg_question NUMBER;
        l_entry_type_question NUMBER;
        l_target_question NUMBER;
        l_coverage_question NUMBER;
    BEGIN
        SELECT QUESTION_VERSION_SID
          INTO l_entry_type_question
          FROM CFG_COMPLIANCE_QUESTIONS
         WHERE COMPLIANCE_ATTR = 'ENTRY_TYPE_SID';

        SELECT QUESTION_VERSION_SID
          INTO l_budg_question
          FROM CFG_COMPLIANCE_QUESTIONS
         WHERE COMPLIANCE_ATTR = 'BUDG_AGG_SID';

        SELECT QUESTION_VERSION_SID
          INTO l_target_question
          FROM CFG_COMPLIANCE_QUESTIONS
         WHERE COMPLIANCE_ATTR = 'TARGET_UNIT_SID';

        SELECT QUESTION_VERSION_SID
          INTO l_coverage_question
          FROM CFG_COMPLIANCE_QUESTIONS
         WHERE COMPLIANCE_ATTR = 'COVERAGE_SID';
        
        OPEN o_cur FOR
            SELECT CR.COMPLIANCE_SOURCE_SID, ROUND(SUM(E.VALUE), 2) AS VALUE
                    FROM CFG_COMPLIANCE_REFS CR
                        JOIN CFG_COMPLIANCE_SOURCES CS
                            ON CS.COMPLIANCE_SOURCE_SID = CR.COMPLIANCE_SOURCE_SID
                        JOIN ESTAT_INDIC_DATA E ON E.INDICATOR_SID = CR.INDICATOR_SID
                        JOIN ENTRIES R
                            ON R.COUNTRY_ID = E.COUNTRY_ID
                WHERE CS.COMPLIANCE_SOURCE_ID = 'ESTA1'
                    AND E.ROUND_SID = p_round_sid
                    AND CR.ENTRY_TYPE_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_entry_type_question)
                    AND CR.BUDG_AGG_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_budg_question)
                    AND CR.TARGET_UNIT_SID = (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_target_question)
                    AND CR.COVERAGE_SID IN (SELECT TO_NUMBER(RESPONSE) FROM ENTRY_CHOICES WHERE ENTRY_SID = p_entry_sid AND QUESTION_VERSION_SID = l_coverage_question)
                    AND R.ENTRY_SID = p_entry_sid
                    AND CR.PERIOD_SID = p_period_sid
                    AND CS.IS_PRIVATE = 1
                    GROUP BY CR.COMPLIANCE_SOURCE_SID;
    END;

    FUNCTION calcFRSI (pi_cr1 IN NUMBER
                        ,pi_cr2 IN NUMBER
                        ,pi_cr3a IN NUMBER
                        ,pi_cr3b IN NUMBER
                        ,pi_cr3c IN NUMBER
                        ,pi_cr3d IN NUMBER
                        ,pi_cr4  IN NUMBER
                        ,pi_cr5a IN NUMBER
                        ,pi_cr5b IN NUMBER
                        ,pi_cr5c IN NUMBER
                        ,pi_cr5d IN NUMBER)
        RETURN NUMBER
    IS
        po_frsi  NUMBER;
    BEGIN

        po_frsi := 0.2 * ((pi_cr1 + pi_cr2)/3 + (pi_cr3a + pi_cr3b + pi_cr3c + pi_cr3d)/7.5 + pi_cr4/4 + (pi_cr5a + pi_cr5b + pi_cr5c + pi_cr5d)/4);

        RETURN NVL(ROUND(po_frsi, 2), 0);

    END;

    FUNCTION calcComplianceB(pi_cr1 NUMBER,
                            pi_cr2 NUMBER,
                            pi_cr3 NUMBER,
                            pi_ambitious NUMBER)
        RETURN VARCHAR
    IS
        po_bonus VARCHAR(10);
    BEGIN

            IF (pi_cr1 = 1 AND pi_cr2 = 1 AND  pi_ambitious = 1 AND pi_cr3 = 0) THEN
            po_bonus := TO_CHAR(2);
            ELSIF ((pi_cr1 = 1 AND pi_cr2 = 0 AND pi_cr3 = 0) OR
                (pi_cr1 = 1 AND pi_cr2 = 1 AND pi_ambitious != 1 AND pi_cr3 = 0)) THEN
            po_bonus := TO_CHAR (1);
            ELSIF ((pi_cr2 = 1 AND pi_cr1 = 0 AND pi_cr3 = 0) OR
                (pi_cr1 = 0 AND pi_cr2 = 1 AND pi_ambitious = 0 AND pi_cr3 = 0)) THEN
            po_bonus := TO_CHAR (0);
            ELSE
            po_bonus := 'n/a';
            END IF;

            RETURN po_bonus;
    EXCEPTION
        WHEN OTHERS
        THEN
            dbms_output.put_line(SQLERRM);

    END;



    ----------------------------------------------------------------------------
    -- @name clearAssessmentValue
    -- @return number of records updated
    ----------------------------------------------------------------------------
    PROCEDURE clearAssessmentValue(p_entry_sid              IN  NUMBER
                                  ,p_question_version_sid   IN  NUMBER
                                  ,p_period_sid             IN  NUMBER
                                  ,o_res                    OUT NUMBER)
    IS
    BEGIN
        UPDATE ENTRY_CHOICES
           SET RESPONSE = NULL,
               DETAILS  = NULL
         WHERE ENTRY_SID = p_entry_sid
           AND QUESTION_VERSION_SID = p_question_version_sid
           AND ASSESSMENT_PERIOD    = p_period_sid;

        o_res := SQL%ROWCOUNT;
    END;

    ----------------------------------------------------------------------------
    -- @name deleteEntryTargetNAYear
    -- @return number of records deleted
    ----------------------------------------------------------------------------
    PROCEDURE deleteEntryTargetNAYear(p_entry_sid              IN     NUMBER
                                     ,p_question_version_sid   IN     NUMBER
                                     ,p_year                   IN     NUMBER
                                     ,o_res                    OUT    NUMBER)
    IS
    BEGIN
        DELETE TARGET_ENTRIES
        WHERE ENTRY_SID = p_entry_sid
            AND QUESTION_VERSION_SID =  p_question_version_sid
            AND RESPONSE_SID = p_year;
        o_res := SQL%ROWCOUNT;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name getRuleTypes
    -- @return types of entries for NFR app
    ----------------------------------------------------------------------------
    PROCEDURE getRuleTypes(o_cur        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN o_cur FOR
            SELECT L.DESCR
                  ,L.LOV_SID
              FROM CFG_LOVS L
                  ,CFG_LOV_TYPES LT
             WHERE LT.LOV_TYPE_SID = L.LOV_TYPE_SID
               AND LT.LOV_TYPE_ID = 'RTYPES';
    END;

    ----------------------------------------------------------------------------
    -- @name getQuestionPeriod
    -- @return period of a question
    ----------------------------------------------------------------------------
    PROCEDURE getQuestionPeriod (p_question_version_sid     IN  NUMBER
                                ,o_res                      OUT NUMBER)
    IS
    BEGIN
        SELECT SV.ASSESSMENT_PERIOD
          INTO o_res
          FROM CFG_SECTION_VERSIONS SV
              ,CFG_QSTNNR_SECTION_QUESTIONS SQ
         WHERE SQ.SECTION_VERSION_SID  = SV.SECTION_VERSION_SID
           AND SQ.QUESTION_VERSION_SID = p_question_version_sid;
    END;

    ----------------------------------------------------------------------------
    -- @name setAmbitious
    -- @return setAmbitious for an entry
    ----------------------------------------------------------------------------
    PROCEDURE setAmbitious (p_entry_sid     IN  NUMBER
                           ,p_ambitious     IN  NUMBER
                           ,o_res           OUT NUMBER)
    IS
    BEGIN
        UPDATE ENTRIES_ADD_CFG
           SET IS_AMBITIOUS = p_ambitious
         WHERE ENTRY_SID = p_entry_sid;

        o_res := SQL%ROWCOUNT;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name clearQuestionValue
    -- @purpose clear value of a question
    ----------------------------------------------------------------------------
    PROCEDURE clearQuestionValue (p_entry_sid                IN  NUMBER
                                 ,p_question_version_sid     IN  NUMBER
                                 ,o_res                      OUT NUMBER)
    IS
    BEGIN
        DELETE ENTRY_CHOICES
         WHERE ENTRY_SID = p_entry_sid
           AND QUESTION_VERSION_SID =  p_question_version_sid;
        o_res := SQL%ROWCOUNT;
        COMMIT;
    END;

    ----------------------------------------------------------------------------
    -- @name getQuestionLastUpdate
    -- @purpose return date of last update for a certain question
    ----------------------------------------------------------------------------
    PROCEDURE getQuestionLastUpdate (p_entry_sid                IN  NUMBER
                                    ,p_question_version_sid     IN  NUMBER
                                    ,o_res                      OUT VARCHAR2)
    IS
    BEGIN
        SELECT DISTINCT LAST_UPDATE
          INTO o_res
          FROM ENTRY_CHOICES
         WHERE ENTRY_SID =  p_entry_sid
           AND QUESTION_VERSION_SID = p_question_version_sid;
    EXCEPTION
        WHEN OTHERS THEN
            o_res := NULL;
    END;


END CFG_ACCESSORS;