const express = require("express");
const { register, login, firebaseAuth, refresh, logout, saveFcmToken, getProfile } = require("../controllers/authController");
const authMiddleware = require("../middlewares/authMiddleware");

const router = express.Router();

// Mobile client routes
router.post("/register", register);
router.post("/login", login);
router.post("/firebase-auth", firebaseAuth);
router.post("/refresh-token", refresh);

// Protected routes
router.post("/logout", authMiddleware, logout);
router.post("/save-fcm-token", authMiddleware, saveFcmToken);
router.get("/profile", authMiddleware, getProfile);

module.exports = router;