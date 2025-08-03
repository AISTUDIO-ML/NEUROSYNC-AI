
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "neurosync" {
  ami           = "ami-0c02fb55956c7d316"  # Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  key_name      = "your-key-name"

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io docker-compose unzip git
              systemctl start docker
              usermod -aG docker ubuntu
              cd /home/ubuntu
              git clone https://github.com/your-org/neurosync-sdk.git
              cd neurosync-sdk
              docker-compose up --build -d
              EOF

  tags = {
    Name = "NeuroSyncAI"
  }
}
