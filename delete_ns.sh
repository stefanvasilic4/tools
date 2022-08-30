#!/usr/bin/env bash
set -eou pipefail

get_namespace(){
  read -p "Please enter NameSpace you wish to terminate: " NAMESPACE
  echo $NAMESPACE
  kubectl get namespace $NAMESPACE -o json | jq '.spec = {"finalizers":[]}' > tmp.json
}

kubectl_proxy_start() {
  kubectl proxy & 
  jobs
  sleep 5
}

kubectl_proxy_kill() {
  pkill -9 -f "kubectl proxy"

}

terminate_ns(){
  curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
  rm -rf tmp.json
}

get_namespace
kubectl_proxy_start
terminate_ns
kubectl_proxy_kill

