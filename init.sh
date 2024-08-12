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


# Docker build
docker build -t jenkins .

# Jenkins 컨테이너 실행
container_id=$(docker run -dit --restart=always -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins)

# 소켓 권한 설정
docker exec -u root $container_id chown root:docker /var/run/docker.sock

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
