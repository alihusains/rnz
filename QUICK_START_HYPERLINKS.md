# Quick Start Guide - Hyperlinks Feature

## 🚀 What Was Implemented

Your app now supports **interactive hyperlinks** in description text!

---

## 📌 Quick Reference

### For Users
```
Hyperlinks appear as: blue underlined text
Tapping them:         Loads related content in a new screen
Going back:           Use the back button to return
Multiple levels:      You can tap hyperlinks within hyperlinks
```

### For Developers

**To create a hyperlink in your database:**
```
Description: "This relates to <hyperlink-name> which is important."
Database:    HyperlinkEnglishName = "hyperlink-name"
Result:      Blue underlined "hyperlink-name" (no brackets shown)
```

---

## 🔧 What You Need to Do

### 1. Database Setup ✅
Add columns to `subindex` table (if they don't exist):
```sql
ALTER TABLE subindex ADD COLUMN HyperlinkEnglishName VARCHAR(255);
ALTER TABLE subindex ADD COLUMN HyperlinkUrduName VARCHAR(255);
ALTER TABLE subindex ADD COLUMN HyperlinkArabicName VARCHAR(255);
-- Add for other languages as needed
```

### 2. Add Test Data ✅
```sql
INSERT INTO subindex VALUES (
  ...,
  HyperlinkEnglishName = "test-hyperlink",
  HyperlinkUrduName = "ٹیسٹ-ہائپرلنک",
  ...
);

-- Add description with hyperlink reference
INSERT INTO lines (EnglishDescription) VALUES (
  "This is related to <test-hyperlink> for more info."
);
```

### 3. Test It! ✅
- Open app
- Navigate to detail screen
- Look for blue underlined text in description
- Tap on it
- Should load related content

---

## 🎯 How It Works

```
Step 1: User sees description text
        ↓
Step 2: App detects <hyperlink> pattern
        ↓
Step 3: Renders as blue underlined text (without brackets)
        ↓
Step 4: User taps hyperlink
        ↓
Step 5: App queries: SELECT * FROM lines 
        WHERE subindex.HyperlinkEnglishName = 'hyperlink'
        ↓
Step 6: Shows results on new screen
        ↓
Step 7: User can tap back to return
```

---

## 📝 Example Walkthrough

### Setup
```
Database Table: subindex
├─ id: 42
├─ HyperlinkEnglishName: "Wudu-Steps"

Database Table: lines
├─ id: 999
├─ SubindexId: 42
├─ EnglishDescription: "First learn <Wudu-Steps>"
```

### User Experience
```
1. App displays: "First learn Wudu-Steps"
                           ↑ (blue, underlined)

2. User taps "Wudu-Steps"

3. Loading snackbar shows

4. New screen opens with all Wudu-Steps content

5. User sees related hyperlinks in that content too

6. User taps back button to return to original description
```

---

## 🛠️ Configuration Options

### Text Styling
Change hyperlink appearance in `_buildDescription()`:
```dart
// Current: Blue with underline
color: Colors.blue[600],
decoration: TextDecoration.underline,

// Customize to your preference
color: Colors.purple,  // Different color
decoration: TextDecoration.none,  // No underline
```

### Pattern Matching
Current regex: `<([^>]+)>` matches anything in angle brackets

To customize, change line 9 in `detail_screen.dart`:
```dart
final RegExp _hyperlinkPattern = RegExp(r'<([^>]+)>');
```

---

## ✅ Testing Checklist

### Basic Test (5 min)
- [ ] Add `<test>` to a description
- [ ] Verify blue underlined text appears
- [ ] Tap it
- [ ] Verify it tries to load

### Full Test (15 min)
- [ ] Create test hyperlink in database
- [ ] Add proper `HyperlinkEnglishName` value
- [ ] Create associated lines in `linesmetadata`
- [ ] Tap hyperlink in app
- [ ] Verify correct content displays
- [ ] Verify back button works
- [ ] Test with different languages

### Edge Cases (10 min)
- [ ] Hyperlink with no results → Should show error
- [ ] Multiple hyperlinks in same text → All should work
- [ ] Nested hyperlinks → Should allow drilling down
- [ ] Language switching → Should use correct column
- [ ] Empty description → Should not crash

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Hyperlinks not appearing | Check description has `<text>` format |
| Tap does nothing | Check `HyperlinkEnglishName` exists in DB |
| Wrong content loads | Verify hyperlink name matches DB exactly |
| Error message | Check database query in console logs |
| Preferences not saved | Check SharedPreferences initialization |

---

## 📋 Code Locations

| Feature | File | Line(s) |
|---------|------|---------|
| Regex pattern | `detail_screen.dart` | 9 |
| Parse logic | `detail_screen.dart` | 394 |
| Display logic | `detail_screen.dart` | 247-280 |
| Tap handler | `detail_screen.dart` | 432-471 |
| DB query | `database_helper.dart` | 106-130 |
| Hyperlink screen | `detail_screen.dart` | 495-1100 |

---

## 🎨 Customization Examples

### Change Link Color to Red
```dart
color: Colors.red[600],
```

### Remove Underline
```dart
decoration: TextDecoration.none,
```

### Add Bold Style
```dart
fontWeight: FontWeight.bold,
```

### Change Multiple Properties
```dart
TextStyle(
  fontSize: 14,
  color: Colors.purple,
  decoration: TextDecoration.overline,
  fontWeight: FontWeight.w700,
)
```

---

## 📚 More Information

For detailed docs, see:
- `HYPERLINK_IMPLEMENTATION.md` - Complete technical guide
- `IMPLEMENTATION_SUMMARY.md` - Feature overview
- Inline code comments - Detailed explanations

---

## 💬 Common Questions

**Q: Can I have multiple hyperlinks in one description?**
A: Yes! The regex finds all instances of `<...>` and makes them all clickable.

**Q: What if a hyperlink name has spaces?**
A: It works fine! Pattern matches anything between `<` and `>`, including spaces.

**Q: Can hyperlinks reference other hyperlinks?**
A: Yes! You can tap hyperlinks within hyperlink results (nested navigation).

**Q: Are hyperlinks case-sensitive?**
A: Yes! Database values must match exactly. Use lowercase consistently.

**Q: Do preferences carry over when tapping hyperlinks?**
A: Yes! Arabic/Transliteration/Translation toggles are preserved.

---

## 🚀 Next Steps

1. Add `HyperlinkEnglishName` column to your `subindex` table
2. Update test data with hyperlink references in descriptions
3. Add `<hyperlink-name>` to descriptions in database
4. Run app and test the feature
5. Customize styling if desired
6. Deploy with confidence!

---

**Feature Status**: ✅ Ready to Use
**Last Updated**: December 29, 2025
**Questions?**: Check the code comments in `detail_screen.dart` or `database_helper.dart`
