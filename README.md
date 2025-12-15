# 🥗 Nutrition Deficiency Detector - Comprehensive Documentation
<div align="center">

<h1>🥗 Nutrition Deficiency Detector</h1>

<img src="https://readme-typing-svg.herokuapp.com?font=Poppins&size=24&duration=3500&pause=1000&color=2ECC71&center=true&vCenter=true&width=800&lines=AI-powered+Nutrition+%26+Health+Tracking+App;Non-Invasive+Deficiency+Detection;AR+Food+Analysis+%7C+Voice+Logging+%7C+AI+Doctor;Built+with+Flutter+%26+Groq+AI" />

<br/>

<p align="center">
  <b>Designed & Developed by</b><br/>
  <b style="font-size:20px;">Dharun2712</b><br/>
  📧 <a href="mailto:dharunkumarm2005@gmail.com">dharunkumarm2005@gmail.com</a>
</p>

<img src="https://capsule-render.vercel.app/api?type=wave&color=gradient&height=120&section=footer"/>

</div>


<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**An AI-powered nutrition and health tracking app with AR features, voice interaction, and personalized diet planning**

[Features](#-features) • [Architecture](#-architecture) • [Installation](#-installation) • [Flow Diagrams](#-flow-diagrams) • [API Integration](#-api-integration)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Technology Stack](#-technology-stack)
- [Architecture](#-architecture)
- [Feature Details](#-feature-details)
- [Flow Diagrams](#-flow-diagrams)
- [Database Schema](#-database-schema)
- [API Integration](#-api-integration)
- [Installation Guide](#-installation-guide)
- [Usage Guide](#-usage-guide)
- [Screenshots](#-screenshots)

---

## 🌟 Overview

The **Nutrition Deficiency Detector** is a comprehensive health and nutrition tracking application that uses artificial intelligence, computer vision, and augmented reality to help users identify nutritional deficiencies, track their diet, and receive personalized health recommendations.

### Core Capabilities

- 🔍 **Visual Deficiency Detection**: Analyze tongue, lips, nails, and eyes for health indicators
- 🍽️ **AI Food Analysis**: Identify foods and calculate nutritional content using Groq Vision AI
- 🎤 **Voice Meal Logging**: Speak your meals for instant nutritional analysis
- 📊 **Progress Tracking**: Monitor deficiency improvements over time with charts
- 🤖 **AI Chatbot**: Get personalized nutrition advice from AI doctor
- 📱 **AR Features**: Immersive augmented reality health visualization
- 📄 **PDF Reports**: Generate comprehensive health reports for doctors

---

## 🚀 Key Features

### 1. **Visual Deficiency Detection System**
- Multi-image analysis (tongue, lips, nails, eyes)
- AI-powered symptom recognition using HuggingFace models
- Real-time confidence scoring
- Detailed deficiency explanations
- Severity classification (Normal, Mild, Moderate, Severe)

**Detected Deficiencies:**
- Iron, Vitamin B1, B2, B3, B6, B12
- Vitamin A, C, D, E, K
- Calcium, Zinc, Magnesium
- Biotin (B7), Folate (B9)

### 2. **🧠 AR Food Analyzer**
- Real-time camera-based food scanning
- Groq Vision AI (Llama 4 Scout) for food recognition
- AR overlays with floating nutrition labels
- Live scanning mode with continuous analysis
- 3D animations and visual effects
- Health scoring (0-100) for meals
- Portion estimation
- Macro & micronutrient breakdown

### 3. **🎤 Voice Meal Logger**
- Speech-to-text meal input
- AI food identification from natural language
- Text-to-speech feedback
- Automatic nutritional analysis
- Database storage for tracking

### 4. **📊 Progress Dashboard**
- Interactive charts showing deficiency trends
- Weekly/monthly progress views
- Improvement percentages
- Meal recovery score tracking
- Visual health timeline

### 5. **🤖 AI Nutrition Chatbot**
- Powered by Groq AI (Llama 3.3 70B) or Google Gemini
- Context-aware responses based on user deficiencies
- Personalized diet recommendations
- Recipe suggestions
- Health Q&A with medical knowledge

### 6. **📱 Barcode Scanner**
- Scan packaged food products
- Fetch nutritional information from Open Food Facts API
- Allergen warnings
- Nutritional grade (A-E)
- Ingredient analysis

### 7. **🗺️ Geo-Location Food Recommendations**
- Location-based food suggestions
- Regional cuisine integration
- Local restaurant recommendations
- Seasonal food availability

### 8. **🍲 Meal Quality Detector**
- Food freshness analysis
- Oil content detection
- Color and texture analysis
- Quality scoring

### 9. **👤 Health Avatar System**
- Gamified health tracking
- Achievement badges
- Level progression
- Streak tracking
- Visual health representation

### 10. **📊 Meal Correlation Engine**
- Tracks which foods improve specific deficiencies
- ML-based correlation analysis
- Confidence scoring for food effectiveness
- 90-day historical analysis

### 11. **📈 Timeline Progress Tracker**
- Day-by-day deficiency severity tracking
- Visual trend lines
- Risk score calculations
- Improvement indicators

### 12. **📄 Smart Report Generator**
- PDF export with charts and data
- Doctor-shareable format
- Weekly improvement summaries
- Meal history logs
- QR code for quick access

### 13. **👨‍⚕️ Symptom Checker**
- Interactive symptom input
- AI-based deficiency prediction
- Severity assessment
- Recommended tests

### 14. **🎯 Personalized Diet Planner**
- Weekly meal plans
- Age-specific recommendations
- BMI-based calorie calculations
- South Indian cuisine focus
- Deficiency-targeted meals

### 15. **👤 User Profile Management**
- BMI calculation
- Age group selection
- Health goal tracking
- Preference settings

### 16. **🎭 Advanced AR Features**
- AR Health Capture Coach
- Diagnostic Heatmap Overlay
- Deficiency Simulation Preview
- 3D Food Recommendations
- AR Nutrient Plate Builder
- Progress Timeline AR
- Skin Tone Normalization
- Hydration Estimator
- Voice Interactive Doctor
- Prescription Planner

---

## 💻 Technology Stack

### Frontend Framework
- **Flutter 3.9.2+** - Cross-platform UI development
- **Material Design 3** - Modern UI components
- **Flutter Animate** - Smooth animations

### AI & ML Services
- **Groq AI API**
  - Llama 4 Scout (Vision model for food recognition)
  - Llama 3.3 70B Versatile (Chatbot, text analysis)
  - Llama 3.1 8B Instant (Fast queries)
- **Google Gemini AI** - Alternative chatbot provider
- **HuggingFace Models** - Image classification for symptoms

### Database
- **SQLite** (via sqflite) - Local data storage
- **sqflite_common_ffi** - Desktop platform support
- **Shared Preferences** - Settings and cache

### Imaging & Camera
- **camera** - Real-time camera access
- **image_picker** - Gallery image selection
- **file_picker** - File system access
- **image** package - Image processing and compression

### Speech & Voice
- **speech_to_text** - Voice meal input
- **flutter_tts** - Text-to-speech feedback

### Charts & Visualization
- **fl_chart** - Beautiful charts and graphs
- **pdf** - PDF generation
- **printing** - PDF preview and sharing

### AR Features
- **camera** - AR camera overlay
- **sensors_plus** - Device motion tracking
- Custom AR implementations

### Location Services
- **geolocator** - GPS location access
- **geocoding** - Address resolution

### Barcode Scanning
- **mobile_scanner** - Fast QR/barcode scanning
- **Open Food Facts API** - Product database

### Networking
- **http** - REST API calls
- **connectivity_plus** - Network status

### Storage & Utilities
- **path_provider** - File system paths
- **intl** - Date/time formatting
- **uuid** - Unique ID generation

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point & landing page
├── models/                            # Data models
│   ├── health_data.dart              # Deficiency, Meal, Food models
│   ├── user_profile.dart             # User data model
│   └── deficiency_knowledge.dart     # Symptom-deficiency mappings
├── pages/                            # UI screens
│   ├── ai_chatbot_page.dart          # AI nutrition assistant
│   ├── ar_food_analyzer_page.dart    # AR food scanning
│   ├── ar_features_page.dart         # AR features hub
│   ├── barcode_scanner_page.dart     # Product scanner
│   ├── deficiency_explanation_page.dart
│   ├── food_analyzer_page.dart       # Image-based food analysis
│   ├── geo_food_recommendations_page.dart
│   ├── health_avatar_page.dart       # Gamification
│   ├── meal_correlation_page.dart    # Food impact analysis
│   ├── meal_quality_detector_page.dart
│   ├── nutrition_report_page.dart    # PDF reports
│   ├── personalized_diet_plan_page.dart
│   ├── progress_dashboard_page.dart  # Charts & trends
│   ├── symptom_input_page.dart       # Manual symptom entry
│   ├── timeline_progress_page.dart   # Historical tracking
│   ├── user_profile_page.dart        # Profile management
│   ├── voice_meal_logger_page.dart   # Voice input
│   └── ar/                           # AR feature modules
│       ├── ar_health_capture_coach.dart
│       ├── diagnostic_heatmap.dart
│       ├── deficiency_simulation.dart
│       └── ... (10+ AR features)
├── services/                         # Business logic
│   ├── health_database.dart          # SQLite operations
│   ├── deficiency_info_service.dart  # Deficiency data
│   └── nutrient_service.dart         # Nutrition calculations
└── utils/                            # Helper functions
    └── south_indian_diet_planner.dart
```

### Design Patterns

1. **BLoC Pattern** - For complex state management
2. **Repository Pattern** - Data access abstraction
3. **Service Layer** - Business logic separation
4. **Singleton Pattern** - Database instance
5. **Factory Pattern** - Model creation

---

## 📖 Feature Details

### 1. Visual Deficiency Detection

**Flow:**
```
User Selects Images (Tongue/Lips/Nails/Eyes)
    ↓
Images Compressed & Encoded to Base64
    ↓
Sent to HuggingFace MobileNet V2 API
    ↓
Features Extracted from Images
    ↓
Mapped to Deficiency Knowledge Base
    ↓
Confidence Scores Calculated
    ↓
Severity Level Assigned
    ↓
Results Displayed with Recommendations
    ↓
Saved to Local Database
```

**Deficiency Mappings:**

| Body Part | Visual Indicator | Deficiencies |
|-----------|-----------------|--------------|
| **Tongue** | Smooth texture | B6, B12, Iron |
| | Red color | B12, Iron |
| | White patches | B2, B3, B12 |
| | Mouth ulcers | B12 |
| **Lips** | Cracked | B1, B2, B3, B6 |
| | Shiny red | B2, B3 |
| | Angular cheilosis | B1, B2, B3, Iron |
| **Nails** | Spoon-shaped | C, B7, B9 |
| | White spots | Calcium, Zinc, B7 |
| | Brittle/cracked | A, C, B7, B12 |
| | Vertical ridges | Magnesium, Iron, B7 |
| **Eyes** | Redness | A, B, B2, B6 |

### 2. AR Food Analyzer

**Technical Implementation:**
- Real-time camera preview using `camera` package
- Groq Vision API integration with Llama 4 Scout model
- Image compression to <500KB for API limits
- AR overlay rendering with custom painters
- 3D transform animations for floating labels
- Staggered grid layout for food labels (2-column)
- Semi-transparent background scrim for visibility
- Live scanning mode with 3-second intervals
- Health scoring algorithm based on macros

**Features:**
- **Capture Mode**: Take photo → analyze → show results
- **Live Mode**: Continuous scanning every 3 seconds
- **AR Labels**: Floating cards with food name, nutrients, health tags
- **Animations**: Pulse effects, 3D rotations, scan lines
- **Health Score**: 0-100 based on protein, fiber, fats, calories
- **Recovery Score**: Targeted to user's deficiencies

### 3. Voice Meal Logger

**Speech Recognition Flow:**
```
User Taps Microphone
    ↓
Speech-to-Text Starts (speech_to_text)
    ↓
User Speaks: "I ate dosa with chutney"
    ↓
Text Captured
    ↓
Sent to Groq AI (Llama 3.3 70B)
    ↓
AI Extracts Food Items & Nutrition
    ↓
JSON Response Parsed
    ↓
Foods & Nutrients Displayed
    ↓
TTS Speaks Summary (flutter_tts)
    ↓
Saved to Database
```

**Supported Languages:** English (extensible)

### 4. AI Chatbot

**Conversation Flow:**
```
User Types Question
    ↓
Context Loaded (User's Deficiencies)
    ↓
System Prompt Prepared (Nutrition Doctor)
    ↓
Sent to Groq AI / Gemini
    ↓
Streamed Response Received
    ↓
Displayed in Chat Bubble
    ↓
Conversation History Maintained
```

**Capabilities:**
- Personalized based on detected deficiencies
- Recipe recommendations
- Meal planning advice
- Symptom interpretation
- Supplement guidance
- Diet Q&A

### 5. Meal Correlation Engine

**Algorithm:**
```
1. Fetch 90 days of deficiency records
2. Fetch 90 days of meal records
3. For each meal:
   - Find deficiency level BEFORE meal
   - Find deficiency level AFTER meal (within 3 days)
   - Calculate improvement = before_severity - after_severity
   - If improvement > 0:
     * Add to correlation score for that food
     * Increment occurrence counter
     * Update confidence level
4. Sort foods by improvement score
5. Display top 10 correlations
```

**Output:** Foods that most effectively improve specific deficiencies

---

## 🔄 Flow Diagrams

### Main Application Flow

```
┌─────────────────┐
│  Landing Page   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Symptom Input  │ ──────┐
│   (4 Images)    │       │
└────────┬────────┘       │
         │                │
         ▼                │
┌─────────────────┐       │
│  AI Analysis    │       │
│  (HuggingFace)  │       │
└────────┬────────┘       │
         │                │
         ▼                │
┌─────────────────┐       │
│   Deficiency    │       │
│   Results       │ ◄─────┘
└────────┬────────┘
         │
         ├────────────────────────────────┐
         │                                │
         ▼                                ▼
┌─────────────────┐              ┌──────────────┐
│  Feature Menu   │              │  Dashboard   │
└────────┬────────┘              └──────────────┘
         │
         ├──► Food Analyzer ──► Meal Record ──► Database
         │
         ├──► AR Food Scanner ──► Live Analysis
         │
         ├──► Voice Logger ──► Speech-to-Text ──► AI Analysis
         │
         ├──► AI Chatbot ──► Groq/Gemini ──► Advice
         │
         ├──► Progress Charts ──► SQLite ──► Visualizations
         │
         ├──► Meal Correlation ──► ML Analysis ──► Insights
         │
         ├──► Report Generator ──► PDF Export
         │
         ├──► Barcode Scanner ──► API Lookup
         │
         └──► Profile & Settings
```

### Food Analysis Flow

```
┌──────────────┐
│ Select Image │ ──┐
│  or Camera   │   │
└──────────────┘   │
                   ▼
          ┌────────────────┐
          │ Image Selected │
          └────────┬───────┘
                   │
          ┌────────▼───────────┐
          │ Compress < 500KB   │
          │ (image package)    │
          └────────┬───────────┘
                   │
          ┌────────▼────────────┐
          │ Convert to Base64   │
          └────────┬────────────┘
                   │
          ┌────────▼────────────────┐
          │ Send to Groq Vision API │
          │ (Llama 4 Scout Model)   │
          └────────┬────────────────┘
                   │
          ┌────────▼─────────┐
          │ Parse JSON       │
          │ Extract Foods    │
          └────────┬─────────┘
                   │
          ┌────────▼──────────┐
          │ Calculate Totals  │
          │ & Recovery Score  │
          └────────┬──────────┘
                   │
          ┌────────▼──────────┐
          │ Display Results   │
          │ with AR Overlay   │
          └────────┬──────────┘
                   │
          ┌────────▼──────────┐
          │ Save to Database  │
          └───────────────────┘
```

### Database Schema Flow

```
┌──────────────────┐
│ health_database  │
└────────┬─────────┘
         │
         ├──► deficiencies
         │     ├─ id (TEXT PRIMARY KEY)
         │     ├─ detectedAt (INTEGER)
         │     ├─ bodyPart (TEXT)
         │     ├─ nutrient (TEXT)
         │     ├─ severity (TEXT)
         │     ├─ confidence (REAL)
         │     └─ imagePath (TEXT)
         │
         ├──► meals
         │     ├─ id (TEXT PRIMARY KEY)
         │     ├─ consumedAt (INTEGER)
         │     ├─ foods (TEXT JSON)
         │     ├─ recoveryScore (INTEGER)
         │     ├─ feedbackMessage (TEXT)
         │     └─ imagePath (TEXT)
         │
         └──► progress_tracking
               ├─ id (TEXT PRIMARY KEY)
               ├─ date (INTEGER)
               ├─ nutrient (TEXT)
               ├─ score (REAL)
               └─ notes (TEXT)
```

### AI Integration Architecture

```
                    ┌─────────────────┐
                    │  Flutter App    │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
           ▼                 ▼                 ▼
    ┌─────────────┐   ┌─────────────┐  ┌─────────────┐
    │  Groq API   │   │ Gemini API  │  │ HuggingFace │
    └──────┬──────┘   └──────┬──────┘  └──────┬──────┘
           │                 │                 │
           ├─ Vision         ├─ Chatbot       └─ Vision
           │  (Llama 4       │  (Gemini 2.0      (MobileNet)
           │   Scout)        │   Flash)
           │                 │
           ├─ Chatbot        └─ Context-aware
           │  (Llama 3.3)       responses
           │
           └─ Fast queries
              (Llama 3.1)
```

---

## 🗄️ Database Schema

### Tables

#### 1. deficiencies
```sql
CREATE TABLE deficiencies (
  id TEXT PRIMARY KEY,
  detectedAt INTEGER NOT NULL,
  bodyPart TEXT NOT NULL,
  nutrient TEXT NOT NULL,
  severity TEXT NOT NULL,  -- 'normal', 'mild', 'moderate', 'severe'
  confidence REAL NOT NULL,
  imagePath TEXT,
  symptoms TEXT
);
```

#### 2. meals
```sql
CREATE TABLE meals (
  id TEXT PRIMARY KEY,
  consumedAt INTEGER NOT NULL,
  foods TEXT NOT NULL,          -- JSON array of FoodItem
  recoveryScore INTEGER,
  feedbackMessage TEXT,
  imagePath TEXT
);
```

#### 3. progress_tracking
```sql
CREATE TABLE progress_tracking (
  id TEXT PRIMARY KEY,
  date INTEGER NOT NULL,
  nutrient TEXT NOT NULL,
  score REAL NOT NULL,
  notes TEXT
);
```

#### 4. user_profile
```sql
CREATE TABLE user_profile (
  id TEXT PRIMARY KEY,
  name TEXT,
  age INTEGER,
  gender TEXT,
  weight REAL,
  height REAL,
  bmi REAL,
  activityLevel TEXT,
  dietaryPreference TEXT,
  updatedAt INTEGER
);
```

---

## 🔌 API Integration

### 1. Groq AI API

**Base URL:** `https://api.groq.com/openai/v1/chat/completions`

**Models Used:**
- `meta-llama/llama-4-scout-17b-16e-instruct` - Vision analysis
- `llama-3.3-70b-versatile` - Chatbot & text analysis
- `llama-3.1-8b-instant` - Fast queries

**Request Format:**
```json
{
  "model": "llama-3.3-70b-versatile",
  "messages": [
    {
      "role": "system",
      "content": "You are a nutrition doctor..."
    },
    {
      "role": "user",
      "content": "What foods help with iron deficiency?"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 1000
}
```

**Vision Request:**
```json
{
  "model": "meta-llama/llama-4-scout-17b-16e-instruct",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Analyze this food image..."
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,..."
          }
        }
      ]
    }
  ]
}
```

### 2. Google Gemini API

**Model:** `gemini-2.0-flash-exp`

**Usage:** Alternative chatbot provider with vision capabilities

### 3. HuggingFace API

**Model:** `google/mobilenet_v2_1.0_224`

**Endpoint:** `https://api-inference.huggingface.co/models/google/mobilenet_v2_1.0_224`

**Usage:** Image classification for symptom detection

### 4. Open Food Facts API

**Base URL:** `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`

**Usage:** Barcode scanning for packaged food nutritional info

---

## 📦 Installation Guide

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0+
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds - macOS only)

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/nutrition-deficiency-detector.git
cd nutrition-deficiency-detector
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure API Keys

Create `lib/config/api_keys.dart`:

```dart
class ApiKeys {
  static const groqApiKey = 'your_groq_api_key_here';
  static const geminiApiKey = 'your_gemini_api_key_here';
  static const huggingFaceToken = 'your_huggingface_token_here';
}
```

### Step 4: Run the App

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d chrome
```

**Windows:**
```bash
flutter run -d windows
```

### Step 5: Build Release APK

```bash
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/`

---

## 📱 Usage Guide

### 1. First Time Setup

1. Open the app
2. On landing page, tap **"Get Started"**
3. Complete user profile (name, age, weight, height)
4. Grant camera and microphone permissions
5. Optionally enable location services

### 2. Visual Deficiency Check

1. Tap **"Analyze Health"** on home screen
2. Upload 4 images:
   - Tongue (close-up, well-lit)
   - Lips (front view)
   - Nails (clean, natural lighting)
   - Eyes (open, looking at camera)
3. Tap **"Analyze Images"**
4. View detected deficiencies with confidence scores
5. Read explanations and food recommendations

### 3. AR Food Scanning

1. Tap **"AR Food Analyzer"**
2. Point camera at meal
3. Choose mode:
   - **Capture**: Tap camera button to analyze
   - **Live**: Toggle for continuous scanning
4. View AR overlays with nutrition info
5. Check meal score and health advice

### 4. Voice Meal Logging

1. Tap **"Voice Meal Logger"**
2. Tap microphone button
3. Speak your meal: "I ate chicken curry with rice"
4. AI identifies foods and calculates nutrition
5. Review and save to meal history

### 5. Track Progress

1. Go to **"Progress Dashboard"**
2. View charts showing deficiency improvements
3. See weekly/monthly trends
4. Check meal recovery scores

### 6. Chat with AI Doctor

1. Open **"AI Chatbot"**
2. Ask nutrition questions
3. Get personalized advice based on your deficiencies
4. Request recipes, meal plans, or health tips

### 7. Generate Reports

1. Navigate to **"Health Report"**
2. Tap **"Generate PDF Report"**
3. Review summary, charts, and meal history
4. Share with doctor or save to device

---

## 🎨 Screenshots

*(Screenshots would be added here)*

### Landing Page
- Beautiful gradient background
- Feature highlights
- Get Started button

### Deficiency Detection
- Image upload interface
- Analysis progress
- Results with severity indicators

### AR Food Analyzer
- Real-time camera view
- Floating nutrition labels
- Health score display

### Progress Dashboard
- Interactive line charts
- Bar graphs for nutrients
- Historical comparisons

### AI Chatbot
- Chat interface
- Bubble messages
- Quick suggestions

---

## 🔒 Privacy & Security

- **Local Data Storage**: All health data stored locally on device using SQLite
- **No Cloud Sync**: Data never leaves your device unless you explicitly export
- **API Security**: API keys encrypted in production builds
- **Permission Management**: Granular control over camera, mic, location access
- **Data Export**: Users can export/delete their data anytime

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Groq AI** for fast and accurate AI models
- **Google Gemini** for conversational AI
- **HuggingFace** for vision models
- **Open Food Facts** for product database
- **Flutter Team** for the amazing framework
- Medical advisors for nutritional guidance

---

<div align="center">

<!-- Animated Gradient Divider -->
<img src="https://capsule-render.vercel.app/api?type=wave&color=gradient&height=90&section=header"/>

<!-- Animated Typing Title -->
<img src="https://readme-typing-svg.herokuapp.com?font=Poppins&weight=600&size=24&pause=1000&color=00E676&center=true&vCenter=true&width=800&lines=Designed+%26+Developed+by+Dharun2712;GitHub+ID%3A+Dharun2712;AI-powered+Healthcare+Innovation;Flutter+%7C+AI+%7C+AR+%7C+Vision" />

<br/>

<!-- Profile Badges -->
<p align="center">
  <img src="https://img.shields.io/badge/GitHub-Dharun2712-black?style=for-the-badge&logo=github"/>
  <img src="https://img.shields.io/badge/Flutter-Developer-02569B?style=for-the-badge&logo=flutter"/>
  <img src="https://img.shields.io/badge/AI-Healthcare-2ECC71?style=for-the-badge"/>
</p>

<!-- Animated Contact -->
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Montserrat&size=18&pause=1500&color=36BCF7&center=true&vCenter=true&width=600&lines=Contact+the+Developer;Open+to+Hackathons+%26+Collaborations" />
</p>

📧 <a href="mailto:dharunkumarm2005@gmail.com"><b>dharunkumarm2005@gmail.com</b></a>  
🔗 <a href="https://github.com/Dharun2712"><b>github.com/Dharun2712</b></a>

<br/><br/>

<!-- Star Animation -->
<img src="https://readme-typing-svg.herokuapp.com?font=Poppins&size=18&pause=1200&color=FBC02D&center=true&vCenter=true&width=600&lines=⭐+Star+this+repository+to+support+the+project!;Your+support+motivates+innovation+🚀" />

<br/>

<!-- Bottom Animated Divider -->
<img src="https://capsule-render.vercel.app/api?type=wave&color=gradient&height=90&section=footer"/>

</div>



---
Discussions: [GitHub Discussions](https://github.com/yourusername/nutrition-deficiency-detector/discussions)

---

## 🗺️ Roadmap

### Version 2.0 (Planned)
- [ ] Multi-language support (Hindi, Tamil, Telugu, etc.)
- [ ] Apple Watch integration
- [ ] Meal planning with grocery lists
- [ ] Social features (share recipes, challenges)
- [ ] Integration with fitness trackers
- [ ] Prescription supplement tracking
- [ ] Doctor consultation booking
- [ ] Insurance claim integration

### Version 3.0 (Future)
- [ ] Blood test result integration
- [ ] Wearable device sync
- [ ] Family health tracking
- [ ] Telemedicine integration
- [ ] AI-powered recipe generator
- [ ] Augmented reality meal planning
- [ ] Genetic nutrition recommendations

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star this repo if you find it useful!

</div>
