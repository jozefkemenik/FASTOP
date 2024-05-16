CREATE OR REPLACE PACKAGE BODY FASTOP.ST_STATUS_CHANGES
AS
   /**************************************************************************
    *********************** PRIVATE SECTION **********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name setCtyStatusChanges
   ----------------------------------------------------------------------------
   PROCEDURE setCtyStatusChanges(p_round_sid            IN VARCHAR2
                               , p_country_id           IN VARCHAR2
                               , p_first_input_date     IN DATE DEFAULT NULL
                               , p_last_input_date      IN DATE DEFAULT NULL
                               , p_last_submit_date     IN DATE DEFAULT NULL
                               , p_last_validation_date IN DATE DEFAULT NULL
                               , p_output_gap_date      IN DATE DEFAULT NULL
                               , p_last_archiving_date  IN DATE DEFAULT NULL
)
   IS
   BEGIN
      UPDATE st_cty_status_changes
         SET FIRST_INPUT_DATE     = COALESCE(p_first_input_date, FIRST_INPUT_DATE)
           , LAST_INPUT_DATE      = COALESCE(p_last_input_date, LAST_INPUT_DATE)
           , LAST_SUBMIT_DATE     = COALESCE(p_last_submit_date, LAST_SUBMIT_DATE)
           , LAST_VALIDATION_DATE = COALESCE(p_last_validation_date, LAST_VALIDATION_DATE)
           , OUTPUT_GAP_DATE      = COALESCE(p_output_gap_date, OUTPUT_GAP_DATE)
           , LAST_ARCHIVING_DATE  = COALESCE(p_last_archiving_date, LAST_ARCHIVING_DATE)
       WHERE ROUND_SID = p_round_sid AND COUNTRY_ID = p_country_id;

      IF SQL%ROWCOUNT = 0 THEN
         INSERT INTO st_cty_status_changes(ROUND_SID
                                         , COUNTRY_ID
                                         , FIRST_INPUT_DATE
                                         , LAST_INPUT_DATE
                                         , LAST_SUBMIT_DATE
                                         , LAST_VALIDATION_DATE
                                         , OUTPUT_GAP_DATE
                                         , LAST_ARCHIVING_DATE)
              VALUES (p_round_sid
                    , p_country_id
                    , p_first_input_date
                    , p_last_input_date
                    , p_last_submit_date
                    , p_last_validation_date
                    , p_output_gap_date
                    , p_last_archiving_date);
      END IF;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END setCtyStatusChanges;

   /**************************************************************************
    *********************** PUBLIC SECTION ***********************************
    **************************************************************************/

   ----------------------------------------------------------------------------
   -- @name setInputDate
   ----------------------------------------------------------------------------
   PROCEDURE setInputDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2)
   IS
      l_exists NUMBER(2);
   BEGIN
      BEGIN
         -- Check if First date exists
         SELECT COUNT(*)
           INTO l_exists
           FROM st_cty_status_changes C
          WHERE C.ROUND_SID = p_round_sid
            AND C.COUNTRY_ID = p_country_id
            AND C.FIRST_INPUT_DATE IS NOT NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_exists := 0;
      END;

      IF l_exists = 0 THEN
         -- If FIRST_INPUT_DATE not exists then set it
         setCtyStatusChanges(p_round_sid, p_country_id, p_first_input_date => SYSDATE);
      END IF;

      -- set LAST_UPDATE_DATE always
      setCtyStatusChanges(p_round_sid, p_country_id, p_last_input_date => SYSDATE);

   END setInputDate;

   ----------------------------------------------------------------------------
   -- @name setLastSubmitDate
   ----------------------------------------------------------------------------
   PROCEDURE setLastSubmitDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2)
   IS
   BEGIN
      setCtyStatusChanges(p_round_sid, p_country_id, p_last_submit_date => SYSDATE);
   END setLastSubmitDate;

   ----------------------------------------------------------------------------
   -- @name setLastValidationDate
   ----------------------------------------------------------------------------
   PROCEDURE setLastValidationDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2)
   IS
   BEGIN
      setCtyStatusChanges(p_round_sid, p_country_id, p_last_validation_date => SYSDATE);
   END setLastValidationDate;

   ----------------------------------------------------------------------------
   -- @name setOutputGapDate
   ----------------------------------------------------------------------------
   PROCEDURE setOutputGapDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2)
   IS
   BEGIN
      setCtyStatusChanges(p_round_sid, p_country_id, p_output_gap_date => SYSDATE);
   END setOutputGapDate;

   ----------------------------------------------------------------------------
   -- @name setLastArchivingDate
   ----------------------------------------------------------------------------
   PROCEDURE setLastArchivingDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2)
   IS
   BEGIN
      setCtyStatusChanges(p_round_sid, p_country_id, p_last_archiving_date => SYSDATE);
   END setLastArchivingDate;

   ----------------------------------------------------------------------------
   -- @name updateStatusChanges
   ----------------------------------------------------------------------------
   PROCEDURE updateStatusChanges(p_round_sid   IN VARCHAR2
                               , p_country_id  IN VARCHAR2
                               , p_from_status IN VARCHAR2
                               , p_to_status   IN VARCHAR2)
   IS
   BEGIN
      IF p_from_status = 'ACTIVE' AND p_to_status = 'SUBMIT' THEN
         setLastSubmitDate(p_round_sid, p_country_id);
      ELSIF p_from_status = 'SUBMIT' AND p_to_status = 'VALIDATE' THEN
         setLastValidationDate(p_round_sid, p_country_id);
      END IF;
   END updateStatusChanges;
END ST_STATUS_CHANGES;
/