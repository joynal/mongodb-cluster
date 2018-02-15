const mongoose = require("mongoose");
const v4 = require("uuid/v4");
const uuidParse = require("uuid-parse");
const Schema = mongoose.Schema;

// Covert str to buffer value
const castToBuffer = str => {
  if (!str) {
    return null;
  }
  if (Buffer.isBuffer(str) || Buffer.isBuffer(str.buffer)) {
    return str;
  }
  let buffer = uuidParse.parse(str);
  return new mongoose.Types.Buffer(buffer).toObject(0x04);
};

// Convert buffer to uuid
const castToUUID = buffer => {
  if (!buffer || buffer.length !== 16) {
    return null;
  }
  return uuidParse.unparse(buffer);
};

const VisitorSchema = new Schema({
  _id: {
    type: mongoose.Schema.Types.Buffer,
    set: castToBuffer,
    get: castToUUID,
    default: () => castToBuffer(v4())
  },
  firstName: String,
  lastName: String,
  email: String,
  address: String,
  description: String,
  siteId: {
    type: mongoose.Schema.Types.Buffer,
    set: castToBuffer,
    get: castToUUID
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Visitor", VisitorSchema);
