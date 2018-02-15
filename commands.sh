db.getSiblingDB("$external").runCommand(
  {
    createUser: "emailAddress=team@aaroza.com,CN=192.168.33.10,OU=Engineering,O=Aaroza,L=Dhaka,ST=Dhaka,C=BD",
    roles: [
             { role: 'readWrite', db: 'growthfunnel' },
             { role: 'userAdminAnyDatabase', db: 'admin' }
           ],
    writeConcern: { w: "majority" , wtimeout: 5000 }
  }
)

db.getSiblingDB("$external").auth(
  {
    mechanism: "MONGODB-X509",
    user: "emailAddress=team@aaroza.com,CN=192.168.33.10,OU=Engineering,O=Aaroza,L=Dhaka,ST=Dhaka,C=BD"
  }
)