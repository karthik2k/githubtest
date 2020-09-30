node {
  checkout scm
  agent any

    stages {
      stage ("ansible test") {
        steps {
          ansiblePlaybook(
            playbook: 'site.yml',
            colorized: true
            )
        }
      }
    }
}
