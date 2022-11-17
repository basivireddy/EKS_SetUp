pipeline{
    agent any
    stages {
        stage('Initialize'){
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-key', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                        script {
                            final scmVars = checkout(scm)
                            echo "scmVars: ${scmVars}"
                            echo "scmVars.GIT_BRANCH: ${scmVars.GIT_BRANCH}"
                            branchName = sh(
                                label: "getBranchName", 
                                    returnStdout: true, 
                                    script: """
                                        echo "${scmVars.GIT_BRANCH}" | cut -d '/' -f 2
                                    """).trim()
                            println branchName
                            if("${branchName}" == "master") {
                                deployEnv = "prod"
                                shouldDeploy = true
                                cluster_name = "prod-eks-cluster"
                            }else if("${branchName}" == 'develop') {
                                        deployEnv = "nonprod"
                                        shouldDeploy = true
                                        cluster_name = "nonprod-eks-cluster"
                            }else {
                                shouldDeploy = false
                            }
                            println deployEnv
                            def exists = fileExists '/var/lib/jenkins/.aws/credentials'
                            if (exists) {
                                echo '\u2776 aws Configuration file detected so skiping awscli configuration'
                            }else{
                                sh  'cp -r .aws /var/lib/jenkins && echo "[default]" | cat >>  /var/lib/jenkins/.aws/credentials'
                                sh  ('#!/bin/sh -e\n' + 'echo  "aws_access_key_id = '+AWS_ACCESS_KEY_ID+'" | cat >> /var/lib/jenkins/.aws/credentials &&  echo  "aws_secret_access_key = '+AWS_SECRET_ACCESS_KEY+'" | cat >> /var/lib/jenkins/.aws/credentials')
                            }
                            println "${deployEnv}"          
                        }
                }
            }
        }
        stage('Plan Infrastructure') {
            steps {      
                script {
                    println "${deployEnv}"
                    dir("${WORKSPACE}/terraform/Environments/${deployEnv}") {
                            echo "\u2776 Terraform"
                            sh """
                                terraform init -var-file=${deployEnv}.tfvars
                                terraform plan -var-file=${deployEnv}.tfvars -out=tfplan
                            """
                            stash includes: 'tfplan', name: 'output'
                        }
                }
            }
        }
        stage('Deploy') {
            when {
                allOf {
                    expression{shouldDeploy == true}
                }
            }
            steps {
                dir("${WORKSPACE}/terraform/Environments/${deployEnv}") {
                    unstash 'output'
                    echo "\u2776 Terraform"
                    sh """
                        terraform apply tfplan
                    """
                }
            }
        }
        stage('Jenkins Installation On Eks') {
            steps{
                withCredentials([usernamePassword(credentialsId: 'account_creds', passwordVariable: 'region', usernameVariable: 'awsaccount')]) {
                    script{
                    sh "aws eks update-kubeconfig --name ${cluster_name}"
                    sh '$(aws ecr get-login --region '+region+' --no-include-email) > /dev/null'
                    sh '''
                        docker build -t jenkins .
                        docker tag jenkins:latest "${awsaccount}".dkr.ecr."${region}".amazonaws.com/jenkins:latest
                        docker push "${awsaccount}".dkr.ecr."${region}".amazonaws.com/jenkins:latest
                    '''
                    echo "Setting up storage class"
                    sh '''
                        kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
                        kubectl apply -f storageclass.yaml
                        kubectl apply -f jenkins-sa.yaml
                        kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
                        echo 'Jenkins installation started'
                        helm upgrade --install jenkins   --set jenkinsUser=admin --set serviceAccountName=jenkins-admin --set persistence.size=20Gi  --set service.type=LoadBalancer --set image.repository="${awsaccount}".dkr.ecr."${region}".amazonaws.com/jenkins --set image.tag=latest ./jenkins-k8s
                    ''' 
                    }
                }
            }
        }
        stage('Jfrog'){
            steps{
                script{
                    echo "Jfrog Installtion started"
                    sh '''
                        helm repo add jfrog https://charts.jfrog.io
                        helm repo update
                        helm upgrade --install artifactory --set postgresql.enabled=false  --set nginx.service.type=LoadBalancer jfrog/artifactory
                    '''
                }
            }
        }
        stage('Sonarqube'){
            steps{
                script{
                    sh '''
                        helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
                        helm repo update
                        helm upgrade --install  sonarqube sonarqube/sonarqube  --set service.type=LoadBalancer
                    '''
                }
            }
        }
        stage('ELk stack'){
            steps{
                script{
                    sh '''
                        helm repo add elastic https://helm.elastic.co
                        helm repo update
                        helm upgrade --install elasticsearch elastic/elasticsearch 
                        helm upgrade --install kibana elastic/kibana --set service.type=LoadBalancer
                        helm upgrade --install metricbeat elastic/metricbeat
                    '''
                }
            }
        }
        stage('owaps'){
            steps{
                script{
                    sh '''
                        helm repo add simplyzee https://charts.simplyzee.dev/
                        helm upgrade --install "vuln-scan-$(date '+%Y-%m-%d-%H-%M-%S')-job" simplyzee/kube-owasp-zap \
                            --set zapcli.debug.enabled=true \
                            --set zapcli.spider.enabled=false \
                            --set zapcli.recursive.enabled=false \
                             --set zapcli.targetHost=example.com
                    '''
                }
            }
        }
        stage('Application_Urls') {
            steps{
                script{
                    Jenkins_URL = sh(
                                    label: "getUrl", 
                                    returnStdout: true, 
                                    script: "kubectl get svc | grep jenkins | awk '{print \$4}'"
                                  ).trim()
                    Jfrog_URL = sh(
                                    label: "getUrl", 
                                    returnStdout: true, 
                                    script: "kubectl get svc | grep artifactory-artifactory-nginx | awk '{print \$4}'"
                                  ).trim()
                    Sonarqube_URL = sh(
                                    label: "getUrl", 
                                    returnStdout: true, 
                                    script: "kubectl get svc | grep sonarqube-sonarqube | awk '{print \$4}'"
                                  ).trim()
                    Kibana_URL = sh(
                                    label: "getUrl", 
                                    returnStdout: true, 
                                    script: "kubectl get svc | grep kibana | awk '{print \$4}'"
                                  ).trim()
                    println "Jenkins_URL:  http://${Jenkins_URL}:8080"
                    println "Jfrog_URL: http://${Jfrog_URL}"
                    println "Sonarqube_URL: http://${Sonarqube_URL}:9000"
                    println "Kibana_URL:  http://${Kibana_URL}:5601"
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}