Query to endpoint, assuming SSM can be queried from local terminal :

curl -H "Authorization: Bearer $(aws ssm get-parameter --name /web-app/api-token --with-decryption --query Parameter.Value --output text)" <IP from TF output>