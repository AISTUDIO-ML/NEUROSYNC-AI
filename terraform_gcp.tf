
provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "neurosync_vm" {
  name         = "neurosync-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
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

  tags = ["neurosync"]
}
