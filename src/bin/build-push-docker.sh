#!/bin/sh

# ============================================================================
# Usage
#
#   build-push-docker.sh \
#     --image-name=name \
#     --dockerfile=Dockerfile \
#     --private-repo-url=my-private-docker-registry.foo
#     --private-repo-path=/path
#     --username=foo \
#     --password=bar \
#     --version=1.0.0 \
#
# Outcome
# Two new images will be created here
#
#     my-private-docker-registry.foo/path/name:1.0.0
#     AND
#     my-private-docker-registry.foo/path/name:latest
#
# ============================================================================

for argumentName in "$@"
do
    case $argumentName in

        --image-name=*)
        IMAGE_NAME="${argumentName#*=}"
        ;;

        --dockerfile=*)
        DOCKERFILE="${argumentName#*=}"
        ;;

        --private-repo-url=*)
        PRIVATE_REPO_URL="${argumentName#*=}"
        ;;

        --private-repo-path=*)
        PRIVATE_REPO_PATH="${argumentName#*=}"
        ;;

        --username=*)
        USERNAME="${argumentName#*=}"
        ;;

        --password=*)
        PASSWORD="${argumentName#*=}"
        ;;

        --version=*)
        VERSION="${argumentName#*=}"
        ;;

    esac
done

if [ -z "${IMAGE_NAME}" ]; then
    echo "ERROR: No image name defined! (Missing --image-name argument)"
    exit 1
elif [ -z "${USERNAME}" ]; then
    echo "ERROR: No username defined! (Missing --username argument)"
    exit 1
elif [ -z "${PASSWORD}" ]; then
    echo "ERROR: No password defined! (Missing --password argument)"
    exit 1
fi

if [ -z "${VERSION}" ]; then
    echo "WARNING: No explicit version has been defined! Using 'latest' as default"
    VERSION="latest"
fi

if [ -z "${DOCKERFILE}" ]; then
    echo "Info: No explicit Deockerfile has been defined! Using 'Dockerfile' as default"
    DOCKERFILE="Dockerfile"
fi

FULL_IMAGE_NAME=${PRIVATE_REPO_URL}${PRIVATE_REPO_PATH}/${IMAGE_NAME}

echo "Push image: ${FULL_IMAGE_NAME}:${VERSION}"
docker login ${PRIVATE_REPO_URL} -u ${USERNAME} --password-stdin ${PASSWORD}
set +x && docker build -f ${DOCKERFILE} -t ${FULL_IMAGE_NAME} .
set +x && docker tag ${FULL_IMAGE_NAME}:latest ${FULL_IMAGE_NAME}:${VERSION}

set +x && docker push ${FULL_IMAGE_NAME}:${VERSION}
if [ "$VERSION" != "latest" ]; then
    set +x && docker push ${FULL_IMAGE_NAME}:latest
    echo "Push image: ${FULL_IMAGE_NAME}:latest"
fi
