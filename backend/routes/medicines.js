const express = require("express");
const router = express.Router();
const { body, validationResult } = require("express-validator");
const Medicine = require("../models/Medicine");
const { protect } = require("../middleware/auth");

router.use(protect);

// GET /api/medicines?status=safe|near_expiry|expired&search=query
router.get("/", async (req, res) => {
  try {
    const { status, search } = req.query;
    const now = new Date();
    const sixMonthsFromNow = new Date();
    sixMonthsFromNow.setMonth(sixMonthsFromNow.getMonth() + 6);

    let filter = {};

    if (status === "expired") {
      filter.expiryDate = { $lt: now };
    } else if (status === "near_expiry") {
      filter.expiryDate = { $gte: now, $lte: sixMonthsFromNow };
    } else if (status === "safe") {
      filter.expiryDate = { $gt: sixMonthsFromNow };
    }

    if (search) {
      const regex = new RegExp(search, "i");
      filter.$or = [{ name: regex }, { batchNumber: regex }, { companyName: regex }];
    }

    const medicines = await Medicine.find(filter).sort({ expiryDate: 1 });
    res.json(medicines);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/medicines/:id
router.get("/:id", async (req, res) => {
  try {
    const medicine = await Medicine.findById(req.params.id);
    if (!medicine) return res.status(404).json({ message: "Medicine not found" });
    res.json(medicine);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/medicines
router.post(
  "/",
  [
    body("name").trim().notEmpty().withMessage("Name is required"),
    body("batchNumber").trim().notEmpty().withMessage("Batch number is required"),
    body("companyName").trim().notEmpty().withMessage("Company name is required"),
    body("quantity").isInt({ min: 0 }).withMessage("Quantity must be a non-negative integer"),
    body("expiryDate").isISO8601().withMessage("Valid expiry date is required"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const medicine = await Medicine.create(req.body);
      res.status(201).json(medicine);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
);

// PUT /api/medicines/:id
router.put(
  "/:id",
  [
    body("name").optional().trim().notEmpty(),
    body("quantity").optional().isInt({ min: 0 }),
    body("expiryDate").optional().isISO8601(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const medicine = await Medicine.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true,
      });
      if (!medicine) return res.status(404).json({ message: "Medicine not found" });
      res.json(medicine);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
);

// DELETE /api/medicines/:id
router.delete("/:id", async (req, res) => {
  try {
    const medicine = await Medicine.findByIdAndDelete(req.params.id);
    if (!medicine) return res.status(404).json({ message: "Medicine not found" });
    res.json({ message: "Medicine deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
