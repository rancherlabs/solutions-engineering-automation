ubuntu_image_path = "/home/skanakala/Downloads/mylab/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
k3s_cluster_pools = "/home/skanakal/Downloads/k3s_cluster_pools"

k3s_join_token = "secrettoken"

k3s_server_ips = ["192.168.122.145"]
k3s_worker_ips = ["192.168.122.146"]
vm_vcpu = 4
vm_memory = 4096
vm_disk_size = "26843545600"     # 1024 * 1024 * 1024 * 10 (Bytes)

install_k3s_version="v1.25.11+k3s1"