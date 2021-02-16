#! /bin/bash

NAMESPACE="pre-${BUILD_ID}"
INSTALL_NAMESPACE=$NAMESPACE

echo "labeling the ${INSTALL_NAMESPACE} namespace"
kubectl label ns "${INSTALL_NAMESPACE}" trilio-label-

all_releases=("$(helm ls -n "${NAMESPACE}" | awk 'FNR > 1 {print $1}')")
for rel in "${all_releases[@]}"; do
  echo "found release ${rel}"
  echo "Deleting helm release ${rel}"
  helm delete -n "${NAMESPACE}" "${rel}" || true
done

kubectl delete target --all -n "${NAMESPACE}"

kubectl delete policy --all -n "${NAMESPACE}"

all_res=["backup", "restore", "backupplan", "jobs", "pvc", "mysqlcluster"]
# shellcheck disable=SC2154
for r in "${all_res[@]}"; do
  # shellcheck disable=SC2207
  res_list=($(kubectl get backup -n "${NAMESPACE}" | awk 'FNR > 1 {print $1}'))
  for res in "${res_list[@]}"; do
    echo "Deleting ${r}"
    kubectl delete "${r}" -n "${NAMESPACE}" "${res}" --force --grace-period=0 --timeout=5s || true
    kubectl patch "${r}" -n "${NAMESPACE}" "${res}" --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]' || true
  done
done

kubectl delete sa RELEASE_NAME-mysql-operator -n "${NAMESPACE}" --force --grace-period=0

kubectl delete secret sample-mysql-cluster-secret RELEASE_NAME-mysql-operator-orc -n "${NAMESPACE}" --force --grace-period=0

kubectl delete statefulset.apps/RELEASE_NAME-mysql-operator -n "${NAMESPACE}" --force --grace-period=0

kubectl delete svc RELEASE_NAME-mysql-operator-0-svc RELEASE_NAME-mysql-operator -n "${NAMESPACE}" --force --grace-period=0

kubectl delete cm RELEASE_NAME-mysql-operator-orc -n "${NAMESPACE}" --force --grace-period=0

kubectl delete all -l triliobackupall=RELEASE_NAME -n "${NAMESPACE}" --force --grace-period=0 || true
kubectl delete po RELEASE_NAME-mysql-operator-0 -n "${NAMESPACE}" --force --grace-period=0 || true
kubectl delete po RELEASE_NAME-mysql-operator-1 -n "${NAMESPACE}" --force --grace-period=0 || true
kubectl delete po sample-mysqlcluster-mysql-0 -n "${NAMESPACE}" --force --grace-period=0 || true

echo "labeled back the ${INSTALL_NAMESPACE} namespace"
kubectl label namespace "${INSTALL_NAMESPACE}" trilio-label="${INSTALL_NAMESPACE}" || true
