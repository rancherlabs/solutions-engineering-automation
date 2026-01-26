#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Function to fetch namespaces and allow the user to select one
select_namespace() {
  namespaces=$(kubectl get ns --no-headers -o custom-columns=":metadata.name")
  
  # Prepare options with serial numbers
  menu_options=()
  count=1
  for ns in $namespaces; do
    menu_options+=("$count" "$ns")
    count=$((count + 1))
  done

  NAMESPACE_INDEX=$(whiptail --title "Select Namespace" --menu "Choose a namespace:" 20 70 10 "${menu_options[@]}" 3>&1 1>&2 2>&3)

  if [ $? != 0 ]; then
    echo "Namespace selection cancelled."
    exit 0
  fi

  # Map selected index back to namespace
  NAMESPACE=$(echo "$namespaces" | sed -n "${NAMESPACE_INDEX}p")
  echo "Selected namespace: $NAMESPACE"
}

# Function to fetch pods in the selected namespace and allow the user to select one
select_pod() {
  pods=$(kubectl get pods -n $NAMESPACE --no-headers -o custom-columns=":metadata.name")
  
  # Prepare options with serial numbers
  menu_options=()
  count=1
  for pod in $pods; do
    menu_options+=("$count" "$pod")
    count=$((count + 1))
  done

  POD_INDEX=$(whiptail --title "Select Pod" --menu "Choose a pod in namespace $NAMESPACE:" 20 70 10 "${menu_options[@]}" 3>&1 1>&2 2>&3)

  if [ $? != 0 ]; then
    echo "Pod selection cancelled."
    exit 0
  fi

  # Map selected index back to pod
  POD_NAME=$(echo "$pods" | sed -n "${POD_INDEX}p")
  echo "Selected pod: $POD_NAME"
}

# Function to fetch PID of the container
fetch_pid() {
  pod_id=$(crictl pods --namespace ${NAMESPACE} --name ${POD_NAME} -q)
  if [ -z "$pod_id" ]; then
    whiptail --title "Error" --msgbox "Pod ID not found for pod ${POD_NAME}. Exiting." 10 50
    exit 1
  fi

  container_id=$(crictl ps --pod ${pod_id} -q)
  if [ -z "$container_id" ]; then
    whiptail --title "Error" --msgbox "Container ID not found for pod ${POD_NAME}. Exiting." 10 50
    exit 1
  fi

  pid=$(crictl inspect --output json ${container_id} | jq -r '.info.pid')
  if [ -z "$pid" ] || [ "$pid" == "null" ]; then
    whiptail --title "Error" --msgbox "PID not found for container ${container_id}. Exiting." 10 50
    exit 1
  fi

  nsenter_parameters="-n -t ${pid}"
  echo "PID fetched: $pid"
}

# Function to run tcpdump
run_tcpdump() {
  OUTPUT_FILE="/tmp/${NAMESPACE}_${POD_NAME}_${HOSTNAME}_$(date +%d_%m_%Y-%H_%M_%S-%Z).pcap"
  whiptail --title "Running tcpdump" --msgbox "Starting packet capture on eth0. Output: $OUTPUT_FILE" 10 50
  nsenter $nsenter_parameters -- tcpdump -nni eth0 -w ${OUTPUT_FILE}

  whiptail --title "tcpdump Completed" --msgbox "Packet capture completed. File saved to: $OUTPUT_FILE" 10 50
  echo "Packet capture completed. File saved to: $OUTPUT_FILE"
}

# Main logic
select_namespace
select_pod
fetch_pid
run_tcpdump

