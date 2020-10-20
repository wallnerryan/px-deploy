#!/bin/bash

kubectl delete -f mysql-ontap-san.yml -n mysql-ontap

kubectl delete ns mysql-ontap

kubectl delete -f iscsi-storageclass.yml

./root/trident-installer/tridentctl -n trident delete backend ontapsan