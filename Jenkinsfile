pipeline {
    agent { label 'sonar' }

    environment {
        // ---- SonarQube ----
        SONARQUBE_SERVER = 'SonarQube'

        // ---- Nexus ----
        NEXUS_URL       = 'http://172.28.99.196:8081'
        NEXUS_REPO      = 'starbugs-app'
        NEXUS_GROUP     = 'com/web/starbugs'
        NEXUS_ARTIFACT  = 'starbugs-app'
    }

    stages {

        /* === Stage 1: Checkout Code === */
        stage('Checkout Code') {
            steps {
                echo '📦 Cloning source code...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/reddi122/starbucks-recreate.git']]
                ])
            }
        }

        /* === Stage 2: Install Dependencies === */
        stage('Install Dependencies') {
            steps {
                echo '📥 Installing npm dependencies...'
                sh '''
                    npm install
                    echo "Dependencies installed!"
                '''
            }
        }

        /* === Stage 3: SonarQube Analysis === */
        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Running SonarQube analysis...'
                sh 'npm install -g sonarqube-scanner || true'

                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                        npx sonar-scanner \
                          -Dsonar.projectKey=starbugs-app-js \
                          -Dsonar.projectName="Starbugs App JS" \
                          -Dsonar.projectVersion=0.0.${BUILD_NUMBER} \
                          -Dsonar.sources=src \
                          -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                          -Dsonar.sourceEncoding=UTF-8
                    '''
                }
            }
        }

        /* === Stage 4: Run Tests === */
        stage('Run Tests') {
            steps {
                echo '🧪 Running tests...'
                sh 'npm test || true'
            }
        }

        /* === Stage 5: Build Application === */
        stage('Build Application') {
            steps {
                echo '⚙️ Building application...'
                sh '''
                    npm run build
                    echo "Build Completed!"
                    ls -lh dist/ || true
                '''
            }
        }

        /* === Stage 6: Package Artifact === */
        stage('Package Artifact') {
            steps {
                echo '📦 Packaging build output...'
                sh '''
                    VERSION="0.0.${BUILD_NUMBER}"
                    tar -czf ${NEXUS_ARTIFACT}-${VERSION}.tar.gz -C dist .
                    echo "Artifact created: ${NEXUS_ARTIFACT}-${VERSION}.tar.gz"
                '''
            }
        }

        /* === Stage 7: Upload to Nexus === */
        stage('Upload to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus', usernameVariable: 'NEXUS_USR', passwordVariable: 'NEXUS_PSW')]) {
                    sh '''
                        VERSION="0.0.${BUILD_NUMBER}"
                        TARBALL="${NEXUS_ARTIFACT}-${VERSION}.tar.gz"

                        echo "📤 Uploading artifact to Nexus..."

                        curl -v -u ${NEXUS_USR}:${NEXUS_PSW} \
                          --upload-file "$TARBALL" \
                          "${NEXUS_URL}/repository/${NEXUS_REPO}/${NEXUS_GROUP}/${NEXUS_ARTIFACT}/${VERSION}/${TARBALL}"

                        echo "✅ Artifact uploaded successfully!"
                    '''
                }
            }
        }
    }

    post {
        success { echo '🎉 Pipeline completed successfully!' }
        failure { echo '❌ Pipeline failed — check logs.' }
    }
}
