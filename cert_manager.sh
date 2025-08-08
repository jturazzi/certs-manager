#!/bin/bash

# ==============================================================================
# Certificate Management Script
#
# A bash script to create a self-signed Certificate Authority (CA) and sign
# server/client certificates using a simple whiptail interface.
#
# Author: Jérémy TURAZZI
# ==============================================================================

# Function to display messages
display_message() {
    whiptail --title "Message" --msgbox "$1" 10 78
}

# Function to display errors
display_error() {
    whiptail --title "Error" --msgbox "$1" 10 78
}

# Function to check if a directory exists
check_directory() {
    if [ -d "$1" ]; then
        display_error "Directory '$1' already exists."
        return 1
    fi
    return 0
}

# Function to check if a file exists
check_file() {
    if [ -e "$1" ]; then
        display_error "File '$1' already exists."
        return 1
    fi
    return 0
}

# Function to validate input (allow letters, numbers, spaces, underscores, and dashes)
validate_input() {
    local input=$1
    local pattern="^[a-zA-Z0-9 _-]+$"  # Updated pattern to be more permissive
    if [[ ! $input =~ $pattern ]]; then
        display_error "Invalid input. Please try again."
        return 1
    fi
    return 0
}

# Function to create a CA certificate with a custom name if it doesn't already exist
create_ca_cert() {
    local ca=$1
    local ca_name=$2

    check_directory "${ca}" || return 1
    mkdir -p "${ca}"

    check_file "${ca}/${ca}.crt" || return 1

    (
    echo "XXX"; echo "10"; echo "Creating CA certificate '$ca_name'..."; echo "XXX"
    openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-384 -keyout "${ca}/${ca}.key" -out "${ca}/${ca}.crt" -days 3650 -nodes -subj "/O=$ca_name/OU=$ca_name/CN=$ca_name CA" -utf8
    echo "XXX"; echo "100"; echo "CA certificate '$ca_name' created successfully!"; echo "XXX"
    ) | whiptail --title "Creating CA Certificate" --gauge "Please wait..." 10 78 0

    chmod 400 "${ca}/${ca}.key"
    display_message "CA certificate created successfully.\nKey: ${ca}/${ca}.key\nCertificate: ${ca}/${ca}.crt"
    return 0
}

# Function to generate a Certificate Signing Request (CSR) if it doesn't already exist
generate_csr() {
    local csr=$1
    local csr_name=$2

    check_directory "${csr}" || return 1
    mkdir -p "${csr}"

    check_file "${csr}/${csr}.csr" || return 1

    (
    echo "XXX"; echo "10"; echo "Generating Certificate Signing Request (CSR)..."; echo "XXX"
    openssl req -new -keyout "${csr}/${csr}.key" -out "${csr}/${csr}.csr" -newkey ec -pkeyopt ec_paramgen_curve:P-384 -nodes -subj "/O=$csr_name/OU=$csr_name/CN=$csr_name" -utf8
    echo "XXX"; echo "100"; echo "CSR '$csr_name' generated successfully!"; echo "XXX"
    ) | whiptail --title "Generating CSR" --gauge "Please wait..." 10 78 0

    chmod 400 "${csr}/${csr}.key"
    display_message "CSR generated successfully.\nKey: ${csr}/${csr}.key\nCSR: ${csr}/${csr}.csr"
    return 0
}

# Function to sign a certificate using the CA
sign_cert() {
    local ca=$1
    local csr=$2
    local dns_list=$3
    local ip_list=$4

    if [ ! -e "${ca}/${ca}.crt" ]; then
        display_error "CA certificate '${ca}/${ca}.crt' does not exist."
        return 1
    fi

    if [ ! -e "${csr}/${csr}.csr" ]; then
        display_error "Certificate Signing Request '${csr}/${csr}.csr' does not exist."
        return 1
    fi

    local ext_options="[req_ext]\nsubjectAltName = @alt_names\n\n[alt_names]\n"
    local dns_counter=1
    local ip_counter=1

    if [ -n "$dns_list" ]; then
        IFS=',' read -ra dns_array <<< "$dns_list"
        for dns in "${dns_array[@]}"; do
            ext_options+="DNS.${dns_counter} = ${dns}\n"
            ((dns_counter++))
        done
    fi

    if [ -n "$ip_list" ]; then
        IFS=',' read -ra ip_array <<< "$ip_list"
        for ip in "${ip_array[@]}"; do
            ext_options+="IP.${ip_counter} = ${ip}\n"
            ((ip_counter++))
        done
    fi

    echo -e "$ext_options" > "${csr}/extfile.cnf"

    (
    echo "XXX"; echo "10"; echo "Signing certificate $csr..."; echo "XXX"
    openssl x509 -req -in "${csr}/${csr}.csr" -CA "${ca}/${ca}.crt" -CAkey "${ca}/${ca}.key" -CAcreateserial -out "${csr}/${csr}.crt" -days 365 -sha256 -extensions req_ext -extfile "${csr}/extfile.cnf"
    echo "XXX"; echo "100"; echo "Certificate $csr signed successfully!"; echo "XXX"
    ) | whiptail --title "Signing Certificate" --gauge "Please wait..." 10 78 0

    rm "${csr}/extfile.cnf"
    display_message "Certificate signed successfully.\nCertificate: ${csr}/${csr}.crt"
    return 0
}

# Function to generate and sign a certificate
generate_and_sign_cert() {
    local ca=$1
    local csr=$2
    local csr_name=$3
    local dns_list=$4
    local ip_list=$5

    generate_csr "$csr" "$csr_name" || return 1
    sign_cert "$ca" "$csr" "$dns_list" "$ip_list" || return 1

    return 0
}

# Main menu
while true; do
    choice=$(whiptail --title "Certificate Management" --menu "What would you like to do?" 20 78 8 \
        "1" "Create a CA certificate (10 years)" \
        "2" "Generate and sign a certificate (1 year)" \
        "3" "Quit" 3>&1 1>&2 2>&3)

    case $choice in
        1)
            ca=$(whiptail --title "Create CA Certificate" --inputbox "Enter a directory name for the CA certificate (e.g., testCA):" 10 78 3>&1 1>&2 2>&3)
            validate_input "$ca" "^[a-zA-Z0-9 _-]+$" || continue
            ca_name=$(whiptail --title "Create CA Certificate" --inputbox "Enter a custom name for your CA (e.g., Test):" 10 78 3>&1 1>&2 2>&3)
            validate_input "$ca_name" "^[a-zA-Z0-9 _-]+$" || continue
            create_ca_cert "$ca" "$ca_name"
            ;;
        2)
            ca=$(whiptail --title "Generate and Sign Certificate" --inputbox "Enter the CA certificate directory name:" 10 78 3>&1 1>&2 2>&3)
            validate_input "$ca" "^[a-zA-Z0-9 _-]+$" || continue
            csr=$(whiptail --title "Generate and Sign Certificate" --inputbox "Enter a directory name for the Certificate Signing Request (CSR):" 10 78 3>&1 1>&2 2>&3)
            validate_input "$csr" "^[a-zA-Z0-9 _-]+$" || continue
            csr_name=$(whiptail --title "Generate and Sign Certificate" --inputbox "Enter a custom name for the Certificate Signing Request (CSR):" 10 78 3>&1 1>&2 2>&3)
            validate_input "$csr_name" "^[a-zA-Z0-9 _-]+$" || continue
            dns_list=$(whiptail --title "Generate and Sign Certificate" --inputbox "Enter the list of domain names (comma-separated) (leave empty if none):" 10 78 3>&1 1>&2 2>&3)
            ip_list=$(whiptail --title "Generate and Sign Certificate" --inputbox "Enter the list of IP addresses (comma-separated) (leave empty if none):" 10 78 3>&1 1>&2 2>&3)
            generate_and_sign_cert "$ca" "$csr" "$csr_name" "$dns_list" "$ip_list"
            ;;
        3|"")
            clear
            echo "Goodbye!"
            exit 0
            ;;
    esac
done
