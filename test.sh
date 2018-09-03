#!/usr/bin/env bash

#*********** TEST LOCATIONS ***************************
curl http://localhost/probe_local
curl http://localhost/probe_applicant
curl http://localhost/probe_remote
curl http://localhost/*

#*********** TEST LOADBALANCING **********************
for run in {1..10}
do
  curl http://localhost/probe_local
done

curl http://localhost/probe_local
curl http://localhost/probe_local
curl http://localhost/probe_local
curl http://localhost/probe_local
curl http://localhost/probe_local

#*********** TEST FAILOVER **********************
ssh 192.168.30.4 'sudo service nginx stop'
for run in {1..4}
do
  curl http://localhost/probe_local
done
ssh 192.168.30.4 'sudo service nginx start'
for run in {1..4}
do
  curl http://localhost/probe_local
done

#********** PERFORMANCE TESTING *****************
for run in {1..10000}
do
  curl http://localhost/probe_local
done
