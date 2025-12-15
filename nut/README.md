# Nutrition Deficiency Detector

A Flutter mobile/desktop app for image classification and nutritional deficiency detection using the Hugging Face model `google/mobilenet_v2_1.0_224`. The app analyzes images of the user's tongue, lips, nails, and eyes to suggest possible nutritional deficiencies based on visual features.

## Features

- **Image Selection**: Select up to 4 images (tongue, lips, nails, eyes) from your device
- **Automatic Analysis**: Auto-analyze when all 4 images are selected
- **AI-Powered**: Uses Hugging Face's MobileNet V2 for image classification
- **Deficiency Detection**: Maps visual features to possible nutritional deficiencies
- **Diet Recommendations**: Provides specific food recommendations for detected deficiencies
- **Cross-Platform**: Works on Android, iOS, Windows, macOS, Linux, and Web

## Deficiency Mappings

### Tongue
- Smooth Texture → B6, B12, Iron
- Red Color → B12, Iron
- Glossitis (White patch) → B2, B3, B12
- Mouth Ulcers → B12

### Lips
- Cracked → B1, B2, B3, B6
- Shiny Red → B2, B3
- Angular Cheilosis → B1, B2, B3, Iron

### Nails
- Spoon-Shaped → C, B7, B9
- Beau's Lines → Zinc, B7, B9
- Leukonychia (white spots) → Calcium, Zinc, B7, B9
- Cracked, Dry & Brittle → A, C, B7, B9, B12
- Vertical Ridges → Magnesium, Iron, B7, B9, B12

### Eyes
- Redness → A, B, B2, B6

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone or download this repository
2. Navigate to the project directory:
   ```bash
   cd nut
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

#### Desktop (Windows/macOS/Linux)
```bash
flutter run -d windows  # For Windows
flutter run -d macos    # For macOS
flutter run -d linux    # For Linux
```

#### Mobile (Android/iOS)
```bash
flutter run -d android  # For Android
flutter run -d ios      # For iOS (macOS only)
```

#### Web
```bash
flutter run -d chrome   # For web browser
```

## How to Use

1. **Select Images**: Click on each card to select images for:
   - Tongue
   - Lips
   - Nails
   - Eyes

2. **Auto-Analyze Toggle**: 
   - When enabled, the app automatically analyzes images once all 4 are selected
   - When disabled, you need to manually click "Analyze Now"

3. **View Results**: After analysis, you'll see:
   - ✅ **NORMAL** status if no deficiencies are detected
   - ⚠️ **DEFICIENCY DETECTED** with specific vitamins/minerals listed
   - **Recommended Foods** for each deficiency

## Output Format

The app provides clear output statements:

- **Normal**: "NORMAL - No deficiencies detected. Keep maintaining a balanced diet!"
- **Deficient**: 
  - Shows specific vitamins/minerals that may be deficient
  - Lists recommended foods for each deficiency
  - Example: "Vitamin B12: Meat, fish, dairy, eggs, fortified plant milk"

## API Configuration

The app uses the Hugging Face Inference API:
- **Model**: `google/mobilenet_v2_1.0_224`
- **API Key**: Included in the code (for production, consider using environment variables)

## Dependencies

- `file_picker: ^8.1.6` - For selecting images
- `http: ^1.2.2` - For API requests
- `image_picker: ^1.1.2` - For camera/gallery access

## Project Structure

```
lib/
  main.dart                    # Main application code
    - MyApp                    # Root widget
    - ImageUploadPage          # Image selection page
    - ImagePickerCard          # Image picker widget
    - ResultsPage              # Results display page
    - ResultCard               # Individual result widget
    - DeficiencyMapper         # Maps classifications to deficiencies
    - HuggingFaceService       # API integration
```

## Disclaimer

This app is for educational and informational purposes only. It is **not** a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.

## License

This project is open source and available for educational purposes.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
