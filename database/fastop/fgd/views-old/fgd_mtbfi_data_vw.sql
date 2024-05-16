CREATE OR REPLACE VIEW FGD_MTBFI_DATA_VW AS
WITH t AS (
    SELECT f.frame_sid as rule_sid,
           f.country_id,
           ROUND((sc.C1A + sc.C1B) / 4 , 4) as sdim1,
           ROUND((sc.C2A + sc.C2B + sc.C2C) / 6, 4) as sdim2,
           ROUND((sc.C3 / 3), 4) as sdim3,
           ROUND((sc.C4 / 4), 4) as sdim4,
           ROUND((sc.C5A + sc.C5B + sc.C5C + sc.C5D) / 4, 4) as sdim5
      FROM fgd_mtbf_frames f,
           fgd_mtbf_scores_vw sc
     WHERE f.frame_sid = sc.frame_sid
)
    SELECT
        t.rule_sid,
        t.country_id,
        ROUND(NVL(t.sdim1, 0), 2) as sdim1,
        ROUND(NVL(t.sdim2, 0), 2) as sdim2,
        ROUND(NVL(t.sdim3, 0), 2) as sdim3,
        ROUND(NVL(t.sdim4, 0), 2) as sdim4,
        ROUND(NVL(t.sdim5, 0), 2) as sdim5,
        NVL(ROUND((t.sdim1 + t.sdim2 + t.sdim3 + t.sdim4 + t.sdim5)/5, 2), 0) as mtbfi
    FROM t;
    
