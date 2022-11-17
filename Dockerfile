FROM jenkins/jenkins:lts

# Running as root to have an easy support for Docker
USER root

# A default admin user
ENV ADMIN_USER=admin \
    ADMIN_PASSWORD=password

# Jenkins init scripts
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/

# Install Jenkins plugins
RUN mkdir -p /usr/share/jenkins/ref/ && \
    echo lts > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state && \
    echo lts > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

# Install Docker, kubectl, awscli, maven and helm 
RUN apt-get update && apt install python3-pip -y && pip3 install awscli --upgrade
RUN apt-get -qq update && \
    apt-get -qq -y install curl && apt install maven -y && \
    curl -sSL https://get.docker.com/ | sh && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
RUN jenkins-plugin-cli --plugins "blueocean:1.25.3 docker-workflow:1.28 pipeline-utility-steps:2.12.1 git sonar:2.14 artifactory:3.16.2 ssh-agent ssh-credentials ssh-slaves ws-cleanup"
