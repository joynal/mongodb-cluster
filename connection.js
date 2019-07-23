require('dotenv').config();
const fs = require('fs');
const mongoose = require('mongoose');

mongoose.Promise = Promise;
mongoose.connect(process.env.MONGODB_URL, {
  ssl: true,
  auth: { authMechanism: 'MONGODB-X509' },
  user: process.env.MONGODB_SSL_USER,
  sslCA: [fs.readFileSync(process.env.MONGODB_ROOT_CERT)],
  sslKey: fs.readFileSync(process.env.MONGODB_CLIENT_CERT_KEY),
  sslCert: fs.readFileSync(process.env.MONGODB_CLIENT_CERT_CRT),
});

mongoose.connection.on('error', (err) => {
  console.error(err);
  console.log('MongoDB connection error. Please make sure MongoDB is running.');
  process.exit();
});
