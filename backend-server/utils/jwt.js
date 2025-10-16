const jwt = require("jsonwebtoken");

const generateTokens = (user) => {
  const payload = {
    userId: user._id,
    email: user.email,
    authProvider: user.authProvider
  };

  if (user.uid) {
    payload.uid = user.uid;
  }

  const accessToken = jwt.sign(
    payload,
    process.env.JWT_SECRET,
    { expiresIn: "6h" }
  );

  const refreshToken = jwt.sign(
    { userId: user._id, uid: user.uid },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: "7d" }
  );

  return { accessToken, refreshToken };
};

module.exports = generateTokens;