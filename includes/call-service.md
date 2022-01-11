## Interacting with Services

Retrieve the Istio Ingress Gateway url to access the application,

```bash
export INGRESS_GATEWAY_IP=$(kubectl --context ${CLUSTER1} -n istio-gateways get svc ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}')
export SVC_URL="${INGRESS_GATEWAY_IP}/customer"
```

### Call Service

Call the service using the script,

```bash
$DEMO_HOME/bin/call_service.sh
```

#### Poll Service

Poll the service using the script,

```bash
$DEMO_HOME/bin/poll_service.sh
```

#### Using Default Browser

Open the URL in the browser `open http://$SVC_URL`.
