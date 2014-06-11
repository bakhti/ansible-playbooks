#!/bin/bash
# run: AWS_CONFIG_FILE=/root/.aws_config /root/bin/get_logs_from_s3.sh [trail|elb]

read Y M D H <<< $(date +"%Y %m %d %H")
ACCNUM=000000000000
BCKT=${1}-logs
declare -A REG SRVC PORT
REG=([trail]=us-east-1 [elb]=us-east-1)
SRVC=([trail]=CloudTrail [elb]=elasticloadbalancing)
PORT=([trail]=3333 [elb]=3334)
PREFIX=AWSLogs/${ACCNUM}/${SRVC[${1}]}/${REG[${1}]}/${Y}/${M}/${D}
LDIR=/tmp/${SRVC[${1}]}

[ -d $LDIR/$D ] || mkdir -p $LDIR/$D
[ -d ${LDIR}-split/$D ] || mkdir -p ${LDIR}-split/$D

aws s3 sync s3://${BCKT}/${PREFIX}/ ${LDIR}/$D/ --quiet

for GZF in $LDIR/$D/*; do
    if [ ${GZF:(-3)} = ".gz" ]; then
	if [ ! -f ${LDIR}-split/$D/$(basename ${GZF/%.gz}) ]; then
	    gunzip --to-stdout $GZF |jq -r -M .Records[] -c |tee >(nc -w 1 127.0.0.1 ${PORT[${1}]}) > ${LDIR}-split/$D/$(basename ${GZF/%.gz})
	fi
    elif [ ! -f ${LDIR}-split/$D/$(basename ${GZF}) ]; then
	cat $GZF |tee >(nc -w 1 127.0.0.1 ${PORT[${1}]}) > ${LDIR}-split/$D/$(basename ${GZF})
    fi
done

if [ $H == "03" ]; then rm -rf $LDIR{,-split}/$(($D - 1)); fi
