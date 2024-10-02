#!/bin/bash

# 색상 코드 정의
GREEN='\033[0;32m'
NC='\033[0m' # No Color

normalize_input() {
    case "$1" in
        [Yy] | [Yy][Ee][Ss])
            echo "yes"
            ;;
        [Nn] | [Nn][Oo])
            echo "no"
            ;;
        *)
            echo "no"
            ;;
    esac
}

echo -e "${GREEN}Is there a volume attached to your container that handles data persistence? (yes/no): ${NC}"
read volume_check

volume_check=$(normalize_input "$volume_check")

if [[ $volume_check == "yes" ]]; then
    echo -e "${GREEN}No need to move data from inside the container. Proceed with the next steps.${NC}"
else
    echo -e "${GREEN}Current running containers:${NC}"
    docker ps

    echo -e "${GREEN}Please enter the Docker container name: ${NC}"
    read container_name
    echo -e "${GREEN}Enter the path of data inside the container: ${NC}"
    read container_data_path
    echo -e "${GREEN}Enter the path on the host to store data: ${NC}"
    read host_data_path

    # Copy data from container to host
    docker cp ${container_name}:${container_data_path} ${host_data_path}
    echo "Data copied from container to host."
fi


# 첫 번째 인자로 SSH 설정 이름 확인
if [ -z "$1" ]; then
    # 인자가 제공되지 않은 경우 사용자 입력 받기
    echo -e "${GREEN}Enter the SSH configuration name (from .ssh/config) for the PEM key transfer: ${NC}"
    read ssh_config_name
else
    # 첫 번째 인자 사용
    ssh_config_name=$1
fi

# PEM 키 경로 입력 받기
echo -e "${GREEN}Enter the path of the PEM key on your local machine: ${NC}"
read pem_key_path
echo -e "${GREEN}Enter the destination path on the remote server to save the PEM key: ${NC}"
read destination_path

# rsync를 사용한 PEM 키 전송
echo "Transferring the PEM key..."
rsync -avz -e $pem_key_path ${ssh_config_name}:${destination_path}

echo "PEM key has been transferred."
