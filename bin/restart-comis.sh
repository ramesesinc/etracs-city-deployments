#!/bin/sh
RUN_DIR=`pwd`
cd ..
BASE_DIR=`pwd`

cd $BASE_DIR/appserver/comis && docker-compose down

cd $BASE_DIR/appserver/comis && docker-compose up -d

cd $BASE_DIR/appserver/comis && docker-compose logs -f

cd $RUN_DIR
