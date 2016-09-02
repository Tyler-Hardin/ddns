#!/bin/bash

port=1157

error() {
    printf "Error" 1>&2
    [ ! -z "$1" ] && printf ": $1" 1>&2
    echo 1>&2
    exit 1
}

show_help() {
    echo "$(basename $0) ddns-server domain [ip]"
}

getip() {
    server=$1
    pubk_file=~/.ddns/_$server.pub
    [ -e $pubk_file ] || { error "no pub key for $server"; return 1; }

    printf "" | ncat $server $port 2> /dev/null | { 
        read ip
        read sign

        openssl dgst -verify $pubk_file -signature <(printf "$sign" | xxd -p -r) \
                <(echo "$ip") &> /dev/null || error "invalid signature"
        
        echo "$ip" 
    }
}

get_message() {
    domain=$1
    ip=$2

    key=~/.ddns/$domain.pem

    [ -e $key ] || error "no private key for $domain found"

    sign=`openssl dgst -sign $key <(echo "$domain $ip") | xxd -p | tr -d '\n'` \
        || error "couldn't create signature"

    echo $domain
    echo $ip
    echo $sign
}

server=$1
domain=$2
ip=$3
[ ! -z "$server" ] || { show_help; error "server required"; }
[ ! -z "$domain" ] || { show_help; error "domain required"; }
echo "$domain" | grep -Eq "^[a-z]{1,64}$" || error "invalid domain";
[ ! -z "$ip" ] || ip=`getip $server` || error "failed to get IP"

message="`get_message $domain $ip`" || exit 1

echo "$message" | ncat $server $port | {
    read response
    [ $response = "Ok" ] || error "unsuccessful response from server"
}
