CREATE OR REPLACE PACKAGE CORE_JOBS
AS
    PROCEDURE LOG_INFO_SUCC(pi_proc IN VARCHAR2, pi_msg IN VARCHAR2, pi_date IN DATE);

    PROCEDURE LOG_INFO_FAIL(pi_proc IN VARCHAR2, pi_msg IN VARCHAR2, pi_err_msg IN VARCHAR2, pi_date IN DATE);

    PROCEDURE INFO_MAIL(pi_proc IN VARCHAR2, pi_msg IN VARCHAR2, pi_status IN VARCHAR2, pi_recipient IN VARCHAR2);
    
    -- PROCEDURE roundCheckJob;
END;