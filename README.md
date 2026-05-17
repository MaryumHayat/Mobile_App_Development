```markdown
# Abaya Designer 👗✨

An elegant, high-end e-commerce mobile application built using **Flutter** and **Dart**. The app features a luxury minimalist aesthetic, custom smooth animations, and a dynamic AI-powered mix-and-match fashion stylist engine.

---

## 🚀 Key Features

*   **Virtual Mix-and-Match Interface:** Seamlessly preview high-fashion combinations of abayas with various hijab matching styles directly on an interactive canvas.
*   **AI Fashion Stylist:** Integrated with **Groq AI (Llama-3.3-70b)** acting as a luxury fashion consultant to recommend bold, contrasting, and high-end color pairing choices from available stock.
*   **Advanced E-Commerce Workflow:** 
    *   **Add to Cart:** Effortlessly manage selected garments and tailored matching pairs.
    *   **Favorites & Saves:** Save custom-curated combinations to a personal wishlist for later viewing.
    *   **Order Placement:** A fully operational checkout pipeline to complete purchases.
*   **Intelligent Hard Filtering:** Hardcoded style logic built directly into the response lifecycle to eliminate boring, overused default neutral shades (like Light Grey) in favor of high-fashion choices.
*   **Robust Failsafe Pipeline:** Engineered with instant fallback options to ensure a continuous fluid shopping experience even during full API or network dropouts.

---

## 🛠️ Built With

*   **Frontend Framework:** Flutter & Dart
*   **Backend & Sync:** Firebase Realtime Database & Authentication
*   **AI Service Provider:** Groq API Cloud Client Engine
*   **Model Architecture:** `llama-3.3-70b-versatile` (Strict JSON Object output enforcement)

---

## ⚙️ Project Setup & Security Note

To prevent API exploitation, the live **Groq API Key** is completely extracted from the tracking history. 

To run this project locally, you must create a file named `api_config.dart` within the `lib/` directory manually:

```dart
// lib/api_config.dart
const String groqApiKey = "YOUR_GROQ_API_KEY_HERE";

```

> **Warning**
> Never commit `lib/api_config.dart` to GitHub. It is actively restricted inside the `.gitignore` configuration.

---

## 📲 Local Development Installation

1. Clone this repository to your local machine:
```bash
git clone [https://github.com/MaryumHayat/Mobile_App_Development.git](https://github.com/MaryumHayat/Mobile_App_Development.git)

```


2. Navigate into the root project directory:
```bash
cd abaya-designer

```


3. Fetch your flutter framework dependencies:
```bash
flutter pub get


```



```
4. Setup your `lib/api_config.dart` credentials file as instructed above.
5. Connect your mobile device or simulator and run the compiler:
   ```bash
   flutter run
   

```
