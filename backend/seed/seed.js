require("dotenv").config({ path: require("path").join(__dirname, "../.env") });
const mongoose = require("mongoose");
const User = require("../models/User");
const Medicine = require("../models/Medicine");
const Supplier = require("../models/Supplier");

const users = [
  { username: "admin", password: "admin123", role: "admin" },
  { username: "pharmacist", password: "pharma123", role: "pharmacist" },
];

const suppliers = [
  { name: "HealthCare Distributors", location: "Lahore", phone: "0300-1234567", details: "Main pharma distributor" },
  { name: "Global Pharma Ltd.", location: "Karachi", phone: "0321-9876543", details: "International medicines supplier" },
  { name: "Wellness Medical Supplies", location: "Islamabad", phone: "0333-5556789", details: "Specialty healthcare products" },
  { name: "MedExpress Pakistan", location: "Peshawar", phone: "0345-1112233", details: "Fast-delivery medical supplies" },
  { name: "CureMed Distributors", location: "Faisalabad", phone: "0311-9988776", details: "Generic medicines wholesale" },
];

const now = new Date();
const addDays = (d) => { const dt = new Date(); dt.setDate(dt.getDate() + d); return dt; };
const addMonths = (m) => { const dt = new Date(); dt.setMonth(dt.getMonth() + m); return dt; };

const medicines = [
  // Safe (expire > 6 months from now)
  { name: "Paracetamol 500mg", batchNumber: "BT-1001", companyName: "HealthCare Distributors", quantity: 250, expiryDate: addMonths(18) },
  { name: "Amoxicillin 250mg", batchNumber: "BT-1002", companyName: "Global Pharma Ltd.", quantity: 100, expiryDate: addMonths(24) },
  { name: "Metformin 500mg", batchNumber: "BT-1003", companyName: "Wellness Medical Supplies", quantity: 180, expiryDate: addMonths(12) },
  { name: "Atorvastatin 10mg", batchNumber: "BT-1004", companyName: "HealthCare Distributors", quantity: 60, expiryDate: addMonths(15) },
  { name: "Omeprazole 20mg", batchNumber: "BT-1005", companyName: "Global Pharma Ltd.", quantity: 90, expiryDate: addMonths(20) },
  { name: "Azithromycin 500mg", batchNumber: "BT-1006", companyName: "MedExpress Pakistan", quantity: 50, expiryDate: addMonths(10) },
  { name: "Ciprofloxacin 500mg", batchNumber: "BT-1007", companyName: "CureMed Distributors", quantity: 75, expiryDate: addMonths(14) },
  { name: "Lisinopril 5mg", batchNumber: "BT-1008", companyName: "Wellness Medical Supplies", quantity: 120, expiryDate: addMonths(22) },

  // Near expiry (expire within 6 months)
  { name: "Ibuprofen 400mg", batchNumber: "BT-2001", companyName: "HealthCare Distributors", quantity: 40, expiryDate: addMonths(3) },
  { name: "Cetirizine 10mg", batchNumber: "BT-2002", companyName: "Global Pharma Ltd.", quantity: 30, expiryDate: addMonths(2) },
  { name: "Dextromethorphan Syrup", batchNumber: "BT-2003", companyName: "Wellness Medical Supplies", quantity: 20, expiryDate: addDays(90) },
  { name: "Diclofenac 50mg", batchNumber: "BT-2004", companyName: "MedExpress Pakistan", quantity: 55, expiryDate: addDays(120) },
  { name: "Ranitidine 150mg", batchNumber: "BT-2005", companyName: "CureMed Distributors", quantity: 25, expiryDate: addMonths(5) },

  // Expired
  { name: "Aspirin 75mg", batchNumber: "BT-3001", companyName: "HealthCare Distributors", quantity: 10, expiryDate: addDays(-30) },
  { name: "Tetracycline 250mg", batchNumber: "BT-3002", companyName: "Global Pharma Ltd.", quantity: 5, expiryDate: addDays(-90) },
  { name: "Chlorphenamine 4mg", batchNumber: "BT-3003", companyName: "Wellness Medical Supplies", quantity: 15, expiryDate: addDays(-10) },
];

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("Connected to MongoDB");

    await Promise.all([User.deleteMany(), Medicine.deleteMany(), Supplier.deleteMany()]);
    console.log("Cleared existing data");

    for (const u of users) await User.create(u);
    console.log(`Seeded ${users.length} users`);

    await Supplier.insertMany(suppliers);
    console.log(`Seeded ${suppliers.length} suppliers`);

    await Medicine.insertMany(medicines);
    console.log(`Seeded ${medicines.length} medicines`);

    console.log("\nSeed complete!");
    console.log("Login credentials:");
    console.log("  Admin     -> username: admin      | password: admin123");
    console.log("  Pharmacist-> username: pharmacist | password: pharma123");
  } catch (err) {
    console.error("Seed error:", err.message);
  } finally {
    mongoose.disconnect();
  }
};

seed();
