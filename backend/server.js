require("dotenv").config();

const axios = require("axios");
const express = require("express");
const cors = require("cors");
const OpenAI = require("openai");

const app = express();

app.use(cors());
app.use(express.json());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// ✅ AI FUNCTION
async function isRecallMatch(productName, recallDescription) {
  if (!productName || !recallDescription) return false;

  const prompt = `
Product: "${productName}"
Recall: "${recallDescription}"

Are these the SAME or RELATED product?

Answer ONLY "YES" or "NO".
`;

  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
    });

    const answer = response.choices[0].message.content
      .trim()
      .toUpperCase();

    return answer.includes("YES");
  } catch (err) {
    console.error("AI error:", err);
    return false; // fail safe
  }
}

// test route
app.get("/", (req, res) => {
  res.send("Backend is running!");
});

// barcode route
app.get("/api/barcode/:barcode", async (req, res) => {
  const barcode = req.params.barcode;

  try {
    // 1️⃣ Get product from OpenFoodFacts
    const url = `https://world.openfoodfacts.org/api/v0/product/${barcode}.json`;
    const response = await axios.get(url);

    if (response.data.status === 0) {
      return res.status(404).json({ message: "Product not found" });
    }

    const product = response.data.product;
    const productName = product.product_name;

    // 2️⃣ Get FDA recall
    let recallData = null;

    if (productName) {
      try {
        const fdaUrl = `https://api.fda.gov/food/enforcement.json?search=product_description:${productName}&limit=1`;
        const fdaResponse = await axios.get(fdaUrl);

        recallData = fdaResponse.data.results
          ? fdaResponse.data.results[0]
          : null;
      } catch (err) {
        recallData = null;
      }
    }

    // 3️⃣ AI FILTER (IMPORTANT)
    if (recallData && productName) {
      const match = await isRecallMatch(
        productName,
        recallData.product_description
      );

      if (!match) {
        recallData = null;
      }
    }

    // 4️⃣ Return result
    res.json({
      product: {
        name: product.product_name,
        brand: product.brands,
        image: product.image_url,
      },
      recall: recallData,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching data" });
  }
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

app.get("/api/recalls", async (req, res) => {
  try {
    const url = `https://api.fda.gov/food/enforcement.json?limit=15&sort=report_date:desc`;

    const response = await axios.get(url);

    const recalls = response.data.results.map(r => ({
      product: r.product_description,
      reason: r.reason_for_recall,
      company: r.recalling_firm,
      date: r.report_date,
    }));

    res.json(recalls);

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching recalls" });
  }
});