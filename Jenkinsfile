 
node {	

	stage('Build Images'){
		dir("${env.WORKSPACE}") {
			checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/achmelo/s2i-kramerius.git']]])
			sh 'docker login --username admin --password admin harbor.nkp.cz:30004'
			sh 's2i build --incremental=true --exclude="" https://github.com/moravianlibrary/kramerius.git harbor.nkp.cz:30004/library/kramerius-builder:latest library/kramerius -r master'
		}
	}	
    stage('Deploy') {
            sh """
				export KUBECONFIG=/var/jenkins_home/admin.conf
				kubectl get pods
            """
    }	
}