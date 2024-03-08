const jwt = require('jsonwebtoken');

const auth = async (req, res, next) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) {
      return res.status(401).json({ error: "No auth Token Access Denied" });
    }
    const verify = jwt.verify(token, "tokenKey");

    if (!verify) {
      return res
        .status(401)
        .json({ error: "Token Verification Failed ,Authorizarion Denied" });
    }

    req.user = verify.id;
    req.token = token;
    next();
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

module.exports = auth;