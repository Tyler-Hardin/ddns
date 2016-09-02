#!/bin/bash

error() {
    printf "Error"
    [ ! -z "$1" ] && printf ": $1"
    echo
    exit 1
}

sanitize() {
    [ $(echo "$1" | wc -l) -eq 1 ] || error
    echo "$1" | grep -E "$2" > /dev/null || error
}

update() {
    domain=$1
    ip=$2

    [ ! -z "$domain" ] || error
    [ ! -z "$ip" ] || error

nsupdate <<EOF
server ns.thardin.name
zone thardin.name
update delete ${domain}.thardin.name. A
update add ${domain}.thardin.name. 3600 A $ip
send
EOF

    return $?
}

handle_getip() {
    [ -e ~/.ddns/_getip.pub ] || error "getip: no privkey"
    echo $REMOTE_HOST
    openssl dgst -sign ~/.ddns/_getip.pub <(echo "$REMOTE_HOST") | xxd -p | tr -d '\n' \
        || error "sig fail"
}

handle_update() {
    # Subdomain name to assign. Lower case characters only.
    read domain
    sanitize "$domain" "^[a-z]{1,64}$" || error "invalid domain"

    # IP to which the subdomain should be assigned.
    read ip
    sanitize "$ip" "^[0-9.]{7,15}$" || error "invalid ip"

    # Signature of "$domain $ip", hex encoded.
    read sign
    sanitize "$sign" "^[0-9a-fA-F]{1,1000}$" || error "invalid signature format"

    pubk_file=~/.ddns/${domain}.pub
    [ -e $pubk_file ] || error "no pubkey for $domain"

    # Check if the signature is valid for the pubkey associated with the domain.
    openssl dgst -verify $pubk_file -signature <(echo $sign | xxd -p -r) \
        <(echo "$domain $ip") &> /dev/null || error "invalid signature"
    
    # Do the update.
    update $domain $ip || error "update fail"
}

handle_connection() {
    input=$(head -c 10000)
    lines=$(echo "$input" | wc -l)
    
    echo "$input" | if [ "$input" = "" ]; then
        handle_getip
    elif [ $lines -eq 3 ]; then
        handle_update
    else
        error "invalid input \"$input\""
    fi

    echo "Ok"
}

handle_connection
