const mongoose = require("mongoose");
const faker = require("faker");
const v4 = require("uuid/v4");
const Visitor = require("./visitor");

mongoose.Promise = Promise;
mongoose.connect("mongodb://127.0.0.1:27017/growthfunnel");

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
