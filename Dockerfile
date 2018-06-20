FROM azolo/jnlp-kubectl-slave

USER root
RUN apk update && apk add curl
RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm ./get_helm.sh && \
    helm init --client-only
