 
node {	

	stage('Build Images'){
		dir("${env.WORKSPACE}") {
			checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/achmelo/s2i-kramerius.git']]])
			sh 'docker login --username admin --password admin harbor.nkp.cz:30004'
			sh 's2i build --incremental=true --exclude="" https://github.com/ceskaexpedice/kramerius.git harbor.nkp.cz:30004/library/kramerius-builder:0.0.1 kramerius -r v5.4.3_NKP-dnnt'
		}
	}
	
	stage('Push') {
            sh """
				docker tag kramerius:latest harbor.nkp.cz:30004/library/kramerius:latest
				docker push harbor.nkp.cz:30004/library/kramerius:latest
            """
    }
	
    stage('Deploy') {
	dir("kubernetes-conf"){
            sh """
				export KUBECONFIG=/var/jenkins_home/admin.conf
				kubectl replace --force -f kramerius.yaml
            """
    }	
	}
}