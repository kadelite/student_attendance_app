# 📱 Student Attendance App - Installation Guide

## 🎯 Available Platforms

Your Flutter Student Attendance App is now available for multiple platforms:

### ✅ **Currently Built & Ready:**
- 🤖 **Android APK** (46.7 MB) - Ready to install
- 🌐 **Web App** (PWA) - Ready to deploy/host
- 🖥️ **Windows** - Requires Visual Studio setup

### 🍎 **iOS** - Requires macOS and Xcode

---

## 📲 Android Installation

### **File Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

### **How to Install:**
1. **Transfer APK to your Android phone:**
   - USB cable, email, cloud drive, or ADB
2. **Enable "Unknown Sources":**
   - Settings → Security → Unknown Sources (Enable)
   - Or Settings → Apps → Special Access → Install Unknown Apps
3. **Install the APK:**
   - Tap the `app-release.apk` file
   - Tap "Install"
   - Open the app!

### **Features:**
- ✅ Works offline (local storage)
- ✅ Firebase authentication when connected
- ✅ Full attendance tracking
- ✅ Role switching (Student/Teacher/Admin)

---

## 🌐 Web App (PWA) Installation

### **File Location:**
```
build/web/
```

### **Deployment Options:**

#### **Option 1: Firebase Hosting (Recommended)**
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Deploy to Firebase Hosting
firebase login
firebase init hosting
firebase deploy
```

#### **Option 2: Simple HTTP Server**
```bash
# Navigate to web build folder
cd build/web

# Start simple Python server
python -m http.server 8080

# Open: http://localhost:8080
```

#### **Option 3: Host on Any Web Server**
- Upload entire `build/web` folder to your web hosting
- Access via your domain URL

### **PWA Features:**
- 📱 Install as app on mobile browsers
- 🔄 Works offline after first load
- 🔔 Push notifications (if configured)

---

## 🖥️ Windows Desktop App

### **Requirements:**
- Windows 10/11
- Visual Studio 2019/2022 with C++ tools

### **Setup Visual Studio:**
1. Download Visual Studio Community (free)
2. Install with "Desktop development with C++" workload
3. Run: `flutter doctor` to verify

### **Build Command:**
```bash
flutter build windows --release
```

### **Installation:**
- Executable will be in: `build/windows/x64/runner/Release/`
- Run the `.exe` file directly
- No installation required - portable app!

---

## 🍎 iOS Installation

### **Requirements:**
- macOS computer
- Xcode installed
- Apple Developer Account ($99/year for App Store)

### **For Development/Testing:**
```bash
flutter build ios --release
```

### **For App Store:**
```bash
flutter build ipa
```

---

## 🚀 Quick Start After Installation

### **Default Test Accounts:**
Since Firebase is configured, you can:

1. **Register new accounts** with different roles:
   - Email: `student@school.edu` / Role: Student
   - Email: `teacher@school.edu` / Role: Teacher  
   - Email: `admin@school.edu` / Role: Admin

2. **Use the back button (←)** to switch between roles

3. **Test Features:**
   - Student: View attendance, statistics
   - Teacher: Mark attendance, manage students
   - Admin: System overview, reports

---

## 🛠️ Troubleshooting

### **Android Issues:**
- **Installation blocked:** Enable "Unknown Sources"
- **App won't open:** Check Android version (minimum API 21)
- **Firebase errors:** Check internet connection

### **Web Issues:**
- **Blank page:** Clear browser cache
- **Firebase errors:** Check `firebase-config.js` setup
- **Performance:** Use Chrome/Firefox for best experience

### **Windows Issues:**
- **Build fails:** Install Visual Studio with C++ tools
- **App won't start:** Install Visual C++ Redistributables

---

## 📁 File Summary

```
student_attendance_app/
├── build/
│   ├── app/outputs/flutter-apk/
│   │   └── app-release.apk          # Android APK (46.7 MB)
│   ├── web/                         # Web app files
│   │   ├── index.html              # Main web entry
│   │   └── assets/                 # App resources
│   └── windows/ (after build)      # Windows executable
├── INSTALLATION_GUIDE.md           # This guide
└── FIREBASE_SETUP.md              # Firebase configuration
```

---

## 💡 Tips

- **Android:** Use file manager apps to easily install APK
- **Web:** Add to home screen for app-like experience  
- **Testing:** Use back button to quickly switch user roles
- **Performance:** Web version is fastest, mobile apps are most feature-rich

Your Student Attendance App is ready to use across multiple platforms! 🎉