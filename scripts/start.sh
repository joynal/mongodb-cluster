#!/bin/bash

# Configure db path
DB_PATH=/data/mongodb

# Killing mongo processes
echo "killing mongod and mongos..."
killall mongod
killall mongos

# start 3 config servers
mongod -f ./confs/config/r0.yml
mongod -f ./confs/config/r1.yml
mongod -f ./confs/config/r2.yml
echo "Ready config server"

# start a replica set and tell it that it will be shard0
mongod -f ./confs/shard0/r0.yml
mongod -f ./confs/shard0/r1.yml
mongod -f ./confs/shard0/r2.yml
echo "Ready shard0"

# start a replicate set and tell it that it will be a shard1
mongod -f ./confs/shard1/r0.yml
mongod -f ./confs/shard1/r1.yml
mongod -f ./confs/shard1/r2.yml
echo "Ready shard1"

# start a replicate set and tell it that it will be a shard2
mongod -f ./confs/shard2/r0.yml
mongod -f ./confs/shard2/r1.yml
mongod -f ./confs/shard2/r2.yml
echo "Ready shard2"

# start mongos router
mongos -f ./confs/mongos/m1.yml
mongos -f ./confs/mongos/m2.yml
echo "Ready mongos router"
