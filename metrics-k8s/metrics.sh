#!/bin/bash

git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git

cd kubernetes-metrics-server/

kubectl create -f .

