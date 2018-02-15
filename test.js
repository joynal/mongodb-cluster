const mongoose = require("mongoose");
const Visitor = require("./visitor");

mongoose.Promise = Promise;
mongoose.connect("mongodb://127.0.0.1:27017/test");

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
