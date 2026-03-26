const axios = require("axios"); 
const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

// test route
app.get("/", (req, res) => {
  res.send("Backend is running!");
});

// NEW: barcode route
app.get("/api/barcode/:barcode", async (req, res) => {
  const barcode = req.params.barcode;

  try {
    const url = `https://world.openfoodfacts.org/api/v0/product/${barcode}.json`;

    const response = await axios.get(url);

    if (response.data.status === 0) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    const product = response.data.product;

    res.json({
      name: product.product_name,
      brand: product.brands,
      image: product.image_url,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: "Error fetching product",
    });
  }
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});