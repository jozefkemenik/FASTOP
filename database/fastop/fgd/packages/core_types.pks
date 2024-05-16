create or replace PACKAGE CORE_TYPES as

    /******************************************************************************
         NAME:       CORE_TYPES
         PURPOSE:    Common cfg, stored also in cfg tables;
                     Usage of types recommended over hardcoding
    ******************************************************************************/

    -- QUESTION TYPES RECORD
    TYPE T_QUESTION_TYPES IS RECORD (
        SINGLE_CHOICE               NUMBER := 1,
        MULTIPLE_CHOICE             NUMBER := 2,
        SINGLE_DROPDOWN             NUMBER := 3,
        MULTIPLE_DROPDOWN           NUMBER := 4,
        FREE_TEXT                   NUMBER := 5,
        SINGLE_LINE                 NUMBER := 6,
        NUMERICAL                   NUMBER := 7,
        LINKED_ENTRIES              NUMBER := 8,
        NO_ANSWER                   NUMBER := 9,
        NUMERICAL_TARGET            NUMBER := 10,
        DATETIME                    NUMBER := 11,
        NO_CHOICE                   NUMBER := 12,
        ASSESSMENT_TEXT             NUMBER := 13,
        ASSESSMENT_SINGLE_CHOICE    NUMBER := 14,
        ASSESSMENT_MULTIPLE_CHOICE  NUMBER := 15,
        ASSESSMENT_MULTIPLE_TEXT    NUMBER := 16,
        ASSESSMENT_COMPLIANCE       NUMBER := 17,
        ASSESSMENT_NUMBER           NUMBER := 18
    );

    --HORIZONTAL ELEMENTS TYPES RECORD
    TYPE T_HORIZ_ELEMENTS IS RECORD (
        ATTRIBUTE       NUMBER := 1,
        QUESTION        NUMBER := 2,
        SCORE           NUMBER := 3,
        STAGE           NUMBER := 4,
        CUSTOM          NUMBER := 5,
        SUBMIT          NUMBER := 6,
        ADD_ATTRIBUTE   NUMBER := 7
    );

    --ENTRY_EDIT_STEPS TYPES RECORD
    TYPE T_EDIT_STEPS IS RECORD (
        VFY         NUMBER := 1,
        UPD         NUMBER := 2,
        RFM         NUMBER := 3,
        CPL         NUMBER := 4,
        NEW         NUMBER := 5,
        NOC         NUMBER := 6,
        RFF         NUMBER := 7
    );

    TYPE T_AVAILABILITY IS RECORD (
        C           VARCHAR2(32) := 'Current',
        F           VARCHAR2(32) := 'Future',
        A           VARCHAR2(32) := 'Abolished',
        NA          VARCHAR2(32) := 'Not Available'
    );

END; 