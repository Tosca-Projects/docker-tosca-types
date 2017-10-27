#!/bin/bash

# configuration
KUBE_ADMIN_CONFIG_PATH=admin.conf

KUBE_SERVICE_NAME="apache-service"
KUBE_SERVICE_CONFIG=$(cat <<-END
apiVersion: v1
kind: Service
metadata:
  name: apache-service  # Should generate a uniq name
spec:
  ports:
  - name: apache-docker-endpoint
    port: 80
  type: NodePort
  selector:
    apache: k
END
)

function deploy_service(){
    SERVICE_CONFIG_TMP_FILE=$(mktemp)

    # create kube service config file
    echo "${KUBE_SERVICE_CONFIG}" > "${SERVICE_CONFIG_TMP_FILE}"

    # deploy service
    kubectl --kubeconfig "${KUBE_ADMIN_CONFIG_PATH}" create -f "${SERVICE_CONFIG_TMP_FILE}"
    SERVICE_DEPLOY_STATUS=$?

    # cleanup
    rm "${SERVICE_CONFIG_TMP_FILE}"

    if [ "${SERVICE_DEPLOY_STATUS}" -ne 0 ]
    then
        echo "Failed to deploy service"
        exit "${SERVICE_DEPLOY_STATUS}"
    fi

    # get IP/PORT
    export SERVICE_IP=$(kubectl --kubeconfig "${KUBE_ADMIN_CONFIG_PATH}" get services "${KUBE_SERVICE_NAME}" -o=jsonpath={.spec.clusterIP})
    # export SERVICE_PORT=$(kubectl --kubeconfig "${KUBE_ADMIN_CONFIG_PATH}" get services "${KUBE_SERVICE_NAME}" -o=jsonpath={.spec.ports[0].port})
}

deploy_service
exit 0