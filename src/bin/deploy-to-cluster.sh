#!/bin/sh

# ============================================================================
# Usage
#
#   deploy-to-cluster.sh \
#     --artifact=artifact \
#     --namespace=development \
#     --tls-secrets-location=/secrets \
#     --version=1.0.0 \
#     --slack-url=https://hooks.slack.com/services/THESERVICEHOOK
# ============================================================================

NAMESPACE=development
HELM_OPERATION=upgrade

for argumentName in "$@"
do
    case $argumentName in

        --artifact=*)
        ARTIFACT="${argumentName#*=}"
        ;;

        --tls-secrets-location=*)
        TLS_SECRETS_LOCATION="${argumentName#*=}"
        ;;

        --deploy-subdirectory=*)
        DEPLOY_SUBDIRECTORY="${argumentName#*=}"
        ;;

        --version=*)
        VERSION="${argumentName#*=}"
        ;;

        --namespace=*)
        NAMESPACE="${argumentName#*=}"
        ;;

        --slack-url=*)
        SLACK_URL="${argumentName#*=}"
        ;;

        --helm-operation=*)
        HELM_OPERATION="${argumentName#*=}"
        ;;

    esac
done

if [ -z "${ARTIFACT}" ]; then
    echo "ERROR: No artifact defined! (Missing --artifact argument)"
    exit 1
elif [ -z "${TLS_SECRETS_LOCATION}" ]; then
    echo "ERROR: No TLS secrets location defined! (Missing --tls--secrets-location argument)"
    exit 1
elif [ ! -d "${TLS_SECRETS_LOCATION}" ]; then
    echo "ERROR: TLS secrets location not existing at defined location: ${TLS_SECRETS_LOCATION}"
    exit 1
elif [ -z "${NAMESPACE}" ]; then
    echo "ERROR: No namespace defined! (Missing --namespace argument)"
    exit 1
fi

if [ -z "${VERSION}" ]; then
    echo "WARNING: No explicit version has been defined! Using 'latest' as default"
    VERSION=latest
fi

echo "Artifact: ${ARTIFACT}"
echo "Namespace: ${NAMESPACE}"
echo "TLS secrets location: ${TLS_SECRETS_LOCATION}"
echo "Version: ${VERSION}"

if [ "${HELM_OPERATION}" == "upgrade" ]; then
    helm upgrade \
      --tls \
      --tls-ca-cert ${TLS_SECRETS_LOCATION}/ca.pem \
      --tls-cert ${TLS_SECRETS_LOCATION}/cert.pem \
      --tls-key ${TLS_SECRETS_LOCATION}/key.pem \
      --tiller-namespace ${NAMESPACE} \
      --namespace ${NAMESPACE} \
      --install \
      ${ARTIFACT} \
      deploy/${DEPLOY_SUBDIRECTORY}template \
      -f deploy/${DEPLOY_SUBDIRECTORY}configuration/${NAMESPACE}.yaml \
      --set image.version=${VERSION}
elif [ "${HELM_OPERATION}" == "delete" ]; then
   helm del \
      --tls \
      --tls-ca-cert ${TLS_SECRETS_LOCATION}/ca.pem \
      --tls-cert ${TLS_SECRETS_LOCATION}/cert.pem \
      --tls-key ${TLS_SECRETS_LOCATION}/key.pem \
      --tiller-namespace ${NAMESPACE} \
      --purge \
      ${ARTIFACT}
else
    echo "ERROR: Invalid helm operation: ${HELM_OPERATION}"
    exit 1
fi

if [ -n "${SLACK_URL}" ]; then
    SLACK_MESSAGE="(${ARTIFACT}) Deployed version ${VERSION} to the ${NAMESPACE} environment"
    echo "Sending notification to Slack: ${SLACK_MESSAGE}"
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$SLACK_MESSAGE\"}" ${SLACK_URL}
fi
