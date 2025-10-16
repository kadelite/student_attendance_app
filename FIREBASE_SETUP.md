# Firebase Setup Instructions

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `student-attendance-app`
4. Continue through setup (disable Google Analytics if not needed)
5. Click "Create project"

## Step 2: Enable Authentication
1. Go to **Authentication** in the left sidebar
2. Click "Get started"
3. Go to **Sign-in method** tab
4. Enable **Email/Password** authentication
5. Click "Save"

## Step 3: Add Web App
1. In Firebase Console, click the **Web icon** (`</>>`)
2. Enter app nickname: `student-attendance-web`
3. Check "Also set up Firebase Hosting" (optional)
4. Click "Register app"
5. Copy the Firebase configuration object

## Step 4: Update Configuration Files

### Update `lib/firebase_options.dart`
Replace the placeholder values in `firebase_options.dart` with your actual Firebase configuration values from Step 3.

### Update `web/firebase-config.js`
Replace the placeholder values in `firebase-config.js` with your actual Firebase configuration values.

## Step 5: Deploy to Firebase Hosting (Optional)
```bash
flutter build web
firebase deploy
```

## Configuration Template
```javascript
const firebaseConfig = {
  apiKey: "your-actual-api-key",
  authDomain: "your-project-id.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project-id.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456"
};
```

## Testing
1. Run `flutter run -d chrome` to test locally
2. Register a new user with email/password
3. Verify authentication works in Firebase Console > Authentication > Users