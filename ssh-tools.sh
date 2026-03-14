#!/bin/bash

CONFIG="$HOME/.ssh/config"

add_host() {
    local name ip user id port=22

    # Short format: ssh-tools add pi@192.168.1.42 rpi-4
    if [[ "$1" == *@* && "$2" != "" ]]; then
        user="${1%@*}"
        ip="${1#*@}"
        name="$2"
        shift 2
    fi

    # Full format: ssh-tools add host rpi-4 --ip ... --user ...
    while [[ $# -gt 0 ]]; do
        case "$1" in
            host) name="$2"; shift 2 ;;
            --ip) ip="$2"; shift 2 ;;
            --user) user="$2"; shift 2 ;;
            --id) id="$2"; shift 2 ;;
            --port) port="$2"; shift 2 ;;
            *) echo "❌ Unknown option: $1"; exit 1 ;;
        esac
    done

    if [[ -z "$name" || -z "$ip" || -z "$user" ]]; then
        echo "⚠️  Missing required arguments: host, ip, or user"
        exit 1
    fi

    {
        echo ""
        echo "Host $name"
        echo "  HostName $ip"
        echo "  User $user"
        echo "  Port $port"
        [[ -n "$id" ]] && echo "  IdentityFile $id"
    } >> "$CONFIG"

    chmod 600 "$CONFIG"
    echo "✅ Host '$name' added to SSH config."
}

list_hosts() {
    grep -E '^Host ' "$CONFIG" | awk '{print $2}'
}

case "$1" in
    add) shift; add_host "$@" ;;
    list) list_hosts ;;
    *) echo "Usage: ssh-tools {add|list}"; exit 1 ;;
esac
