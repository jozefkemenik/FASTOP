DELIMITER //
DROP PROCEDURE IF EXISTS logStatistics
//
CREATE PROCEDURE logStatistics(
    IN p_user_id TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
  , IN p_agent   TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
  , IN p_addr    TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
  , IN p_uri     TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
  , IN p_source  TEXT CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    INSERT INTO statistique(userid, datein, agent, addr, uri, source)
    VALUES (p_user_id, now(), p_agent, p_addr, p_uri, p_source);

    SELECT LAST_INSERT_ID();
END
//
DELIMITER ;
