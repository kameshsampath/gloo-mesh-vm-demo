---
title: Troubleshooting
summary: Troubleshooting some common errors

authors:
  - Kamesh Sampath<kamesh.sampath@hotmail.com>
date: 2022-01-10
---

## Certificates Expired

### Issue

Calling `customer` service `curl $SVC_URL` shows an error like,

```shell
upstream connect error or disconnect/reset before headers. reset reason: connection failure, transport failure reason: TLS error: 268436501:SSL routines:OPENSSL_internal:SSLV3_ALERT_CERTIFICATE_EXPIRED
```

And hecking ingressgateway logs,

```shell
kubectl --context=$CLUSTER1 logs -f -listio=ingressgateway  -nistio-gateways
```

```shell
ingressgateway-7cc46d9596-v8qnt istio-proxy [2022-01-11T06:44:07.918Z] "GET /customer HTTP/1.1" 503 UF,URX upstream_reset_before_response_started{connection_failure,TLS_error:_268436501:SSL_routines:OPENSSL_internal:SSLV3_ALERT_CERTIFICATE_EXPIRED} - "TLS error: 268436501:SSL routines:OPENSSL_internal:SSLV3_ALERT_CERTIFICATE_EXPIRED" 0 201 77 - "192.168.64.90" "curl/7.77.0" "51c9ed69-6ad3-43a4-a183-58229a34d444" "192.168.64.90" "172.16.0.20:8080" outbound|8080|v1|customer.default.svc.cluster.local - 172.16.0.12:8080 192.168.64.90:19213 - -
```

### Solution

Restart Istio and Gateway deployments

```shell
kubectl --context=$CLUSTER1 rollout restart -n istio-system deployment istiod-1-11-5
kubectl --context=$CLUSTER1  rollout restart -n istio-gateways deployment ingressgateway
```
