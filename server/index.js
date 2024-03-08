const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");

const Document = require("./models/document");

const PORT = process.env.PORT | 3001;

const userController = require("./routes/user");
const documentController = require("./routes/document");

const app = express();
var server = http.createServer(app);

var socket = require("socket.io");
var io = socket(server);

const DB =
  "mongodb+srv://shashank59327:QiN1cxb33gVMV0zK@cluster0.bsugt6j.mongodb.net/";

mongoose
  .connect(DB)
  .then(() => {
    console.log("successfully connected");
  })
  .catch((err) => {
    console.log(err);
  });

io.on("connection", (socket) => {
  socket.on("join", (documentId) => {
    socket.join(documentId);
    console.log("joined!");
  });
  console.log("connected" + socket.id);

  socket.on("typing", (data) => {
    socket.broadcast.to(data.room).emit("changes", data);
  });

  socket.on("save", async (data) => {
    saveData(data);
  });
});

const saveData = async (data) => {
  await Document.findByIdAndUpdate(data.room, {
    content: data.delta,
  });
};

app.use(cors());
app.use(express.json());
app.use(userController);
app.use(documentController);

server.listen(PORT, "0.0.0.0", () => {
  console.log("connected at port", PORT);
});
