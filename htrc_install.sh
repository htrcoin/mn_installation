#!/bin/bash

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='HighTemperature.conf'
CONFIGFOLDER='/root/.HighTemperature'
COIN_DAEMON='hightemperatured'
COIN_CLI='hightemperatured'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='https://github.com/htrcoin/htrcoin/releases/download/v1.1.0.0/hightemperatured'
BOOTSTRAP='https://github.com/htrcoin/mn_installation/releases/download/v1.0/bootstrap.tar.gz'
COIN_NAME='HighTemperature'
COIN_PORT=11368
RPC_PORT=11369

NODEIP=$(curl -s4 icanhazip.com)


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function download_node() {
  echo -e "Prepare to download ${GREEN}$COIN_NAME${NC}."
  cd $TMP_FOLDER >/dev/null 2>&1
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  wget -q $COIN_TGZ
  compile_error
  unzip $COIN_ZIP >/dev/null 2>&1
  compile_error
  chmod +x $COIN_DAEMON
  cp $COIN_DAEMON $COIN_PATH
  echo -e "Downloading ${GREEN}$COIN_NAME Bootstrap${NC}, it may take some time to finish."
  wget -q $BOOTSTRAP
  tar xf bootstrap.tar.gz -C $CONFIGFOLDER
  cd ~ >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}


function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function create_config() {
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT
EOF
}

function create_key() {
  echo -e "Enter your ${RED}$COIN_NAME Masternode Private Key${NC}. Leave it blank to generate a new ${RED}Masternode Private Key${NC} for you:"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
  $COIN_PATH$COIN_DAEMON -daemon
  sleep 30
  if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
   echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
   exit 1
  fi
  COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  if [ "$?" -gt "0" ];
    then
    echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
    sleep 30
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  fi
  $COIN_PATH$COIN_CLI stop
fi
clear
}

function update_config() {
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
#bind=$NODEIP
gen=1
masternode=1
masternodeaddr=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY
addnode=45.55.128.136
addnode=165.227.236.55
addnode=92.238.120.156:54235
addnode=46.101.11.127:37390
addnode=80.211.235.109:36392
addnode=176.56.128.63:39916
addnode=108.160.128.66:57946
addnode=45.76.43.185:35556
addnode=209.250.235.11
addnode=213.87.242.88:29859
addnode=207.148.15.251:35738
addnode=108.61.245.231:44370
addnode=206.81.9.239:47328
addnode=206.189.200.121:47970
addnode=198.50.186.4:44444
addnode=140.82.41.75:38568
addnode=45.76.235.147:58776
addnode=45.77.30.217:60062
addnode=173.249.28.244:55790
addnode=107.191.63.219:54772
addnode=159.65.144.36:40434
addnode=198.13.52.143:41476
addnode=138.197.165.50:33488
addnode=140.82.26.86:39722
addnode=43.254.133.136
addnode=94.60.85.88:32336
addnode=209.250.240.84:54210
addnode=66.11.126.195
addnode=144.202.19.157
addnode=199.247.17.204:36486
addnode=5.132.191.184
addnode=185.203.116.186
addnode=199.247.30.182
addnode=37.223.3.10:58535
addnode=80.211.176.174:48430
addnode=80.211.56.66:58942
addnode=204.48.27.42:45524
addnode=108.61.169.130:58154
addnode=207.148.0.212:36950
addnode=108.61.197.108:39574
addnode=185.87.50.107:58514
addnode=85.25.119.74
addnode=45.76.148.172:46914
addnode=139.99.193.132
addnode=138.197.164.213:51964
addnode=45.76.71.207:41862
addnode=77.55.221.206
addnode=45.76.234.249:59672
addnode=178.128.158.96:52778
addnode=45.76.38.54:47792
addnode=94.60.85.88:56324
addnode=[2002:6baf:2283::6baf:2283]:49408
addnode=144.202.33.132:32824
addnode=144.202.78.11:35136
addnode=45.77.112.204:59236
addnode=[2001:0:9d38:90d7:184a:377f:8e5e:b7ed]
addnode=188.40.110.143:21368
addnode=188.227.120.159:58257
addnode=5.189.177.203:50593
addnode=199.247.20.178:45048
addnode=107.191.55.164:51284
addnode=45.76.88.100:46004
addnode=144.202.77.15:36676
addnode=202.182.118.159:52860
addnode=144.202.33.99:43386
addnode=176.223.131.164:37074
addnode=140.82.58.37:52298
addnode=144.202.2.227:57280
addnode=144.202.76.204:38666
addnode=51.254.75.142
addnode=176.223.133.183:54604
addnode=149.28.235.130:53464
addnode=45.76.81.144:44342
addnode=41.242.166.41:55342
addnode=176.223.134.156:45434
addnode=86.16.184.149:36765
addnode=188.24.5.28:51770
addnode=195.248.225.176
addnode=80.240.28.178:40362
addnode=184.161.149.29:55988
addnode=176.223.133.188:48278
addnode=188.227.120.159:56385
addnode=199.247.6.20:34512
addnode=108.50.47.168
addnode=118.209.44.38:56915
addnode=45.76.94.77
addnode=176.223.137.237:47314
addnode=144.202.63.105:53410
addnode=144.202.100.170:60156
addnode=95.179.150.163
addnode=108.61.178.67:43924
addnode=149.28.125.116:40516
addnode=45.77.28.68
addnode=80.240.30.66
addnode=103.232.33.189:50244
addnode=195.3.144.70
addnode=176.223.133.177
addnode=82.74.39.5:59422
addnode=130.43.106.1:21399
addnode=174.31.239.45:61088
addnode=80.211.51.184:47180
addnode=185.40.30.83:64399
addnode=185.126.95.101:38492
addnode=185.126.95.102:46942
addnode=185.40.30.3:48920
addnode=188.168.138.7:50455
addnode=149.28.172.207
addnode=108.61.178.95:54120
addnode=85.217.225.161:64643
addnode=199.247.13.115:56628
addnode=207.246.116.65:40956
addnode=209.222.30.153:38078
addnode=185.126.95.4:47124
addnode=45.76.128.232:37828
addnode=188.192.159.30:54708
addnode=209.250.243.42:56680
addnode=81.82.51.7:49355
addnode=46.61.45.142:63840
addnode=188.227.120.159:54893
addnode=85.217.225.161:63677
addnode=185.126.95.1:34976
addnode=45.76.24.37:48990
addnode=178.217.107.66:64491
addnode=206.189.12.151:58206
addnode=31.172.130.81:52360
EOF
}


function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC}"
  exit 1
fi
}

function prepare_system() {
echo -e "Prepare the system to install ${GREEN}$COIN_NAME${NC} master node."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${GREEN}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip"
 exit 1
fi
clear
}

function important_information() {
 echo -e "================================================================================================================================"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} daemon is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "Use ${RED}$COIN_CLI masternode status${NC} to check your MN. A running MN will show ${RED}Status 9${NC}."
 echo -e "================================================================================================================================"
}

function setup_node() {
  get_ip
  create_config
  create_key
  update_config
  enable_firewall
  important_information
  configure_systemd
}


##### Main #####
clear

checks
prepare_system
download_node
setup_node
