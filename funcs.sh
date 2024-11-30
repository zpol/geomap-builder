
b() {
    echo "IBtbMDsxOzM1Ozk1beKjjxtbMDsxOzMxOzkxbeKhsRtbMG0gG1swOzE7MzM7OTNt4qGA4qKAG1sw
bSAbWzA7MTszMjs5Mm3io4cbWzA7MTszNjs5Nm3ioYAbWzBtIBtbMDsxOzM0Ozk0beKhhxtbMG0g
G1swOzE7MzU7OTVt4qCEG1swbSAbWzA7MTszMTs5MW3iooDio4AbWzBtICAgG1swOzE7MzI7OTJt
4qGHG1swbSAbWzA7MTszNjs5Nm3io48bWzA7MTszNDs5NG3iobEbWzBtICAgG1swOzE7MzE7OTFt
4qGO4qCRG1swbSAbWzA7MTszMzs5M23iooAbWzA7MTszMjs5Mm3ioYAbWzBtIBtbMDsxOzM2Ozk2
beKigOKhgBtbMG0gG1swOzE7MzQ7OTRt4qOAG1swOzE7MzU7OTVt4qOAG1swbSAgG1swOzE7MzE7
OTFt4qKAG1swOzE7MzM7OTNt4qOAG1swbSAbWzA7MTszMjs5Mm3io4DioYAbWzBtCiAbWzA7MTsz
MTs5MW3ioIcbWzBtICAbWzA7MTszMjs5Mm3ioKPioLwbWzBtIBtbMDsxOzM2Ozk2beKgpxtbMDsx
OzM0Ozk0beKgnBtbMG0gG1swOzE7MzU7OTVt4qCjG1swbSAbWzA7MTszMTs5MW3ioIcbWzBtIBtb
MDsxOzMzOzkzbeKgo+KgpBtbMG0gICAbWzA7MTszNjs5Nm3ioIcbWzBtIBtbMDsxOzM0Ozk0beKg
hxtbMG0gICAgG1swOzE7MzM7OTNt4qCj4qCdG1swbSAbWzA7MTszMjs5Mm3ioKMbWzA7MTszNjs5
Nm3ioK0bWzBtIBtbMDsxOzM0Ozk0beKgo+KgnBtbMG0gG1swOzE7MzU7OTVt4qCHG1swOzE7MzE7
OTFt4qCH4qCHG1swbSAbWzA7MTszMzs5M23ioKMbWzA7MTszMjs5Mm3ioLwbWzBtIBtbMDsxOzM2
Ozk2beKhp+KgnBtbMG0K"|base64 -d
}


#create_ssm_secure_parameter $1 $2 $3
create_ssm_secure_parameter() {
    local region="$1"
    local name="$2"
    local value="$3"

    # do we got argvs?
    if [[ -z "$region" || -z "$name" || -z "$value" ]]; then
        echo "Uso: create_ssm_secure_parameter <region> <nombre> <valor>"
        return 1
    fi

    # Crear el parámetro con la clave KMS administrada por AWS (alias/aws/ssm)
    echo ">> Creating SSM Parameter ..."
    aws ssm put-parameter \
        --region "$region" \
        --name "$name" \
        --value "$value" \
        --type "SecureString" \
        --key-id "alias/aws/ssm"

    if [[ $? -eq 0 ]]; then
        echo ">> SSM parameter created: $name"
    else
        echo ">> Error creating: $name"
        return 1
    fi
}



# get_parameter $1
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

# create_dummy_secrets
create_dummy_secrets() {
    for secret in ${secrets[@]}
    do
        echo ">> Creating parameter: [${secret}]"
        create_ssm_secure_parameter ${REGION} ${secret} "somestupidvalue678e2gdu3i"
    done
}

# get_container_ip <container_name>
get_container_ip() {
    container_name=$1
    docker inspect ${container_name} |grep -i ipaddress|egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
}


# extract docker cfgs & ip addrs
extract_docker_cfg() {
    
    docker ps &>/dev/null
    if [ $? != "0" ]
    then
        echo ">> ERR: Docker not found"
        exit 2
    else
        echo ">> Docker found, extracting cfgs..."
        num_containers=$(docker ps -q |wc -l)
        if [ ${num_containers} -lt 1 ]
        then
            echo ">> ERR: No containers running, exitting..."
            exit 3
        else
            echo ">> Docker containers found...... :)"
            echo ">> Database host/IP: $(get_container_ip mariadb)"  # TODO it's hardcoded careful :) 
        fi
    fi

}

import_db_schema() {
    echo ">> Importing db schema ..........................."
    mysql -u root -p${MYSL_ROOT_PASSWORD} -h 127.0.0.1 < dbschema.sql
}