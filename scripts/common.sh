#!/bin/bash

function connect_mongosh() {
  local port=$1
  local host=${4:-"database.fluddi.com"}
  local tlsCertificateKeyFile=${2:-"/opt/mongodb/member.pem"}
  local tlsCAFile=${3:-"/opt/mongodb/CA.pem"}

  mongosh --port "$port" --host "$host" --tls --tlsCertificateKeyFile "$tlsCertificateKeyFile" --tlsCAFile "$tlsCAFile"
}

function initiate_replica_set_string() {
  local REPLICA_NAME=$1
  local PORT_START=$2

  echo "rs.initiate({
    _id: \"$REPLICA_NAME\",
    members: [
      { _id : 0, host : \"database.fluddi.com:${PORT_START}\" },
      { _id : 1, host : \"database.fluddi.com:$((PORT_START+1))\" },
      { _id : 2, host : \"database.fluddi.com:$((PORT_START+2))\" }
    ]
  })"
}

# Function to start replica set and initiate it
function start_replica_set() {
  local DB_PATH=$1
  local PORT_START=$2
  local REPLICA_NAME=$3
  local CONF_PATH=$4

  for (( i=0; i<3; i++ )); do
    mkdir -p $DB_PATH/rs$i
    mongod -f ${CONF_PATH}/r$i.yml
  done

  sleep 5
  local rs_initiate_cmd=$(initiate_replica_set_string "$REPLICA_NAME" "$PORT_START")
  connect_mongosh $PORT_START <<< "$rs_initiate_cmd"

  echo ">>>>> $REPLICA_NAME replica initialized"
}

# Function to create local user for a replica set
function create_local_user() {
  local PORT=$1
  local USER_NAME=$2
  local PASSWORD=$3

  connect_mongosh $PORT << 'EOF'
db.getSiblingDB("admin").createUser(
  {
    user: "$USER_NAME",
    pwd: "$PASSWORD",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
    ]
  }
)
EOF

  echo ">>>>> $USER_NAME local user created"
}
