import mongoose from 'mongoose';
import { v4 } from 'uuid';
import uuidParse from 'uuid-parse';

const { Schema } = mongoose;

// Covert str to buffer value
const castToBuffer = (str) => {
  if (!str) {
    return null;
  }
  if (Buffer.isBuffer(str) || Buffer.isBuffer(str.buffer)) {
    return str;
  }
  const buffer = uuidParse.parse(str);
  return new mongoose.Types.Buffer(buffer).toObject(0x04);
};

// Convert buffer to uuid
const castToUUID = (buffer) => {
  if (!buffer || buffer.length !== 16) {
    return null;
  }
  return uuidParse.unparse(buffer);
};

const VisitorSchema = new Schema(
  {
    _id: {
      type: mongoose.Schema.Types.Buffer,
      set: castToBuffer,
      get: castToUUID,
      default: () => castToBuffer(v4()),
    },
    firstName: String,
    lastName: String,
    email: String,
    address: String,
    description: String,
    siteId: {
      type: mongoose.Schema.Types.Buffer,
      set: castToBuffer,
      get: castToUUID,
    },
    createdAt: { type: Date, default: Date.now },
  },
  { shardKey: { siteId: 1, _id: 1 } },
);

export default mongoose.model('Visitor', VisitorSchema);
