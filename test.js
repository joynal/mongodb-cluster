const fs = require('fs');
const mongoose = require("mongoose");
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

Visitor.findOne(
  { _id: "59fc3d4c-5104-47e7-8b6b-c84dedf17136" },
  (err, visitor) => {
    if (err) console.log("query error >>", err);
    console.log("visitor >>", visitor);
    console.log("visitor _id >>", visitor._id);
    console.log("visitor siteid >>", visitor.siteId);
    process.exit();
  }
);
