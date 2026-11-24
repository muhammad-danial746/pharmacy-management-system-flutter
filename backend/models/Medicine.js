const mongoose = require("mongoose");

const medicineSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    batchNumber: { type: String, required: true, trim: true },
    companyName: { type: String, required: true, trim: true },
    quantity: { type: Number, required: true, min: 0 },
    expiryDate: { type: Date, required: true },
  },
  { timestamps: true }
);

medicineSchema.virtual("status").get(function () {
  const now = new Date();
  const sixMonthsFromNow = new Date();
  sixMonthsFromNow.setMonth(sixMonthsFromNow.getMonth() + 6);

  if (this.expiryDate < now) return "expired";
  if (this.expiryDate <= sixMonthsFromNow) return "near_expiry";
  return "safe";
});

medicineSchema.set("toJSON", { virtuals: true });
medicineSchema.set("toObject", { virtuals: true });

module.exports = mongoose.model("Medicine", medicineSchema);
