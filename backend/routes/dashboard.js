const express = require("express");
const router = express.Router();
const Medicine = require("../models/Medicine");
const { protect } = require("../middleware/auth");

// GET /api/dashboard
router.get("/", protect, async (req, res) => {
  try {
    const now = new Date();
    const sixMonthsFromNow = new Date();
    sixMonthsFromNow.setMonth(sixMonthsFromNow.getMonth() + 6);

    const [total, expired, nearExpiry, safe] = await Promise.all([
      Medicine.countDocuments(),
      Medicine.countDocuments({ expiryDate: { $lt: now } }),
      Medicine.countDocuments({ expiryDate: { $gte: now, $lte: sixMonthsFromNow } }),
      Medicine.countDocuments({ expiryDate: { $gt: sixMonthsFromNow } }),
    ]);

    const safeStock = await Medicine.aggregate([
      { $match: { expiryDate: { $gt: sixMonthsFromNow } } },
      { $group: { _id: null, totalQuantity: { $sum: "$quantity" } } },
    ]);

    const recentMedicines = await Medicine.find({ expiryDate: { $gt: sixMonthsFromNow } })
      .sort({ createdAt: -1 })
      .limit(5);

    res.json({
      totalMedicines: total,
      expired,
      nearExpiry,
      safe,
      safeStockQuantity: safeStock[0]?.totalQuantity ?? 0,
      recentMedicines,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
