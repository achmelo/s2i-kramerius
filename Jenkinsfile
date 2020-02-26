 
node {	

	stage('Build Images'){
		dir("${env.WORKSPACE}") {
			checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/achmelo/s2i-kramerius.git']]])
			sh 'docker build -t kramerius-builder .'
			s2i build --incremental=true --exclude="" https://github.com/moravianlibrary/kramerius.git kramerius-builder harbor.nkp.cz:30004/library/kramerius -r master
		}
	}	
	stage('Push Images'){

		dir("${env.WORKSPACE}") {
			
			sh 'pwd'
			sh 'chmod 775 scripts/push-custom-images-to-cloud.sh'
			sh 'bash scripts/push-custom-images-to-cloud.sh 0.0.1'
		}
	}
    stage('Deploy') {
        withCredentials([azureServicePrincipal(servicePrincipalId)]) {
            sh """
				export KUBECONFIG=/var/jenkins_home/admin.conf
				kubectl get pods
            """
        }
    }	
}