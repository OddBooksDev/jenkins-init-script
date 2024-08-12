FROM jenkins/jenkins:lts

COPY plugins.txt /usr/share/jenkins/ref/plugins/plugins.txt

USER root

# Docker 설치
RUN apt update && curl -fsSL https://get.docker.com | sh

# jenkins 사용자를 docker 그룹에 추가
RUN usermod -aG docker jenkins

# 플러그인 설치
RUN mkdir -p /usr/share/jenkins/ref/plugins && chown -R jenkins:jenkins /usr/share/jenkins/ref/plugins
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins/plugins.txt --verbose

USER jenkins

RUN chown -R jenkins:jenkins /var/jenkins_home

