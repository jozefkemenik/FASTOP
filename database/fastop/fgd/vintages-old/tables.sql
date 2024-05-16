create table FGD_IDX_FRCI_ARCH
(RULE_SID number(9),
RULE_NO number(9),
RULE_VERSION number (9),
COUNTRY_ID     varchar2(4000 BYTE), 
SECTOR_ID      varchar2(4000 BYTE), 
ROUND_SID       number(9),
EX_ANTE_COMPLIANCE varchar2(4000 BYTE), 
EX_POST_COMPLIANCE varchar2(4000 BYTE), 
BONUS   number(9),
COMPLIANCEWITHBONUS varchar2(4000 BYTE), 
COVERAGE    number,
RANKING number, 
ESCAPE_CLAUSES_TRIGGERED number(1), 
COMPLIANCEBYCOVERAGE varchar2(4000 BYTE), 
RULEWEIGHT number, 
RULEFRCI_INDEX varchar2(4000 BYTE), 
NA  number);

create table fgd_rule_scores_annual_arch(
rule_sid number,
round_sid number,
cr1 varchar2(4000 Byte),
cr2 varchar2(4000 Byte),
cr3 varchar2(4000 Byte));

CREATE TABLE fgd_idx_frsi_arch(
    ROUND_SID NUMBER(9),
    RULE_SID NUMBER(9),
    RULE_NO NUMBER(9),
    RULE_VERSION NUMBER(9),
    COUNTRY_ID   VARCHAR2(4000 byte),
    SECTOR_ID    VARCHAR2(4000 byte),
    FRSI         NUMBER,
    COVERAGE     NUMBER,
    IN_FORCE     NUMBER(1),
    FRI          NUMBER,
    RANKING      NUMBER(1)
);