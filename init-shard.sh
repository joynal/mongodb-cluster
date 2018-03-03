# Configure db path
DB_PATH=/data/mongodb

# Killing mongo processes
echo "killing mongod and mongos..."
killall mongod
killall mongos

# 1. start a replica set and tell it that it will be shard0
mkdir -p $DB_PATH/shard0/rs0 $DB_PATH/shard0/rs1 $DB_PATH/shard0/rs2
mongod --config ./confs/shard0/r0.conf
mongod --config ./confs/shard0/r1.conf
mongod --config ./confs/shard0/r2.conf

sleep 5
# connect to one server and initiate the set
mongo --port 37017 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/certificate.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
rs.initiate({
  _id: "s0",
  members: [
    { _id : 0, host : "database.fluddi.com:37017" },
    { _id : 1, host : "database.fluddi.com:37018" },
    { _id : 2, host : "database.fluddi.com:37019", arbiterOnly: true }
  ]
})
EOF

echo ">>>>> shard0 replica initialized"

# 2. start a replicate set and tell it that it will be a shard1
mkdir -p $DB_PATH/shard1/rs0 $DB_PATH/shard1/rs1 $DB_PATH/shard1/rs2
mongod --config ./confs/shard1/r0.conf
mongod --config ./confs/shard1/r1.conf
mongod --config ./confs/shard1/r2.conf

sleep 5

mongo --port 47017 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/certificate.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
rs.initiate({
  _id: "s1",
  members: [
    { _id : 0, host : "database.fluddi.com:47017" },
    { _id : 1, host : "database.fluddi.com:47018" },
    { _id : 2, host : "database.fluddi.com:47019", arbiterOnly: true }
  ]
})
EOF

echo ">>>>> shard1 replica initialized"

# 3. start a replicate set and tell it that it will be a shard2
mkdir -p $DB_PATH/shard2/rs0 $DB_PATH/shard2/rs1 $DB_PATH/shard2/rs2
mongod --config ./confs/shard2/r0.conf
mongod --config ./confs/shard2/r1.conf
mongod --config ./confs/shard2/r2.conf

sleep 5

mongo --port 57017 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/certificate.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
rs.initiate({
  _id: "s2",
  members: [
    { _id : 0, host : "database.fluddi.com:57017" },
    { _id : 1, host : "database.fluddi.com:57018" },
    { _id : 2, host : "database.fluddi.com:57019", arbiterOnly: true }
  ]
})
EOF

echo ">>>>> shard2 replica initialized"

# 4. now start 3 config servers
mkdir -p $DB_PATH/config/rs0 $DB_PATH/config/rs1 $DB_PATH/config/rs2 
mongod --config ./confs/config/r0.conf
mongod --config ./confs/config/r1.conf
mongod --config ./confs/config/r2.conf

sleep 5

mongo --port 57040 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/certificate.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
rs.initiate({
  _id: "cfg",
  configsvr: true,
  members: [
    { _id : 0, host : "database.fluddi.com:57040" },
    { _id : 1, host : "database.fluddi.com:57041" },
    { _id : 2, host : "database.fluddi.com:57042" }
  ]
})
EOF

echo ">>>>> configsvr replica initialized"
echo ">>>>> Wait 10 sec for every replica's primary come online"

sleep 10

# Create shard's local user
#1
mongo --port 37017 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/certificate.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
db.getSiblingDB("admin").createUser(
  {
    user: "shard0",
    pwd: "grw@123",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
    ]
  }
)
EOF

echo ">>>>> shard0 local user created"

#2
mongo --port 47017 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/certificate.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
db.getSiblingDB("admin").createUser(
  {
    user: "shard1",
    pwd: "grw@123",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
    ]
  }
)
EOF

echo ">>>>> shard1 local user created"

#3
mongo --port 57017 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/certificate.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
db.getSiblingDB("admin").createUser(
  {
    user: "shard2",
    pwd: "grw@123",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
    ]
  }
)
EOF

echo ">>>>> shard2 local user created"

# now start the mongos on port 27018
mongos --config ./confs/mongos/m1.conf
echo ">>>>> Waiting 60 seconds for the replica sets to fully come online"

sleep 60

echo ">>>>> Connnecting to mongos and enabling sharding"

# add shards and enable sharding on the fluddi db
mongo --port 27018 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/certificate.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
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
    createUser: "emailAddress=support@fluddi.com,CN=*.fluddi.com,OU=appadmin,O=Fluddi,L=Dhaka,ST=Dhaka,C=BD",
    roles: [
      { role : "clusterAdmin", db : "admin" },
      { role: "dbOwner", db: "fluddi" },
    ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)

db.getSiblingDB("$external").runCommand(
  {
    createUser: "emailAddress=support@fluddi.com,CN=*.fluddi.com,OU=webapp,O=Fluddi,L=Dhaka,ST=Dhaka,C=BD",
    roles: [
      { role: "readWrite", db: "fluddi" },
    ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)
EOF

echo ">>>>> Created database admin"
echo ">>>>> Shard enabled in database fluddi"
echo ">>>>> Created appadmin SSL client user for fluddi"
echo ">>>>> Created webapp SSL client user for web application"

mongo --port 27018 --ssl --host database.fluddi.com --sslPEMKeyFile /opt/mongodb/admin-client.pem --sslCAFile /opt/mongodb/CA.pem << 'EOF'
db.getSiblingDB("$external").auth(
  {
    mechanism: "MONGODB-X509",
    user: "emailAddress=support@fluddi.com,CN=*.fluddi.com,OU=appadmin,O=Fluddi,L=Dhaka,ST=Dhaka,C=BD"
  }
)

use fluddi

db.createCollection("visitors")
db.visitors.ensureIndex({"siteId": 1, "_id": 1})
sh.shardCollection("fluddi.visitors", {"siteId": 1, "_id": 1})
EOF

echo ">>>>> Sharded Collection fluddi.visitors"

sleep 5
echo ">>>>> Done setting up sharded environment on database.fluddi.com"