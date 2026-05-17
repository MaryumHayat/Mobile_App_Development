Here is the final, comprehensive **`README.md`** file. It now includes an open-source **MIT License** section and integrates the **Developer Options/Phone Connection Guide** right into the documentation so anyone looking at your GitHub repository knows exactly how to set it up and run it on their own physical device.

Copy and paste everything inside the block below:

```markdown
# Abaya Designer 👗✨

An elegant, high-end e-commerce mobile application built using **Flutter** and **Dart**. The app features a luxury minimalist aesthetic, custom smooth animations, and a dynamic AI-powered mix-and-match fashion stylist engine.

---

## 🚀 Key Features

*   **Virtual Mix-and-Match Interface:** Seamlessly preview high-fashion combinations of abayas with various hijab matching styles directly on an interactive canvas.
*   **AI Fashion Stylist:** Integrated with **Groq AI (Llama-3.3-70b)** acting as a luxury fashion consultant to recommend bold, contrasting, and high-end color pairing choices from available stock.
*   **Advanced E-Commerce Workflow:** 
    *   **Add to Cart:** Effortlessly manage selected garments and tailored matching pairs.
    *   **Favorites & Wishlist:** Save custom-curated combinations to a personal wishlist for quick access later.
    *   **Order Placement:** A fully operational checkout pipeline to finalize purchases and process orders.
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
git clone [https://github.com/your-username/abaya-designer.git](https://github.com/your-username/abaya-designer.git)


```



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

---

## 🔌 Connecting Your Physical Phone (Developer Options)

To run this app smoothly on your personal physical phone instead of using a heavy desktop emulator, configure your device using the steps below:

### For Android Phones
1. Open your phone's **Settings**.
2. Go to **About Phone** (or **System** > **About Device** depending on your phone brand).
3. Find the **Build Number** listing and **tap it rapidly 7 times**. You will see a notification saying *"You are now a developer!"* (Enter your lock screen PIN if prompted).
4. Go back to the main **Settings** menu, look for **Developer Options** (often under *System* or *Additional Settings*), and open it.
5. Find and turn **ON** the switch for **USB Debugging**.
6. Connect your phone to your computer with a USB cable. When a prompt appears on your phone asking to *Allow USB Debugging*, check "Always allow" and tap **OK**.

### For iPhones (iOS 16+)
1. Open **Settings** on your iPhone and go to **Privacy & Security**.
2. Scroll all the way to the bottom and tap **Developer Mode**.
3. Toggle the switch to **On**. Your phone will prompt you to restart. Tap **Restart**.
4. Once the phone reboots and you unlock it, tap **Turn On** on the alert message and enter your passcode.
5. Connect your iPhone to your computer via cable and select **Trust This Computer** when prompted.

---

## 🏁 Launching the App

Once your phone is configured and plugged into your computer, run these commands in your project terminal:

```bash
# Verify your physical device is recognized
flutter devices

# Compile and launch the app directly onto your connected device
flutter run

```

## 📄 License

All Rights Reserved. 

Copyright (c) 2026 Maryum Hayat.

This software and its associated documentation files are proprietary. No part of this project may be copied, modified, distributed, compiled, or used for any purpose—commercial or non-commercial—without the explicit, written permission of the copyright owner. 

If you wish to use or build upon this project, you must contact the author directly to obtain a formal license.


```


```
