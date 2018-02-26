const Visitor = require("./visitor");

require('./connection');

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
