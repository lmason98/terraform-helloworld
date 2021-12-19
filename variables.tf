variable "region" {
  description = "AWS resource region"
  default     = "us-west-1"
}

variable "ssh_public_key" {
  description = "public key so we can ssh into the new instance"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrQpZWyNaepKv4wtrAJ7P8qSIWH4JiI/YB3lmhMtcWFkVLjlVwDI/pKuuax9gdCfX87PlaWM4UY6zrRew9I5yOdOgvnqrm6cYorFLJX3oQFzGRU3P6WCzU7rXJk0vu6ZmNE2k6H1vU/phhkhVAoWJp5AxVB1HQ3FDIOnGA5yj0i1dlSs9f7nW0ChO3r9XI3IbVxhSQrxGjtchFD/N4lh+/Kc1Urw4sJ6QMFRpgoReaiNB0HbpCM2Cvi2FlRB9c4oZ7OiJK3oq/3TBk6UK3WJJUtD52+6t8PvtaeNVxqdzTJDjAZn6aIPUh8PkkYRJWr80Ji5seNJUfWFBmCZR02HBy+ZX2EXLm8Q9ho6Fcqp0NShqazIo4BoXy712fALU0R1Lyf2Y5bcOpL53QQlUG4idYg6nbRjzBsX93K2N9QH0iBQi6BPSfuaT8jMwaAFB3fBfPESV9+IMRIUjQ9g+GppCsBVelaZB+YXEMJYN94zLsJX48rzyhOnnEmVnD+YbmJzEx7uGLBY/ZUJkxu0Q2RyBuzFTAXcLfg5JhVe5+IvzHeITGBR0fFaPoYs8DZO69gOPfpe4OvOee+EmQwvvoKAY/u0kvx7Oq887YCJCoaUOkVaPsfM9Z1xcK2V6Unnr8R1dK456EZnsZsr66GunIAUPEoZsfISQT4eqCsSyh/tw7uw== lmason98@gmail.com"
}

variable "state_name" {
  description = "S3 State bucket name, must be unique"
  default     = "lmason98-tf-state-210901047"
}

variable "locks_name" {
  description = "DynamoDB locks table name"
  default     = "tf_lock"
}
