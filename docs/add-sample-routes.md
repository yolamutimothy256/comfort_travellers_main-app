# Adding Sample Routes to Firestore

The booking feature requires routes to be created in Firestore. Here are two ways to add the sample routes.

## Option 1: Using Firebase Console (Easiest)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `comfort-ticketing-app`
3. Navigate to **Firestore Database**
4. Click **Start collection** (if routes collection doesn't exist) or click on **routes** collection
5. Click **Add document**

### Route 1: Kampala to Lira

Click **Add document** and add these fields:

| Field | Type | Value |
|-------|------|-------|
| `name` | string | `Kampala to Lira` |
| `origin` | string | `Kampala` |
| `destination` | string | `Lira` |
| `basePrice` | number | `40000` |
| `estimatedDurationMinutes` | number | `240` |
| `stops` | array | `["Kampala", "Lira"]` |
| `isActive` | boolean | `true` |
| `createdAt` | timestamp | Click "Set" and choose "Server timestamp" |

### Route 2: Kampala to Lira to Apac

Click **Add document** again and add:

| Field | Type | Value |
|-------|------|-------|
| `name` | string | `Kampala to Lira to Apac` |
| `origin` | string | `Kampala` |
| `destination` | string | `Apac` |
| `basePrice` | number | `50000` |
| `estimatedDurationMinutes` | number | `300` |
| `stops` | array | `["Kampala", "Lira", "Apac"]` |
| `isActive` | boolean | `true` |
| `createdAt` | timestamp | Click "Set" and choose "Server timestamp" |

## Option 2: Using Dart Script (Automated)

1. Make sure you have Firebase initialized in your project
2. Run the script:
   ```bash
   dart run scripts/add_sample_routes.dart
   ```

**Note:** You may need to configure Firebase options first. If the script doesn't work, use Option 1 instead.

## Option 3: Using Firebase CLI (Advanced)

You can also use Firebase CLI to add documents, but Option 1 (Console) is the easiest.

## Verifying Routes

After adding the routes:

1. Go to Firebase Console → Firestore Database
2. Click on the `routes` collection
3. You should see 2 documents
4. Try the booking feature in the app - routes should now appear in the dropdown

## Route Details

### Route 1: Kampala to Lira
- **Origin:** Kampala
- **Destination:** Lira
- **Price:** 40,000 UGX
- **Duration:** 4 hours (240 minutes)
- **Stops:** Kampala → Lira

### Route 2: Kampala to Lira to Apac
- **Origin:** Kampala
- **Destination:** Apac
- **Price:** 50,000 UGX
- **Duration:** 5 hours (300 minutes)
- **Stops:** Kampala → Lira → Apac

## Next Steps

After adding routes, you'll also need to create **Trips** for these routes. Trips are the actual scheduled bus journeys. You can create trips through:
- Firebase Console (manually)
- The app (if you're logged in as an agent/admin)
- A similar script for trips

Would you like me to create a guide for adding sample trips as well?

