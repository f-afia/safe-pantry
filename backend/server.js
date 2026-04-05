require("dotenv").config();
const axios = require("axios");
const express = require("express");
const cors = require("cors");
const OpenAI = require("openai");

const app = express();
app.use(cors());
app.use(express.json());

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

// ✅ AI MATCHING FUNCTION
async function isRecallMatch(productName, recallDescription) {
  if (!productName || !recallDescription) return false;

  const prompt = `Product: "${productName}"
Recall Description: "${recallDescription}"

Is this the SAME product being recalled? Answer ONLY "YES" or "NO".`;

  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
    });

    return response.choices[0].message.content
      .trim()
      .toUpperCase()
      .includes("YES");
  } catch (err) {
    console.error("AI Error:", err.message);
    return false;
  }
}

// ✅ MAIN ROUTE
app.get("/api/barcode/:barcode", async (req, res) => {
  const barcode = req.params.barcode;

  try {
    // =========================
    // 1. GET PRODUCT FROM OFF
    // =========================
    const offUrl = `https://world.openfoodfacts.org/api/v0/product/${barcode}.json`;
    const offRes = await axios.get(offUrl);

    if (offRes.data.status === 0) {
      return res.status(404).json({
        message: "Product not found in OpenFoodFacts",
      });
    }

    const product = offRes.data.product;
    const productName = product.product_name || "";
    const brand = product.brands
      ? product.brands.split(",")[0].trim()
      : "";

    console.log("Product:", productName, "| Brand:", brand);

    let recallData = null;

    // =========================
    // 2. PLAN A: BARCODE SEARCH
    // =========================
    try {
      const fdaBarcodeUrl = `https://api.fda.gov/food/enforcement.json?search=code_info:"${barcode}"+OR+product_description:"${barcode}"&limit=1`;

      const fdaRes = await axios.get(fdaBarcodeUrl);

      if (fdaRes.data.results) {
        recallData = fdaRes.data.results[0];
        console.log("Direct barcode match found");
      }
    } catch (err) {
      console.log("No barcode recall match");
    }

    // =========================
    // 3. PLAN B: NAME + BRAND
    // =========================
    if (!recallData && productName) {
      try {
        const cleanName = productName
          .replace(/[^a-zA-Z0-9 ]/g, "")
          .split(" ")
          .slice(0, 4)
          .join(" ");

        const cleanBrand = brand.replace(/[^a-zA-Z0-9 ]/g, "");

        const query = cleanBrand
          ? `product_description:"${cleanName}"+AND+recalling_firm:"${cleanBrand}"`
          : `product_description:"${cleanName}"`;

        const fdaUrl = `https://api.fda.gov/food/enforcement.json?search=${query}&limit=5`;

        const fdaRes = await axios.get(fdaUrl);

        if (fdaRes.data.results) {
          for (const item of fdaRes.data.results) {
            console.log(
              "Comparing:",
              productName,
              "VS",
              item.product_description
            );

            const match = await isRecallMatch(
              productName,
              item.product_description
            );

            if (match) {
              recallData = item;
              console.log("AI confirmed match");
              break;
            }
          }
        }
      } catch (err) {
        console.log("No fuzzy recall match");
      }
    }

    // =========================
    // 4. FINAL RESPONSE
    // =========================
    res.json({
      product: {
        name: productName,
        brand: product.brands,
        image: product.image_url,
      },
      recall: recallData,
    });
  } catch (error) {
    console.error("SERVER ERROR:", error.message);
    res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
});

// ✅ START SERVER
const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});