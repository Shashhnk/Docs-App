const express = require("express");
const Document = require("../models/document");
const router = express.Router();
const auth = require("../middleware/auth");

// Create a Document
router.post("/doc/create", auth, async (req, res, next) => {
  try {
    const { createdAt } = req.body;
    let document = new Document({
      uid: req.user,
      title: "Untitled Document",
      createdAt,
    });
    document = await document.save();
    res.json(document);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update title for a Single Document
router.post("/doc/title", auth, async (req, res, next) => {
  try {
    const { id, title } = req.body;
    let document = await Document.findByIdAndUpdate(id, { title });
    res.json(document);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get every document created by  user
router.get("/docs/me", auth, async (req, res, next) => {
  try {
    let docs = await Document.find({ uid: req.user });
    res.json(docs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
})

// Get a Single Document
router.get("/doc/:id", auth, async (req, res, next) => {
  try {
    let id = req.params.id;
    let docs = await Document.findById(id);
    res.json(docs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
