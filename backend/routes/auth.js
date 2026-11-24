const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const { body, validationResult } = require("express-validator");
const User = require("../models/User");
const { protect } = require("../middleware/auth");

const generateToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });

// POST /api/auth/register
router.post(
  "/register",
  [
    body("username").trim().notEmpty().withMessage("Username is required"),
    body("password").isLength({ min: 4 }).withMessage("Password must be at least 4 characters"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { username, password, role } = req.body;
    try {
      const exists = await User.findOne({ username });
      if (exists) return res.status(400).json({ message: "Username already taken" });

      const user = await User.create({ username, password, role });
      res.status(201).json({ token: generateToken(user._id), user: { id: user._id, username: user.username, role: user.role } });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
);

// POST /api/auth/login
router.post(
  "/login",
  [
    body("username").trim().notEmpty().withMessage("Username is required"),
    body("password").notEmpty().withMessage("Password is required"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { username, password } = req.body;
    try {
      const user = await User.findOne({ username });
      if (!user || !(await user.matchPassword(password))) {
        return res.status(401).json({ message: "Invalid username or password" });
      }
      res.json({ token: generateToken(user._id), user: { id: user._id, username: user.username, role: user.role } });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
);

// GET /api/auth/me
router.get("/me", protect, (req, res) => {
  res.json({ id: req.user._id, username: req.user.username, role: req.user.role });
});

module.exports = router;
