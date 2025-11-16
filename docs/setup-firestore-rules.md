# Setting Up Firestore Security Rules

## Problem
You're getting a `PERMISSION_DENIED` error when trying to access Firestore. This is because Firestore security rules need to be configured.

## Solution: Deploy Firestore Rules

### Option 1: Using Firebase Console (Easiest)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **comfort-ticketing-app**
3. Click on **Firestore Database** in the left menu
4. Click on the **Rules** tab
5. Copy and paste the rules from `firestore.rules` file
6. Click **Publish**

### Option 2: Using Firebase CLI

1. Install Firebase CLI (if not already installed):
   ```powershell
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```powershell
   firebase login
   ```

3. Initialize Firebase (if not already done):
   ```powershell
   firebase init firestore
   ```
   - Select your existing project
   - Use the existing `firestore.rules` file

4. Deploy the rules:
   ```powershell
   firebase deploy --only firestore:rules
   ```

## What the Rules Do

The security rules allow:

1. **Users Collection**:
   - Users can read/write their own user document
   - Users can create their own user document when they first log in

2. **Routes & Trips**:
   - All authenticated users can read
   - All authenticated users can write (you may want to restrict this later)

3. **Tickets**:
   - Users can read their own tickets
   - Agents and admins can read all tickets
   - Only agents and admins can create/update tickets
   - Only admins can delete tickets

4. **Vehicle Locations**:
   - All authenticated users can read (for tracking)
   - Only agents and admins can update locations

5. **Transactions**:
   - Users can read their own transactions
   - Agents and admins can read all transactions
   - Only agents and admins can create transactions

## Testing the Rules

After deploying the rules:

1. Try logging in again
2. The user document should be created automatically
3. You should see the home screen with your user data

## Troubleshooting

If you still get permission errors:

1. **Check Firestore is in production mode**:
   - Go to Firestore Database → Settings
   - Make sure it's not in "test mode" (which expires after 30 days)

2. **Verify rules were published**:
   - Check the Rules tab in Firebase Console
   - Make sure your rules are there

3. **Check user authentication**:
   - Make sure you're logged in
   - Check Firebase Console → Authentication → Users to see if your user exists

4. **For development/testing only** (NOT for production):
   You can temporarily use these permissive rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
   **Warning**: These rules allow any authenticated user to read/write everything. Only use for testing!

## Next Steps

After setting up the rules:
1. Deploy them to Firebase
2. Restart your app
3. Try logging in again
4. The home screen should now work!





