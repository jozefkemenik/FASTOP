DROP TYPE "MEASUREARRAY";
/
CREATE OR REPLACE TYPE "MEASUREOBJECT" AS OBJECT (
      TITLE                    VARCHAR2 (100 CHAR)
,     SHORT_DESCR              VARCHAR2 (4000 CHAR)
,     SOURCE_SID               NUMBER
,     ESA_SID                  NUMBER
,     ACC_PRINCIP_SID          NUMBER
,     ADOPT_STATUS_SID         NUMBER
,     DATA                     VARCHAR2 (4000 CHAR)
,     START_YEAR               NUMBER
,     YEAR                     NUMBER
,     ONE_OFF_SID              NUMBER
,     ONE_OFF_TYPE_SID         NUMBER
,     ONE_OFF_DISAGREE_SID     NUMBER
,     ONE_OFF_COMMENTS         VARCHAR2 (4000 CHAR)
,     EXERCISE_SID             NUMBER
,     STATUS_SID               NUMBER
,     NEED_RESEARCH_SID        NUMBER
,     INFO_SRC                 VARCHAR2 (400 CHAR)
,     ADOPT_DATE_YR            NUMBER
,     ADOPT_DATE_MH            NUMBER
,     COMMENTS                 VARCHAR2 (4000 CHAR)
,     REV_EXP_SID              NUMBER
,     ESA_COMMENTS             VARCHAR2 (4000 CHAR)
,     QUANT_COMMENTS           VARCHAR2 (4000 CHAR)
,     OO_PRINCIPLE_SID         NUMBER
,     UPLOADED_MEASURE_SID     NUMBER
,     LABEL_SIDS               SIDSLIST
,     IS_EU_FUNDED_SID         NUMBER(8)
,     EU_FUND_SID              NUMBER(8)
);
/
CREATE OR REPLACE TYPE "MEASUREARRAY" IS TABLE OF "MEASUREOBJECT";
/
