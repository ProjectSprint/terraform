output "debug_db" {
  value = {
    for k, v in aws_db_instance.debug_db :
    k => {
      endpoint = v.endpoint
      username = v.username
      password = random_string.debug_db_pass[k].result
    }
  }
  depends_on  = [aws_db_instance.debug_db]
  sensitive   = true
  description = "debug_db connection info"
}
