# Card Recognizer
**Card Recognizer** is a Flutter-based mobile application that leverages the power of **Google Gemini** to identify and provide detailed some information about collectible trading cards (TCGs).


## 🚀 Features

* **Multimodal Input:** * **Camera:** Snap a live photo of any card.
    * **Gallery:** Import existing card photos from your library.
    * **Clipboard:** Directly paste image data from your clipboard into the chat.
* **AI-Powered Recognition:** Uses Google Gemini to identify the card type and details.
* **Intelligent Chat Context:** Ask follow-up questions about the card (e.g., "What is the market value of this Pokémon card?").

---

## 🛠️ Tech Stack

* **Frontend:** [Flutter](https://flutter.dev) (Dart)
* **AI Engine:** [Google Gemini API](https://aistudio.google.com/) (using the `google_generative_ai` package)
* **Image Handling:** `image_picker` & `pasteboard`
* **State Management:** `flutter_riverpod`

---

## ⚙️ Getting Started

### Prerequisites

1.  **Flutter SDK:** Ensure you have the latest stable version installed.
2.  **Gemini API Key:** Go to [Google AI Studio](https://aistudio.google.com/).
    * Generate a new API Key.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/newasia2538/card-recognizer-app.git
    cd card-recognizer-app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Setup API Key:**
    Create a `.env` file in the root directory or add your key to a configuration file:
    ```dart
    // lib/config.dart
    const String geminiApiKey = 'YOUR_API_KEY_HERE';
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 📸 Usage

1.  **Launch the app** and navigate to the AI Chat screen.
2.  **Upload a photo** using the 📷 (Camera), 🖼️ (Gallery), or 📋 (Clipboard) buttons.
3.  **The AI will analyze** the image and provide a summary of the card.
4.  **Chat** with the AI to extract more specific data.



---

## 🤝 Contributing

Contributions are welcome! Whether it's a bug fix, a new feature, or improving documentation:

1.  Fork the Project.
2.  Create your Feature Branch (`git checkout -b feature/any-new-feature`).
3.  Commit your Changes (`git commit -m 'Add some feature new'`).
4.  Push to the Branch (`git push origin feature/any-new-feature`).
5.  Open a Pull Request.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

**Developed by [[newasia2538](https://github.com/newasia2538)]**
