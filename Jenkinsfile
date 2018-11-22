
pipeline
{
    environment
    {
        AWS_ACCESS_KEY_ID     = credentials( 'safe.aws.access.key' )
        AWS_SECRET_ACCESS_KEY = credentials( 'safe.aws.secret.key' )
        AWS_REGION            = credentials( 'safe.aws.region.key' )
    }

    agent { dockerfile true }

    stages
    {
        stage('terraform init')
        {
            steps
            {
		sh 'terraform init integration.test.dir'
            }
        }
        stage('terraform apply')
        {
            steps
            {
		sh 'terraform apply -auto-approve integration.test.dir'
            }
        }
        stage('terraform destroy')
        {
            steps
            {
		sh 'terraform destroy -auto-approve integration.test.dir'
            }
        }
    }
}
