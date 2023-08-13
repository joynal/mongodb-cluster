#!/bin/bash

source ./scripts/common.sh

# Configure db path
DB_PATH=/data/mongodb

# Killing mongo processes
echo "killing mongod and mongos..."
killall mongod
killall mongosh

# Start config servers
echo ">>>>> Initializing config replica"
start_replica_set "$DB_PATH/config" 57040 "cfg" "./confs/config"

# Start replica sets for shard0, shard1, and shard2
start_replica_set "$DB_PATH/shard0" 37017 "s0" "./confs/shard0"
start_replica_set "$DB_PATH/shard1" 47017 "s1" "./confs/shard1"
start_replica_set "$DB_PATH/shard2" 57017 "s2" "./confs/shard2"

echo ">>>>> Wait 10 sec for every replica's primary to come online"

sleep 10

# Create local users for each replica set
create_local_user 37017 "shard0" "grw@123"
create_local_user 47017 "shard1" "grw@123"
create_local_user 57017 "shard2" "grw@123"

# now start the mongos on port 27018
mongos -f ./confs/mongos/m1.yml
echo ">>>>> Waiting 30 seconds for the replica sets to fully come online"

sleep 30

echo ">>>>> Connnecting to config db and enabling sharding"

# add shards and enable sharding on the fluddi db
connect_mongosh 27018 << 'EOF'
db.getSiblingDB("admin").createUser(
  {
    user: "admin",
    pwd: "grw@123",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role : "clusterAdmin", db : "admin" }
    ]
  }
)

db.getSiblingDB("admin").auth("admin", "grw@123")

sh.addShard("s0/database.fluddi.com:37017")
sh.addShard("s1/database.fluddi.com:47017")
sh.addShard("s2/database.fluddi.com:57017")

sh.enableSharding("fluddi")

db.getSiblingDB("$external").runCommand(
  {
    createUser: "emailAddress=support@fluddi.com,CN=*.fluddi.com,OU=DbAdmin,O=Fluddi,L=Purmerend,ST=Nord Holland,C=NL",
    roles: [
      { role : "clusterAdmin", db : "admin" },
      { role: "dbOwner", db: "fluddi" },
    ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)

db.getSiblingDB("$external").runCommand(
  {
    createUser: "emailAddress=support@fluddi.com,CN=*.fluddi.com,OU=Webapp,O=Fluddi,L=Purmerend,ST=Nord Holland,C=NL",
    roles: [
      { role: "readWrite", db: "fluddi" },
    ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)
EOF

echo ">>>>> Created database admin"
echo ">>>>> Shard enabled in database fluddi"
echo ">>>>> Created DbAdmin SSL client user for fluddi"
echo ">>>>> Created Webapp SSL client user for web application"

# use admin client certificate
connect_mongosh 27018 "/opt/mongodb/db_admin.pem" << 'EOF'
db.getSiblingDB("$external").auth(
  {
    mechanism: "MONGODB-X509",
    user: "emailAddress=support@fluddi.com,CN=*.fluddi.com,OU=DbAdmin,O=Fluddi,L=Purmerend,ST=Nord Holland,C=NL"
  }
)

use fluddi

db.createCollection("visitors")
db.visitors.ensureIndex({"siteId": 1, "_id": 1})
sh.shardCollection("fluddi.visitors", {"siteId": 1, "_id": 1})
EOF

echo ">>>>> Sharded Collection fluddi.visitors"
echo ">>>>> Completed setting up sharded environment"
