resource "aws_docdb_subnet_group" "service" {
  name       = "tf-${var.name}"
  subnet_ids = ["${module.vpc.public_subnets}"]
}

resource "aws_docdb_cluster_instance" "service" {
  count              = 1
  identifier         = "tf-${var.name}-${count.index}"
  cluster_identifier = "${aws_docdb_cluster.service.id}"
  instance_class     = "${var.docdb_instance_class}"
}

resource "aws_docdb_cluster" "service" {
  skip_final_snapshot     = true
  db_subnet_group_name    = "${aws_docdb_subnet_group.service.name}"
  cluster_identifier      = "tf-${var.name}"
  engine                  = "docdb"
  master_username         = "tf_${replace(var.name, "-", "_")}_admin"
  master_password         = "${var.docdb_password}"
  db_cluster_parameter_group_name = "${aws_docdb_cluster_parameter_group.service.name}"
  vpc_security_group_ids = ["${aws_security_group.service.id}"]
}

resource "aws_docdb_cluster_parameter_group" "service" {
  family = "docdb3.6"
  name = "tf-${var.name}"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}