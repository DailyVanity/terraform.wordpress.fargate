variable EFS_ID {}
variable VPC_ID {}
variable ALB_NAME {}
variable MOUNT_MAP {}
variable CERT_DOMAIN {}
variable PROJECT_NAME {}
variable PROJECT_DOMAIN {}
variable DEFAULT_DOCKER_TAG {}
variable REGION {}
variable PROD_WORDPRESS_CLUSTER_NAME {}
variable ECS_EXECUTION_ROLE {}
variable ECS_TASK_ROLE {}
variable ENV {}
variable DOCKER_LISTENING_PORT {}
variable LISTENING_DOMAINS {}
variable WORDPRESS_ALB_SG_NAME {}
variable LOAD_BALANCER_LOGS_BUCKET {}
variable COMMON_ALB_SG_NAME {}
variable PROD_LOG_PREFIX {}
variable MEMORY {}
variable CPU {}
variable CLUSTER_CAPACITY_WEIGHT {
    default = {
        FARGATE = {
            base = 1
            weight = 1
        },
        FARGATE_SPOT = {
            base = 0
            weight = 3
        }
    }
}