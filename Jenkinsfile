 
node {	

	stage('Build Images'){
		dir("${env.WORKSPACE}") {
			checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/achmelo/s2i-kramerius.git']]])
			sh 'docker build -t kramerius-builder .'
			sh 's2i build --incremental=true --exclude="" https://github.com/moravianlibrary/kramerius.git kramerius-builder library/kramerius -r master'
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