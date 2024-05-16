/* Formatted on 03-04-2020 16:05:29 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE ST_STATUS_CHANGES
AS
   PROCEDURE setInputDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2);

   PROCEDURE setLastSubmitDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2);

   PROCEDURE setLastValidationDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2);

   PROCEDURE setOutputGapDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2);

   PROCEDURE setLastArchivingDate(p_round_sid IN VARCHAR2, p_country_id IN VARCHAR2);

   PROCEDURE updateStatusChanges(p_round_sid   IN VARCHAR2
                               , p_country_id  IN VARCHAR2
                               , p_from_status IN VARCHAR2
                               , p_to_status   IN VARCHAR2);
END ST_STATUS_CHANGES;
/