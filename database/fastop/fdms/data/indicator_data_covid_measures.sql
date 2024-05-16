SET DEFINE OFF;

DECLARE
    o_res  NUMBER(8);
    l_round_sid ROUNDS.ROUND_SID%TYPE := CORE_GETTERS.getCurrentRoundSid('FDMS');
    l_storage_sid STORAGES.STORAGE_SID%TYPE := CORE_GETTERS.getCurrentStorageSid('FDMS');
BEGIN

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'AT',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,15.17241,14.469547,2.2885210000000002,0',2=>'0,0.0,0.0,0.0,0',3=>'0,-2.75,-3.0,-1.2,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'BE',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,18.2978,13.0639,2.3998,0',2=>'0,0.0,0.0436,0.0,0',3=>'0,-2.1841999999999997,-1.72097,-0.10137,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'BG',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,2.6542,5.2101,1.7208999999999999,0',2=>'0,0.7,0.0,0.0,0',3=>'0,0.0,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'CY',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,0.62427,0.6348,0.08,0',2=>'0,0.0,0.0,0.0,0',3=>'0,-0.1459,-0.0658,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'CZ',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,92.3,90.9,2.599999999999998,0',2=>'0,41.45,26.6,3.1000000000000014,0',3=>'0,-31.7,-2.7,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'DE',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,76.05,141.421,32.229,0',2=>'0,0.0,0.0,0.0,0',3=>'0,-13.575,-9.49,-0.035,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'DK',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,60.5,99.5,0.0,0',2=>'0,0.0,0.0,0.0,0',3=>'0,0.0,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'EE',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,0.296,0.7122,0.0,0',2=>'0,0.0,0.0,0.0,0',3=>'0,0.0,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'EL',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,5.033,6.37,1.77,0',2=>'0,4.572,3.636,0.352,0',3=>'0,-2.843,-1.882,-0.9,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'ES',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,44.392,29.131,4.019,0',2=>'0,0.0,9.55,2.0,0',3=>'0,8.95,0.709,-0.3,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'FI',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,5.561,4.218,0.66,0',2=>'0,0.0,0.75,0.0,0',3=>'0,-1.05,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'FR',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,76.7,60.55,12.95,0',2=>'0,-0.4,5.05,1.45,0',3=>'0,0.9,0.1,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'HR',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,1.0655999999999999,0.7392049999999999,0.07231999999999986,0',2=>'0,0.0,0.0,0.0,0',3=>'0,-0.02069,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'HU',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,553.64,444.1,76.85,0',2=>'0,1228.3600000000001,464.11,0.0,0',3=>'0,-117.34,-130.4,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'IE',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,13.77,12.089,3.481,0',2=>'0,0.0,0.0,0.0,0',3=>'0,0.0,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'IT',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,42.01605880677998,33.12966462493502,12.854391063999998,0',2=>'0,22.537089999999996,28.218542000000014,7.399446369710466,0',3=>'0,-6.803334079999999,0.45376250000000073,-0.19187000000000023,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'LT',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,0.6275,0.23659999999999998,0.14173,0',2=>'0,0.08331000000000001,0.009019999999999997,0.0013399999999999964,0',3=>'0,-0.055299999999999995,-0.07989999999999998,-0.1378,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'LU',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,1.168,0.516,0.083,0',2=>'0,0.107,0.024200000000000003,0.010000000000000004,0',3=>'0,-0.232,-0.004,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'LV',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,0.343,1.5743,0.43570000000000003,0',2=>'0,0.3237,0.085,0.045399999999999996,0',3=>'0,-0.1485,-0.03440000000000001,-0.0050999999999999995,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'MT',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,0.681225,0.46420000000000006,0.14399299999999998,0',2=>'0,0.009,0.0,0.0,0',3=>'0,-0.0845,-0.022798,0.0040019999999999995,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'NL',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,18.763999999999996,15.648,2.745999999999998,0',2=>'0,0.0,0.0,0.0,0',3=>'0,0.0,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'PL',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,92.2,60.1,22.6,0',2=>'0,13.2,3.2,0.0,0',3=>'0,0.0,-0.3,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'PT',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,3.3083700000000005,4.07337,1.2326400000000004,0',2=>'0,0.458,0.154,0.506,0',3=>'0,0.0,-0.0417,-0.06570000000000001,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'RO',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,16.50066,10.083409999999999,0.03867999999999966,0',2=>'0,0.0,0.0,0.0,0',3=>'0,-1.0659,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'SE',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,119.70000000000002,101.58999999999999,61.39,0',2=>'0,11.3,1.4000000000000004,0.0,0',3=>'0,-33.0,-5.0,-5.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'SI',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,2.2509999999999994,2.0961,0.5727000000000001,0',2=>'0,0.0,0.03,0.0,0',3=>'0,0.0,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);

  fdms_indicator.setIndicatorData(
    o_res => o_res, 
    p_app_id => 'FDMS',
    p_country_id => 'SK',
    p_indicator_ids => CORE_COMMONS.VARCHARARRAY(1=>'COVCUR.1.0.0.0',2=>'COVCAP.1.0.0.0',3=>'COVREV.1.0.0.0'), 
    p_provider_id => 'COVID', 
    p_periodicity_id => 'A', 
    p_scale_id => 'BILLION', 
    p_start_year => 2019, 
    p_time_series => CORE_COMMONS.VARCHARARRAY(1=>'0,1.891,3.195,0.846,0',2=>'0,0.188,0.047,0.032,0',3=>'0,-0.08525227114,0.0,0.0,0'), 
    p_user => 'MANUAL', 
    p_add_missing => 1,
    p_round_sid => l_round_sid,
    p_storage_sid => l_storage_sid);


  fdms_upload.setIndicatorDataUpload(
      p_round_sid => l_round_sid,
      p_storage_sid => l_storage_sid,
      p_provider_id => 'COVID',
      p_user => 'MANUAL', 
      o_res => o_res);        
END;
/