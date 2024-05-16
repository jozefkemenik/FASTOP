CREATE OR REPLACE FORCE EDITIONABLE VIEW "FASTOP"."FGD_IFI_SCORES_VW" ("INSTITUTION_SID", "TK1A", "TK1B", "TK1C", "CTK1", "TK2A", "TK2B", "TK2C", "CTK2", "TK3A", "TK3B", "CTK3", "TK4", "TK5", "TK6") AS 
  SELECT
        institution_sid,
        "'tk1a'",
        "'tk1b'",
        "'tk1c'",
        "'Ctk1'",
        "'tk2a'",
        "'tk2b'",
        "'tk2c'",
        "'Ctk2'",
        "'tk3a'",
        "'tk3b'",
        "'Ctk3'",
        "'tk4'",
        "'tk5'",
        "'tk6'"
    FROM
        (
            SELECT
                institution_sid,
                criterion,
                score
            FROM
                (
                    SELECT
                        rc.institution_sid,
                        c.criterion_id || c.sub_criterion_id criterion,
                        rc.score,
                        sv.order_by,
                        MAX(sv.order_by) OVER(
                            PARTITION BY rc.institution_sid, rc.criterion_sid
                        ) max_order_by
                    FROM
                        fgd_ifi_inst_criteria    rc
                        JOIN fgd_idx_criteria         c ON c.criterion_sid = rc.criterion_sid
                        JOIN fgd_idx_score_versions   sv ON sv.score_version_sid = rc.score_version_sid
                    WHERE
                        rc.score IS NOT NULL
                        AND rc.round_sid IS NULL OR rc.round_sid = core_getters.getLatestApplicationRound('FGD', TO_NUMBER(CORE_GETTERS.getParameter('CURRENT_ROUND')), 0)
                )
            WHERE
                order_by = max_order_by
        ) PIVOT (
            MAX ( score )
            FOR criterion
            IN ( 'tk1a',
            'tk1b',
            'tk1c',
            'Ctk1',
            'tk2a',
            'tk2b',
            'tk2c',
            'Ctk2',
            'tk3a',
            'tk3b',
            'Ctk3',
            'tk4',
            'tk5',
            'tk6' )
        );
