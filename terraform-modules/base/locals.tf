locals {
    admin_public_ip = "${chomp(data.http.myip.body)}/32"
}