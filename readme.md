## Initiate & run shard cluster

```
bash sharding.sh
```

## Start shard cluster

```
bash start.sh
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

## Create SSL user

Example:
```
db.getSiblingDB("$external").runCommand(
  {
    createUser: "emailAddress=support@testsite.com,CN=*.testsite.com,OU=admin,O=Growthfunnel,L=Dhaka,ST=Dhaka,C=BD",
    roles: [
      { role : "clusterAdmin", db : "admin" },
      { role: "dbOwner", db: "growthfunnel" },
    ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)
```

Validate
```
db.getSiblingDB("$external").auth(
  {
    mechanism: "MONGODB-X509",
    user: "emailAddress=support@crazyengage.com,CN=*.crazyengage.com,OU=admin,O=Growthfunnel,L=Dhaka,ST=Dhaka,C=BD"
  }
)
```