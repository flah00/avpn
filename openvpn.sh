#!/bin/bash
. /etc/default/openvpn

function aws() {
  docker run -v $OVPN_DATA:/etc/openvpn -v $PWD:/work -w /work --rm amazon/aws-cli --region us-east-1 $*
}
function s3_sync() {
  if [ $1 = 'to' ]; then
    aws s3 sync /etc/openvpn s3://$S3_PATH --delete
  else
    aws s3 sync s3://$S3_PATH /etc/openvpn
  fi
}
case $1 in
  init)
    if ! docker volume ls 2>&1 | grep -q $OVPN_DATA; then
      $0 update-route53
      docker volume create --name $OVPN_DATA

      if [ '`aws s3 ls $S3_PATH`' = '' ]; then
        # config directory is empty, initialize it
        docker run -v $OVPN_DATA:/etc/openvpn --rm $IMAGE ovpn_genconfig \
          -C $OVPN_CIPHERS -T $OVPN_CIPHERS -u udp://$DOMAIN
        # copy configs to s3
        s3_sync to
        echo "OPENVPN INITIALIZED, YOU MUST RUN: echo ssh -i SSH_KEY core@$DOMAIN sudo /opt/openvpn.sh init-pki" >/tmp/init-pki
        exit 1
      else
        # copy configs to volume
        s3_sync from
      fi
    fi
    if ! docker inspect openvpn >/dev/null 2>&1 ; then
      SYSCTL_ARGS=$(sed -E -e 's/^/--sysctl /' /etc/sysctl.d/network.conf)
      docker create $SYSCTL_ARGS --name openvpn -v $OVPN_DATA:/etc/openvpn -p \
      1194:1194/udp --cap-add=NET_ADMIN $IMAGE
    fi
  ;;
  init-pki)
    docker run -v $OVPN_DATA:/etc/openvpn --rm -it $IMAGE ovpn_initpki
    s3_sync to
    rm /tmp/init-pki
    systemctl restart openvpn
  ;;
  start)
    if [ -f /tmp/init-pki ]; then
      logger -s -f /tmp/init-pki
      exit 1
    fi
    docker start -a openvpn
  ;;
  stop)
    docker stop openvpn
    s3_sync to
  ;;
  restart)
    systemctl stop openvpn
    systemctl start openvpn
  ;;
  update-route53)
    ZONE_ID=$(aws route53 list-hosted-zones-by-name --query 'HostedZones[*][Id,Name]' --output text | grep ", {"Ref":"HostedZoneName"}, "| awk '{print$1}')
    IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
    RR_UPSERT='{
    "Comment": "update a record",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "%s",
                "Type": "A",
                "TTL": 30,
                "ResourceRecords": [ { "Value": "%s" } ]
            }
        }
    ]
}'
    printf "$RR_UPSERT" $DOMAIN $IP > r53
    aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file:///work/r53
    rm -f r53
  ;;
  upgrade-container)
    systemctl stop openvpn
    docker rm -f openvpn
    docker pull $IMAGE
    docker rmi $(docker images --filter dangling=true -q)
    systemctl start openvpn
  ;;
  gen*)
    cli=${2:?Missing client}
    docker run -v $OVPN_DATA:/etc/openvpn --rm -it $IMAGE easyrsa build-client-full ${cli} nopass
  ;;
  get)
    cli=${2:?Missing client}
    docker run -v $OVPN_DATA:/etc/openvpn --rm $IMAGE ovpn_getclient ${cli} > ${cli}.ovpn
  ;;
  *)
    echo "$0 {init|start|stop|restart|upgrade-container|gen CLIENT|get CLIENT}"
    exit 1
  ;;
esac
