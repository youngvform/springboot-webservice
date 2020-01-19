#!/usr/bin/env bash

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
source $ABSDIR/profile.sh
source $ABSDIR/switch.sh

IDLE_PORT=$(find_idle_port)

echo "> Health Check start"
echo "> IDLE_PORT: $IDLE_PORT"
echo "> curl -s http://localhost:$IDLE_PORT/profile"
sleep 10

for RETRY_COUNT in {1..10}
do
  RESPONSE=$(curl -s http://localhost:${IDLE_PORT}/profile)
  UP_COUNT=$(echo ${RESPONSE} | grep 'real' | wc -l)

  if [ ${UP_COUNT} -ge 1 ]
  then
    echo "> Health Check Success"
    switch_proxy
    break
  else
    echo "> Health Check 응답할 수 없거나 실행상태가 아님"
    echo "> Health Check: ${RESPONSE}"
  fi

  if [ ${RETRY_COUNT} -eq 10 ]
  then
    echo "> Health Check Fail"
    echo "> 엔진엑스에 연결하지 않고 배포 종료"
    exit 1
  fi

  echo "> Health Check 연결 실패. 재시도..."
  sleep 10
done




