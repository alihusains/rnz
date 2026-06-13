# Hyperlink Feature - Architecture & Data Flow

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    RAAZONEYAZ APPLICATION                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              DetailedScreen Widget                        │   │
│  │  ┌──────────────────────────────────────────────────────┐ │   │
│  │  │  _DetailedScreenState                                 │ │   │
│  │  │  - _lines: List<Map>                                  │ │   │
│  │  │  - _selectedLanguage: String                          │ │   │
│  │  │  - _showArabic: bool                                  │ │   │
│  │  │  - _showTransliteration: bool                         │ │   │
│  │  │  - _showTranslation: bool                             │ │   │
│  │  │                                                        │ │   │
│  │  │  Methods:                                             │ │   │
│  │  │  • _buildDescription() → uses _parseHyperlinks()     │ │   │
│  │  │  • _parseHyperlinks() → List<dynamic>                │ │   │
│  │  │  • _onHyperlinkTap() → getLinesByHyperlinkName()     │ │   │
│  │  └──────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓ (navigation)                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         DetailedScreenFromHyperlink Widget               │   │
│  │  ┌──────────────────────────────────────────────────────┐ │   │
│  │  │  _DetailedScreenFromHyperlinkState                    │ │   │
│  │  │  - lines: List<Map> (passed from parent)             │ │   │
│  │  │  - Same methods as DetailedScreen                    │ │   │
│  │  │  - Same styling and preferences                      │ │   │
│  │  │  - Supports nested hyperlink navigation              │ │   │
│  │  └──────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    DatabaseHelper Class                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Methods:                                                 │   │
│  │  • getCategories()                                        │   │
│  │  • getSubcategories()                                     │   │
│  │  • getLinesForSubindex()                                  │   │
│  │  • getLinesByHyperlinkName() ← NEW                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    SQLite Database                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  tables:                                                 │    │
│  │  • categories                                            │    │
│  │  • subindex ← HyperlinkEnglishName (NEW)                │    │
│  │  • linesmetadata                                         │    │
│  │  • lines                                                 │    │
│  │  • (other tables...)                                     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Diagram

### Initial Load
```
User Opens DetailedScreen
         ↓
getLinesForSubindex(subindexId)
         ↓
SQL: SELECT lm.*, l.{language}Title, ... FROM linesmetadata lm 
     JOIN lines l ... WHERE lm.SubindexId = ?
         ↓
List<Map> returned to _lines
         ↓
ListView.builder renders each line
         ↓
_buildDescription() called for each line
         ↓
_parseHyperlinks() scans for <...> pattern
         ↓
RichText rendered with mix of plain text and hyperlinks
```

### Hyperlink Navigation Flow
```
Description text contains: "Learn about <Salat-Method>"
         ↓
_parseHyperlinks() detected
         ↓
Returns: ["Learn about ", HyperlinkSpan(text: "Salat-Method", ...)]
         ↓
RichText renders "Learn about " + blue underlined "Salat-Method"
         ↓
User taps hyperlink
         ↓
_onHyperlinkTap("Salat-Method") called
         ↓
Show loading snackbar
         ↓
getLinesByHyperlinkName("Salat-Method")
         ↓
SQL: SELECT lm.*, l.{language}Title, ... FROM linesmetadata lm 
     JOIN lines l ... JOIN subindex s ...
     WHERE s.Hyperlink{language}Name = ?
         ↓
List<Map> returned
         ↓
Navigator.push() → DetailedScreenFromHyperlink(
     title: "Salat-Method",
     lines: List<Map>,
     showArabic: true,
     showTransliteration: true,
     showTranslation: true
)
         ↓
New screen displays with same preferences
         ↓
User can tap back or tap nested hyperlinks
```

---

## 🧩 Component Structure

### HyperlinkSpan Class
```
HyperlinkSpan
├─ text: String (display text)
└─ hyperlinkName: String (lookup key)
```

### _parseHyperlinks() Output
```
List<dynamic> = [
  "Normal text before",           // Type: String
  HyperlinkSpan("link1", ...),   // Type: HyperlinkSpan
  " more text ",                  // Type: String
  HyperlinkSpan("link2", ...),   // Type: HyperlinkSpan
  "end text"                      // Type: String
]
```

### RichText Rendering
```
RichText
└─ TextSpan (parent)
   ├─ TextSpan (normal text)
   │  └─ style: grey, normal font
   ├─ WidgetSpan (hyperlink)
   │  └─ GestureDetector
   │     └─ Text (blue, underlined)
   ├─ TextSpan (normal text)
   ├─ WidgetSpan (hyperlink)
   └─ TextSpan (normal text)
```

---

## 🗄️ Database Schema

### Current Table: subindex
```sql
CREATE TABLE subindex (
  id INTEGER PRIMARY KEY,
  CategoryId INTEGER,
  ParentId INTEGER,
  Level INTEGER,
  Number INTEGER,
  ... other columns ...
  
  -- NEW COLUMNS (for hyperlink support)
  HyperlinkEnglishName VARCHAR(255),
  HyperlinkUrduName VARCHAR(255),
  HyperlinkRUrduName VARCHAR(255),
  HyperlinkArabicName VARCHAR(255),
  HyperlinkRArabicName VARCHAR(255)
);
```

### Query Relationships
```
getLinesByHyperlinkName("Salat-Method")
         ↓
SELECT lm.*, l.English...
FROM linesmetadata lm
├─ JOIN lines l ON lm.LinesId = l.id
├─ JOIN subindex s ON lm.SubindexId = s.id
└─ WHERE s.HyperlinkEnglishName = "Salat-Method"
         ↓
Returns all lines associated with that hyperlink
```

---

## 🎯 Pattern Matching Logic

### Regex Pattern
```
Pattern: <([^>]+)>
Meaning:
  <      = literal opening bracket
  (      = start capture group 1
  [^>]+  = one or more characters that are NOT >
  )      = end capture group 1
  >      = literal closing bracket

Examples:
  Input:  "Learn <Salat-Method> today"
  Match:  "<Salat-Method>"
  Group1: "Salat-Method"

  Input:  "Topics: <topic-1>, <topic-2>, <topic-3>"
  Matches: "<topic-1>", "<topic-2>", "<topic-3>"
  Groups:  "topic-1", "topic-2", "topic-3"
```

### Parsing Algorithm
```
_parseHyperlinks(text):
  result = []
  lastIndex = 0
  
  FOR EACH match in RegExp.allMatches(text):
    IF match.start > lastIndex:
      result.add(text[lastIndex:match.start])
    
    hyperlinkName = match.group(1)
    result.add(HyperlinkSpan(text: hyperlinkName, ...))
    
    lastIndex = match.end
  
  IF lastIndex < text.length:
    result.add(text[lastIndex:end])
  
  RETURN result
```

---

## 📊 State Management

### DetailedScreen State
```
_DetailedScreenState
│
├─ _lines: List<Map<String, dynamic>>
│  ├─ Loaded from: getLinesForSubindex()
│  ├─ Contains: All line data + metadata
│  └─ Used by: ListView.builder
│
├─ _selectedLanguage: String
│  ├─ Loaded from: SharedPreferences
│  ├─ Values: "English", "Urdu", "RUrdu", "Arabic", "RArabic"
│  └─ Used by: Column access in queries
│
├─ _showArabic: bool
│  ├─ Persisted: SharedPreferences
│  ├─ Default: true
│  └─ Used by: Conditional rendering
│
├─ _showTransliteration: bool
│  ├─ Persisted: SharedPreferences
│  ├─ Default: true
│  └─ Used by: Conditional rendering
│
└─ _showTranslation: bool
   ├─ Persisted: SharedPreferences
   ├─ Default: true
   └─ Used by: Conditional rendering
```

### DetailedScreenFromHyperlink State
```
_DetailedScreenFromHyperlinkState
│
├─ lines: List<Map<String, dynamic>>
│  ├─ Loaded from: getLinesByHyperlinkName() result
│  ├─ Passed from: DetailedScreen._onHyperlinkTap()
│  └─ Immutable: Only read, never modified
│
├─ _showArabic, _showTransliteration, _showTranslation: bool
│  ├─ Initialized: From parent screen parameters
│  ├─ Can change: User can toggle on this screen
│  └─ Auto-persist: SavePreferences on toggle
│
└─ _selectedLanguage: String
   ├─ Reloaded: From SharedPreferences in initState()
   └─ May differ: If user changed language preference
```

---

## 🔐 Error Handling Flow

```
User taps hyperlink
         ↓
try {
  ScaffoldMessenger.showSnackBar("Loading...")
         ↓
  lines = await getLinesByHyperlinkName(hyperlinkName)
         ↓
  if (lines.isEmpty) {
    ├─ ScaffoldMessenger.showSnackBar("No content found")
    └─ return (no navigation)
  } else {
    └─ Navigator.push(DetailedScreenFromHyperlink(...))
  }
}
catch (e) {
  ├─ debugPrint(e)
  ├─ if (mounted) {
  │   └─ ScaffoldMessenger.showSnackBar("Error: $e")
  │  }
  └─ User remains on current screen
}
```

---

## 🚀 Execution Timeline

### First Load
```
Time 0ms:     DetailedScreen created
Time 5ms:     initState() called
Time 10ms:    _loadPreferences() starts
Time 15ms:    _fetchData() starts
Time 50ms:    SharedPreferences.getString() returns
Time 100ms:   getLinesForSubindex() returns
Time 150ms:   setState() called, UI updates
Time 200ms:   ListView.builder renders first items
Time 250ms:   _buildDescription() parses hyperlinks
Time 300ms:   RichText renders with blue links
```

### Hyperlink Tap
```
Time 0ms:     GestureDetector.onTap triggered
Time 5ms:     _onHyperlinkTap() called
Time 10ms:    ScaffoldMessenger.showSnackBar("Loading...")
Time 15ms:    getLinesByHyperlinkName() starts
Time 50ms:    SQL query executed
Time 100ms:   Results processed
Time 150ms:   if (mounted) check passed
Time 155ms:   Navigator.push() called
Time 200ms:   New DetailedScreenFromHyperlink created
Time 250ms:   New screen animates into view
Time 300ms:   ListView builder renders new content
```

---

## 🔗 Method Call Chain

### Hyperlink Rendering
```
build()
└─ ListView.builder
   └─ Column (children)
      ├─ _buildTitle()
      ├─ _buildDescription()  ← HYPERLINK RENDERING
      │  ├─ _parseHyperlinks()
      │  │  └─ RegExp.allMatches()
      │  └─ RichText (with GestureDetector)
      │     └─ _onHyperlinkTap() [callback]
      ├─ _buildArabicContent()
      ├─ _buildTransliteration()
      └─ _buildTranslation()
```

### Hyperlink Navigation
```
_onHyperlinkTap(hyperlinkName)
├─ ScaffoldMessenger.showSnackBar()
├─ DatabaseHelper().getLinesByHyperlinkName()
│  └─ rawQuery() [SQL execution]
├─ if (lines.isEmpty)
│  └─ ScaffoldMessenger.showSnackBar("No content...")
└─ else
   └─ Navigator.push()
      └─ MaterialPageRoute()
         └─ DetailedScreenFromHyperlink(...)
```

---

## 💾 Data Persistence

### Preferences Saved
```
SharedPreferences
├─ selectedLanguage: String
├─ showArabic: bool
├─ showTransliteration: bool
└─ showTranslation: bool
```

### Where Saved
```
DetailedScreen:
├─ _loadPreferences() - reads in initState()
├─ _savePreferences() - called on checkbox toggle
└─ Saved to SharedPreferences

DetailedScreenFromHyperlink:
├─ _loadLanguagePreference() - reads in initState()
├─ _savePreferences() - called on checkbox toggle
└─ Saved to SharedPreferences (same storage)
```

---

## 📱 UI Hierarchy

```
Scaffold
├─ AppBar (toolbarHeight: 110)
│  └─ Column
│     ├─ Row
│     │  ├─ BackButton
│     │  ├─ Text (title)
│     │  ├─ Spacer
│     │  └─ IconButton (copy)
│     └─ Row (checkboxes)
│        ├─ Checkbox (Arabic)
│        ├─ Checkbox (Transliteration)
│        └─ Checkbox (Translation)
│
└─ body:
   └─ ListView.builder
      └─ Column (per line)
         ├─ _buildTitle()
         │  └─ Text
         ├─ _buildDescription()
         │  └─ RichText
         │     └─ WidgetSpan (for hyperlinks)
         │        └─ GestureDetector
         │           └─ Text (styled)
         ├─ _buildArabicContent()
         │  └─ Container > Text
         ├─ _buildTransliteration()
         │  └─ Text
         ├─ _buildTranslation()
         │  └─ Text
         └─ SizedBox (spacing)
```

---

**Diagram Generated**: December 29, 2025
**Version**: 1.0
**Status**: Complete Implementation
