# Firestore Indexes Setup Guide

Firestore requires composite indexes for queries that filter and order by different fields. This document lists all the indexes you need to create.

## Required Indexes

### 1. Tickets Collection - User Tickets Query

**Query:** Get all tickets for a user, ordered by issue date (descending)

**Fields:**
- Collection: `tickets`
- Fields to index:
  - `userId` (Ascending)
  - `issuedAt` (Descending)

**How to create:**
1. Click the link provided in the error message, OR
2. Go to [Firebase Console](https://console.firebase.google.com)
3. Navigate to: Firestore Database → Indexes → Create Index
4. Set:
   - Collection ID: `tickets`
   - Fields:
     - Field: `userId`, Order: Ascending
     - Field: `issuedAt`, Order: Descending
5. Click "Create"

**Direct Link (from error):**
```
https://console.firebase.google.com/v1/r/project/comfort-ticketing-app/firestore/indexes?create_composite=ClVwcm9qZWN0cy9jb21mb3J0LXRpY2tldGluZy1hcHAvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3RpY2tldHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDAoIaXNzdWVkQXQQAhoMCghfX25hbWVfXxAC
```

### 2. Tickets Collection - Date Range Query (Optional)

**Query:** Get tickets by date range, optionally filtered by user

**Fields:**
- Collection: `tickets`
- Fields to index:
  - `issuedAt` (Ascending)
  - `userId` (Ascending) - only if filtering by user
  - `issuedAt` (Descending) - for ordering

**Note:** This query might need multiple indexes depending on usage. Create as needed when you encounter errors.

### 3. Trips Collection - Route and Date Query

**Query:** Get trips for a route, filtered by date range

**Fields:**
- Collection: `trips`
- Fields to index:
  - `routeId` (Ascending)
  - `isActive` (Ascending) - if filtering by active status
  - `departureTime` (Ascending)

**How to create:**
1. Go to Firebase Console → Firestore Database → Indexes
2. Create Index:
   - Collection ID: `trips`
   - Fields:
     - Field: `routeId`, Order: Ascending
     - Field: `isActive`, Order: Ascending
     - Field: `departureTime`, Order: Ascending

### 4. Trips Collection - Route, Active, and Date Range Query

**Query:** Get active trips for a route within a date range

**Fields:**
- Collection: `trips`
- Fields to index:
  - `routeId` (Ascending)
  - `isActive` (Ascending)
  - `departureTime` (Ascending)

**Note:** This is the same as index #3, but ensure `isActive` is included.

## Quick Setup

### Option 1: Use the Error Link
When you see an index error, Firebase provides a direct link. Simply click it and the index will be created automatically.

### Option 2: Manual Creation
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project: `comfort-ticketing-app`
3. Go to **Firestore Database** → **Indexes** tab
4. Click **Create Index**
5. Fill in the fields as specified above
6. Click **Create**

### Option 3: Using firestore.indexes.json (Recommended for Production)

Create a `firestore.indexes.json` file in your project root:

```json
{
  "indexes": [
    {
      "collectionGroup": "tickets",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "issuedAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "trips",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "routeId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "departureTime",
          "order": "ASCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Then deploy using Firebase CLI:
```bash
firebase deploy --only firestore:indexes
```

## Index Build Time

- **Small collections (< 1,000 documents):** Usually completes in seconds
- **Medium collections (1,000 - 100,000 documents):** May take a few minutes
- **Large collections (> 100,000 documents):** Can take 10-30 minutes

You'll receive an email when the index is ready. The app will work once the index is built.

## Troubleshooting

### Index Still Building
- Wait for the index to finish building (check Firebase Console)
- You'll see a "Building" status in the Indexes tab
- The app will work automatically once the index is ready

### Multiple Index Errors
- Create indexes one at a time as errors appear
- Firebase will provide direct links for each missing index

### Query Still Fails After Index Creation
- Verify the index fields match exactly (including order: Ascending/Descending)
- Check that the collection name is correct
- Ensure the field names match your Firestore documents

## Current Required Indexes Summary

| Collection | Fields | Order | Status |
|------------|--------|-------|--------|
| `tickets` | `userId` (ASC), `issuedAt` (DESC) | Required | ⚠️ **NEEDS CREATION** |
| `trips` | `routeId` (ASC), `isActive` (ASC), `departureTime` (ASC) | Recommended | ⚠️ May be needed |

## Next Steps

1. **Immediate:** Click the link in the error message to create the first index
2. **Short-term:** Create the trips index if you encounter errors when loading trips
3. **Long-term:** Set up `firestore.indexes.json` for version control and easier deployment

