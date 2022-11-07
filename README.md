# tf-alb-ingress

## linking up to the cluster
aws eks update-kubeconfig  --name diu-eks-cluster

# connect through bastion

Local...   
ssh -i "myKey.pem" ec2-user@=&lt;YOUR PUBLIC EC2 DNS&gt;   

In public...   
PRIVATE_IP=&lt;YOUR PRIVATE EC2 IP&gt;  
ssh -A ec2_user@$PRIVATE_IP  

In private....     
curl &lt;YOUR LOAD BALANCER DNS&gt;  