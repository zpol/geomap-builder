#!/bin/bash

REGION="us-east-1"

source funcs.sh
b

# Listado de secretos necesarios
secrets=(
    "GF_SECURITY_ADMIN_PASSWORD" 
    "MYSQL_ROOT_PASSWORD"
    "MYSQL_PASSWORD"
)

# Obtener secretos desde SSM
for secret in "${secrets[@]}"
do
    echo ">> Gathering credentials from SSM for: [${secret}]"
    value=$(get_parameter "${secret}")
    if [[ $? -eq 0 && -n "$value" ]]; then

        eval "${secret}='${value}'"
        eval "export ${secret}"
        # echo ">>> ${secret} obtained & exported: ${!secret}"  # show dynamic value
        echo ">>> ${secret} obtained & exported: [OK]" 

    else

        echo ">>> Error: Cant obtain value for [${secret}]"

    fi
done

# Uncomment to check if passwd values are ok DO NOT FORGET TO COMMENT AGAIN OR DELETE!!!!!!!
# env |grep "PASSW"

# start the party!
docker-compose up -d 

extract_docker_cfg