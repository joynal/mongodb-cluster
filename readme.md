## Initiate & run shard cluster

```
bash sharding.sh
```

## Restart shard cluster

```
bash start.sh
```

## Connect to mongos

```
mongo --port 27018
```

## Generate dummy data

```
node index.js
```

## Gracefully shutdown cluster

Excute following commands from mongos
```
sh.stopBalancer()

# Use sh.getBalancerState() to verify that the balancer has stopped.
sh.getBalancerState()

# Now shutdown server
db.getSiblingDB("admin").shutdownServer()
```

## Change chunk size

```
use config
db.settings.save( { _id:"chunksize", value: <sizeInMB> } )
```

## Disable Balancing

```
sh.disableBalancing( "test.visitors")
```

## Generate cluster key file

```
cd /data/keys/mongodb/
openssl rand -base64 756 > cluster.key
chmod 400 cluster.key
```