db.getSiblingDB("$external").runCommand(
  {
    createUser: "emailAddress=support@crazyengage.com,CN=*.crazyengage.com,OU=Engineering,O=Growthfunnel,L=Dhaka,ST=Dhaka,C=BD",
    roles: [
      { role: 'userAdminAnyDatabase', db: 'admin' },
      { role : "clusterAdmin", db : "admin" },
      { role: "dbOwner", db: "growthfunnel" },
    ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)

db.getSiblingDB("$external").auth(
  {
    mechanism: "MONGODB-X509",
    user: "emailAddress=support@crazyengage.com,CN=*.crazyengage.com,OU=Engineering,O=Growthfunnel,L=Dhaka,ST=Dhaka,C=BD"
  }
)