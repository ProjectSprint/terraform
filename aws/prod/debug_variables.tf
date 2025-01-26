variable "debug_services" {
  default = ["user-service", "product-service", "purchase-service", "file-service"]
}

# Dev
variable "debug_service_configs" {
  default = {
    "user-service"     = { container_port = 8081, cpu = 256, memory = 512, path_pattern = "/v1/user/*", instance_count = 1 }
    "product-service"  = { container_port = 8082, cpu = 256, memory = 512, path_pattern = "/v1/product/*", instance_count = 2 }
    "purchase-service" = { container_port = 8083, cpu = 256, memory = 512, path_pattern = "/v1/purchase/*", instance_count = 1 }
    "file-service"     = { container_port = 8084, cpu = 256, memory = 512, path_pattern = "/v1/file/*", instance_count = 1 }
  }
}

# Prod
# variable "debug_service_configs" {
#   default = {
#     "user-service"     = { container_port = 8081, cpu = 1024, memory = 4096, path_pattern = "/v1/user/*", instance_count = 1 }
#     "product-service"  = { container_port = 8082, cpu = 1024, memory = 4096, path_pattern = "/v1/product/*", instance_count = 2 }
#     "purchase-service" = { container_port = 8083, cpu = 1024, memory = 4096, path_pattern = "/v1/purchase/*", instance_count = 1 }
#     "file-service"     = { container_port = 8084, cpu = 1024, memory = 4096, path_pattern = "/v1/file/*", instance_count = 1 }
#   }
# }

variable "debug_databases" {
  default = ["debug-user-service-db", "debug-product-service-db", "debug-purchase-service-db", "debug-file-service-db"]
}

# Dev
variable "debug_database_configs" {
  default = {
    "debug-user-service-db"     = { instance_type = "db.t4g.micro", db_name = "users" }
    "debug-product-service-db"  = { instance_type = "db.t4g.micro", db_name = "products" }
    "debug-purchase-service-db" = { instance_type = "db.t4g.micro", db_name = "purchases" }
    "debug-file-service-db"     = { instance_type = "db.t4g.micro", db_name = "files" }
  }
}

# Prod
# variable "debug_database_configs" {
#   default = {
#     "debug-user-service-db"     = { instance_type = "db.t4g.medium", db_name = "users" }
#     "debug-product-service-db"  = { instance_type = "db.t4g.large", db_name = "products" }
#     "debug-purchase-service-db" = { instance_type = "db.t4g.medium", db_name = "purchases" }
#     "debug-file-service-db"     = { instance_type = "db.t4g.small", db_name = "files" }
#   }
# }