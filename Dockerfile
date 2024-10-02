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

# if you run docke in macos, use [--platform linux/amd64]
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

    
RUN mkdir -p /var/thinbackups
RUN mkdir -p /var/jenkins_home/.ssh

RUN chown -R jenkins:jenkins /var/jenkins_home
RUN chown -R jenkins:jenkins /var/thinbackups
RUN chown -R jenkins:jenkins /var/jenkins_home/.ssh

USER jenkins