const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());

// Set up storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uid = req.query.uid;
    const subfolder = req.query.subfolder;

    if (!uid || !subfolder) {
      return cb(new Error("Missing uid or subfolder in query params"), null);
    }

    const dir = path.join(__dirname, 'owners', uid, subfolder);
    fs.mkdirSync(dir, { recursive: true });
    console.log(`❤️ ${dir}`);
    cb(null, dir); // folder to store images
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname)); // unique name
  }
});

const upload = multer({ storage: storage });

// Endpoint to handle upload
app.post('/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }
  res.status(200).json({ message: "💡 Image uploaded", filePath: req.file.path});
});

// Serve uploaded images statically
app.use('/uploads', express.static('uploads'));

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

//Get the already present images
const fs = require('fs');

// app.get('/images', (req, res) => {
//   const dirPath = path.join(__dirname, 'uploads');
//   fs.readdir(dirPath, (err, files) => {
//     if (err) {
//       return res.status(500).json({ error: 'Unable to scan uploads folder' });
//     }
//     const filteredFiles = files.filter(file => file !== '.DS_Store');
//     const imageUrls = filteredFiles.map(file => `http://192.168.29.48:3000/uploads/${file}`);
//     res.json(imageUrls);
//   });
// });

const BASE_PATH = path.join(__dirname, 'owners');
app.use('/images', express.static(BASE_PATH));

app.get('/get-images/:uid/:subfolder', (req, res) => {
  const { uid, subfolder } = req.params;
  const dirPath = path.join(BASE_PATH, uid, subfolder);

  fs.readdir(dirPath, (err, files) => {
    if (err) return res.status(500).json({ error: 'Directory not found' });

    const imageUrls = files.map(file => `/images/${uid}/${subfolder}/${file}`);
    res.json({ images: imageUrls });
  });
});


//To delete the image present in backend
app.delete('/delete/:uid/:subfolder/:filename', (req, res) => {
  console.log('Delete route HIT');
  const filename = decodeURIComponent(req.params.filename);
  const uid = decodeURIComponent(req.params.uid);
  const subfolder = decodeURIComponent(req.params.subfolder);
  const filePath = path.join(__dirname, 'owners',uid,subfolder,filename);
  console.log('Attempting to delete file at:', filePath);

  fs.unlink(filePath, (err) => {
    if (err) {
      console.error('File deletion error:', err);
      return res.status(500).json({ message: 'Failed to delete file' });
    }
    console.log(`Deleted file: ${filename}`);
    res.status(200).json({ message: 'File deleted successfully' });
  });
});

app.use(express.json()); 

//Creating new Folder for Owner
app.post('/create',(req, res) => {
  const uid = req.body.uid;
  if (!uid) {
    return res.status(400).send("UID and image file are required.");
  }

  // Full target path: UID/subfolder/
  const dir = path.join(__dirname,'owners',uid);

  // Create nested directory if it doesn't exist
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`✅ Folder created at: ${dir}`);
    return res.send("✅ Folder created successfully.");
  } else {
    console.log(`📁 Folder already exists at: ${dir}`);
    return res.send("📁 Folder already exists.");
  }
});

app.post('/parking',(req, res) => {
  const uid = req.body.uid;
  const subfolder = req.body.subfolder;
  if (!uid) {
    return res.status(400).send("UID is required.");
  }

  // Full target path: UID/subfolder/
  const dir = path.join(__dirname,'owners',uid,subfolder);

  // Create nested directory if it doesn't exist
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`✅ Folder created at: ${dir}`);
    return res.send("✅ Folder created successfully.");
  } else {
    console.log(`📁 Folder already exists at: ${dir}`);
    return res.send("📁 Folder already exists.");
  }
});