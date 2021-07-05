#!/bin/bash

### This script reads in a file in /etc/hosts format <ip> <hostname>, then attempts to netcat to the host using provided port
### if no port is provided, it will attempt to connect via port 22
### if no file is provided, it will use /etc/hosts to read in IPs
### Usage: ./netcat.sh <port> <file>
### Example: ./netcat.sh  <- this will try scanning /etc/hosts and connect to each IP via port 22
### Example: ./netcat.sh 21500 /home/user/testfile


# nctest
port=${1:-22}  # default 22
file=${2:-"/etc/hosts"}  # default /etc/hosts
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'  # no color

## check if netcat is installed
if (type nc 2>&1 >/dev/null)
then
    echo "netcat is installed, proceeding.."
else
    echo -e "${RED}[ERROR]${NC} netcat is not installed on this host"
    exit 1
fi


while read -r line
do        
    if [[ -n $line ]] && [[ "${line}" != \#* ]]
    then
        ip=$(echo $line | awk '{print $1}')
        hostname=$(echo $line | awk '{print $2}')

        ## if ipv4
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "--------------------------------------"
            
            ## attempt netcat connection, timeout of 2
            if (nc -z -w 2 $ip $port 2>&1 >/dev/null)
            then
                echo -e "${hostname}   nc ${ip} ${port} ... ${GREEN}ok${NC}"
            else
                echo -e "${hostname}   nc ${ip} ${port} ... ${RED}[FAIL]${NC}"
            fi
        fi
    fi

done < $file
