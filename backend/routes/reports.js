const express = require("express");
const router = express.Router();
const Medicine = require("../models/Medicine");
const { protect } = require("../middleware/auth");

// GET /api/reports/stock
router.get("/stock", protect, async (req, res) => {
  try {
    const medicines = await Medicine.find({}, "name batchNumber quantity companyName").sort({ name: 1 });
    const totalQuantity = medicines.reduce((sum, m) => sum + m.quantity, 0);
    res.json({ medicines, totalQuantity });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/reports/expiry
router.get("/expiry", protect, async (req, res) => {
  try {
    const now = new Date();
    const sixMonthsFromNow = new Date();
    sixMonthsFromNow.setMonth(sixMonthsFromNow.getMonth() + 6);

    const [expired, nearExpiry] = await Promise.all([
      Medicine.find({ expiryDate: { $lt: now } }, "name batchNumber expiryDate quantity").sort({ expiryDate: 1 }),
      Medicine.find(
        { expiryDate: { $gte: now, $lte: sixMonthsFromNow } },
        "name batchNumber expiryDate quantity"
      ).sort({ expiryDate: 1 }),
    ]);

    res.json({ expired, nearExpiry });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/reports/summary
router.get("/summary", protect, async (req, res) => {
  try {
    const now = new Date();
    const sixMonthsFromNow = new Date();
    sixMonthsFromNow.setMonth(sixMonthsFromNow.getMonth() + 6);

    const [total, expired, nearExpiry, quantityAgg] = await Promise.all([
      Medicine.countDocuments(),
      Medicine.countDocuments({ expiryDate: { $lt: now } }),
      Medicine.countDocuments({ expiryDate: { $gte: now, $lte: sixMonthsFromNow } }),
      Medicine.aggregate([{ $group: { _id: null, total: { $sum: "$quantity" } } }]),
    ]);

    res.json({
      totalMedicines: total,
      totalQuantity: quantityAgg[0]?.total ?? 0,
      nearExpiryCount: nearExpiry,
      expiredCount: expired,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
