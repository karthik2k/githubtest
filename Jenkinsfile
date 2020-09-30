#!groovy

pipeline {
  
  agent any

    stages {
      stage ("ansible test") {
        steps {
          ansiblePlaybook(
            installation: 'Ansible 2',
            playbook: 'site.yml',
            colorized: true
            )
        }
      }
    }
}
