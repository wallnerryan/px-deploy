#!/bin/bash

./root/trident-installer/tridentctl -n trident create backend -f /assets/trident/backend-ontap-san.json

kubectl create -f iscsi-storageclass.yml

kubectl create ns mysql-ontap

kubectl create -f mysql-ontap-san.yml -n mysql-ontap

#wait for operator
echo "waiting for MySQL to come up"
until kubectl get deployment -n mysql-ontap -l app=mysql | grep "1/1"
do
  echo "waiting, then trying again"
  sleep 3
done

echo "MySQL Ready..."
sleep 1
echo "Fetching K8s node MySQL is running on..."
origin_node=$(kubectl get deployment -n mysql-ontap -l app=mysql -o wide | tail -n 1 | awk '{print $7}')

echo "Shutting down ${origin_node}"
cat <<EOF | ssh ${origin_node}
echo "shutdown -h now" >> /tmp/halt-node.sh
EOF

cat <<EOF | ssh ${origin_node}
nohup sh /tmp/halt-node.sh`</dev/null` >nohup.out 2>&1 &
EOF

echo "Observe behavior with: "
echo ""
echo "watch kubectl get no"
echo "watch kubectl get po -n mysql-ontap -o wide"
echo "kubectl describe po <newPod> -n mysql-ontap"

