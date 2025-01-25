variable "debug_services" {
  default = ["user-service", "product-service", "purchase-service", "file-service"]
}

variable "debug_service_configs" {
  default = {
    "user-service"     = { container_port = 8081, cpu = 256, memory = 512, path_pattern = "/v1/user/*", instance_count = 1 }
    "product-service"  = { container_port = 8082, cpu = 256, memory = 512, path_pattern = "/v1/product/*", instance_count = 2 }
    "purchase-service" = { container_port = 8083, cpu = 256, memory = 512, path_pattern = "/v1/purchase/*", instance_count = 1 }
    "file-service"     = { container_port = 8084, cpu = 256, memory = 512, path_pattern = "/v1/file/*", instance_count = 1 }
  }
}

# variable "debug_service_configs" {
#   default = {
#     "user-service"     = { container_port = 8081, cpu = 1024, memory = 4096, path_pattern = "/v1/user/*", instance_count = 1 }
#     "product-service"  = { container_port = 8082, cpu = 1024, memory = 4096, path_pattern = "/v1/product/*", instance_count = 2 }
#     "purchase-service" = { container_port = 8083, cpu = 1024, memory = 4096, path_pattern = "/v1/purchase/*", instance_count = 1 }
#     "file-service"     = { container_port = 8084, cpu = 1024, memory = 4096, path_pattern = "/v1/file/*", instance_count = 1 }
#   }
# }

variable "debug_databases" {
  default = ["debug-db-1", "debug-db-2", "debug-db-3"]
}