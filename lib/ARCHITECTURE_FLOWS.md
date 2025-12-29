# Architecture & Flow Diagrams

## App Flow Diagram

App Start (main.dart)
  |
  v
LanguageCheckerScreen
  - Checks if language is selected in SharedPreferences
  - If YES: Go to CategoriesScreen
  - If NO: Go to LanguageSelectionScreen
  |
  +--- Language Selected --- No Language ---+
  |                                         |
  v                                         v
CategoriesScreen (Root)        LanguageSelectionScreen
                                            |
  +-------- Language Selected ------+       |
  |                                |       |
  v                                v       |
CategoriesScreen                  |
  (Main List)                      |
  Header: [Heart] [Settings]       |
  Items: Category list             |
  |                                |
  +---- Item with Children ----+   |
  |                            |   |
  v                            v   v
Settings             Bookmarks  Subcategories
  |                     |           |
  v                     |           v
SettingsScreen          |       [More Subcategories]
  - Change Language      |           |
  - Save                 |           v
  |                      |       [Leaf Item]
  v                      |       (with details)
[Language Changed]       |           |
[Refresh Data]           |           v
  |                      |       DetailedScreen
  v                      |       Header: [Heart] [Copy]
[Back to Categories]     |       Content:
  |                      |       - Title
  +------+-------+-------+       - Description
         |       |               - Arabic section
         |       |               - Transliteration
         |       |               - Translation
         v       v
    [Bookmark Toggled]

         v
    BookmarksScreen
      - Shows language-specific bookmarks
      - Tap to view details
      - X to remove
      - Empty state if none

---

## Language-Specific Bookmark Flow

User Bookmarks an Item
  |
  +--- English ------- Urdu ---+
  |                            |
  v                            v
saveBookmark(          saveBookmark(
  id: 123              id: 123
  title: "Item A"      title: "Item A"
  language: English    language: Urdu
)                      )
  |                            |
  v                            v
SharedPreferences      SharedPreferences
bookmarks_English      bookmarks_Urdu
= ["123|Item A"]       = ["123|Item A"]
  |                            |
  v                            v
Only shows in          Only shows in
BookmarksScreen        BookmarksScreen
when English           when Urdu
is selected            is selected

Result: Each bookmark appears only when its language is selected

---

## Data Loading Sequence

BEFORE FIX (BROKEN):
initState()
  |- _loadLanguagePreference() [ASYNC]
  |   |- Return immediately (async)
  |
  |- _fetchCategories() [ASYNC]
  |   |- items.isEmpty = true
  |   |- Show CircularProgressIndicator
  |
  |- (Later) Language loaded -> fetchCategories again
  |- ERROR: "Failed to load categories" during initial load

AFTER FIX (CORRECT):
initState()
  |- _loadLanguagePreferenceAndData() [ASYNC]
     |- Set _isLoading = true
     |- Load language from SharedPreferences
     |- Set _selectedLanguage = loaded language
     |- Call _fetchCategories()
     |   |- Query database with language
     |   |- Update items
     |- Set _isLoading = false
        |- UI refreshes with loaded items

---

## Grouped Content Display

BEFORE (Scattered):
DetailedScreen
  Title
  Description
  Arabic Text          <- Confusing!
  RArabic Text         <- Which is which?
  English Text

AFTER (Organized with Labels):
DetailedScreen
  Title
  Description
  ───────────────────
  Arabic [Amber]
  Arabic Text Here
  ───────────────────
  Transliteration - Roman Urdu [Blue]
  RArabic Text Here
  ───────────────────
  English Translation [Green]
  English Text Here

Color Guide:
- Amber = Arabic
- Blue = Transliteration
- Green = Language Translation

---

## SharedPreferences Storage Structure

selectedLanguage: String
  -> "English" | "Urdu" | "RUrdu"

showArabic: Boolean
showTransliteration: Boolean
showTranslation: Boolean

bookmarks_English: List<String>
  -> ["123|Title1", "456|Title2", ...]

bookmarks_Urdu: List<String>
  -> ["123|Urdu Title", "789|Urdu Title", ...]

bookmarks_RUrdu: List<String>
  -> ["123|Title", "789|Title", ...]

---

## State Management

CategoriesScreen State:
  - items: List of categories/subcategories
  - _selectedLanguage: Current language
  - _isLoading: Loading indicator

DetailedScreen State:
  - _lines: Lines data from database
  - _selectedLanguage: Current language
  - _isBookmarked: Is item bookmarked
  - _show*: Toggle visibility

BookmarksScreen State:
  - bookmarks: List of bookmarks
  - _selectedLanguage: Current language
  - _isLoading: Loading indicator

---

## User Interaction Flows

FLOW 1: Bookmark an Item
User in DetailedScreen
  |
  v
Tap Heart Icon
  |
  v
_toggleBookmark()
  |
  +--- if (_isBookmarked) --- removeBookmark()
  |                           -> SharedPreferences.remove()
  |
  +--- else --- saveBookmark()
                -> SharedPreferences.save()
  |
  v
setState() updates UI
  |
  +-- Heart icon color changes
  +-- SnackBar shows message
  +-- _isBookmarked flag toggles

FLOW 2: View Bookmarks
User in CategoriesScreen (Root)
  |
  v
Tap Heart Icon (AppBar)
  |
  v
Navigator.push() -> BookmarksScreen
  |
  v
_loadBookmarks()
  |- Get current language
  |- Fetch bookmarks from SharedPreferences
  |  (bookmarks_[language])
  |- setState() with bookmarks list
  |
  v
Screen Rendered
  |
  +--- if bookmarks.isEmpty
  |     -> Show empty state
  |
  +--- else
       -> Show ListView of bookmarks
          |- Each item: [Icon] [Title] [Delete]
          |- Tap to navigate to details

FLOW 3: Change Language and See Bookmarks Update
User in BookmarksScreen
  |
  v
Tap Settings
  |
  v
Navigate to SettingsScreen
  |- Change language
  |- Tap "Save Language"
     -> SharedPreferences.setString(selectedLanguage, ...)
  |
  v
Pop SettingsScreen
  |
  v
CategoriesScreen.then() callback
  |- _loadLanguagePreferenceAndData()
     |- Reload language
     |- Refresh categories
     |- UI updates
  |
  v
Categories now in new language
  |
  v
Tap bookmarks again
  |
  v
BookmarksScreen _loadBookmarks()
  |- Get CURRENT language (newly changed)
  |- Fetch bookmarks_[NewLanguage]
  |
  v
Shows bookmarks for NEW language
(Different list than before!)

---

## Component Architecture

main.dart
  |
  +-- LanguageCheckerScreen
       |
       +-- CategoriesScreen (ROOT)
            |
            +-- SettingsScreen
            |    (affects: selectedLanguage)
            |
            +-- BookmarksScreen
            |    (reads: bookmarks_language)
            |
            +-- CategoriesScreen (non-root)
                 |
                 +-- DetailedScreen
                      |
                      +-- DetailedScreenFromHyperlink
                           (recursive)

Database Methods Used:
- getCategories()
- getSubcategories()
- getLinesForSubindex()
- getLinesByHyperlinkName()
- isBookmarked()
- saveBookmark()
- removeBookmark()
- getBookmarksForLanguage()

SharedPreferences Keys Used:
- selectedLanguage
- showArabic
- showTransliteration
- showTranslation
- bookmarks_English
- bookmarks_Urdu
- bookmarks_RUrdu

---

Architecture Quality:
✓ Modular - Each screen has clear responsibility
✓ Scalable - Easy to add new languages/features
✓ Maintainable - Clear data flow and state management
✓ Testable - Each method can be tested independently
✓ Performant - Uses efficient storage (SharedPreferences)
