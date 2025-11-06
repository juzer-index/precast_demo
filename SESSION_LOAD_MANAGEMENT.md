# Session-Based Load Management Implementation

## Overview
This implementation adds a global session-based load management system that allows loads created during the current session to be saved and viewed in the Load History page.

## Changes Made

### 1. Created LoadHistoryProvider (`lib/Providers/LoadHistoryProvider.dart`)
A new Provider class that manages load data globally across the application session:

**Features:**
- `sessionLoads` - List of all loads created in the current session
- `addLoad(LoadData)` - Add or update a load in the session
- `removeLoad(String loadID)` - Remove a load from the session
- `clearAllLoads()` - Clear all session loads
- `getLoadByID(String loadID)` - Retrieve a specific load
- `loadCount` - Get the number of loads in the session

### 2. Updated main.dart
- Registered `LoadHistoryProvider` in the MultiProvider list
- This makes the provider available throughout the entire app

### 3. Updated stockLoadingPage.dart
Modified the `_pushCurrentLoadToSession()` method to:
- Save loads to the global `LoadHistoryProvider` whenever a load is created or updated
- Maintains backward compatibility with the existing `widget.addLoadData` callback
- Automatically saves loads at key points:
  - When a new load is created (`createNewLoad`)
  - When a load is fetched/viewed (`fetchLoadDataFromURL`)
  - When load lines are saved (`updateUD104A`)
  - When load data is reloaded (`loadLoadAndData`)

### 4. Updated load_history.dart
- Now fetches loads from `LoadHistoryProvider` instead of just the passed widget parameter
- Uses `context.watch<LoadHistoryProvider>().sessionLoads` to reactively display all session loads
- Automatically updates when new loads are added to the session

## How It Works

1. **Creating a Load:**
   - User creates a new load in the Stock Loading page
   - Load is saved to the backend API
   - `_pushCurrentLoadToSession()` is called automatically
   - Load is added to `LoadHistoryProvider`
   - Load appears immediately in Load History

2. **Viewing Load History:**
   - Navigate to Load History page
   - Page watches `LoadHistoryProvider.sessionLoads`
   - All loads created/viewed in the current session are displayed
   - Click on a Load ID to view/edit that load

3. **Session Persistence:**
   - Loads are stored in memory during the app session
   - Loads persist across navigation between pages
   - Session clears when the app is restarted

## Benefits

- ✅ Centralized load management using Provider pattern
- ✅ Automatic synchronization between pages
- ✅ No need to manually pass loads between pages
- ✅ Reactive updates - UI updates automatically when loads change
- ✅ Backward compatible with existing code
- ✅ Easy to extend with additional features (e.g., persistence to local storage)

## Usage Example

```dart
// In any widget with access to context:

// Add a load to session
context.read<LoadHistoryProvider>().addLoad(myLoad);

// Get all session loads
final loads = context.watch<LoadHistoryProvider>().sessionLoads;

// Get a specific load
final load = context.read<LoadHistoryProvider>().getLoadByID('I-51');

// Clear all session loads
context.read<LoadHistoryProvider>().clearAllLoads();
```

## Future Enhancements

Potential improvements that could be added:

1. **Persistent Storage:** Save loads to local storage (SharedPreferences/SQLite) to persist across app restarts
2. **Sync with Backend:** Periodically sync session loads with the backend database
3. **Filtering/Sorting:** Add filters and sorting options in the Load History page
4. **Export:** Export load history to CSV/PDF
5. **Session Statistics:** Show summary statistics (total loads, total volume, etc.)

## Testing

To test the implementation:

1. Create a new load in the Stock Loading page
2. Navigate to Load History
3. Verify the load appears in the table
4. Create another load
5. Verify both loads appear in Load History
6. Click on a Load ID to edit/view it
7. Make changes and save
8. Verify updates appear in Load History

## Notes

- The session clears when the app is closed/restarted
- Loads from the database are not automatically loaded into the session
- Only loads created or viewed during the current session appear in Load History
- The implementation maintains backward compatibility with existing code

