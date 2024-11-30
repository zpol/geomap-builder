#!/bin/bash 


create_ssm_secure_parameter() {
    local region="$1"
    local name="$2"
    local value="$3"

    # Validar que se pasen todos los argumentos
    if [[ -z "$region" || -z "$name" || -z "$value" ]]; then
        echo "Uso: create_ssm_secure_parameter <region> <nombre> <valor>"
        return 1
    fi

    # Crear el parámetro con la clave KMS administrada por AWS (alias/aws/ssm)
    echo "Creando parámetro en SSM Parameter Store..."
    aws ssm put-parameter \
        --region "$region" \
        --name "$name" \
        --value "$value" \
        --type "SecureString" \
        --key-id "alias/aws/ssm"

    if [[ $? -eq 0 ]]; then
        echo "Parámetro creado exitosamente: $name"
    else
        echo "Error al crear el parámetro: $name"
        return 1
    fi
}

create_ssm_secure_parameter $1 $2 $3