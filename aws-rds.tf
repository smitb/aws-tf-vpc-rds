resource "random_password" "master" {
  length  = 20
  special = false
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-cluster-mendix"
  engine                  = "aurora-postgresql"
  engine_mode             = "serverless"
  engine_version          = "11.21" # specify your desired version
  database_name           = "mendix"
  master_username         = "root"
  storage_encrypted       = true
  master_password         = random_password.master.result
  skip_final_snapshot     = true
  enable_http_endpoint    = true

  scaling_configuration {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }  

  db_subnet_group_name    = aws_db_subnet_group.mendix_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.mendix_db_security_group.id]
}

resource "aws_db_subnet_group" "mendix_db_subnet_group" {
  name       = "mendix-db-subnet-group"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_security_group" "mendix_db_security_group" {
  name        = "mendix-db-security-group"
  description = "Allow inbound traffic from VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

output "postgresql_cluster_master_password" {
  description = "The database master password"
  value       = aws_rds_cluster.aurora_cluster.master_password
  sensitive   = true
}

output "postgresql_cluster_master_user" {
  description = "The database master user"
  value       = aws_rds_cluster.aurora_cluster.master_username
}

output "postgresql_cluster_endpoint" {
  description = "The database endpoint"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "postgresql_database_name" {
  description = "The database endpoint"
  value       = aws_rds_cluster.aurora_cluster.database_name
}