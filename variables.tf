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
variable STEADY_ALB_SG_NAME {}
variable LOAD_BALANCER_LOGS_BUCKET {}
variable COMMON_ALB_SG_NAME {}
variable PROD_LOG_PREFIX {}
variable MEMORY {}
variable CPU {}
variable ACC_ID {}
variable COMMON_DB_SG_NAME {}
variable CLUSTER_CAPACITY_WEIGHT {
  default = {
    FARGATE = {
      base = 0
      weight = 2
    },
    FARGATE_SPOT = {
      base = 1
      weight = 1
    }
  }
}
variable PROVIDER_STRATEGY {
  default = {
    FARGATE = {
      base = 0
      weight = 2
    }
    FARGATE_SPOT = {
      base = 1
      weight = 1
    }
  }
}

variable AUTO_SCALING {
  default = {
    max = 1
    min = 1
  }
}

variable TARGET_SCALING {
  default = {
    max = 4
    min = 1
    CONFIG = {
      ECSServiceAverageCPUUtilization = {
        target_value = 75
        scale_out = 60
        scale_in = 30
      }
      ECSServiceAverageMemoryUtilization = {
        target_value = 40
        scale_out = 60
        scale_in = 30
      }
      ALBRequestCountPerTarget = {
        target_value = 150
        scale_out = 60
        scale_in = 30
      }
    }
  }
}

variable SCHEDULE_SCALING {
  default = {
    max = 1
    min = 1
    schedule = {
      start = {
        max = 4
        min = 1
        time = "cron(0 9 ? * MON-FRI *)"
        timezone = "Asia/Singapore"
      }
      end = {
        max = 1
        min = 1
        time = "cron(0 21 * * ? *)"
        timezone = "Asia/Singapore"
      }
    }
  }
}

variable CONTAINER_SECRET {
  default = {}
}

variable LOG_GROUP {
  default = ""
}

variable S3_ASSET_BUCKET {
  default = ""
}