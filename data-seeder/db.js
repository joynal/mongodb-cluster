import { config } from 'dotenv';
import mongoose from 'mongoose';

config();

mongoose.Promise = Promise;
mongoose.connect(process.env.MONGODB_URL, {
  user: process.env.MONGODB_CERT_SUBJECT,
  tls: true,
  tlsCAFile: process.env.MONGODB_ROOT_CERT,
  tlsCertificateKeyFile: process.env.MONGODB_CLIENT_CERT,
  authMechanism: 'MONGODB-X509',
  authSource: '$external',
})
  .then(() => {
    console.log('Connected to MongoDB successfully!');
  })
  .catch((err) => {
    console.error('Error connecting to MongoDB:', err);
  });
