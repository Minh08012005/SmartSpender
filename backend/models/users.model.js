const mongoose = require("mongoose");

// Define the User schema
const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      unique: true
    },
    password: {
      type: String,
      required: true
    },
    fullName: {
      type: String,
      required: true
    }
  },
  { timestamps: true }
);

// Export the User model
module.exports = mongoose.model("User", userSchema);
