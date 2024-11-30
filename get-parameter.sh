#!/bin/bash

REGION="us-east-1"

get_parameter() {
    if ! command -v aws &> /dev/null; then
        echo ">> ERR: AWS CLI not installed."
        exit 1
    fi

    if [ -z "$1" ]; then
        echo "Usage: $0 <parameter_name> [--with-decryption]"
        exit 1
    fi


    PARAMETER_NAME=$1
    WITH_DECRYPTION=${2:-"--with-decryption"}

    # Extract secret
    #echo ">> Obtaining secret from SSM ..."
    SECRET=$(aws ssm get-parameter \
        --name "${PARAMETER_NAME}" \
        $WITH_DECRYPTION \
        --query 'Parameter.Value' \
        --output text 2>/dev/null --region $REGION)

    if [ $? -ne 0 ] || [ -z "${SECRET}" ]; then
        echo ">> Error: Cant get parameter: ${PARAMETER_NAME} value"
        exit 1
    fi

    # Mostrar el secreto
    echo "${SECRET}"

}

get_parameter $1