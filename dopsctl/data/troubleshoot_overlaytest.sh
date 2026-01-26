#!/bin/bash

set -e

echo "=> Deploying the overlaytest DaemonSet"
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: overlaytest
spec:
  selector:
      matchLabels:
        name: overlaytest
  template:
    metadata:
      labels:
        name: overlaytest
    spec:
      tolerations:
      - operator: Exists
      containers:
      - image: rancherlabs/swiss-army-knife
        imagePullPolicy: Always
        name: overlaytest
        command: ["sh", "-c", "tail -f /dev/null"]
        terminationMessagePath: /dev/termination-log
EOF

echo "=> Waiting for DaemonSet to roll out"
kubectl rollout status ds/overlaytest -w

# Pause for 5 seconds
echo "=> Pausing for 5 seconds before starting the network test"
sleep 5

# Run the overlay network test
echo "=> Starting the overlay network test"

echo "--------------------------------------"
echo
kubectl get pods -l name=overlaytest -o jsonpath='{range .items[*]}{@.metadata.name}{" "}{@.spec.nodeName}{"\n"}{end}' |
while read spod shost
do
  kubectl get pods -l name=overlaytest -o jsonpath='{range .items[*]}{@.status.podIP}{" "}{@.spec.nodeName}{"\n"}{end}' |
  while read tip thost
  do
    kubectl --request-timeout='10s' exec $spod -c overlaytest -- /bin/sh -c "ping -c2 $tip > /dev/null 2>&1"
    RC=$?
    if [ $RC -ne 0 ]; then
      echo "FAIL: $spod on $shost cannot reach pod IP $tip on $thost"
    else
      echo "$shost can reach $thost"
    fi
  done
done

echo
echo
echo "--------------------------------------"
echo "=> Network overlay test completed"
echo
echo
# Prompt to delete the DaemonSet
read -p "Do you want to clean up the DaemonSet? (y/n): " confirm
if [[ $confirm == "y" || $confirm == "Y" ]]; then
  echo "=> Cleaning up the DaemonSet"
  kubectl delete ds/overlaytest
  echo "=> Cleanup completed"
else
  echo "=> DaemonSet retained for further inspection"
fi

echo "=> Script execution completed"

