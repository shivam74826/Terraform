region      = "ap-south-1"
environment = "dev"

servers_name = ["web-dev-01", "web-dev-02"]

ami_id = {
  "ap-south-1" = "ami-0f918f7e67a3323f0"
  "us-west-1"  = "ami-0c55b159cbfafe1f0"
}

key_pair = "~/.ssh/id_rsa.pub"

ports = [
  { from_port = 22, cidr_blocks = ["0.0.0.0/0"] },
  { from_port = 80, cidr_blocks = ["0.0.0.0/0"] },
]
