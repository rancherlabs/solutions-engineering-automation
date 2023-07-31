rke2_os_image_path = "./ubuntu-18.04-server-cloudimg-amd64.img"
rke2_cluster_storage_pool_path = "/tmp/rancher_rke2_tf"

rke2_join_token = "secrettoken"

rke2_server_ips = ["192.168.100.151"]
rke2_server_vcpu = 8
rke2_server_memory = 8096
rke2_server_disk_size = "26843545600"     # 1024 * 1024 * 1024 * 25 (Bytes)

rke2_add_server_ips = []

rke2_agent_ips = []
agent_vcpu = 2
agent_memory = 2048
agent_disk_size =  "26843545600"     #  1024 * 1024 * 1024 * 25 (Bytes)

install_rke2_version = "v1.24.14+rke2r1"
rancher_version = "2.7.5"
