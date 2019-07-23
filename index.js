const faker = require('faker');
const v4 = require('uuid/v4');
const Visitor = require('./visitor');

require('./connection');

const run = async () => {
  try {
    let visitors = [];
    const batchSize = 10000;
    const total = process.argv[2] || 50000;

    console.info(`generating ${total} dummy subscribers...`);

    for (let index = 0; index < total; index += 1) {
      const model = new Visitor({
        firstName: faker.name.firstName(),
        lastName: faker.name.lastName(),
        email: faker.internet.email(),
        address: `${faker.address.zipCode()}, ${faker.address.city()}, ${faker.address.streetAddress()}, ${faker.address.country()}`,
        description: faker.lorem.sentence(),
        siteId: v4(),
      });

      visitors.push(model);

      if (visitors.length === batchSize) {
        // eslint-disable-next-line no-await-in-loop
        await Visitor.insertMany(visitors);
        visitors = [];
      }
    }

    await Visitor.insertMany(visitors);

    console.log('generation completed');
    process.exit(0);
  } catch (err) {
    console.error('err:', err);
  }
};

run();

for (let i = 1; i <= 50000; i += 1) {
  const visitor = new Visitor({
    firstName: faker.name.firstName(),
    lastName: faker.name.lastName(),
    email: faker.internet.email(),
    address: `${faker.address.zipCode()}, ${faker.address.city()}, ${faker.address.streetAddress()}, ${faker.address.country()}`,
    description: faker.lorem.sentence(),
    siteId: v4(),
  });

  visitor.save((err) => {
    console.log(err || `created visitor: ${i}`);
  });
}
