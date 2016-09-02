#!/bin/bash

error() {
    printf "Error"
    [ ! -z "$1" ] && printf ": $1"
    echo
    show_help
    exit 1
}

show_help() {
    echo "$(basename $0) basename"
}

name=$1

[ ! -z "$name" ] || error "basename required"
[ ! -e "$name.pem" ] || error "file exists"
[ ! -e "$name.pub" ] || error "file exists"

openssl genpkey -algorithm RSA -out ${name}.pem || error "privkey gen fail"
openssl pkey -in ${name}.pem -out ${name}.pub -pubout || error "pubkey gen failed"
