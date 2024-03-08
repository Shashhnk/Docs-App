const express = require("express");
const User = require("../models/user");
const jwt = require('jsonwebtoken')
const router = express.Router();
const auth = require('../middleware/auth')


router.post("/api/signup", async (req, res, next) => {
  try {
    const { name, email, profilePic } = req.body;
    let user = await User.findOne({ email: email });
    if (!user) {
      user = new User({
        name,
        email,
        profilePic,
      });
      user = await user.save();
    }
   const token =  jwt.sign({id: user._id},"tokenKey")
    res.json({ user , token });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

router.get("/api/get", auth ,async (req, res, next) => {
 const user = await  User.findById(req.user);
 res.json({user,token:req.token})
});

module.exports = router;
