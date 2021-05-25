set -e

export LOG_FILE=/tmp/install.log

CERT_DIR=/etc/ssl/certs
KEY_DIR=/etc/ssl/private
CONFIG_DIR=/etc/lamassu
MIGRATE_STATE_PATH=$CONFIG_DIR/.migrate
LAMASSU_CA_PATH=$CERT_DIR/Lamassu_CA.pem


MNEMONIC_DIR=$CONFIG_DIR/mnemonics 
MNEMONIC_FILE=$MNEMONIC_DIR/mnemonic.txt 
BACKUP_DIR=/var/backups/postgresql
BLOCKCHAIN_DIR=/mnt/blockchains
OFAC_DATA_DIR=/var/lamassu/ofac
ID_PHOTO_CARD_DIR=/opt/lamassu-server/idphotocard
FRONTCAMERA_DIR=/opt/lamassu-server/frontcamera

CA_KEY_PATH=$KEY_DIR/Lamassu_OP_Root_CA.key
CA_PATH=$CERT_DIR/Lamassu_OP_Root_CA.pem
SERVER_KEY_PATH=$KEY_DIR/Lamassu_OP.key
SERVER_CERT_PATH=$CERT_DIR/Lamassu_OP.pem

decho "Generating SSL certificates..."

openssl genrsa \
  -out $CA_KEY_PATH \
  4096 >> $LOG_FILE 2>&1

openssl req \
  -x509 \
  -sha256 \
  -new \
  -nodes \
  -key $CA_KEY_PATH \
  -days 3650 \
  -out $CA_PATH \
  -subj "/C=IS/ST=/L=Reykjavik/O=Lamassu Operator CA/CN=operator.lamassu.is" \
  >> $LOG_FILE 2>&1

openssl genrsa \
  -out $SERVER_KEY_PATH \
  4096 >> $LOG_FILE 2>&1

openssl req -new \
  -key $SERVER_KEY_PATH \
  -out /tmp/Lamassu_OP.csr.pem \
  -subj "/C=IS/ST=/L=Reykjavik/O=Lamassu Operator/CN=$IP" \
  -reqexts SAN \
  -sha256 \
  -config <(cat /etc/ssl/openssl.cnf \
      <(printf "[SAN]\nsubjectAltName=IP.1:$IP")) \
  >> $LOG_FILE 2>&1

openssl x509 \
  -req -in /tmp/Lamassu_OP.csr.pem \
  -CA $CA_PATH \
  -CAkey $CA_KEY_PATH \
  -CAcreateserial \
  -out $SERVER_CERT_PATH \
  -extfile <(cat /etc/ssl/openssl.cnf \
      <(printf "[SAN]\nsubjectAltName=IP.1:$IP")) \
  -extensions SAN \
  -days 3650 >> $LOG_FILE 2>&1

rm /tmp/Lamassu_OP.csr.pem
