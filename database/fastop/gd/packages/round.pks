/* Formatted on 24/01/2020 11:26:48 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE GD_ROUND
AS
    FUNCTION prepareNextRound(p_previous_round_sid  IN  NUMBER
,                             p_new_round_sid       IN  NUMBER)
        RETURN NUMBER;

END GD_ROUND;