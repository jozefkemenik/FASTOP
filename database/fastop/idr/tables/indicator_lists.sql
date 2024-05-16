/* Formatted on 12/2/2019 15:03:06 (QP5 v5.252.13127.32847) */
ALTER TABLE INDICATOR_LISTS
   DROP PRIMARY KEY CASCADE;

DROP TABLE INDICATOR_LISTS CASCADE CONSTRAINTS;
DROP SEQUENCE INDICATOR_LISTS_SEQ;

CREATE TABLE INDICATOR_LISTS
(
   INDICATOR_LIST_SID   NUMBER (8) CONSTRAINT INDICATOR_LISTS_PK PRIMARY KEY
,  INDICATOR_SID        NUMBER (8)
                           NOT NULL
                           CONSTRAINT INDICATOR_LISTS_INDIC_FK
                               REFERENCES INDICATORS (INDICATOR_SID)
,  WORKBOOK_GROUP_SID   NUMBER (8)
                           NOT NULL
                           CONSTRAINT INDICATOR_LISTS_WRKBK_GRP_FK
                              REFERENCES WORKBOOK_GROUPS (WORKBOOK_GROUP_SID)
,  CONSTRAINT INDICATOR_LISTS_UNQ UNIQUE (INDICATOR_SID, WORKBOOK_GROUP_SID)
);

COMMENT ON TABLE INDICATOR_LISTS IS 'Indicator Lists';
COMMENT ON COLUMN INDICATOR_LISTS.INDICATOR_LIST_SID IS 'Indicator List SID';
COMMENT ON COLUMN INDICATOR_LISTS.INDICATOR_SID IS 'Indicator SID';
COMMENT ON COLUMN INDICATOR_LISTS.WORKBOOK_GROUP_SID IS 'Workbook Group SID';


CREATE SEQUENCE INDICATOR_LISTS_SEQ START WITH 1;

CREATE OR REPLACE TRIGGER INDICATOR_LISTS_TRG
   BEFORE INSERT
   ON INDICATOR_LISTS
   FOR EACH ROW
BEGIN
   SELECT INDICATOR_LISTS_SEQ.NEXTVAL INTO :NEW.INDICATOR_LIST_SID FROM DUAL;
END;
