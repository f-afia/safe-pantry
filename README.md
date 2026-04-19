# Safe Pantry – Food Recall Scanner App

Conveniently scan food products to see if a relevant recall exists. This is for US consumers only. This app works with food products (including non-drug supplements) but does not cover pet foods, cosmetics, medical devis, or drugs.

 The application combines:
- A Flutter-based frontend (web application)
- A Node.js backend
- External APIs (FDA Recall API + OpenFoodFacts API)
- Optional AI-based recall matching (OpenAI integration)



## Running this project


### 1. Start the Backend Server

Make sure you are in the project root folder, then run:

```bash
npm install
node server.js
```
2. Open the Frontend (Web App)

After building the Flutter project, open:

build/web/index.html

NOTE:
The backend must be running for the app to fetch product and recall data.
The AI recall matching feature requires an OpenAI API key.
If no API key is provided, the app will still function using basic recall matching.
The frontend currently uses localhost for API requests, so both frontend and backend must run on the same machine.
