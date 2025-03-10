--FRSI
  --DIMENSIONS FOR FRSI
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM1
VALUES (1, 4, 'CFG_INDEX_CRITERIA', 'CR1', NULL, NULL, NULL);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM2
VALUES (1, 4, 'CFG_INDEX_CRITERIA', 'CR2', NULL, NULL, NULL);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM3
VALUES (1, 4, 'CFG_INDEX_CRITERIA', '( CR3 + CR4 + CR5 + CR6 )/7.5', NULL, NULL, NULL);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM4
VALUES (1, 4, 'CFG_INDEX_CRITERIA', 'CR7 /4', NULL, NULL, NULL);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM5
VALUES (1, 4, 'CFG_INDEX_CRITERIA', '( CR8 + CR9 + CR10 + CR11 )/4', NULL, NULL, NULL);

  --FRSI
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM6
VALUES (1, 5, 'CFG_INDICE_CRITERIA', '(0,2 * ( ( SDIM1 + SDIM2 )/3 + SDIM3 + SDIM4 + SDIM5 )).toFixed(4)', 'FRSI', NULL, 1);
  --Coverage
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM7
VALUES (1, 3, 'FUNCTION_BASED', 'getCoverage', 'Coverage', NULL, 2);
  --In Force
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM8
VALUES (1, 1, 'FUNCTION_BASED', 'isInForce', 'In Force', NULL, 3);
  --FRI
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM9
VALUES (1, 5, 'CFG_INDICE_CRITERIA', '( SDIM7 * SDIM8 ).toFixed(4)', 'FRI', NULL, 4);
  --Ranking
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM10
VALUES (1, 5, 'RANKING1', NULL,  'Ranking', NULL, 5);

--FRCI
  --Dimensions for FRCI
  --EXA COMPLIANCE
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM11
VALUES (2, 4, 'CFG_INDEX_CRITERIA', 'CR12', 'Ex Ante Compliance', NULL, 1);
  --EXP COMPLIANCE
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM12
VALUES (2, 4, 'CFG_INDEX_CRITERIA', 'CR13', 'Ex Post Compliance', NULL, 2);
  --COMPLIANCE SCORING
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM13
VALUES (2, 1, 'FUNCTION_BASED', 'getComplianceScoring', NULL, NULL, NULL);
  --Bonus
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM14
VALUES (2, 1, 'FUNCTION_BASED', 'getComplianceBonus', 'Bonus', NULL, 3);
  --Compliance with Bonus
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM15
VALUES (2, 5, 'CFG_INDICE_CRITERIA', ' SDIM13 + SDIM14 ', 'Compliance With Bonus', NULL, 4);
  --Coverage
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM16
VALUES (2, 3, 'FUNCTION_BASED', 'getCoverage', 'Coverage', NULL, 5);
  --Ranking
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM17
VALUES (2, 5, 'RANKING2', NULL, 'Ranking', NULL, 6);
  --escc trig
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM18
VALUES (2, 4, 'CFG_INDEX_CRITERIA', 'CR14', 'Escape Clauses Triggered', NULL, 7);
  --Compliance by coverage
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM19
VALUES (2, 5, 'CFG_INDICE_CRITERIA', 'SDIM14 * SDIM16', 'Compliance by coverage', NULL, 8);
  --Rule Weight
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM20
VALUES (2, 5, 'CFG_INDICE_CRITERIA', '( SDIM16 /SDIM17 ).toFixed(6)', 'Rule Weight', NULL, 9);
  --Rule FRCI Index
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM21
VALUES (2, 5, 'FINAL', '( SDIM19 / SDIM17 , 6)', 'Rule FRCI Index', NULL, 10);
  --NA
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM22
VALUES (2, 5, 'CFG_INDICE_CRITERIA', ' SDIM13 !== -1 || ( SDIM11 === 0 '|| chr(38) || chr(38)||' SDIM12 === 0 ) ? 0 : 1', 'NA', NULL, 11);

--SIFI
  --Dimensions for SIFI
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM23
VALUES (3, 4, 'CFG_INDEX_CRITERIA', '(((( CR15 + CR16 + CR17 )* CR18 ) / 3) * 30).toFixed(4) ', 'SDIM1', NULL, 1);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM24
VALUES (3, 4, 'CFG_INDEX_CRITERIA', '(((( CR19 + CR20 + CR21 )* CR22 ) /3) * 25).toFixed(4) ', 'SDIM2', NULL, 2);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM25
VALUES (3, 4, 'CFG_INDEX_CRITERIA', '(((( CR23 + CR24 ) * CR25 )/3.5) * 20).toFixed(4) ', 'SDIM3', NULL, 3);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM26
VALUES (3, 4, 'CFG_INDEX_CRITERIA', 'CR26 * 10', 'SDIM4', NULL, 4);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM27
VALUES (3, 4, 'CFG_INDEX_CRITERIA', 'CR27 * 5', 'SDIM5', NULL, 5);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM28
VALUES (3, 4, 'CFG_INDEX_CRITERIA', 'CR28 * 10', 'SDIM6', NULL, 6);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM29
VALUES (3, 5, 'CFG_INDICE_CRITERIA', 'SDIM1 + SDIM2 + SDIM3 + SDIM4 + SDIM5 + SDIM6', 'SIFI', NULL, 7);

--MTBFI
  --Dimensions for MTBFI
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM30
VALUES (4, 4, 'CFG_INDEX_CRITERIA', '(( CR29 + CR30 ) / 4 ).toFixed(4)', 'SDIM1', NULL, 1);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM31
VALUES (4, 4, 'CFG_INDEX_CRITERIA', '(( CR31 + CR32 + CR33 ) / 6).toFixed(4)', 'SDIM2', NULL, 2);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM32
VALUES (4, 4, 'CFG_INDEX_CRITERIA', '( CR34 / 3).toFixed(4)', 'SDIM3', NULL, 3);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM33
VALUES (4, 4, 'CFG_INDEX_CRITERIA', '( CR35 / 4).toFixed(4)', 'SDIM4', NULL, 4);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM34
VALUES (4, 4, 'CFG_INDEX_CRITERIA', '(( CR36 + CR37 + CR38 + CR39 ) / 4).toFixed(4)', 'SDIM5', NULL, 5);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM35
VALUES (4, 5, 'CFG_INDICE_CRITERIA', '(( SDIM30 + SDIM31 + SDIM32 + SDIM33 + SDIM34 )/5).toFixed(2)', 'MTBFI', NULL, 6);

--FRSI multi entry
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM36
VALUES (1, 6, 'CFG_INDICE_CRITERIA', '(SDIM7 * SDIM8 * 10 / SDIM10)', 'Country FRI', NULL, 6);

--FRCI multi entry
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM37
VALUES (2, 6, 'CFG_INDICE_CRITERIA', 'SDIM21', NULL, NULL, NULL);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM38
VALUES (2, 6, 'CFG_INDICE_CRITERIA', 'SDIM20', NULL, NULL, NULL);
INSERT INTO CFG_INDICE_CRITERIA(INDEX_SID, INDICE_TYPE_SID, ACCESSOR, CRITERION_VALUE, DISPLAY_NAME, DEP_IND_CRITERION_SID, ORDER_BY) --SDIM39
VALUES (2, 6, 'CFG_INDICE_CRITERIA', '(SDIM37 / SDIM36).toFixed(4)', 'Weighted FRCI', NULL, 12);
COMMIT;