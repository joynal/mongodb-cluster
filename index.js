const mongoose = require("mongoose");
const faker = require("faker");
const v4 = require("uuid/v4");
const fs = require('fs');
const Visitor = require("./visitor");

const ca = [fs.readFileSync("/opt/mongodb/CA.pem")];
const key = fs.readFileSync("/opt/mongodb/client.key");
const cert = fs.readFileSync("/opt/mongodb/client.crt");

const userName = "emailAddress=support@crazyengage.com,CN=*.crazyengage.com,OU=webapp,O=Growthfunnel,L=Dhaka,ST=Dhaka,C=BD";

mongoose.Promise = Promise;
mongoose.connect("mongodb://127.0.0.1:27018/growthfunnel", {
  ssl: true,
  user: userName,
  auth: { authMechanism: "MONGODB-X509" },
  sslCA:ca,
  sslKey:key,
  sslCert:cert,
});

mongoose.connection.on("error", err => {
  console.error(err);
  console.log("MongoDB connection error. Please make sure MongoDB is running.");
  process.exit();
});

for (let i = 1; i <= 10; i++) {
  let visitor = new Visitor({
    firstName: faker.name.firstName(),
    lastName: faker.name.lastName(),
    email: faker.internet.email(),
    address: `${faker.address.zipCode()}, ${faker.address.city()}, ${faker.address.streetAddress()}, ${faker.address.country()}`,
    description: faker.lorem.sentence(),
    siteId: v4()
  });

  visitor.save(err => {
    console.log(err || `Created visitor >> ${i}`);
  });
}
