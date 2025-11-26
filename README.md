# Insulator Condition Detection System - Complete Documentation

## 📋 Project Summary

**Project Name:** AI-Powered Insulator Condition Detection System  
**Version:** 2.0  
**Platform:** Mobile (Android) + Backend (Flask)  
**AI Model:** OpenAI CLIP (Vision-Language Model)  
**Purpose:** Automated detection and classification of electrical insulator conditions using computer vision and deep learning

---

## 🎯 Project Overview

The Insulator Condition Detection System is an end-to-end AI solution designed to automatically analyze electrical insulators and determine whether they are **healthy** or **damaged**. The system combines a Flutter-based mobile application with a Python Flask backend powered by state-of-the-art CLIP (Contrastive Language-Image Pre-training) model for accurate condition assessment.

### Key Capabilities:
- ✅ Real-time insulator condition analysis
- ✅ Image capture via camera or gallery upload
- ✅ AI-powered classification (Healthy vs Damaged)
- ✅ Confidence scoring with detailed analytics
- ✅ Comprehensive damage cause identification
- ✅ Professional UI/UX with smooth animations
- ✅ Network-enabled analysis (WiFi/LAN connectivity)

---

## 🏗️ System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MOBILE APPLICATION                        │
│                      (Flutter/Dart)                          │
│  ┌────────────┐  ┌────────────┐  ┌──────────────────┐      │
│  │  Upload    │→ │ Analyzing  │→ │  Result Display  │      │
│  │  Screen    │  │  Screen    │  │  with Causes     │      │
│  └────────────┘  └────────────┘  └──────────────────┘      │
│         │                                   ▲                │
│         │ HTTP POST /api/analyze            │                │
│         │ (multipart/form-data)             │ JSON Response  │
└─────────┼───────────────────────────────────┼────────────────┘
          │                                   │
          │        WiFi/LAN Network           │
          ▼                                   │
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND SERVER                            │
│                    (Flask - Python)                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Flask API Server                        │   │
│  │  • GET  /           → Web Interface                  │   │
│  │  • POST /api/analyze → Mobile API Endpoint           │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Image Processing Pipeline                   │   │
│  │  1. Receive image → 2. Resize (224×224)              │   │
│  │  3. Enhance contrast → 4. Compute edge density       │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              AI Inference Engine                      │   │
│  │  ┌─────────────────────────────────────────────┐     │   │
│  │  │    CLIP Model (openai/clip-vit-base-patch32)│     │   │
│  │  │  • Vision Encoder: ViT-B/32                 │     │   │
│  │  │  • Text Encoder: Transformer                │     │   │
│  │  │  • Embedding: 512-dimensional space         │     │   │
│  │  └─────────────────────────────────────────────┘     │   │
│  │  ┌─────────────────────────────────────────────┐     │   │
│  │  │    Edge Detection (OpenCV Canny)            │     │   │
│  │  │  • Adaptive thresholding                    │     │   │
│  │  │  • Edge density computation                 │     │   │
│  │  └─────────────────────────────────────────────┘     │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Ensemble Decision Algorithm                   │   │
│  │  Combined Score = 60% CLIP + 40% Edge Density       │   │
│  │  Threshold: > 0.5 → Damaged, ≤ 0.5 → Healthy        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 System Flow Diagram

### Complete Analysis Workflow

```
                        ┌─────────────────────┐
                        │   USER LAUNCHES     │
                        │   MOBILE APP        │
                        └──────────┬──────────┘
                                   │
                        ┌──────────▼──────────┐
                        │  UPLOAD SCREEN      │
                        │  • Camera Capture   │
                        │  • Gallery Selection│
                        └──────────┬──────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
         ┌──────────▼──────────┐      ┌──────────▼──────────┐
         │  CAPTURE FROM       │      │  SELECT FROM        │
         │  CAMERA             │      │  GALLERY            │
         └──────────┬──────────┘      └──────────┬──────────┘
                    │                             │
                    └──────────────┬──────────────┘
                                   │
                        ┌──────────▼──────────┐
                        │  IMAGE SELECTED     │
                        │  Display Preview    │
                        └──────────┬──────────┘
                                   │
                        ┌──────────▼──────────┐
                        │  USER CLICKS        │
                        │  "Analyze Condition"│
                        └──────────┬──────────┘
                                   │
                        ┌──────────▼──────────┐
                        │  ANALYZING SCREEN   │
                        │  • Loading Animation│
                        │  • "Analyzing..."   │
                        └──────────┬──────────┘
                                   │
                        ┌──────────▼──────────────────────┐
                        │  HTTP POST REQUEST              │
                        │  To: http://SERVER_IP:5000      │
                        │  Endpoint: /api/analyze         │
                        │  Method: multipart/form-data    │
                        │  Body: image file               │
                        └──────────┬──────────────────────┘
                                   │
                        ┌──────────▼──────────────────────┐
                        │    FLASK SERVER RECEIVES        │
                        │    • Validates file exists      │
                        │    • Saves to uploads/          │
                        └──────────┬──────────────────────┘
                                   │
                        ┌──────────▼──────────────────────┐
                        │  IMAGE PREPROCESSING            │
                        │  1. Load image with PIL         │
                        │  2. Convert to RGB              │
                        │  3. Resize to 224×224           │
                        │  4. Enhance contrast (α=1.2)    │
                        │  5. Brightness boost (β=10)     │
                        └──────────┬──────────────────────┘
                                   │
                ┌──────────────────┴──────────────────┐
                │                                     │
   ┌────────────▼────────────┐          ┌────────────▼────────────┐
   │  CLIP INFERENCE         │          │  EDGE ANALYSIS          │
   │  1. Tokenize texts:     │          │  1. Canny edge detect   │
   │     • "healthy..."      │          │  2. Count edge pixels   │
   │     • "damaged..."      │          │  3. Calculate density   │
   │  2. Encode image (ViT)  │          │  4. Normalize score     │
   │  3. Compute similarity  │          │     (vs calibration)    │
   │  4. Softmax → probs     │          │                         │
   │  Result: [H%, D%]       │          │  Result: edge_score     │
   └────────────┬────────────┘          └────────────┬────────────┘
                │                                     │
                └──────────────┬──────────────────────┘
                               │
                    ┌──────────▼──────────────────────┐
                    │  ENSEMBLE DECISION              │
                    │  combined_score =               │
                    │    0.6 × damaged_prob +         │
                    │    0.4 × edge_score             │
                    │                                 │
                    │  IF combined_score > 0.5:       │
                    │    → DAMAGED                    │
                    │  ELSE:                          │
                    │    → HEALTHY                    │
                    └──────────┬──────────────────────┘
                               │
                    ┌──────────▼──────────────────────┐
                    │  BUILD JSON RESPONSE            │
                    │  {                              │
                    │    success: true,               │
                    │    is_healthy: bool,            │
                    │    is_damaged: bool,            │
                    │    confidence: float,           │
                    │    message: string,             │
                    │    details: {...}               │
                    │  }                              │
                    └──────────┬──────────────────────┘
                               │
                    ┌──────────▼──────────────────────┐
                    │  HTTP 200 OK RESPONSE           │
                    │  Content-Type: application/json │
                    └──────────┬──────────────────────┘
                               │
                    ┌──────────▼──────────────────────┐
                    │  MOBILE APP PARSES JSON         │
                    │  • Extract is_healthy           │
                    │  • Extract confidence           │
                    │  • Extract message              │
                    └──────────┬──────────────────────┘
                               │
                    ┌──────────▼──────────────────────┐
                    │  RESULT SCREEN DISPLAY          │
                    │  ┌──────────────────────────┐   │
                    │  │ • Insulator Image        │   │
                    │  │ • Animated Status Icon   │   │
                    │  │   ✓ Green (Healthy)      │   │
                    │  │   ⚠ Red (Damaged)        │   │
                    │  │ • Title (32px bold)      │   │
                    │  │ • Confidence Badge       │   │
                    │  │   (36px percentage)      │   │
                    │  │ • Analysis Message       │   │
                    │  │                          │   │
                    │  │ IF DAMAGED:              │   │
                    │  │ • Damage Causes Section  │   │
                    │  │   ⚡ Electrical Stress   │   │
                    │  │   ☁️ Environmental       │   │
                    │  │   💧 Contamination       │   │
                    │  │   🔧 Mechanical          │   │
                    │  │   ⏱️ Aging               │   │
                    │  │                          │   │
                    │  │ • Analysis Details Card  │   │
                    │  │ • Action Buttons         │   │
                    │  │   [New Analysis] [Home]  │   │
                    │  └──────────────────────────┘   │
                    └─────────────────────────────────┘
```

---

## 📱 Mobile Application Architecture

### Screen Flow

```
┌────────────────────┐
│  Upload Screen     │ ← App Entry Point
│  (upload_screen.   │
│   dart)            │
│                    │
│  Components:       │
│  • Camera Button   │
│  • Gallery Button  │
│  • Image Preview   │
│  • Analyze Button  │
└─────────┬──────────┘
          │ User clicks "Analyze"
          ▼
┌────────────────────┐
│ Analyzing Screen   │ ← Temporary Loading State
│ (built-in widget)  │
│                    │
│  Components:       │
│  • Loading Spinner │
│  • "Analyzing..."  │
│  • Progress Text   │
└─────────┬──────────┘
          │ API Response received
          ▼
┌────────────────────┐
│  Result Screen     │ ← Final Display
│  (result_screen.   │
│   dart)            │
│                    │
│  Animations:       │
│  • Fade-in (1s)    │
│  • Slide-up (1.2s) │
│  • Scale (1.4s)    │
│  • Bounce (1.6s)   │
│                    │
│  Sections:         │
│  1. Image Card     │
│  2. Status Icon    │
│  3. Title          │
│  4. Confidence     │
│  5. Message        │
│  6. Damage Causes* │
│  7. Details Card   │
│  8. Action Buttons │
│                    │
│  *Only if damaged  │
└────────────────────┘
```

### Key Components

#### 1. API Service (`lib/services/api_service.dart`)
```dart
class ApiService {
  static const String baseUrl = 'http://192.168.246.206:5000';
  
  Future<DetectionResult> detectInsulator(File imageFile) async {
    // 1. Create multipart request
    // 2. Attach image file
    // 3. POST to /api/analyze
    // 4. Parse JSON response
    // 5. Return DetectionResult model
  }
}
```

#### 2. Detection Result Model (`lib/models/detection_result.dart`)
```dart
class DetectionResult {
  final bool isHealthy;
  final double confidence;
  final String message;
  
  // Factory constructor for JSON parsing
  factory DetectionResult.fromJson(Map<String, dynamic> json)
}
```

---

## 🖥️ Backend Server Architecture

### API Endpoints

#### 1. **GET /** - Web Interface
- **Purpose:** Serve HTML web interface for browser-based analysis
- **Response:** HTML page with upload form
- **Use Case:** Desktop/laptop users

#### 2. **POST /api/analyze** - Mobile API
- **Purpose:** Analyze insulator images from mobile app
- **Request Format:**
  ```
  Content-Type: multipart/form-data
  Body: file=<image_binary>
  ```
- **Response Format:**
  ```json
  {
    "success": true,
    "is_healthy": false,
    "is_damaged": true,
    "confidence": 0.87,
    "status": "Damaged",
    "message": "Insulator is DAMAGED - AI Powered Analysis",
    "details": {
      "clip_healthy": 0.15,
      "clip_damaged": 0.85,
      "edge_score": 0.72,
      "combined_score": 0.79
    }
  }
  ```

### AI Model Pipeline

#### Stage 1: Image Preprocessing
```python
def preprocess_image(image_path):
    # 1. Load image
    image = Image.open(image_path).convert("RGB")
    
    # 2. Resize to 224×224 (CLIP input size)
    image = image.resize((224, 224))
    
    # 3. Enhance contrast and brightness
    image_cv = np.array(image)
    image_cv = cv2.convertScaleAbs(image_cv, alpha=1.2, beta=10)
    
    return Image.fromarray(image_cv)
```

#### Stage 2: Edge Density Computation
```python
def compute_edge_density(image_path):
    # 1. Load image as grayscale
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    
    # 2. Apply Gaussian blur
    blurred = cv2.GaussianBlur(img, (5, 5), 0)
    
    # 3. Canny edge detection (auto thresholds)
    edges = cv2.Canny(blurred, threshold1, threshold2)
    
    # 4. Calculate edge density ratio
    edge_density = np.sum(edges > 0) / edges.size
    
    return edge_density
```

#### Stage 3: CLIP Inference
```python
def clip_inference(image):
    # 1. Define text prompts
    texts = [
        "a clean, undamaged electrical insulator",
        "a broken, damaged electrical insulator"
    ]
    
    # 2. Tokenize texts
    text_inputs = tokenizer(texts, padding=True, return_tensors="pt")
    
    # 3. Preprocess image (normalize with ImageNet stats)
    pixel_values = preprocess_image_clip(image)
    
    # 4. Forward pass through CLIP
    outputs = model(input_ids=text_inputs, pixel_values=pixel_values)
    
    # 5. Compute probabilities
    probs = outputs.logits_per_image.softmax(dim=1)
    
    return probs[0]  # [healthy_prob, damaged_prob]
```

#### Stage 4: Ensemble Decision
```python
def make_decision(clip_probs, edge_score):
    healthy_prob, damaged_prob = clip_probs
    
    # Weighted combination
    combined_score = 0.6 * damaged_prob + 0.4 * edge_score
    
    # Threshold-based classification
    is_damaged = combined_score > 0.5
    confidence = combined_score if is_damaged else (1 - combined_score)
    
    return is_damaged, confidence
```

---

## 🎨 UI/UX Design Features

### Result Screen Enhancements

#### 1. **Typography Hierarchy**
- App Bar Title: **22px bold** (increased from 17px)
- Main Title: **32px bold** (increased from 22px)
- Confidence: **36px bold** (new prominent display)
- Body Text: **16px medium** (increased from 12.5px)
- Detail Labels: **15-16px** (increased from 12px)

#### 2. **Animation Timeline**
```
0ms    → App opens result screen
200ms  → Slide animation starts (content slides up)
400ms  → Scale animation starts (icon grows from 0.3 to 1.0)
600ms  → Fade animation starts (content fades in)
800ms  → Bounce animation starts (title bounces)
1600ms → All animations complete
```

#### 3. **Damage Causes Section** (Only for Damaged Insulators)
```
┌─────────────────────────────────────────────────┐
│  ⚠️ Possible Damage Causes                      │
├─────────────────────────────────────────────────┤
│  ⚡ Electrical Stress (Yellow accent)           │
│     High voltage surges, lightning strikes...   │
│                                                 │
│  ☁️ Environmental Factors (Blue accent)         │
│     Prolonged exposure to rain, UV radiation... │
│                                                 │
│  💧 Contamination (Purple accent)               │
│     Accumulation of dust, salt deposits...      │
│                                                 │
│  🔧 Mechanical Damage (Orange accent)           │
│     Physical impacts, vibrations from wind...   │
│                                                 │
│  ⏱️ Material Aging (Gray accent)                │
│     Natural degradation over time, thermal...   │
└─────────────────────────────────────────────────┘
```

#### 4. **Color Scheme**
- **Healthy Status:**
  - Primary: `#10B981` (Green)
  - Background Gradient: `#D1FAE5` → `#A7F3D0` (Light green)
  
- **Damaged Status:**
  - Primary: `#EF4444` (Red)
  - Background Gradient: `#FEE2E2` → `#FECACA` (Light red)

---

## 📊 Technical Specifications

### Mobile App
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | Latest stable |
| Language | Dart | 2.19+ |
| State Management | StatefulWidget | Built-in |
| HTTP Client | http package | ^1.1.0 |
| Image Picker | image_picker | ^1.0.4 |
| Permissions | permission_handler | ^11.0.1 |

### Backend Server
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flask | 2.2.5 |
| AI Model | CLIP (ViT-B/32) | openai/clip-vit-base-patch32 |
| Deep Learning | PyTorch | 2.8.0 |
| Transformers | Hugging Face | 4.57.0 |
| Computer Vision | OpenCV | 4.8.1 |
| Image Processing | Pillow | 10.1.0 |
| Numerical Computing | NumPy | 1.24.4 |
| ML Toolkit | scikit-learn | 1.2.2 |

### System Requirements
| Requirement | Specification |
|-------------|---------------|
| Python | 3.9+ |
| RAM | 4GB minimum (8GB recommended) |
| Storage | 2GB for model cache |
| Network | WiFi/LAN connectivity |
| Mobile OS | Android 6.0+ |

---

## 🚀 Deployment & Setup

### Quick Start Guide

#### 1. **Backend Setup (One-Click)**
```batch
# Simply double-click this file:
start_server.bat

# What it does automatically:
# ✓ Checks Python installation
# ✓ Upgrades pip
# ✓ Installs all requirements
# ✓ Creates necessary directories
# ✓ Downloads CLIP model (first run)
# ✓ Runs calibration
# ✓ Starts Flask server on port 5000
```

#### 2. **Find Your Server IP**
```batch
# The start_server.bat displays:
Server will be available at:
  - Local:   http://127.0.0.1:5000
  - Network: http://192.168.246.206:5000
            ^^^^^^^^^^^^^^^^^^^^^^^^^^
            Use this IP in mobile app
```

#### 3. **Mobile App Configuration**
```dart
// lib/services/api_service.dart
class ApiService {
  // Update this with YOUR server IP from step 2:
  static const String baseUrl = 'http://192.168.246.206:5000';
  //                                   ^^^^^^^^^^^^^^^^
  //                                   YOUR_PC_IP_HERE
}
```

#### 4. **Build & Install Mobile App**
```bash
# Connect Android device via USB
# Enable USB debugging on phone

# Build APK
flutter build apk --release

# Install on device
flutter install -d <DEVICE_ID>

# Or just run:
flutter run
```

---

## 📈 Performance Metrics

### Model Accuracy
- **CLIP Confidence:** 85-95% (typical range)
- **Edge Detection:** Supplementary validation
- **Ensemble Method:** Improved robustness vs single-model
- **Calibration:** Adaptive thresholds based on healthy/damaged samples

### Response Times
| Operation | Duration |
|-----------|----------|
| Image Upload | 0.5-2s (network dependent) |
| CLIP Inference | 1-3s (CPU) / 0.2-0.5s (GPU) |
| Edge Processing | 0.1-0.3s |
| Total Analysis | 2-5s (typical) |
| First Run | +10-30s (model download) |

### Resource Usage
| Resource | Usage |
|----------|-------|
| Model Size | ~600MB (CLIP ViT-B/32) |
| Peak RAM | 2-4GB (during inference) |
| APK Size | ~42MB (release build) |
| Network | ~1-5MB per analysis (image size dependent) |

---

## 🔒 Security & Privacy

### Data Handling
- ✅ Images stored temporarily in `uploads/` folder
- ✅ No persistent storage of user data
- ✅ No external API calls (model runs locally)
- ✅ Network traffic: local LAN only (configurable)

### Recommended Practices
1. Use **private WiFi networks** for mobile-server communication
2. Configure **firewall rules** to restrict port 5000 access
3. Consider **HTTPS/TLS** for production deployments
4. Implement **authentication** for multi-user scenarios
5. Regularly **clean uploads/** directory

---

## 🛠️ Troubleshooting Guide

### Common Issues & Solutions

#### 1. **"Connection refused" on Mobile**
- ✅ Check server is running (`start_server.bat`)
- ✅ Verify PC and phone on same WiFi network
- ✅ Update `baseUrl` in `api_service.dart` with correct IP
- ✅ Disable Windows Firewall or allow port 5000

#### 2. **"500 Internal Server Error"**
- ✅ Check Flask terminal for Python traceback
- ✅ Verify all requirements installed correctly
- ✅ Ensure NumPy version compatibility (1.24.4)
- ✅ Re-run `start_server.bat` to reinstall packages

#### 3. **"Analysis takes too long"**
- ✅ First run downloads model (~600MB) - wait 5-10 min
- ✅ Subsequent runs should be 2-5 seconds
- ✅ Check CPU usage (high = model loading)
- ✅ Consider using GPU-enabled PyTorch for faster inference

#### 4. **"Numpy.dtype size changed" Error**
- ✅ Fixed in latest `requirements.txt` (NumPy pinned to 1.24.4)
- ✅ Run: `pip uninstall numpy scikit-learn -y`
- ✅ Then: `pip install -r requirements.txt`

---

## 📚 File Structure

```
insulator/
├── android/                     # Android build configuration
├── ios/                         # iOS build configuration (unused)
├── lib/                         # Flutter source code
│   ├── main.dart               # App entry point
│   ├── models/
│   │   └── detection_result.dart   # Data model for API response
│   ├── screens/
│   │   ├── upload_screen.dart      # Image upload/capture screen
│   │   └── result_screen.dart      # Analysis result display (enhanced UI)
│   ├── services/
│   │   └── api_service.dart        # HTTP client for Flask API
│   └── widgets/                    # Reusable UI components
├── uploads/                     # Temporary image storage (server)
├── model_cache/                 # Downloaded CLIP model cache
├── healthy/                     # Sample healthy insulator images (calibration)
├── damaged/                     # Sample damaged insulator images (calibration)
├── static/                      # Web UI assets (CSS)
├── templates/                   # Flask HTML templates
│   └── index.html              # Web upload interface
├── app.py                       # Flask server main file
├── requirements.txt             # Python dependencies
├── start_server.bat             # One-click server launcher (Windows)
├── pubspec.yaml                 # Flutter dependencies
└── PROJECT_DOCUMENTATION.md     # This file
```

---

## 🎓 Educational Value

### Learning Outcomes
This project demonstrates:
1. **Mobile-Server Architecture** - Building client-server applications
2. **REST API Design** - Creating JSON APIs for mobile apps
3. **Computer Vision** - Image preprocessing and analysis
4. **Deep Learning** - Using pre-trained models (CLIP)
5. **Ensemble Methods** - Combining multiple signals for robust decisions
6. **UI/UX Design** - Creating professional mobile interfaces
7. **Network Programming** - HTTP communication and error handling
8. **Cross-Platform Development** - Flutter for Android/iOS

### Potential Extensions
- 📸 Add insulator localization (object detection)
- 📊 Historical analysis tracking and trends
- 🗂️ Database integration for record keeping
- 🔐 User authentication and multi-user support
- 🌐 Cloud deployment (AWS/GCP/Azure)
- 📱 iOS version development
- 🤖 Model fine-tuning on custom dataset
- 📈 Severity grading (mild/moderate/severe damage)

---

## 👥 Project Credits

**Development:** AI-Powered Insulator Detection System  
**Version:** 2.0 (Enhanced UI + Damage Causes Analysis)  
**Technology Stack:**
- Frontend: Flutter (Dart)
- Backend: Flask (Python)
- AI Model: OpenAI CLIP (Hugging Face Transformers)
- Computer Vision: OpenCV
- Deep Learning: PyTorch

---

## 📄 License & Usage

This project is intended for **educational and research purposes**. For production deployment in critical infrastructure (power grid inspection), please ensure:
- Validation against ground truth data
- Safety protocols and human oversight
- Compliance with relevant industry standards
- Professional liability insurance

---

## 📞 Support

For issues, questions, or contributions:
1. Check the **Troubleshooting Guide** section above
2. Review Flask server logs in the terminal
3. Use `flutter doctor` to verify mobile setup
4. Consult official documentation:
   - Flutter: https://flutter.dev/docs
   - Flask: https://flask.palletsprojects.com/
   - CLIP: https://huggingface.co/openai/clip-vit-base-patch32

---

## 🔄 Version History

### Version 2.0 (Current)
- ✨ Enhanced UI with bigger text and modern design
- 📋 Added comprehensive damage causes section
- 🎬 Smooth staggered animations (fade, slide, scale, bounce)
- 📊 Prominent confidence display with gradient badge
- 🎨 Color-coded damage cause cards with icons
- 🔧 Fixed JSON API endpoint (/api/analyze)
- 📱 One-click server launcher (start_server.bat)
- 📝 Complete project documentation

### Version 1.0
- ✅ Basic mobile app with upload and result screens
- 🤖 CLIP-based insulator classification
- 🌐 Flask backend with web interface
- 📡 REST API for mobile communication
- 🔍 Edge density analysis
- ⚡ Ensemble decision making

---

## 🎯 Visual Flow Diagrams

### 1. USER JOURNEY FLOW

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER INTERACTION FLOW                        │
└─────────────────────────────────────────────────────────────────────┘

    📱 USER                         🖥️ MOBILE APP                   ☁️ SERVER
      │                                  │                              │
      │  1. Open App                     │                              │
      ├─────────────────────────────────>│                              │
      │                                  │                              │
      │  2. Tap "Camera" or "Gallery"    │                              │
      ├─────────────────────────────────>│                              │
      │                                  │                              │
      │  3. Capture/Select Image         │                              │
      ├─────────────────────────────────>│                              │
      │                                  │                              │
      │                                  │ Display Image Preview        │
      │                                  │                              │
      │  4. Tap "Analyze Condition"      │                              │
      ├─────────────────────────────────>│                              │
      │                                  │                              │
      │                                  │ Show "Analyzing..." screen   │
      │                                  │                              │
      │                                  │  5. POST /api/analyze        │
      │                                  ├─────────────────────────────>│
      │                                  │      (Send image file)       │
      │                                  │                              │
      │                                  │                              │  Process:
      │                                  │                              │  • Resize
      │                                  │                              │  • CLIP
      │                                  │                              │  • Edges
      │                                  │                              │  • Decision
      │                                  │                              │
      │                                  │  6. JSON Response            │
      │                                  │<─────────────────────────────┤
      │                                  │  {is_healthy, confidence...} │
      │                                  │                              │
      │                                  │ Parse & Navigate to Result   │
      │                                  │                              │
      │  7. View Result Screen           │                              │
      │<─────────────────────────────────┤                              │
      │     • Status (✓/⚠)               │                              │
      │     • Confidence %               │                              │
      │     • Damage Causes (if damaged) │                              │
      │                                  │                              │
      │  8. Tap "New Analysis" or "Home" │                              │
      ├─────────────────────────────────>│                              │
      │                                  │                              │
      │  Return to Upload Screen         │                              │
      │<─────────────────────────────────┤                              │
      │                                  │                              │
```

---

### 2. DATA FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ANALYSIS PIPELINE DATA FLOW                       │
└─────────────────────────────────────────────────────────────────────┘

INPUT IMAGE (JPEG/PNG)
    │
    ├──────────────────────────┬──────────────────────────┐
    │                          │                          │
    ▼                          ▼                          ▼
┌─────────┐             ┌─────────┐              ┌─────────┐
│ UPLOAD  │             │  SAVE   │              │ VALIDATE│
│ TO      │────────────>│ TO      │─────────────>│ FILE    │
│ SERVER  │  multipart  │ uploads/│  secure name │ EXISTS  │
└─────────┘             └─────────┘              └────┬────┘
                                                      │
                                                      ▼
                                              ┌───────────────┐
                                              │ LOAD & RESIZE │
                                              │ PIL: 224×224  │
                                              │ RGB mode      │
                                              └───────┬───────┘
                                                      │
                            ┌─────────────────────────┴─────────────────────────┐
                            │                                                   │
                            ▼                                                   ▼
                  ┌──────────────────┐                              ┌──────────────────┐
                  │ ENHANCE IMAGE    │                              │ EDGE DETECTION   │
                  │ • Contrast×1.2   │                              │ • Gaussian blur  │
                  │ • Brightness+10  │                              │ • Canny edges    │
                  │ • OpenCV process │                              │ • Count pixels   │
                  └────────┬─────────┘                              └────────┬─────────┘
                           │                                                 │
                           ▼                                                 │
                  ┌──────────────────┐                                      │
                  │ CLIP INFERENCE   │                                      │
                  │ 1. Normalize     │                                      │
                  │    (ImageNet)    │                                      │
                  │ 2. Vision encode │                                      │
                  │    (ViT-B/32)    │                                      │
                  │ 3. Text encode   │                                      │
                  │    (2 prompts)   │                                      │
                  │ 4. Similarity    │                                      │
                  │ 5. Softmax probs │                                      │
                  └────────┬─────────┘                                      │
                           │                                                 │
                           │ [healthy: 0.15]                                 │
                           │ [damaged: 0.85]                                 │
                           │                                                 │
                           └──────────────────┬──────────────────────────────┘
                                              │                  [edge_score: 0.72]
                                              ▼
                                    ┌─────────────────┐
                                    │ ENSEMBLE FUSION │
                                    │                 │
                                    │ combined_score= │
                                    │  60%×damaged_p  │
                                    │  +40%×edge_s    │
                                    │                 │
                                    │ = 0.85×0.6 +    │
                                    │   0.72×0.4      │
                                    │ = 0.798         │
                                    └────────┬────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │ CLASSIFICATION  │
                                    │                 │
                                    │ IF score > 0.5: │
                                    │   → DAMAGED     │
                                    │ ELSE:           │
                                    │   → HEALTHY     │
                                    └────────┬────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │ BUILD RESPONSE  │
                                    │                 │
                                    │ {               │
                                    │   success: T,   │
                                    │   is_damaged:T, │
                                    │   confidence:   │
                                    │     0.798,      │
                                    │   message: "...",│
                                    │   details: {...}│
                                    │ }               │
                                    └────────┬────────┘
                                             │
                                             ▼
                                    ┌─────────────────┐
                                    │ RETURN JSON     │
                                    │ HTTP 200 OK     │
                                    └─────────────────┘
```

---

### 3. COMPONENT INTERACTION DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────┐
│              SYSTEM COMPONENTS & INTERACTIONS                        │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         MOBILE APP LAYER                             │
├─────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐   ┌────────────┐   ┌────────────┐                  │
│  │  Upload    │──>│ Analyzing  │──>│  Result    │                  │
│  │  Screen    │   │  Screen    │   │  Screen    │                  │
│  └─────┬──────┘   └────────────┘   └──────▲─────┘                  │
│        │                                    │                        │
│        │ uses                               │ displays               │
│        ▼                                    │                        │
│  ┌────────────────────────────────────┐    │                        │
│  │       ApiService                   │    │                        │
│  │  • baseUrl configuration           │────┘                        │
│  │  • detectInsulator(file)           │                             │
│  │  • HTTP POST multipart             │                             │
│  │  • JSON parsing                    │                             │
│  └───────────────┬────────────────────┘                             │
│                  │                                                   │
│                  │ uses                                              │
│                  ▼                                                   │
│  ┌────────────────────────────────────┐                             │
│  │    DetectionResult Model           │                             │
│  │  • isHealthy: bool                 │                             │
│  │  • confidence: double              │                             │
│  │  • message: String                 │                             │
│  │  • fromJson() factory              │                             │
│  └────────────────────────────────────┘                             │
└─────────────────────────────────────────────────────────────────────┘
                           │ HTTP POST
                           │ /api/analyze
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        NETWORK LAYER                                 │
├─────────────────────────────────────────────────────────────────────┤
│  Protocol: HTTP                                                      │
│  Format: multipart/form-data (request) / JSON (response)            │
│  Port: 5000                                                          │
│  Network: WiFi/LAN                                                   │
└─────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      FLASK SERVER LAYER                              │
├─────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Flask App (app.py)                                        │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │    │
│  │  │ Route: /     │  │ Route:       │  │ uploads/        │  │    │
│  │  │ (Web UI)     │  │ /api/analyze │  │ (static files)  │  │    │
│  │  └──────────────┘  └──────┬───────┘  └─────────────────┘  │    │
│  └──────────────────────────┬┼────────────────────────────────┘    │
│                             ││                                      │
│                             ││ calls                                │
│                             │└─────────────────────┐                │
│                             ▼                      ▼                │
│  ┌──────────────────────────────┐   ┌────────────────────────────┐ │
│  │  Image Processing Module     │   │  AI Inference Module       │ │
│  │  • load_image()              │   │  • CLIP model              │ │
│  │  • resize_image()            │   │  • Tokenizer               │ │
│  │  • enhance_contrast()        │   │  • vision_encoder()        │ │
│  │  • compute_edge_density()    │   │  • text_encoder()          │ │
│  │  • Canny edge detection      │   │  • similarity_computation()│ │
│  └──────────────┬───────────────┘   └────────────┬───────────────┘ │
│                 │                                 │                 │
│                 └────────────┬────────────────────┘                 │
│                              ▼                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Decision Engine                                             │  │
│  │  • Weighted ensemble (60% CLIP + 40% Edge)                   │  │
│  │  • Threshold classification (> 0.5 = damaged)                │  │
│  │  • Confidence calculation                                    │  │
│  │  • JSON response builder                                     │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 4. STATE TRANSITION DIAGRAM (Mobile App)

```
┌─────────────────────────────────────────────────────────────────────┐
│                   MOBILE APP STATE MACHINE                           │
└─────────────────────────────────────────────────────────────────────┘

                        ┌──────────────┐
                        │   APP START  │
                        │  (main.dart) │
                        └──────┬───────┘
                               │
                               ▼
                    ┌─────────────────────┐
              ┌────►│   IDLE / UPLOAD     │◄────┐
              │     │   • Camera button   │     │
              │     │   • Gallery button  │     │
              │     │   • No image loaded │     │
              │     └──────────┬──────────┘     │
              │                │                │
              │     User selects image          │
              │                │                │
              │                ▼                │
              │     ┌─────────────────────┐    │
              │     │  IMAGE SELECTED     │    │
              │     │  • Show preview     │    │
              │     │  • Enable "Analyze" │    │
              │     └──────────┬──────────┘    │
              │                │                │
              │     User clicks "Analyze"       │
              │                │                │
              │                ▼                │
              │     ┌─────────────────────┐    │
              │     │    ANALYZING        │    │
              │     │  • Loading spinner  │    │
              │     │  • API call in      │    │
              │     │    progress         │    │
              │     └──┬────────────────┬─┘    │
              │        │                │      │
              │   API Success      API Error   │
              │        │                │      │
              │        ▼                ▼      │
              │  ┌──────────┐    ┌──────────┐ │
              │  │ RESULT   │    │  ERROR   │ │
              │  │ DISPLAY  │    │ DIALOG   │ │
              │  │ • Status │    │ • Retry  │ │
              │  │ • Causes │    │ • Cancel │ │
              │  │ • Details│    └────┬─────┘ │
              │  └────┬─────┘         │       │
              │       │               │       │
              │  User clicks     User dismisses
              │  "New Analysis"  or retries    │
              │  or "Home"            │        │
              │       │               │        │
              └───────┴───────────────┘        │
                                               │
                      User force quits app     │
                                │              │
                                ▼              │
                         ┌──────────┐          │
                         │ APP EXIT │          │
                         └──────────┘          │
                                               │
                  User restarts app            │
                                │              │
                                └──────────────┘
```

---

### 5. ERROR HANDLING FLOW

```
┌─────────────────────────────────────────────────────────────────────┐
│                      ERROR HANDLING DIAGRAM                          │
└─────────────────────────────────────────────────────────────────────┘

           ┌─────────────────────────────┐
           │  User Initiates Analysis    │
           └─────────────┬───────────────┘
                         │
                         ▼
           ┌─────────────────────────────┐
           │  Validate Image File        │
           └─────────────┬───────────────┘
                         │
            ┌────────────┴────────────┐
            │                         │
         Valid                    Invalid
            │                         │
            ▼                         ▼
   ┌─────────────────┐      ┌─────────────────┐
   │ Send API Request│      │ Show Error:     │
   └────────┬────────┘      │ "No image       │
            │               │  selected"      │
            ▼               └─────────────────┘
   ┌─────────────────┐
   │ Network Layer   │
   └────────┬────────┘
            │
     ┌──────┴──────┐
     │             │
Connection     Connection
 Success        Failed
     │             │
     ▼             ▼
┌─────────┐  ┌──────────────────┐
│ Server  │  │ Show Error:      │
│ Process │  │ "Cannot connect  │
└────┬────┘  │  to server"      │
     │       │ • Check WiFi     │
     │       │ • Verify IP      │
     │       └──────────────────┘
     │
  ┌──┴──┐
  │     │
200 OK  4xx/5xx
  │     │
  ▼     ▼
┌────┐ ┌──────────────────┐
│JSON│ │ Show Error:      │
│Parse│ │ "Server error"   │
└─┬──┘ │ Status code: XXX │
  │    └──────────────────┘
  │
┌─┴─┐
│   │
Valid Invalid
JSON  JSON
│     │
▼     ▼
┌───┐ ┌──────────────────┐
│Show│ │ Show Error:      │
│Result│ │ "Invalid response"│
└───┘ └──────────────────┘
```

---

### 6. DEPLOYMENT FLOW

```
┌─────────────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT WORKFLOW                              │
└─────────────────────────────────────────────────────────────────────┘

BACKEND DEPLOYMENT
══════════════════
1. Setup Python Environment
   │
   ├─► Install Python 3.9+
   ├─► Double-click start_server.bat
   │   └─► Auto-installs requirements
   │   └─► Downloads CLIP model
   │   └─► Runs calibration
   │   └─► Starts Flask on port 5000
   │
2. Get Server IP
   │
   └─► Note IP from terminal output
       Example: http://192.168.246.206:5000

MOBILE DEPLOYMENT
═════════════════
1. Configure API Endpoint
   │
   ├─► Edit lib/services/api_service.dart
   └─► Update baseUrl with server IP

2. Connect Android Device
   │
   ├─► Enable USB debugging
   ├─► Connect via USB
   └─► Verify: flutter devices

3. Build & Install
   │
   ├─► Option A (Debug):
   │   └─► flutter run
   │
   └─► Option B (Release):
       ├─► flutter build apk --release
       └─► flutter install -d <DEVICE_ID>

NETWORK CONFIGURATION
═══════════════════
1. Ensure Same Network
   │
   ├─► Connect PC to WiFi
   ├─► Connect Phone to same WiFi
   └─► Verify: ping from phone to PC IP

2. Firewall Rules (if needed)
   │
   ├─► Windows: Allow port 5000
   └─► Router: No additional config needed (LAN)

TESTING
═══════
1. Start Backend
   │
   └─► Double-click start_server.bat

2. Launch Mobile App
   │
   └─► Tap app icon on phone

3. Test Analysis
   │
   ├─► Capture/Upload image
   ├─► Tap "Analyze Condition"
   └─► Verify result displays correctly
```

---

### 7. DECISION TREE (Classification Logic)

```
┌─────────────────────────────────────────────────────────────────────┐
│                  CLASSIFICATION DECISION TREE                        │
└─────────────────────────────────────────────────────────────────────┘

                        INPUT IMAGE
                             │
                             ▼
                ┌────────────────────────┐
                │  Extract Features      │
                │  • CLIP embeddings     │
                │  • Edge density        │
                └────────────┬───────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
      ┌──────────────────┐      ┌──────────────────┐
      │ CLIP Analysis    │      │ Edge Analysis    │
      │                  │      │                  │
      │ Healthy: 0.15    │      │ Normalized:      │
      │ Damaged: 0.85    │      │ 0.72             │
      └────────┬─────────┘      └────────┬─────────┘
               │                         │
               └────────────┬────────────┘
                            │
                            ▼
                 ┌────────────────────┐
                 │ Weighted Ensemble  │
                 │                    │
                 │ Score = 0.6×0.85   │
                 │       + 0.4×0.72   │
                 │     = 0.798        │
                 └──────────┬─────────┘
                            │
                            ▼
                    Is Score > 0.5?
                            │
                ┌───────────┴───────────┐
                │                       │
              YES                      NO
                │                       │
                ▼                       ▼
        ┌──────────────┐        ┌──────────────┐
        │   DAMAGED    │        │   HEALTHY    │
        │              │        │              │
        │ Confidence:  │        │ Confidence:  │
        │   79.8%      │        │   1 - score  │
        │              │        │              │
        │ Show Causes: │        │ Show Status: │
        │ • Electrical │        │ • Operational│
        │ • Weather    │        │ • No action  │
        │ • Contaminate│        │              │
        │ • Mechanical │        │              │
        │ • Aging      │        │              │
        └──────────────┘        └──────────────┘
```

---

*Last Updated: November 26, 2025*

