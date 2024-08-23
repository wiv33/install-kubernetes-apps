provider "aws" {
  region     = "ap-northeast-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_route53_record" "asterisk_main_domain" {
  depends_on = [helm_release.istiod, helm_release.istio-base]
  name    = "*.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  zone_id = var.zone_id
  #   records = [data.kubernetes_service.istio-ingress.status.0.load_balancer.0.ingress.0.hostname]
  records = var.records_cname
}

resource "aws_route53_record" "double_asterisk_main_domain" {
  depends_on = [helm_release.istiod, helm_release.istio-base]
  name    = "*.*.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  zone_id = var.zone_id
  #   records = [data.kubernetes_service.istio-ingress.status.0.load_balancer.0.ingress.0.hostname]
  records = var.records_cname
}

resource "aws_route53_record" "main_domain" {
  depends_on = [helm_release.istiod, helm_release.istio-base]
  name    = var.domain
  type    = "A"
  ttl     = 300
  zone_id = var.zone_id
  #   records = [data.kubernetes_service.istio-ingress.status.0.load_balancer.0.ingress.0.hostname]
  records = var.records_ip
}
