ALTER TABLE HELP_MSGS DISABLE ALL TRIGGERS;

REM INSERTING into HELP_MSGS
SET DEFINE OFF;
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (463,'Tab9a/bH03','This covers costs that are not recorded as expenditure in national accounts',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (32,'Default','The estimated impact on economic growth of the aggregated budgetary measures in the DBP can be specified in this Table or detailed otherwise in the methodological annex',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (33,'Default','Includes cash beneifts and in kind benefits related to unemployment benefits',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (34,'Default','Member States should detail the methodology used to obtain the cyclical component of unemployment benefit expenditure. It should build on unemployment benefit expenditure as defined in COFOG under the code 10.5',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (35,'Default','Revenue increases mandated by law should not be included in the effect of discretionary revenue measures: data reported in rows 3 and 4 should be mutually exclusive.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (36,'Default','This expenditure category should correspond to item 9 in table 4.c.ii)',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (37,'Default','This expenditure category should correspond to item 7 in table 4.c.ii)',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (38,'Default','This expenditure category should contain, inter alia, government spending related to ALMPs including public employment services. On the contrary, items such as compensation of public employees or vocational training programmes should not be included here.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (4,'Tab1b-1','Optional for stability programmes',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (6,'Tab1c-5','Real GDP per hour worked.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (7,'Tab1c-4','Real GDP per person employed.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (8,'Tab1c-3','Harmonised definition, Eurostat; levels.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (9,'Tab1c-2','Annual hours worked per person employed',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (10,'Tab1c-1','Occupied population, domestic concept national accounts definition. ',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (11,'Tab2a-1','Adjusted for the net flow of swap-related flows, so that TR-TE=EDP B.9.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (12,'Tab2a-3','A plus sign means deficit-reducing one-off measures.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (13,'Tab2a-4','P.11+P.12+P.131+D.39+D.7+D.9 (other than D.91).',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (14,'Tab2a-5','Including those collected by the EU and including an adjustment for uncollected taxes and social contributions (D.995), if appropriate.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (15,'Tab2a-6','Includes cash benefits (D.621 and D.624) and in kind benefits (D.631) related to unemployment benefits.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (16,'Tab2a-7','D.29+D4 (other than D.41)+ D.5+D.7+P.52+P.53+K.2+D.8.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (18,'Tab4-1','As defined in Regulation 479/2009 (not an ESA concept)',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (19,'Tab4-2','Cf. item 7 in Table 2.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (20,'Tab4-3','Cf. item 6 in Table 2.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (21,'Tab4-4','The differences concerning interest expenditure, other expenditure and revenue could be distinguished when relevant or in case the debt-to-GDP ratio is above the reference value. ',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (22,'Tab4-5','Liquid assets (currency), government securities, assets on third countries, government controlled enterprises and the difference between quoted and non-quoted assets could be distinguished when relevant or in case the debt-to-GDP ratio is above the reference value.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (23,'Tab4-6','Changes due to exchange rate movements, and operation in secondary market could be distinguished when relevant or in case the debt-to-GDP ratio is above the reference value.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (24,'Tab4-7','Proxied by interest expenditure divided by the debt level of the previous year.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (25,'Tab4-8','AF1, AF2, AF3 (consolidated at market value), AF5 (if quoted in stock exchange; including mutual fund shares).',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (26,'Tab5-1','A plus sign means deficit-reducing one-off measures.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (27,'Tab7-1','Systemic pension reforms refer to pension reforms that introduce a multi-pillar system that includes a mandatory fully funded pillar.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (28,'Tab7-2','Social contributions or other revenue received by the mandatory fully funded pillar to cover for the pension obligations it acquired in conjunction with the systemic reform',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (29,'Tab7-3','Pension expenditure or other social benefits paid by the mandatory fully funded pillar linked to the pension obligations it acquired in conjunction with the systemic pension reform',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (30,'Tab8-1','If necessary, purely technical assumptions.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (5,'Tab2a-2','The primary balance is calculated as (EDP B.9, item 8) plus (EDP D.41, item 9)',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (17,'Tab3-1','Adjusted for the net flow of swap-related flows, so that TR-TE=EDP B.9',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (1,'Default',null,null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (2,'Test2','This is another test message.',null);
Insert into HELP_MSGS (HELP_MSG_SID,DESCR,MESS,HELP_MSG_TYPE_ID) values (462,'Total hours worked',null,null);
COMMIT;

DROP SEQUENCE HELP_MSGS_SEQ;

DECLARE
    l_seq NUMBER;
BEGIN
    SELECT MAX(HELP_MSG_SID) + 1
    INTO l_seq
    FROM HELP_MSGS;

    EXECUTE IMMEDIATE 'CREATE SEQUENCE HELP_MSGS_SEQ START WITH ' || l_seq;
END;
/
CREATE OR REPLACE TRIGGER HELP_MSGS_TRG
   BEFORE INSERT
   ON HELP_MSGS
   FOR EACH ROW
BEGIN
   SELECT HELP_MSGS_SEQ.NEXTVAL INTO :NEW.HELP_MSG_SID FROM DUAL;
END;
/
ALTER TABLE HELP_MSGS ENABLE ALL TRIGGERS;