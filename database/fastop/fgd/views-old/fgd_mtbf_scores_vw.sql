CREATE OR REPLACE FORCE VIEW FGD_MTBF_SCORES_VW (FRAME_SID, C1A, C1B, C2A, C2B, C2C, C3, C4, C5A, C5B,C5C, C5D) AS 
  SELECT
        FRAME_SID,
        "'c1a'",
                "'c1b'",
                "'c2a'",
                "'c2b'",
                "'c2c'",
                "'c3'",
                "'c4'",
                "'c5a'",
                "'c5b'",
                "'c5c'",
                "'c5d'"
    FROM
        (
            SELECT
                FRAME_SID,
                criterion,
                score
            FROM
                (
                    SELECT
                        rc.FRAME_SID,
                        c.criterion_id || c.sub_criterion_id criterion,
                        rc.score,
                        sv.order_by,
                        MAX(sv.order_by) OVER(
                            PARTITION BY rc.FRAME_SID, rc.criterion_sid
                        ) max_order_by
                    FROM
                        fgd_mtbf_frame_criteria    rc
                        JOIN fgd_idx_criteria         c ON c.criterion_sid = rc.criterion_sid
                        JOIN fgd_idx_score_versions   sv ON sv.score_version_sid = rc.score_version_sid
                    WHERE
                        rc.score IS NOT NULL
                        AND rc.round_sid = core_getters.getcurrentroundsid('FGD')
                )
            WHERE
                order_by = max_order_by
        ) PIVOT (
            MAX ( score )
            FOR criterion
            IN ( 'c1a',
                'c1b',
                'c2a',
                'c2b',
                'c2c',
                'c3',
                'c4',
                'c5a',
                'c5b',
                'c5c',
                'c5d')
        );