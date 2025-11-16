# Adding Sample Trips to Firestore

Trips are scheduled bus journeys for specific routes. Here's how to create them.

## Required Fields

When creating a trip in Firestore, you need these **required** fields:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `routeId` | **string** | ID of the route (from routes collection) | `abc123` (copy from route document ID) |
| `departureTime` | **timestamp** | When the bus departs | Set date/time (e.g., tomorrow 8:00 AM) |
| `arrivalTime` | **timestamp** | When the bus arrives | Set date/time (e.g., tomorrow 12:00 PM) |
| `vehicleId` | **string** | ID of the vehicle (from vehicles collection) | `vehicle1` (see Vehicles section below) |
| `totalSeats` | **number** | Total number of seats on the bus | `60` |
| `availableSeats` | **array** | List of available seat numbers | `[1, 2, 3, 4, ..., 60]` (all seats initially) |
| `createdAt` | **timestamp** | When trip was created | Click "Set" → "Server timestamp" |

## Optional Fields

These fields are optional but recommended:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `vehicleNumber` | string | Display number of the vehicle | `UA651AN` |
| `driverName` | string | Name of the driver | `John Doe` |
| `conductorName` | string | Name of the conductor | `Jane Smith` |
| `isActive` | boolean | Whether trip is active | `true` (default) |
| `updatedAt` | timestamp | Last update time | Leave empty or use server timestamp |

## Step-by-Step: Creating a Trip

### Step 1: Create a Vehicle (if not exists)

First, you need a vehicle. Go to `vehicles` collection and create a document:

**Vehicle Fields:**
- `vehicleNumber` (string): `UA651AN`
- `isActive` (boolean): `true`
- `createdAt` (timestamp): Server timestamp

**Note:** Copy the document ID - this is your `vehicleId` for the trip.

### Step 2: Get Route ID

1. Go to `routes` collection
2. Find your route (e.g., "Kampala to Lira")
3. Copy the **document ID** - this is your `routeId`

### Step 3: Create the Trip

1. Go to `trips` collection
2. Click **Add document**
3. Add these fields:

#### Example Trip: Kampala to Lira (Tomorrow 8:00 AM)

| Field | Type | Value |
|-------|------|-------|
| `routeId` | string | `[Paste route ID from Step 2]` |
| `departureTime` | timestamp | `[Set to tomorrow 8:00 AM]` |
| `arrivalTime` | timestamp | `[Set to tomorrow 12:00 PM]` (4 hours later) |
| `vehicleId` | string | `[Paste vehicle ID from Step 1]` |
| `vehicleNumber` | string | `UA651AN` |
| `totalSeats` | number | `60` |
| `availableSeats` | array | Click "Add item" 60 times, enter: `1`, `2`, `3`, ..., `60` |
| `driverName` | string | `John Doe` (optional) |
| `conductorName` | string | `Jane Smith` (optional) |
| `isActive` | boolean | `true` |
| `createdAt` | timestamp | Click "Set" → "Server timestamp" |

## Quick Example Values

### For "Kampala to Lira" Route:

**Trip 1: Morning Departure**
- `departureTime`: Tomorrow 8:00 AM
- `arrivalTime`: Tomorrow 12:00 PM (4 hours)
- `totalSeats`: `60`
- `availableSeats`: `[1, 2, 3, 4, ..., 60]` (all seats available)

**Trip 2: Afternoon Departure**
- `departureTime`: Tomorrow 2:00 PM
- `arrivalTime`: Tomorrow 6:00 PM (4 hours)
- `totalSeats`: `60`
- `availableSeats`: `[1, 2, 3, 4, ..., 60]`

### For "Kampala to Lira to Apac" Route:

**Trip 1: Morning Departure**
- `departureTime`: Tomorrow 7:00 AM
- `arrivalTime`: Tomorrow 12:00 PM (5 hours)
- `totalSeats`: `60`
- `availableSeats`: `[1, 2, 3, 4, ..., 60]`

## Important Notes

### Available Seats Array

The `availableSeats` array should contain all seat numbers that are available. For a new trip:
- If bus has 60 seats: `[1, 2, 3, 4, ..., 60]`
- If bus has 45 seats: `[1, 2, 3, 4, ..., 45]`

**Tip:** In Firebase Console, you can:
1. Click "Add item" for each seat number
2. Or create a script to generate the array

### Timestamps

- Use **Server timestamp** for `createdAt` (automatic)
- Set `departureTime` and `arrivalTime` to specific dates/times
- Make sure `arrivalTime` is after `departureTime`

### Route ID

- Must match an existing route document ID
- Copy it exactly from the routes collection

### Vehicle ID

- Must match an existing vehicle document ID
- You can create a simple vehicle first, then use its ID

## Creating Multiple Trips

You can create multiple trips for the same route with different departure times:

- Morning trip: 8:00 AM
- Afternoon trip: 2:00 PM
- Evening trip: 6:00 PM

Each trip needs its own document with unique departure/arrival times.

## Testing

After creating trips:

1. Go to the booking page in your app
2. Select a route
3. Select a date
4. You should see the trips you created in the dropdown

## Troubleshooting

### "No trips available for this date"
- Check that `departureTime` matches the selected date
- Check that `isActive` is `true`
- Verify `routeId` matches the selected route

### "Trip not found" error
- Verify the trip document exists in Firestore
- Check that `routeId` is correct

### Seats not showing
- Verify `availableSeats` array is properly formatted
- Check that `totalSeats` matches the number of seats



