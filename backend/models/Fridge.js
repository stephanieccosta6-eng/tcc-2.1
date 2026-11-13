const mongoose = require('mongoose');

const FridgeSchema = new mongoose.Schema({
  ownerEmail: { type: String, required: true },
  temperature: { type: Number, default: 6.0 },
  mode: { type: String, default: 'Ideal' },
  updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Fridge', FridgeSchema);
