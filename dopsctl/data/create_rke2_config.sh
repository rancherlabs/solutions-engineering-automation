#!/bin/bash
create_rke2_config() {
clear
    # Check if the RKE2 directory and config.yaml file exist
    if [ -d "/etc/rancher/rke2/" ] && [ -f "/etc/rancher/rke2/config.yaml" ]; then
        echo "RKE2 configuration directory and config.yaml file already exist."
        read -p "Do you want to view the existing config.yaml (y/n)? " view_existing
        if [ "$view_existing" == "y" ]; then
            cat /etc/rancher/rke2/config.yaml
        fi

        read -p "Select an option:
1. Append to the existing config.yaml
2. Clean (erase) the existing config.yaml
3. Exit
Enter the option (1/2/3): " config_option

        case "$config_option" in
            "1")
                ;;
            "2")
                > /etc/rancher/rke2/config.yaml  # Clean the file
                echo "Cleared the existing config.yaml."
                ;;
            "3")
                exit
                ;;
            *)
                echo "Invalid option. Please choose 1, 2, or 3."
                ;;
        esac
    else
        mkdir -p /etc/rancher/rke2/
        touch /etc/rancher/rke2/config.yaml
    fi
    echo
    read -p "Select an option:
1. Configure network
2. Add control plane node
3. Add worker node
Enter the option (1/2/3): " option

    if [ "$option" == "1" ]; then
        configure_network
    elif [ "$option" == "2" ]; then
        add_control_plane_node
    elif [ "$option" == "3" ]; then
        add_worker_node
    else
        echo "Invalid option. Please choose 1, 2, or 3."
    fi


clear
echo "cat /etc/rancher/rke2/config.yaml"
cat /etc/rancher/rke2/config.yaml
echo; echo ; echo
read -p "Press Enter to continue..."
}

configure_network() {
    read -p "Select a network option:
1. Create Multus
2. Create Calico
3. Create Cilium
4. Create Flannel
Enter the option (1/2/3): " network_option

    if [ "$network_option" == "1" ]; then
        # Add Multus configuration
        append_to_cni_section "multus"
    elif [ "$network_option" == "2" ]; then
        # Add Calico configuration
        append_to_cni_section "calico"
    elif [ "$network_option" == "3" ]; then
        # Add Cilium configuration
        append_to_cni_section "cilium"
    elif [ "$network_option" == "4" ]; then
        # Add Cilium configuration
        append_to_cni_section "flannel"
    else
        echo "Invalid network option. Please choose 1, 2, 3, or 4."
    fi

}

add_control_plane_node() {
    # Check if the server URL and token are already present
    if grep -q "server:" /etc/rancher/rke2/config.yaml && grep -q "token:" /etc/rancher/rke2/config.yaml; then
        echo "Server URL and token are already present in the config.yaml file."
        return
    fi

    read -p "Select an option for control plane node:
1. Create a normal control plane node
2. Create a dedicated etcd node
3. Create a dedicated control plane node
Enter the option (1/2/3): " cp_option

    case "$cp_option" in
        "1")
            # Option 1: Create a normal CP node
            read -p "Enter the server URL (e.g., https://<server>:9345): " server_url
            read -p "Enter the token from the server node: " token
            # Add control plane node configuration to config.yaml
            echo "server: $server_url" >> /etc/rancher/rke2/config.yaml
            echo "token: $token" >> /etc/rancher/rke2/config.yaml
            ;;
        "2" | "3")
            # Option 2 or 3: Create a dedicated etcd or CP node
            read -p "Enter the server URL (e.g., https://<server>:9345): " server_url
            read -p "Enter the token from the server node: " token
            echo "server: $server_url" >> /etc/rancher/rke2/config.yaml
            echo "token: $token" >> /etc/rancher/rke2/config.yaml
            if [ "$cp_option" == "2" ]; then
                # Option 2: Create a dedicated etcd node
                echo "disable-apiserver: true" >> /etc/rancher/rke2/config.yaml
                echo "disable-controller-manager: true" >> /etc/rancher/rke2/config.yaml
                echo "disable-scheduler: true" >> /etc/rancher/rke2/config.yaml
            elif [ "$cp_option" == "3" ]; then
                # Option 3: Create a dedicated CP node
                echo "disable-etcd: true" >> /etc/rancher/rke2/config.yaml
            fi
            ;;
        *)
            echo "Invalid option. Please choose 1, 2, or 3."
            ;;
    esac
}

add_worker_node() {
    # Check if the server URL and token are already present
    if grep -q "server:" /etc/rancher/rke2/config.yaml && grep -q "token:" /etc/rancher/rke2/config.yaml; then
        echo "Server URL and token are already present in the config.yaml file."
        return
    fi

    read -p "Enter the server URL (e.g., https://<server>:9345): " server_url
    read -p "Enter the token from the server node: " token

    # Add worker node configuration to config.yaml
    echo "server: $server_url" >> /etc/rancher/rke2/config.yaml
    echo "token: $token" >> /etc/rancher/rke2/config.yaml
}

append_to_cni_section() {
    local cni_type="$1"
    if grep -q "cni:" /etc/rancher/rke2/config.yaml; then
        # Append to existing "cni" section
        sed -i "/cni:/a\\
  - $cni_type" /etc/rancher/rke2/config.yaml
    else
        # Add a new "cni" section
        echo "cni:" >> /etc/rancher/rke2/config.yaml
        echo "  - $cni_type" >> /etc/rancher/rke2/config.yaml
    fi
}

#create_rke2_config
#echo "cat /etc/rancher/rke2/config.yaml"
#cat /etc/rancher/rke2/config.yaml

create_rke2_config
