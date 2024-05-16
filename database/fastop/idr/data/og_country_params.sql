SET DEFINE OFF;
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('estimate', 'BOOL', 'Compute OG?', 'Set to ''True'' if you wish to estimate Output Gap for that country', 1);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('tfp_nblag', 'NUMERIC', 'TFP ARIMA EXTENSION', 'Order of AR model (p)', 2);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('tfp_ma_order', 'NUMERIC', 'TFP ARIMA EXTENSION', 'Order of MA model (q)', 3);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('tfp_const', 'NUMERIC', 'TFP ARIMA EXTENSION', 'use of a constant', 4);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('tfp_ar_start', 'NUMERIC', 'TFP ARIMA EXTENSION', 'Start of AR process analysis', 5);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('tfp_lambda', 'NUMERIC', 'TFP HP FILTERING', 'Lambda', 6);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('part_nblag', 'NUMERIC', 'PART AR EXTENSION', 'Order of AR model (p)', 7);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('part_const', 'NUMERIC', 'PART AR EXTENSION', 'use of a constant', 8);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('part_timexog', 'NUMERIC', 'PART AR EXTENSION', 'use of time as exogenous value', 9);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('part_ar_start', 'NUMERIC', 'PART AR EXTENSION', 'Start of AR process analysis', 10);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('part_lambda', 'NUMERIC', 'PART HP FILTERING', 'Lambda', 11);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('hpere_nblag', 'NUMERIC', 'HPERE AR EXTENSION', 'Order of AR model (p)', 12);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('hpere_const', 'NUMERIC', 'HPERE AR EXTENSION', 'use of a constant', 13);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('hpere_ar_start', 'NUMERIC', 'HPERE AR EXTENSION', 'Start of AR process analysis', 14);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('hpere_lambda', 'NUMERIC', 'HPERE HP FILTERING', 'Lambda', 15);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('iypot_nblag', 'NUMERIC', 'IYPOT AR EXTENTION', 'Order of AR model (p)', 16);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('iypot_const', 'NUMERIC', 'IYPOT AR EXTENTION', 'use of a constant', 17);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('iypot_ar_start', 'NUMERIC', 'IYPOT AR EXTENTION', 'Start of AR process analysis', 18);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_nblag', 'NUMERIC', 'GDP ARIMA EXTENSION', 'Order of AR model (p)', 19);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_diffs', 'NUMERIC', 'GDP ARIMA EXTENSION', 'Number of regular differences (d)', 20);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_ma_order', 'NUMERIC', 'GDP ARIMA EXTENSION', 'Order of MA model (q)', 21);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_const', 'BOOLNUM', 'GDP ARIMA EXTENSION', 'use of a constant', 22);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_transf', 'STR', 'GDP ARIMA EXTENSION', 'Transformation', 23);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_ar_start', 'NUMERIC', 'GDP ARIMA EXTENSION', 'Start of AR process analysis', 24);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_esmooth', 'STR', 'GDP ARIMA EXTENSION', '', 25);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_hp_start', 'NUMERIC', 'GDP HP FILTERING', 'Start of HP filtering', 26);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('gdp_lambda', 'NUMERIC', 'GDP HP FILTERING', 'Lambda', 27);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('starthp', 'NUMERIC', 'HP FILTERING', 'General starting year of filtering', 28);
INSERT Into OG_COUNTRY_PARAMS
    (PARAM_ID, DATA_TYPE, DESCR1, DESCR2, ORDER_BY)
 Values ('monitor', 'BOOL', 'Reporting', 'Set if the program has to prepare comparison report (possible only if OG are computed)', 29);
COMMIT;
