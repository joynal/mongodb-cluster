import {fakerEN as faker} from '@faker-js/faker';
import {v4} from 'uuid';

import Visitor from "./visitor.js";

import './db.js';

const run = async () => {
  let visitors = [];
  const batchSize = 10000;
  const total = process.argv[2] || 50000;

  console.info(`generating ${total} dummy subscribers...`);

  for (let index = 0; index < total; index += 1) {
    const model = new Visitor({
      firstName: faker.person.firstName(),
      lastName: faker.person.lastName(),
      email: faker.internet.email(),
      address: `${faker.location.zipCode()}, ${faker.location.city()}, ${faker.location.streetAddress()}, ${faker.location.country()}`,
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

  console.info('generation completed');
  process.exit(0);
};

run()
  .catch(err => console.error(err.message));

