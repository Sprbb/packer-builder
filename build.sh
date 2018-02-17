#!/bin/bash
NAME=$1
FILE=$2

if [ -z "${NAME}" ] || [ "${NAME}" == "--help" ] || [ -z "${FILE}" ]; then
  echo "Usage: $0 machine jobname"
  echo "$0 p1 windows_2016_docker"
  exit 1
fi

ip=$(./packet.sh ip $NAME)
scp packer-build.sh root@$ip:

echo "Monitor the packer build with VNC and SSH"
echo "See the VNC port number and password in packer output."
echo ""
echo "ssh -L 127.0.0.1:59xx:127.0.0.1:59xx root@$ip tail -f packer-windows/packer-build.log"

ssh root@$(./packet.sh ip $NAME) ./packer-build.sh $FILE