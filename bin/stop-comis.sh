#!/bin/sh
RUN_DIR=`pwd`
cd ../appserver/comis
docker-compose down
docker system prune -f
cd $RUN_DIR
