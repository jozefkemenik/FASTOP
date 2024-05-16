create or replace PACKAGE CORE_TYPES as

    /******************************************************************************
         NAME:       CORE_TYPES
         PURPOSE:    Common cfg, stored also in cfg tables;
                     Usage of types recommended over hardcoding
    ******************************************************************************/

    -- Period Ids record
    TYPE T_PERIOD_ID IS RECORD (
        SPRING VARCHAR2(32) := 'SPR',
        SUMMER VARCHAR2(32) := 'SUM',
        AUTUMN VARCHAR2(32) := 'AUT',
        WINTER VARCHAR2(32) := 'WIN'
    );

    -- Parameter names record
    TYPE T_PARAM_NAME IS RECORD (
        CURRENT_ROUND   VARCHAR2(32) := 'CURRENT_ROUND',
        CURRENT_STORAGE VARCHAR2(32) := 'CURRENT_STORAGE'
    );

    -- Application IDs record
    TYPE T_APP_ID IS RECORD (
        DBP         VARCHAR2(8) := 'DBP',
        DFM         VARCHAR2(8) := 'DFM',
        SCP         VARCHAR2(8) := 'SCP',
        DRM         VARCHAR2(8) := 'DRM',
        FGD         VARCHAR2(8) := 'FGD',
        FDMS        VARCHAR2(8) := 'FDMS',
        FDMSIE      VARCHAR2(8) := 'FDMSIE',
        NFR         VARCHAR2(8) := 'NFR',
        IFI         VARCHAR2(8) := 'IFI',
        MTBF        VARCHAR2(8) := 'MTBF',
        AUXTOOLS    VARCHAR2(8) := 'AUXTOOLS',
        GBD         VARCHAR2(8) := 'GBD',
        UM          VARCHAR2(8) := 'UM',
    );
    
     -- Inputs record
    TYPE T_INPUT IS RECORD (
        OK      NUMBER := 1,
        NOK     NUMBER := 0
    );
    
    -- Activation record
    TYPE T_ACTIVATION IS RECORD (
        ACTIVE      NUMBER := 1,
        INACTIVE    NUMBER := 0
    );
    
    -- DFM Params record
    TYPE T_DFM_PARAMS IS RECORD (
        START_YEAR                      VARCHAR2(64) := 'START_YEAR',
        MEASURE_DEFAULT_YEAR            VARCHAR2(64) := 'MEASURE_DEFAULT_YEAR',
        CURRENT_FC                      VARCHAR2(64) := 'CURRENT_FC',
        ESA2010_ROUND                   VARCHAR2(64) := 'ESA2010_ROUND',
        ONE_OFF_TYPES_ENABLED_ROUND     VARCHAR2(64) := 'ONE_OFF_TYPES_ENABLED_ROUND',
        CURRENT_CUST_STORAGE            VARCHAR2(64) := 'CURRENT_CUST_STORAGE'
    );
    
    -- Application status record
    TYPE T_STATUS_REPO IS RECORD (
        ACTIVE      VARCHAR2(64) := 'ACTIVE',
        SUBMIT      VARCHAR2(64) := 'SUBMIT',
        ARCHIVE     VARCHAR2(64) := 'ARCHIVE',
        PUBLISH     VARCHAR2(64) := 'PUBLISH',
        TR_OPEN     VARCHAR2(64) := 'TR_OPEN',
        TR_SUBMIT   VARCHAR2(64) := 'TR_SUBMIT',
        TR_PUBLISH  VARCHAR2(64) := 'TR_PUBLISH',
        OPEN        VARCHAR2(64) := 'OPEN',
        CLOSED      VARCHAR2(64) := 'CLOSED',
        VALIDATE    VARCHAR2(64) := 'VALIDATE',
        ACCEPTED    VARCHAR2(64) := 'ACCEPTED',
        REJECTED    VARCHAR2(64) := 'REJECTED',
        ST_CLOSED   VARCHAR2(64) := 'ST_CLOSED'
    );

    -- Task statuses record
    TYPE T_TASK_STATUSES IS RECORD (
        READY       VARCHAR2(16) := 'READY',
        RUNNING     VARCHAR2(16) := 'RUNNING',
        SAVING      VARCHAR2(16) := 'SAVING',
        DONE        VARCHAR2(16) := 'DONE',
        ERROR       VARCHAR2(16) := 'ERROR',
        WARNING     VARCHAR2(16) := 'WARNING',
        ABORT       VARCHAR2(16) := 'ABORT'
    );
END; 