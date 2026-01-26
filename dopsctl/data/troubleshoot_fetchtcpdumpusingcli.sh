#!/bin/bash

# Step 1: Fetch namespaces and prompt user to select one
echo "Fetching available namespaces..."
namespaces=$(kubectl get ns --no-headers -o custom-columns=":metadata.name")
if [ -z "$namespaces" ]; then
    echo "No namespaces found. Exiting."
    exit 1
fi

echo "Available namespaces:"
select NAMESPACE in $namespaces; do
    if [ -n "$NAMESPACE" ]; then
        echo "You selected namespace: $NAMESPACE"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Step 2: Fetch pods in the selected namespace and prompt user to select one
echo "Fetching available pods in namespace $NAMESPACE..."
pods=$(kubectl get pods -n $NAMESPACE --no-headers -o custom-columns=":metadata.name")
if [ -z "$pods" ]; then
    echo "No pods found in namespace $NAMESPACE. Exiting."
    exit 1
fi

echo "Available pods:"
select POD_NAME in $pods; do
    if [ -n "$POD_NAME" ]; then
        echo "You selected pod: $POD_NAME"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Step 3: Fetch Pod ID, Container ID, and PID
echo "Fetching Pod ID..."
pod_id=$(crictl pods --namespace ${NAMESPACE} --name ${POD_NAME} -q)
if [ -z "$pod_id" ]; then
    echo "Error: Pod ID not found for pod ${POD_NAME} in namespace ${NAMESPACE}. Exiting."
    exit 1
fi

echo "Fetching Container ID..."
container_id=$(crictl ps --pod ${pod_id} -q)
if [ -z "$container_id" ]; then
    echo "Error: Container ID not found for pod ${POD_NAME} (Pod ID: ${pod_id}). Exiting."
    exit 1
fi

echo "Fetching PID..."
pid=$(crictl inspect --output json ${container_id} | jq -r '.info.pid')
if [ -z "$pid" ] || [ "$pid" == "null" ]; then
    echo "Error: PID not found for container ${container_id}. Exiting."
    exit 1
fi

# Step 4: Construct nsenter parameters
nsenter_parameters="-n -t ${pid}"

# Step 5: List interfaces
echo "Listing network interfaces inside the container:"
nsenter $nsenter_parameters -- ip a

# Step 6: Prompt for network interface
read -p "Enter the network interface to capture packets (e.g., eth0): " INTERFACE
if [ -z "$INTERFACE" ]; then
    echo "No interface provided. Exiting."
    exit 1
fi

# Step 7: Start tcpdump
OUTPUT_FILE="/tmp/${NAMESPACE}_${POD_NAME}_${HOSTNAME}_$(date +%d_%m_%Y-%H_%M_%S-%Z).pcap"
echo "Starting tcpdump on interface ${INTERFACE}. Output file: ${OUTPUT_FILE}"
nsenter $nsenter_parameters -- tcpdump -nn -i ${INTERFACE} -w ${OUTPUT_FILE} ${TCPDUMP_EXTRA_PARAMS}

# Step 8: Completion message
echo "Packet capture completed. Saved to: ${OUTPUT_FILE}"

~                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
~                                                                                  
