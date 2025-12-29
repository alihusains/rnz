# Hyperlink Implementation Documentation

## Overview
This document describes the implementation of hyperlink extraction and navigation functionality in the Raazoneyaz application. Users can now click on hyperlinks embedded in description text to view related content.

## Features Implemented

### 1. Hyperlink Detection & Parsing
- **Pattern**: Text within angle brackets like `<hyperlink-name>`
- **Location**: Checked in the `${_selectedLanguage}Description` field
- **Extraction**: Uses regex pattern `<([^>]+)>` to extract hyperlink names
- **Display**: Brackets are removed and text is shown as a styled hyperlink

### 2. Hyperlink Styling
- **Color**: Blue (#1976D2 or Colors.blue[600])
- **Decoration**: Underline to indicate clickability
- **Cursor**: Changes to pointer cursor on hover (web/desktop)
- **Integration**: Uses RichText with WidgetSpan for inline hyperlinks

### 3. Hyperlink Navigation
When a user taps on a hyperlink:
1. A "Loading hyperlink..." message appears
2. The app queries the database using `getLinesByHyperlinkName()`
3. Results are fetched based on the `HyperlinkName` column in the `subindex` table
4. A new detail screen displays the related content
5. All user preferences (Arabic, Transliteration, Translation toggles) are preserved

### 4. Nested Hyperlinks
- Hyperlinks within hyperlink results also work
- Users can drill down through multiple levels of hyperlinks
- Back button allows returning to previous screens

## Technical Implementation

### Database Changes

#### New Method: `getLinesByHyperlinkName()`
Located in `database_helper.dart`

```dart
Future<List<Map<String, dynamic>>> getLinesByHyperlinkName(
    String hyperlinkName) async
```

**Query:**
```sql
SELECT lm.*, 
       l.{language}Title, 
       l.{language}Description, 
       l.{language}, 
       l.RArabic,
       CONCAT_WS('', l.ArabicText1, ..., l.ArabicText20) AS ArabicContent
FROM linesmetadata lm
JOIN lines l ON lm.LinesId = l.id
JOIN subindex s ON lm.SubindexId = s.id
WHERE s.Hyperlink{language}Name = ?
ORDER BY lm.Number ASC
```

**Parameters:**
- `hyperlinkName`: The extracted hyperlink name from the description text

**Database Requirements:**
- Table `subindex` must have column `Hyperlink{Language}Name` for each supported language
  - Examples: `HyperlinkEnglishName`, `HyperlinkUrduName`, `HyperlinkArabicName`, etc.

### Frontend Changes

#### New Class: `HyperlinkSpan`
Simple data class to represent a hyperlink:
```dart
class HyperlinkSpan {
  final String text;
  final String hyperlinkName;
  
  HyperlinkSpan({required this.text, required this.hyperlinkName});
}
```

#### Updated: `_buildDescription()` Method
- Now uses `RichText` instead of plain `Text`
- Parses description for hyperlinks using `_parseHyperlinks()`
- Renders hyperlinks as clickable blue underlined text
- Normal text remains unchanged

#### New Method: `_parseHyperlinks()`
```dart
List<dynamic> _parseHyperlinks(String text)
```
- Scans text for pattern `<...>`
- Returns mixed list of String (normal text) and HyperlinkSpan (hyperlinks)
- Removes brackets from display text
- Preserves all surrounding text

#### New Method: `_onHyperlinkTap()`
```dart
void _onHyperlinkTap(String hyperlinkName) async
```
- Handles tap events on hyperlinks
- Shows loading indicator
- Fetches data from database
- Handles errors gracefully
- Navigates to new screen with results

#### New Widget: `DetailedScreenFromHyperlink`
Complete screen widget for displaying hyperlink results:
- Same layout as original `DetailedScreen`
- Takes `lines` data directly instead of fetching from subindex ID
- Supports all display toggles (Arabic, Transliteration, Translation)
- Preserves user preferences from parent screen
- Supports nested hyperlinks

## User Experience Flow

```
1. User views DetailedScreen
   ↓
2. User sees description with blue underlined hyperlinks
   ↓
3. User taps on hyperlink
   ↓
4. "Loading hyperlink..." snackbar appears
   ↓
5. New DetailedScreenFromHyperlink opens with related content
   ↓
6. All user preferences are maintained
   ↓
7. User can tap on hyperlinks within the new content
   ↓
8. User can navigate back using back button
```

## Error Handling

### No Results Found
If the hyperlink name doesn't exist in the database:
- Snackbar message: "No content found for this hyperlink"
- User returns to previous screen
- No navigation occurs

### Database Query Errors
If an exception occurs during database query:
- Error message displayed: "Error loading hyperlink: {error_details}"
- Stack trace logged to console
- User remains on current screen

## Code Files Modified

### 1. `lib/database_helper.dart`
- Added `getLinesByHyperlinkName()` method
- Removed TODO comments (now implemented)

### 2. `lib/detail_screen.dart`
- Added `HyperlinkSpan` class
- Added `_hyperlinkPattern` regex
- Updated `_buildDescription()` to render hyperlinks
- Added `_parseHyperlinks()` method
- Added `_onHyperlinkTap()` method
- Added `DetailedScreenFromHyperlink` widget class
- Added `_DetailedScreenFromHyperlinkState` class

## Configuration Requirements

### Database Schema
Ensure your `subindex` table has these columns:
- `HyperlinkEnglishName` (for English)
- `HyperlinkUrduName` (for Urdu)
- `HyperlinkRUrduName` (for Romanized Urdu)
- `HyperlinkArabicName` (for Arabic)
- `HyperlinkRArabicName` (for Romanized Arabic)

### Description Format
To create hyperlinks in descriptions, use this format:
```
This relates to <hyperlink-name-here> which is important.
```

The text within `< >` should match the corresponding `Hyperlink{Language}Name` value in the `subindex` table.

## Testing Recommendations

1. **Basic Hyperlink Detection**
   - Add test data with `<test-hyperlink>` in description
   - Verify blue underlined text appears

2. **Navigation Flow**
   - Tap on hyperlink
   - Verify loading indicator appears
   - Verify new screen opens with correct content

3. **Nested Hyperlinks**
   - Create hyperlinks that reference other hyperlinks
   - Test multiple levels of navigation
   - Verify back button works correctly

4. **Language Support**
   - Test in different languages (English, Urdu, Arabic)
   - Verify correct `Hyperlink{Language}Name` column is queried

5. **Error Cases**
   - Test with non-existent hyperlink names
   - Test with database connection issues
   - Verify error messages display correctly

6. **Preference Preservation**
   - Toggle display options before tapping hyperlink
   - Verify preferences maintained on new screen
   - Test preference changes on hyperlink screen

## Future Enhancements

1. **Hyperlink History**
   - Add breadcrumb navigation showing visited hyperlinks
   - Quick navigation back to previous hyperlinks

2. **Search Integration**
   - Add search results to hyperlink navigation
   - Allow searching within hyperlink content

3. **Caching**
   - Cache frequently accessed hyperlinks
   - Improve load times for repeated access

4. **Analytics**
   - Track which hyperlinks are most frequently used
   - Monitor user navigation patterns

5. **Formatting Options**
   - Support different link styles (bold, italic, etc.)
   - Allow custom link colors per language

## Troubleshooting

### Hyperlinks Not Appearing
- Check description field contains text in format `<hyperlink-name>`
- Verify regex pattern is correct: `<([^>]+)>`
- Check that `_buildDescription()` is being called

### Hyperlinks Not Clickable
- Verify `GestureDetector` and `MouseRegion` are properly wrapped
- Check that `_onHyperlinkTap()` is being called
- Review console logs for tap event errors

### Wrong Data Displayed
- Verify `Hyperlink{Language}Name` column exists in database
- Check that hyperlink names in description match database values exactly
- Verify `selectedLanguage` preference is set correctly

### Navigation Not Working
- Check `Navigator.of(context).push()` isn't blocked
- Verify `DetailedScreenFromHyperlink` imports are correct
- Review console logs for navigation errors

## Contact & Support
For issues or questions about the hyperlink implementation, refer to the code comments in:
- `lib/detail_screen.dart` - UI implementation
- `lib/database_helper.dart` - Database queries
