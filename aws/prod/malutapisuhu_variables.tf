variable "malutapisuhu_databases" {
  default = "malutapisuhu"
}

variable "malutapisuhu_database_configs" {
  default = {
    name          = "malutapisuhu-db",
    instance_type = "db.t4g.micro",
    db_name       = "malutapisuhu-tutuplapak"
  }
}
