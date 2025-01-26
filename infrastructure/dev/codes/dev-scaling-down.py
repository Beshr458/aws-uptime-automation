import boto3
import os

def lambda_handler(event, context):
    region = 'us-east-1'
    
    # Targeted ECS cluster
    cluster_name = os.getenv('CLUSTER_NAME')
    # Define filter for instances with the tag Dev-Schedule: True
    filters = [
        {
            'Name': 'tag:Dev-Schedule',
            'Values': ['True']
        }
    ]
    # RDS DB Identifier
    rds_ids = os.getenv('RDS_IDS')    

    ecs_client = boto3.client('ecs', region_name=region)
    autoscaling = boto3.client('application-autoscaling', region_name=region)

    # Create EC2 and RDS clients
    ec2_client = boto3.client('ec2')
    rds_client = boto3.client('rds')

    messages = []  # Collect messages for the response

    # Find all instances with the required tag
    instances = ec2_client.describe_instances(Filters=filters)
    # Gather instance IDs to start
    instance_ids = [
        instance['InstanceId']
        for reservation in instances['Reservations']
        for instance in reservation['Instances']
    ]  

    try:
        # List all services in the specified ECS cluster
        services = ecs_client.list_services(cluster=cluster_name, maxResults=20)['serviceArns']
        print(f"Searching for ECS services for Dev env...")

        for service_arn in services:
            service_name = service_arn.split('/')[-1]
            print(f" --->> Found {service_name} service in {cluster_name} ECS clsuter")

            # Reduce the minimum number of tasks
            app_asg_response = autoscaling.register_scalable_target(
                ServiceNamespace='ecs',
                ScalableDimension='ecs:service:DesiredCount',
                MinCapacity=0,                
                ResourceId=f'service/{cluster_name}/{service_name}'
                )
            # Update ECS service to desired count
            ecs_response = ecs_client.update_service(
                cluster=cluster_name,
                service=service_name,
                desiredCount=0
            )                
       
            print(f" --->> Scaled down ECS service {service_name} and Auto Scaling group to 0 successfully")

        # Stop EC2 instance
        messages.append(f"Stoppping EC2 instances for Dev env...")        
        ec2_client.stop_instances(InstanceIds=instance_ids)
        print(f" --->> Stopped instances: {instance_ids} successfully.")

        # Stop RDS DB instance
        messages.append(f"Stopping RDS Databases for Dev env...")         
        for rds_id in rds_ids:
            rds_client.stop_db_cluster(DBClusterIdentifier=rds_id)
            print(f" --->> Stopped RDS instance: {rds_id} successfully.")

    except Exception as e:
        print(f"Error updating Dev resources: {str(e)}")
        return {
             'statusCode': 500,
             'body': f'Error updating ECS services: {str(e)}'
        }

    return {
        'statusCode': 200,
        'body': 'Dev infrastructure has been stopped successfully'  
        }