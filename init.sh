#!/bin/bash
# install docker
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
sudo service docker start

echo "========================"
echo
echo "==  Docker installed  =="
echo
echo "========================"


NETWORK_NAME="uponati-network"
CURRENT_DIR=$(pwd)

# Docker 네트워크가 존재하는지 확인하고, 없으면 생성
if ! docker network ls | grep -q "${NETWORK_NAME}"; then
  echo "Docker 네트워크 '${NETWORK_NAME}'가 존재하지 않습니다. 새 네트워크를 생성합니다."
  docker network create ${NETWORK_NAME}
else
  echo "Docker 네트워크 '${NETWORK_NAME}'가 이미 존재합니다."
fi

mkdir -p $CURRENT_DIR/thinbackups
mkdir -p $CURRENT_DIR/jenkins_home
mkdir -p $CURRENT_DIR/.jenkins_ssh

# 권한 설정(Jenkins Coantiner에서 jenkins user는 pid 1000, gid 1000으로 사용함)
sudo chown -R 1000:1000 $CURRENT_DIR/jenkins_home
sudo chown -R 1000:1000 $CURRENT_DIR/thinbackups
sudo chown -R 1000:1000 $CURRENT_DIR/.jenkins_ssh

# Docker build
docker build -t jenkins .

# Jenkins 컨테이너 실행
container_id=$(docker run -dit --network uponati-network --name jenkins --restart=always -p 8080:8080 -p 50000:50000 \
-v $CURRENT_DIR/thinbackups:/var/thinbackups \
-v $CURRENT_DIR/jenkins_home:/var/jenkins_home \
-v $CURRENT_DIR/.jenkins_ssh:/var/jenkins_home/.ssh \
-v /var/run/docker.sock:/var/run/docker.sock jenkins)

# 소켓 권한 설정
sudo docker exec -u root $container_id chown root:docker /var/run/docker.sock
sudo docker exec -u root $container_id chmod 660 /var/run/docker.sock

echo "Jenkins 초기화 대기 중..."
sleep 30

initial_admin_password=$(docker exec $container_id cat /var/jenkins_home/secrets/initialAdminPassword)
public_ip=$(curl -s http://checkip.amazonaws.com)

echo "========================"
echo
echo "Jenkins 컨테이너가 실행되었습니다. [ $container_id ]"
echo "브라우저에 접속하는 IP: $public_ip"
echo "초기 관리자 비밀번호: $initial_admin_password"
echo
echo "========================"
