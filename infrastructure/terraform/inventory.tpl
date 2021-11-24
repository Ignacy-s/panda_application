[aws]
${ansible_ip}

[aws:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=../id_ed25519_aws-nopass
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
