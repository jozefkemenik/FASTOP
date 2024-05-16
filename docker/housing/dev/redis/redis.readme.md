### Redis for local windows development.

**machine**: fp-py-d.cc.cec.eu.int  
**folder**: /ec/prod/srv-fastop/redis  
**start redis**: podman-compose up -d  
**stop redis**: podman-compose down  
**access redis-cli**: podman exec -it redis_server redis-cli  
**redis basic commands**:  
 * KEYS * : list all stored keys
 * GET <key> : return stored value
 * TTL <key>: get the remaining time of key expiry in seconds
 * INFO : return information and statistics about the server 

Restart redis:
cd $REDIS
./stop_redis.sh
./start_redis.sh
