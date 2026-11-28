Name : Muhammad Reyhan Attarizky

NPM : 2506637086

Class : PBP KI

# MyPortfolio Mobile

[![CI](https://github.com/REYHANCSUI25/myportofolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/REYHANCSUI25/myportofolio_mobile/actions/workflows/main.yaml)

The Flutter mobile client for my personal portfolio, the individual project of Platform-Based Programming (CSGE602022), Fasilkom UI, Odd Semester 2026/2027. Its portfolio sections are **Education** and **Experience**, and their forms match the models on my Django website. Both sections read and save their data through the site's Django REST Framework API, logging in with a token, and experience entries can also be deleted from the app.

- Django website: https://muhammad-reyhan53-myportofolio.pws.cs.ui.ac.id
- Django repository: https://github.com/REYHANCSUI25/myportofolio, whose README documents the API the app uses (`/api/v1/education/`, `/api/v1/experience/` and the token endpoints)

## Features

- **Info cards** show my NPM, full name and PBP class. The three cards always share the row equally and match each other's height, even when my name wraps onto several lines.
- **Action buttons** for View Education, Add Education, View Experience, Add Experience and Logout. Each has its own icon and color: blue, green, teal, purple and red, all Material shade 800. White text on each of these colors passes the WCAG AA contrast minimum of 4.5:1, which the plain `Colors.blue`, `Colors.green`, `Colors.teal` and `Colors.red` don't. Add Education and Add Experience ask you to log in first, and Logout logs you out.
- **Tooltips** describe each button when you hover over it, or long-press it on a phone.
- **Snackbar feedback**: pressing View Education, Add Education, View Experience or Add Experience shows "You pressed the [button name] button!" in a floating snackbar with that button's color and icon and a close button. Logout's snackbar says "You've been logged out.", or "You aren't logged in." when nobody is. Pressing another button replaces the message right away.
- **Drawer navigation**: the ☰ button in the app bar opens the same drawer on the home page, both lists and both forms, with Home, View Education, Add Education, View Experience and Add Experience, and below them Login or Logout. The drawer highlights the page you're on, and choosing that page again just closes the drawer.
  - The View Education, Add Education, View Experience and Add Experience buttons on the home page open their pages on top of it with `Navigator.push`.
  - The drawer's page options open their page on top of the home page too, and remove any other page in between (`Navigator.pushAndRemoveUntil` with `(route) => route.isFirst`).
  - Home in the drawer clears the navigation stack (`Navigator.pushAndRemoveUntil` with `(route) => false`), so there's never a second copy of the home page underneath.

  So Back from a page opened from the home page or the drawer returns to the home page, and Back from a details page, or from a form opened with a list's Add button, returns to that list.
- **Education list from the API**: View Education loads the entries from `GET /api/v1/education/` with a `FutureBuilder`, without logging in. It shows a spinner while loading, an error message with a Retry button when the request fails (including "Couldn't reach the server. Check that Django is running." when the server is off), and "No education entries yet." when there are none. Pulling the list down loads it again. Each card shows the degree, institution, period (such as "August 2025 – Present") and the start of the description. The Add button at the bottom right opens the Add Education form, after a login if needed, and the list loads again when you come back, so a new entry appears right away.
- **Education details**: tapping an entry opens its degree, institution, start date, star count and full description, plus the end date if there is one, or an "Ongoing" chip if there isn't.
- **Experience list from the API**: View Experience loads the entries from `GET /api/v1/experience/`, newest first, also without logging in, with the same loading, error-with-Retry, empty ("No experience entries yet.") and pull-to-refresh states and the same Add button. Each card shows the title, the category, "Ongoing" or the end date (such as "Ended Jun 30, 2025") and the start of the description.
- **Experience details**: tapping an entry opens its title, category, an "Ongoing" or "Completed" chip, the date it was added, the end date if there is one, the thumbnail link (or "None") and the full description.
- **Deleting an experience**: the delete button in the details page's app bar asks "Delete this experience?" first, and then sends `DELETE /api/v1/experience/<id>/` with the token, after a login if nobody is logged in. While it's waiting, the button shows a spinner. When the server has deleted the entry, the app says "Experience deleted.", returns to the list and loads it again. If the server refuses, the app shows its reason, such as "Couldn't delete (403): Your role can't perform this action on experience entries.", and the entry stays. Cancel keeps the entry without sending anything.
- **Token login**: Add Education and Add Experience, on the home page, in the drawer and on the lists' Add buttons, open a login page first when nobody is logged in, and then the form; so does deleting an experience. The app exchanges the username and password for a token at `POST /api/v1/auth/token/`, keeps it in memory in `AuthState` (a `ChangeNotifier` shared with `provider`), and sends it as `Authorization: Token <token>`. A wrong password shows the server's reason, "Login failed (400): Unable to log in with provided credentials.". The drawer shows Login while you're logged out and Logout, with your username, while you're logged in. Logout in the drawer or on the home page revokes the token with `POST /api/v1/auth/logout/`, and forgets it even if the server can't be reached. The token is never written to the device, so closing the app logs you out.
- **Add Education form** whose fields match my Django `Education` model: institution, degree, description, a start date and an optional end date, both picked from a calendar. Every field is checked: the required ones can't be left empty, institution and degree are limited to 255 characters, and the end date can't be before the start date. Errors disappear as soon as they're fixed. Save sends the entry to `POST /api/v1/education/` with the token. While it's sending, the button shows a spinner and can't be pressed again. When the server has saved the entry, a dialog shows the values it saved, and closing the dialog clears the form for the next entry. If the token has expired or been revoked (401), the app logs out, asks you to log in again and then sends the entry again. Any other error keeps your input and shows the server's message, such as "Couldn't save (400): Started at: ...".
- **Add Experience form** whose fields match my Django `Experience` model:
  - a title, required and limited to 255 characters
  - a category picked from the model's six choices, defaulting to Full-Time
  - a description, required
  - an optional thumbnail link, which must start with http:// or https:// and is limited to the 200 characters of Django's `URLField`
  - an optional end date picked from a calendar, left empty while the experience is ongoing

  The model sets the start date itself when an entry is created, so the form doesn't ask for it. Save checks every field and sends the entry to `POST /api/v1/experience/` with the token, with the end date as midnight (`YYYY-MM-DDT00:00:00`), the format Django's `DateTimeField` accepts, and an empty thumbnail as `null`. While it's sending, the button shows a spinner and can't be pressed again. When the server has saved the entry, the dialog "Experience added successfully!" shows the values it saved, and closing it clears the form. A 401 logs you out, asks you to log in again and then sends the entry again. Any other error keeps your input and shows the server's message, such as "Couldn't save (400): Title: This field can't contain only HTML tags.".
- **Protection for unsaved input**: on both forms, going Back (including the browser's Back button) or choosing another page in the drawer after typing something asks "Discard this entry?" first, so nothing is lost by accident. While the drawer is open, Back just closes the drawer.
- **Responsive layout**: on wide screens the content stays in a centered column at most 600 px wide, with the five action buttons in rows of three; on phones they're in rows of two. Short screens scroll, and button labels shrink instead of overflowing.
- **Light and dark mode** follow the device's setting. The app bar takes its text color from the theme, so it stays readable in both.
- **CI/CD with GitHub Actions**: every push to `main` and every pull request runs [very_good_workflows](https://github.com/VeryGoodOpenSource/very_good_workflows): it generates the `json_serializable` code with `build_runner`, checks the formatting with `dart format`, runs `flutter analyze` and runs the tests with coverage. When that passes, a second job builds a release APK and uploads it as the `app-release-apk` artifact of the run. Both jobs use Flutter 3.47.9, the version I build with.

## Project Structure

| File | Contents |
| --- | --- |
| `lib/main.dart` | Entry point: `MyApp` shares one `ApiClient` and one `AuthState` with the whole app through `MultiProvider`, and builds the `MaterialApp` with the light and dark themes |
| `lib/config.dart` | `apiBaseUrl`, the address of the Django API: `http://10.0.2.2:8000` by default, which is the computer running the Android emulator, and changed with `--dart-define=API_BASE_URL=...` |
| `lib/screens/menu.dart` | `MyHomePage`: the info cards, the welcome text and the grid of action buttons |
| `lib/screens/education_list.dart` | `EducationListPage`: the education entries loaded from the API, with an Add button |
| `lib/screens/education_detail.dart` | `EducationDetailPage`: the details of one education entry |
| `lib/screens/education_form.dart` | `EducationFormPage`: the Add Education form, which saves through the API |
| `lib/screens/experience_list.dart` | `ExperienceListPage`: the experience entries loaded from the API, with an Add button |
| `lib/screens/experience_detail.dart` | `ExperienceDetailPage`: every field of one experience entry, and the button that deletes it |
| `lib/screens/experience_form.dart` | `ExperienceFormPage`: the Add Experience form, which saves through the API |
| `lib/screens/login.dart` | `LoginPage`: the username and password form |
| `lib/models/education.dart` | `Education`: one education entry, converted from and to the API's JSON by `json_serializable` |
| `lib/models/experience.dart` | `Experience`: one experience entry, converted from and to the API's JSON by `json_serializable` |
| `lib/models/education.g.dart`, `lib/models/experience.g.dart` | Generated by `build_runner` from the two models, and not committed (see below) |
| `lib/models/experience_category.dart` | `ExperienceCategory`: the six experience categories, with the same values and labels as the Django model; `@JsonEnum(valueField: 'value')` makes the JSON use the stored values, such as `part-time` |
| `lib/models/item_homepage.dart` | `ItemHomepage`: the name, icon, color and tooltip of one action button, the page it opens, if any, and whether it needs a login or logs out |
| `lib/services/api_client.dart` | `ApiClient`: the requests to the API (both lists, adding an entry to either section, deleting an experience, token login and logout), `ApiException` for failed requests, and `describeError`, which turns a failure into a readable message |
| `lib/services/auth_state.dart` | `AuthState`: the token and username of whoever is logged in, which notifies the widgets that watch it when either changes |
| `lib/utils/auth_guard.dart` | `ensureLoggedIn` and `loginIfNeeded`: open the login page first when nobody is logged in, and report whether the login succeeded; `requestWithLogin`: sends a request with the token, and when the server answers 401, logs out, asks for a new login and sends it once more |
| `lib/utils/api_dates.dart` | The API's date formats: `YYYY-MM-DD` for Django's `DateField` (the Education dates) and midnight, `YYYY-MM-DDT00:00:00`, for its `DateTimeField` (the Experience end date); reading keeps only the calendar date |
| `lib/utils/snack_bars.dart` | `showSnackBarMessage`: replaces the current snackbar with a plain message |
| `lib/utils/validators.dart` | The validation rules both forms share: required text, optional web links, and the order of two dates |
| `lib/utils/unsaved_changes_guard.dart` | `UnsavedChangesGuard`: a mixin that makes a form ask before its unsaved input is discarded |
| `lib/widgets/info_card.dart` | `InfoCard`: a card with a title and its content |
| `lib/widgets/item_card.dart` | `ItemCard`: a colored action button that shows a snackbar and opens its page when pressed, after a login if the page needs one; the Logout button logs out instead |
| `lib/widgets/left_drawer.dart` | `LeftDrawer`: the navigation drawer with Home, View Education, Add Education, View Experience, Add Experience, and Login or Logout |
| `lib/widgets/load_error_message.dart` | `LoadErrorMessage`: the message and Retry button a list shows when loading fails |
| `lib/widgets/empty_list_message.dart` | `EmptyListMessage`: the message a list shows when it has no entries, which can still be pulled down to refresh |
| `lib/widgets/detail_row.dart` | `DetailRow`: one label and its value on a details page |
| `lib/widgets/date_form_field.dart` | `DateFormField`: a form field that picks a date from a calendar |
| `lib/widgets/form_decoration.dart` | The outlined input style the forms share |
| `.github/workflows/main.yaml` | The GitHub Actions pipeline: checks and tests, then the release APK |
| `test/widget_test.dart` | Widget tests for the home page, the drawer, login and logout, and the Education pages |
| `test/experience_screens_test.dart` | Widget tests for the Experience list, details, deleting and form |
| `test/test_helpers.dart` | What both widget test files share: starting the app with the fake API, a phone-sized screen, the drawer, logging in, and picking a date |
| `test/api_client_test.dart` | Unit tests for the requests `ApiClient` sends and the error messages it produces |
| `test/auth_state_test.dart` | Unit tests for logging in and out with `AuthState` |
| `test/education_test.dart` | Unit tests for the `Education` JSON conversion |
| `test/experience_test.dart` | Unit tests for the `Experience` JSON conversion |
| `test/api_dates_test.dart` | Unit tests for the date formats |
| `test/validators_test.dart` | Unit tests for the validation rules |
| `test/fake_backend.dart` | A fake Django API for the tests, built on `MockClient` from `package:http/testing.dart`, so no test needs a real server |

## Getting Started

You need the Flutter SDK on the stable channel (this app was built with Flutter 3.47.9 and Dart 3.13), Git, and Google Chrome. The Material widgets come from the `material_ui` package (`import 'package:material_ui/material_ui.dart';`), which replaces `package:flutter/material.dart` from Flutter 3.50 onward; `flutter pub get` installs it. The app's data comes from my Django project, so that has to be running too.

1. `git clone https://github.com/REYHANCSUI25/myportofolio_mobile.git`
2. `cd myportofolio_mobile`
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs` generates `lib/models/education.g.dart` and `lib/models/experience.g.dart`, the JSON code for the two models. Generated files are listed in `.gitignore`, so this step is needed after every fresh clone, and again after any change to a model.
5. Start the Django project with `python manage.py runserver` in its own folder (see the [Django repository](https://github.com/REYHANCSUI25/myportofolio); the Experience API was added to it in Assignment 9, so use its latest `main`), so the API is at `http://localhost:8000`. Both lists can be viewed without an account. Adding entries and deleting experiences needs an account with those permissions, such as a superuser made with `python manage.py createsuperuser`.
6. `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000`. While it runs, press `r` in the terminal to hot reload, `R` to hot restart and `q` to quit. On an Android emulator, `flutter run` is enough: the default address, `http://10.0.2.2:8000`, is how the emulator reaches the computer's `localhost`, and my Django settings accept that address outside production.

Chrome only lets the app call the API because the Django project allows cross-origin requests (CORS) when it isn't running in production. The Android app sends plain `http://` requests to the local server, which `android:usesCleartextTraffic="true"` in `AndroidManifest.xml` allows, next to the `INTERNET` permission. That setting is only meant for local development: a build that talks to a deployed `https://` server should turn it off.

Before committing, I run these three checks:

- `dart format lib test` formats the code in the standard Dart style.
- `flutter analyze` should print `No issues found!`.
- `flutter test` should end with `All tests passed!`.

CI runs the same checks on every push to `main` and every pull request.

## Running the Tests

`flutter test` runs 88 tests, and none of them needs Django: they all talk to the fake API in `test/fake_backend.dart`. The 27 widget tests in `test/widget_test.dart` check that:

- the info cards show my NPM, full name and class
- each action button is drawn in its own color
- pressing View Education, Add Education, View Experience or Add Experience shows its snackbar message (one test per button)
- Add Education opens the login page first; a wrong password shows the server's reason, and the right one opens the form
- the login page asks for both fields before sending anything
- the drawer's Add Education also asks for a login first, and once you're logged in, Add Education opens the form straight away
- the drawer shows Login while you're logged out and Logout with your username while you're logged in, and its Logout revokes the token on the server
- the Logout button logs you out, or says you aren't logged in
- View Education lists the entries without a login, with the degree, institution and period
- a failed load shows the server's message, and Retry loads the list again
- the list says when the server can't be reached
- an empty list says there are no entries yet
- pulling the list down loads it again
- tapping an entry opens its details, with the "Ongoing" chip or, for a finished entry, the end date
- saving an empty Education form shows an error for every required field
- saving a valid entry sends exactly the five writable fields with the token, the start date as `YYYY-MM-DD`, and the dialog shows what the server saved
- when the token has expired, Save asks you to log in again and then saves with the new token
- the list's Add button asks for a login, and after saving, Back returns to the list with the new entry loaded
- the drawer highlights the page you're on
- the home page fits a 320 × 568 phone screen without overflowing
- the app switches to its dark theme when the device is in dark mode

The 21 widget tests in `test/experience_screens_test.dart` check that:

- View Experience lists the entries without a login, and sends no token
- the drawer opens the experience list
- an empty list says there are no entries yet
- a failed load offers Retry, which loads the list again
- a finished entry's card says when it ended, and its page shows the category, "Completed", the date it was added, the end date, the thumbnail link and the description
- an ongoing entry's page shows the "Ongoing" chip, no end date, and "None" for a missing thumbnail
- Add Experience asks for a login first, and then opens the form
- the drawer's Add Experience asks for a login too and opens the form above the home screen, so Back returns home
- Home in the drawer takes the form back to the home screen, with nothing left underneath
- saving an invalid entry (a title of only spaces, no description, a broken link) shows an error next to each of those fields
- saving a valid entry sends exactly the five writable fields with the token, the category as `full-time` and the end date as `YYYY-MM-DDT00:00:00`, the dialog shows what the server saved, and OK clears the form
- when the token has expired, Save asks you to log in again and then saves with the new token
- an entry the server rejects shows its reason in a snackbar and keeps the input
- the list's Add button asks for a login, and after saving, Back returns to the list with the new entry loaded
- Delete asks first, then sends `DELETE` with the token, says "Experience deleted." and returns to the reloaded list
- Delete while logged out asks for a login first, and then deletes
- Cancel keeps the entry without asking for a login
- a refused delete (403) shows the server's reason and keeps the entry
- going Back with unsaved input asks before discarding it, and Discard returns to the home screen
- choosing another page in the drawer with unsaved input asks first, and Keep editing keeps the input
- on a 320 × 568 phone with the on-screen keyboard open, the form's Save button can still be reached and pressed

The 40 unit tests check the code below the screens on its own:

- `test/api_client_test.dart` (13): the method, address, headers and body of every request `ApiClient` sends, including that the lists are read without a token and that adding and deleting send it, and the messages it makes from the server's errors (a `detail` message, field errors, an HTML error page, a 404 after a delete, a failed connection)
- `test/auth_state_test.dart` (7): logging in keeps the token and username and notifies listeners, a rejected login leaves you logged out, and logging out revokes the token and forgets it even when the server rejects the request or can't be reached
- `test/education_test.dart` (4): reading an entry from JSON, and sending only the writable fields with dates as `YYYY-MM-DD`
- `test/experience_test.dart` (6): reading an entry from JSON, Full-Time when the category is missing, sending only the five writable fields with a missing thumbnail and end date as `null`, and every category going back and forth as its Django value
- `test/api_dates_test.dart` (4): writing `YYYY-MM-DD` and `YYYY-MM-DDT00:00:00`, reading the date from a date or a timestamp, and passing `null` through
- `test/validators_test.dart` (6): the shared validation rules: blank text, web links, and the order of a start and end date

## Weekly Progress

| Week | Work |
| --- | --- |
| Tutorial 8 | Installed Flutter 3.47.9 and the VS Code Flutter extension, created `myportofolio_mobile`, moved the home screen into `menu.dart`, converted `MyHomePage` into a `StatelessWidget`, built `InfoCard` and `ItemCard` with a snackbar, and checked the code with `flutter analyze` |
| Assignment 7 | My own NPM, name and class on the info cards; View Education, Add Education and Logout buttons in different colors; colored floating snackbars; tooltips; responsive layout; light and dark mode; `ItemHomepage`, `InfoCard` and `ItemCard` moved into `lib/models` and `lib/widgets`; 7 widget tests replacing the template's counter test |
| Tutorial 9 | Switched from `package:flutter/material.dart` to the `material_ui` package; added a navigation drawer (`LeftDrawer`) with Home and Add Education; built the Add Education form (`EducationFormPage`) with validation, calendar date pickers and a dialog that shows the entered data; made the Add Education button open the form; moved the screens into `lib/screens`; 3 more widget tests |
| Assignment 8 | Add Experience form matching my Django `Experience` model (title, category, description, thumbnail link, end date) with validation and a summary dialog; Add Experience action button and drawer option; forms always open above the home page, so Back returns to it, and Home in the drawer clears the navigation stack; the drawer highlights the current page; a "Discard this entry?" check before unsaved input is lost, on both forms; a responsive action grid; validators, input style and the unsaved-input check shared between the forms; 26 tests in all |
| Tutorial 10 | Connected the app to my Django REST Framework API: the `Education` model with `json_serializable` and `build_runner`; `ApiClient` on the `http` package, with readable error messages; the education list (loading, error, empty and pull-to-refresh states) and detail pages; token login with `AuthState` and `provider`; a login guard on Add Education, and Login and Logout in the drawer and on the Logout button; the Add Education form saving to the API with the token and logging in again when the token has expired; Android network permissions and `lib/config.dart` for the API address; a GitHub Actions pipeline with very_good_workflows that also builds a release APK; 60 tests in all. The token endpoints and CORS are in my [Django repository](https://github.com/REYHANCSUI25/myportofolio) |
| Assignment 9 | Connected Experience, the section of my Assignment 8 form, to a new Experience API in my Django project: the `Experience` model with `json_serializable` and `@JsonEnum` for the categories; list and details pages (loading, error, empty and pull-to-refresh states); the Add Experience form behind a login, saving to the API with the token and logging in again on a 401; deleting an entry with the token after a confirmation; View Experience on the home page and in the drawer; Add buttons on both lists that return to a refreshed list; a fix for the Tutorial 10 crash on Retry and pull-to-refresh that had failed CI; `requestWithLogin`, the list and details widgets, the snackbar helper and the date formats shared by both sections; 88 tests in all. The Experience API is in my [Django repository](https://github.com/REYHANCSUI25/myportofolio) |

### Assignment 7

1. In Flutter the whole interface is made of widgets, and every widget's `build` method returns more widgets. The screen therefore ends up as a tree: one root widget at the top, and every other widget nested inside a parent. In my app the root is `MyApp`, which builds a `MaterialApp` whose home is `MyHomePage`. `MyHomePage` builds a `Scaffold` with an `AppBar` and a body. The body is a `SingleChildScrollView` holding a `Center`, then a `ConstrainedBox`, then a `Column`. That `Column` holds the row of three `InfoCard`s, the welcome `Text` and a `GridView` of three `ItemCard`s. Each `ItemCard` is a small tree of its own: a `Tooltip`, then a `Material`, an `InkWell`, a `Padding`, a `LayoutBuilder`, a `FittedBox`, a `SizedBox`, and finally a `Column` holding an `Icon` and a `Text`. Parents and children relate in three ways:
   - **Parents configure their children.** A parent creates its children and passes data in through their constructors. For example, `MyHomePage` gives each `InfoCard` a `title` and `content`, and each `ItemCard` an `ItemHomepage`. Data moves down the tree this way, never up.
   - **Parents decide layout.** Flutter's rule is "constraints go down, sizes go up, the parent sets the position." The `ConstrainedBox` tells its child it can be at most 600 px wide, and the `Row` gives each `Expanded` a third of that width. Each `InfoCard`'s text wraps to fit its third and reports its height back up. `IntrinsicHeight` then makes the whole row as tall as the tallest card, so the three cards match.
   - **Children can read from their ancestors** through `BuildContext`. `Theme.of(context)` in `MyHomePage` and `ScaffoldMessenger.of(context)` in `ItemCard` look up the theme and the snackbar manager that `MaterialApp` placed higher in the tree.

   Some widgets take a single `child`, like `Padding` and `Center`. Others take a list of `children`, like `Row`, `Column` and `GridView`. Behind the widget tree, Flutter keeps an element tree that tracks where each widget sits and a render tree that does the actual layout and painting. That's why widgets themselves can be cheap, immutable descriptions that are rebuilt freely.
2. These are the widgets I used, the first four of which I wrote myself:
   - `MyApp` (mine): the root `StatelessWidget`, which builds the `MaterialApp` with my light and dark themes.
   - `MyHomePage` (mine): the main page, a `StatelessWidget` in `menu.dart`.
   - `InfoCard` (mine): a reusable card that shows a title above its content.
   - `ItemCard` (mine): a reusable action button built from an `ItemHomepage`.
   - `MaterialApp`: sets up Material Design for the whole app (the light and dark themes, which one to use, the app title and the home page).
   - `Scaffold`: the page layout, with a slot for the app bar, the body, and the place where snackbars appear.
   - `AppBar`: the top bar showing "MyPortfolio".
   - `Text`: shows strings: the card titles and my details, the welcome message, the button labels and the snackbar message.
   - `SingleChildScrollView`: lets the body scroll when it's taller than the screen, so nothing overflows on short screens.
   - `Center`: centers the content horizontally on wide screens.
   - `ConstrainedBox`: limits the content to 600 px wide.
   - `Column`: stacks widgets vertically: the page sections, the title and content inside each card, and the icon above each button label.
   - `IntrinsicHeight`: makes the row of info cards as tall as its tallest card, so all three match.
   - `Row`: puts the three info cards side by side, and the icon next to the message inside the snackbar.
   - `Expanded`: gives each info card an equal share of the row's width, and lets the snackbar message take the width left over by the icon.
   - `Card`: the raised Material surface behind each info card.
   - `Padding`: adds space inside the cards and buttons, and above the welcome text.
   - `SizedBox`: fixed gaps between widgets. In `ItemCard` it also sets the label's width to the button's width, so long labels wrap.
   - `GridView.count`: lays the action buttons out in a grid with 3 columns.
   - `Tooltip`: shows a short description when you hover over a button or long-press it.
   - `Material`: paints each button's colored, rounded background and gives `InkWell` a surface to draw its ripple on.
   - `InkWell`: makes the button react to taps with a ripple and runs the code that shows the snackbar.
   - `LayoutBuilder`: tells the button's label how wide the button actually is.
   - `FittedBox`: shrinks the icon and label together when they don't fit inside the button, instead of overflowing.
   - `Icon`: the Material icons on the buttons and in the snackbar.
   - `SnackBar`: the floating message at the bottom of the screen.

   I also use two widgets that `MaterialApp` creates for me, through `.of(context)`. `Theme` supplies the colors for the app bar, and `ScaffoldMessenger` shows and hides the snackbars.
3. `MaterialApp` wraps everything a Material Design app needs, and in my app it does several jobs:
   - **Theming.** It holds my `theme` and `darkTheme`, both generated from an indigo seed color with `ColorScheme.fromSeed`, picks one of them with `themeMode: ThemeMode.system`, and provides the chosen theme to every widget below it.
   - **Navigation.** It sets up a `Navigator` and shows `home: const MyHomePage()` as the first page, which later tutorials will use to move between pages. The navigator also provides the `Overlay` that tooltips are drawn on.
   - **Snackbars.** It provides the `ScaffoldMessenger` that my `ItemCard` uses to show them.
   - **Text and title.** It sets the text direction and the default Material text (such as the snackbar close button's tooltip), and its `title` becomes the browser tab's title on the web.

   It's used as the root because all of this is looked up by widgets further down the tree. `ScaffoldMessenger.of(context)` and `Tooltip` only work when a `MaterialApp` (or the same widgets added by hand) is above them, and Material widgets like `AppBar`, `Card` and `InkWell` rely on the theme and localizations it provides. With it at the very top, every page of the app shares one theme and one navigation stack. An iOS-style app would use `CupertinoApp` instead, and `WidgetsApp` is the bare version without Material.
4. A `StatelessWidget` has no state of its own: its fields are final, and everything it shows comes from its constructor arguments and from what it reads from its ancestors, such as the theme. It's rebuilt only when its parent gives it new arguments or something it reads changes. A `StatefulWidget` comes with a separate `State` object that survives rebuilds and holds data that changes while the app runs. Calling `setState` tells Flutter to run `build` again with the new data. It also gets lifecycle methods such as `initState` and `dispose` for setting things up and cleaning up.

   Every widget I wrote is a `StatelessWidget`. My NPM, name, class and list of buttons never change while the app runs, so `MyHomePage`, `InfoCard` and `ItemCard` don't need to remember anything. Even the parts that do change don't need state of mine. The `ScaffoldMessenger` that `MaterialApp` provides keeps track of the snackbars, and `MaterialApp` itself switches between light and dark mode when the device setting changes. All their fields are final, so each of them also has a `const` constructor, which lets Flutter reuse the same widget instances instead of creating new ones.

   A `StatefulWidget` becomes necessary when a widget has to remember something that changes because of the user or over time. Examples include the counter in the template app (`_counter` plus `setState`), a form field with a `TextEditingController`, an animation driven by an `AnimationController`, or data that arrives later. The Education entries this app will load from my Django API in upcoming tutorials are that last kind: the page will need a loading state, and then the data.
5. `BuildContext` is a handle to one widget's position in the tree; under the hood it is that widget's `Element`. Every `build(BuildContext context)` method receives the context of its own widget. It matters because it's how a widget finds what its ancestors provide: calls like `Theme.of(context)` start at that position and walk up the tree to the nearest match. My code uses it in two places:
   - **`MyHomePage.build`** uses `Theme.of(context).colorScheme` to color the app bar with the theme's `primary` and `onPrimary` colors, so it adapts to light and dark mode automatically.
   - **`ItemCard`'s tap handler** receives the card's own `context` and calls `ScaffoldMessenger.of(context)` to show the snackbar. This works because the card sits below `MaterialApp`, which provides the `ScaffoldMessenger`, and below the `Scaffold` the snackbar appears in.

   The position is the whole point. The context passed to `MyApp.build` is above `MaterialApp`, so `ScaffoldMessenger.of` called with it throws an error because there is no messenger above it, and `Theme.of` with it returns Flutter's fallback theme instead of mine. `LayoutBuilder` also gives its builder the constraints from its parent along with a context, which `ItemCard` uses to read the button's width. Two practical rules follow:
   - Use the context of a widget that sits below whatever you're looking up.
   - Don't keep using a context after an `await` without checking that the widget is still mounted. The `use_build_context_synchronously` lint checks for this.
6. Hot reload (pressing `r` in the terminal running `flutter run`, or saving a file in VS Code when the app was started from VS Code's debugger) puts the changed code into the running app and rebuilds the widget tree, but keeps the app's state. It usually takes less than a second, so I can change a color or some padding and see it immediately without losing my place; the template's counter, for example, keeps its value. Hot restart (`R`) also loads the new code, but throws the state away and starts the app again from `main()`, which takes a little longer. A full restart means stopping the app and running `flutter run` again, which rebuilds everything, including the native or web host. Hot reload can't be relied on in these cases:
   - **Static fields and global variables.** These count as state, so their initializers aren't run again. My action buttons live in `static final List<ItemHomepage> items`. Once the page has read that list, changing a button's name or color there needs a hot restart. The exception is `static const` values like my `npm`: Flutter treats constants as aliases, so it picks up their new values on a hot reload.
   - **Code that only runs once**, like `main()` or a `State`'s `initState`, isn't run again by a hot reload.
   - **Changed declarations.** Turning a widget from a `StatelessWidget` into a `StatefulWidget` (or back), turning an enum into a class (or back), or changing generic type declarations all need a hot restart.
   - **Changes outside the Dart code**, like adding packages or assets in `pubspec.yaml`, or editing native Android or iOS code or `web/index.html`, need a full restart.

   Hot reload also refuses to apply while the code has a compile error.

**What was implemented**

1. Setup: the project continues from Tutorial 8 in the same public repository. `MyHomePage` is a `StatelessWidget` in `lib/menu.dart`, separate from `lib/main.dart`. The `ItemHomepage` model now lives in `lib/models/item_homepage.dart`, and `InfoCard` and `ItemCard` in `lib/widgets/`, so `menu.dart` only describes the page.
2. Info cards: my NPM, full name and class come from three `static const` fields on `MyHomePage`. The tutorial gave each card a fixed width (the window width divided by 3.5). Here each card is wrapped in `Expanded` instead, so the three always share the row exactly, and `IntrinsicHeight` keeps them the same height.
3. Action buttons: `ItemHomepage` has `name`, `icon`, `color` and `tooltip` fields, set through named parameters of a `const` constructor. The buttons are:
   - View Education: school icon, `Colors.blue.shade800`
   - Add Education: add_circle icon, `Colors.green.shade800`
   - Logout: logout icon, `Colors.red.shade800`

   `ItemCard` passes `item.color` straight to its `Material`, so there are no if-else chains.
4. Snackbar: `ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(...)` shows "You pressed the [name] button!" floating at the bottom, in the button's color, with its icon and a close button.
5. Extras beyond the checklist:
   - tooltips on the buttons
   - the responsive layout: a maximum width of 600 px, scrolling, and labels that shrink with `FittedBox` instead of overflowing
   - light and dark themes with `ThemeMode.system`
   - button colors that pass WCAG AA contrast
   - 7 widget tests replacing the template's counter test, which no longer matched the app
6. Code quality:
   - Every widget has a `const` constructor, so `MaterialApp` gets `const MyHomePage()` and Flutter can reuse widget instances.
   - The action list is `static final`, so it's built once instead of every time `MyHomePage` is created.
   - Both themes come from one `_buildTheme` helper.
   - `flutter analyze` reports no issues, and `dart format` keeps the formatting standard.
7. Git: the work was done on the `feature/portfolio-home` branch with conventional commits, pushed after every commit, and merged into `main` with a merge commit.

Claude was used for me to learn or discover the following:
1. Why the tutorial's card width (`MediaQuery.of(context).size.width / 3.5`) breaks once the content is limited to 600 px: it measures the whole window, not the space the parent actually gives. Also, how `Expanded` plus `IntrinsicHeight` fixes that.
2. Flutter's layout rule ("constraints go down, sizes go up"), and combining `LayoutBuilder` with `FittedBox(fit: BoxFit.scaleDown)` so a button's content shrinks instead of overflowing.
3. That `Colors.blue.shade800` isn't a compile-time constant because it's a getter, so the action list can't be `const`. Making it `static final` still builds it only once and keeps `MyHomePage`'s constructor `const`.
4. Supporting dark mode with `darkTheme` and `ThemeMode.system`, and coloring the app bar with `onPrimary` instead of a hardcoded white so it stays readable in both themes.
5. Checking color contrast against WCAG AA (4.5:1 for normal text), which ruled out the plain `Colors.blue`, `Colors.green` and `Colors.red`.
6. Writing widget tests with `flutter_test`: finders like `find.widgetWithText` and `find.descendant`, simulating a small phone with `tester.view`, and simulating dark mode with `platformBrightnessTestValue`.
7. That hot reload doesn't re-run static initializers, but does pick up changes to `const` values.

### Assignment 8

1. `Navigator` keeps the app's pages (routes) in a stack, and the route on top is the one on screen.
   - **`Navigator.push()`** puts a new route on top of the current one. The page you came from stays underneath, so Back returns to it.
   - **`Navigator.pushReplacement()`** puts a new route on top and removes the current one. The routes further down stay, but the page you came from is gone, so Back skips it, and if nothing is left underneath, Back leaves the app.
   - **`Navigator.pop()`** removes the top route and shows the one underneath. The system Back button and the browser's Back button do this, and my code also calls it to close the drawer and the dialogs.

   The action card opens the form with `Navigator.push()`: `ItemCard._openDestination` calls `Navigator.push(context, MaterialPageRoute(builder: destination))` with the page stored in the button's `ItemHomepage`. The home page stays under the form, so Back returns to it.

   The drawer's Home option calls `Navigator.pushAndRemoveUntil()` with the predicate `(route) => false`. It pushes a new `MyHomePage` and removes every route below it, so the stack holds only the home page again. Tutorial 9 used `pushReplacement()` here, but when a form has been opened from the action card, the stack is home → form, and replacing the form with a new home page leaves home → home, so Back on the home page would show a second copy of it.

   The drawer's two form options also use `pushAndRemoveUntil()`, with `(route) => route.isFirst`: they open the form on top of the home page and remove any other form in between. With `pushReplacement()`, choosing a form from the home page's drawer would replace the home page, leaving the form alone on the stack, so Back would leave the app. Because the home page always stays at the bottom, Back from any form returns home. Before leaving a form with unsaved input, both Back and the drawer ask "Discard this entry?", and choosing the page you're already on only closes the drawer.
2. Every page is built from the same three parts: a `Scaffold` as the page frame, an `AppBar` in its `appBar` slot and my `LeftDrawer` in its `drawer` slot. The `Scaffold` positions them the same way on every page: the title bar at the top, the ☰ button that the `AppBar` adds for the drawer in its corner, and the drawer sliding in from the left. All three pages use the same `LeftDrawer` class, so its header and options never change; each page only tells it which page is current (`currentPage`), so it can highlight that option, and the forms also give it `confirmLeave`, so it can ask before discarding input. Only the body is different on each page.

   The colors come from one theme. `MyApp` in `main.dart` builds the light and dark themes from `ColorScheme.fromSeed(seedColor: Colors.indigo)`, and every page reads them with `Theme.of(context).colorScheme` instead of hardcoding them. For example, `colorScheme.primary` is the background of the app bar on the home page, the Add Education form and the Add Experience form, as well as the drawer header, and the text on all of them uses `colorScheme.onPrimary`. Because of this, all the pages switch between light and dark mode together.
3. A form is read from top to bottom, so both form pages use a single `Column` with one field per row and the Save button at the end, where you finish. The other widgets handle the cases where space runs out:
   - **`SingleChildScrollView`** makes the form scroll when it's taller than the screen. On a short phone, or when the on-screen keyboard covers the bottom of the screen, every field and the Save button can still be scrolled into view instead of overflowing. The `Scaffold` shrinks the body to the space above the keyboard (`resizeToAvoidBottomInset` is on by default), and a text field that gets focus is scrolled into view automatically.
   - **`Center` and `ConstrainedBox(maxWidth: 600)`** stop the fields from stretching across a wide browser window. On a phone, the column simply takes the full width.
   - **`Padding`** puts 8 px around the scroll area and around each field, so the fields don't touch each other or the edge of the screen, and the helper and error texts under each field have room.
   - **`Align`** keeps the Save button centered under the fields.

   The single-line text fields also use `textInputAction: TextInputAction.next`, so the keyboard's action button moves on to the next field. A widget test checks that the Save button can still be reached and pressed on a 320 × 568 phone with the keyboard taking up 260 px of it.
4. When I press Save, `_save()` runs:
   - **`GlobalKey<FormState>`**: `_formKey` is attached to the `Form`, which lets `_save()` reach the form's state through `_formKey.currentState`. `_save()` runs in the page's `State`, whose `context` sits above the `Form`, so `Form.of(context)` couldn't find it there. The form's state keeps track of every field inside the form.
   - **`validator`**: each field has one. It receives the field's current value and returns an error message, or `null` if the value is fine. The rules follow my Django model, and the ones both forms use live in `lib/utils/validators.dart`, which has its own unit tests.
   - **`validate()`**: calling it on the form state runs every field's `validator`, shows each returned message under its field, and returns `true` only if all of them returned `null`. If it returns `false`, `_save()` stops there, so the dialog never shows invalid data. After a failed Save, `AutovalidateMode.onUserInteractionIfError` makes the form check its fields again every time one of them is edited, so each error disappears as soon as its value is fixed.

   Only when `validate()` returns `true` does `_save()` call `save()`, which runs each field's `onSaved` to copy its value into the page's state, and then `showDialog()` shows the summary.

   For example, the Thumbnail URL field rejects `example.com` with "Enter a valid link that starts with http:// or https://.". That field uses `keyboardType: TextInputType.url`, but a keyboard type only decides which on-screen keyboard appears, one laid out for typing web addresses. Nothing stops anyone from typing or pasting any text, and on a computer's keyboard it has no effect at all. The input widget doesn't check values either: a `TextFormField` accepts any text, so a title made only of spaces looks filled in, and only `validateRequired`, which trims the value first, rejects it. Some widgets do rule out bad values: `maxLength: 255` stops typing at the limit, and the category dropdown only offers the six choices from the model. But a rule like "a link that starts with http:// or https://" can only be checked by a validator.

**What was implemented**

1. New form page: `ExperienceFormPage` in `lib/screens/experience_form.dart` is a `StatefulWidget` with a `Form` and a `GlobalKey<FormState>`. The title is "Add Experience Form", and the five inputs match my Django `Experience` model:
   - Title: a `TextFormField`, required and limited to 255 characters (`max_length=255`).
   - Category: a `DropdownButtonFormField` with the model's six choices, defaulting to Full-Time. The choices are the `ExperienceCategory` enum in `lib/models/experience_category.dart`, which stores the same values Django stores (such as `part-time`) together with their labels.
   - Description: a multi-line `TextFormField`, required.
   - Thumbnail URL: a `TextFormField` with the URL keyboard. It's optional (`blank=True`), limited to 200 characters (Django's default `max_length` for a `URLField`), and must be an http:// or https:// link with a domain.
   - End date: a calendar picker (`showDatePicker()`, wrapped in my `DateFormField`), optional and clearable, since `ended_at` can be empty while an experience is ongoing.

   The model fills in `started_at` itself (`auto_now_add=True`), so the form doesn't ask for it.
2. Validation and summary: Save calls `validate()`, and each invalid input shows its error under the field. Values made only of spaces are rejected. When everything is valid, an `AlertDialog` opened with `showDialog()` lists all five values, and OK closes it and returns to the form, which is then cleared.
3. Navigation: the new Add Experience action card opens the form with `Navigator.push()`, and the system or browser Back button returns to the home page. The same `LeftDrawer` is used on the home page and both forms, with the Home and Add Education options kept and Add Experience added. Home in the drawer returns to the home screen from either form.
4. Layout: the form uses a `Scaffold` and an `AppBar` with the same theme colors as the home page, and the `SingleChildScrollView`, `Center`, `ConstrainedBox` and `Padding` layout described in answer 3.
5. Extras beyond the checklist:
   - the "Discard this entry?" check before unsaved input is lost, on both forms, for Back, the browser's Back button and the drawer
   - forms always open above the home page, so Back from any form returns home, and Home in the drawer leaves no extra copies of the home page
   - the drawer highlights the current page, and choosing it again just closes the drawer
   - a responsive action grid: four buttons in a row on wide screens and a 2 × 2 grid on phones, with the new button in purple (`Colors.purple.shade800`), which also passes the WCAG AA contrast minimum with white text
   - code shared by both forms: the validators, the outlined input style (`lib/widgets/form_decoration.dart`) and the unsaved-input check (the `UnsavedChangesGuard` mixin in `lib/utils/unsaved_changes_guard.dart`)
   - 26 tests: 20 widget tests (10 more than in Tutorial 9, and some updated) and 6 unit tests for the validators
6. Code quality: the screens are in `lib/screens/`, the drawer, action card and form widgets in `lib/widgets/`, the data classes in `lib/models/`, and the validators and the unsaved-input mixin in `lib/utils/`. `flutter analyze` reports no issues, and `dart format` keeps the formatting standard.
7. Git: the work was done on the `feature/experience-form` branch with conventional commits, pushed after every commit, and merged into `main` with a merge commit.

Claude was used for me to learn or discover the following:
1. How `push`, `pushReplacement` and `pushAndRemoveUntil` change the navigation stack, and why using `pushReplacement` for Home leaves two home pages when the form was opened with `push`.
2. That popping the last route leaves the `Navigator` empty, which shows a blank screen (or an error while debugging). That's why the drawer opens forms above the home page instead of replacing it.
3. Asking before unsaved input is lost with `Form`'s `canPop` and `onPopInvokedWithResult`, which replaced its deprecated `onWillPop`, and that while the drawer is open, Back should close the drawer instead of asking.
4. Sharing that behavior between the two forms' `State` classes with a mixin (`mixin UnsavedChangesGuard<T extends StatefulWidget> on State<T>`).
5. Keeping a `NavigatorState` from before an `await`, because the drawer's own `BuildContext` stops being valid once the drawer has closed.
6. That a `DropdownButtonFormField` without `onChanged` is disabled unless it gets `enabled: true`, and that `initialValue` replaces its deprecated `value`.
7. That a keyboard type such as `TextInputType.url` only changes the on-screen keyboard, so links still need a validator (`Uri.tryParse` plus checks on the scheme and the host).
8. Carrying the Django model's rules over to Flutter: `max_length` as `maxLength`, the 200-character default of `URLField`, and the `choices` list as an enhanced enum that keeps both the stored value and the label.
9. Testing forms: unit tests for plain functions with `test()` and `group()`, filling in fields with `tester.enterText` and `find.widgetWithText(TextFormField, ...)`, and imitating an open keyboard with `tester.view.viewInsets`.

### Assignment 9

1. A model class gives the API's JSON one definition that the compiler checks. My pages work with `Experience` objects whose fields have types: `title` is a `String`, `category` an `ExperienceCategory` and `endedAt` a `DateTime?`, so a mistyped field name or a value used as the wrong type stops the app from compiling. With a raw `Map<String, dynamic>`, every page would read and write string keys like `entry['ended_at']` and get back `dynamic`, so the same mistakes would only show up while the app runs, on one screen, or not at all. The annotations also write the conversion for me:
   - **`@JsonSerializable(fieldRename: FieldRename.snake)`** makes `build_runner` generate `_$ExperienceFromJson` and `_$ExperienceToJson` in `experience.g.dart`, turning each camelCase field name into Django's snake_case key: `startedAt` becomes `started_at`, and `endedAt` becomes `ended_at`. The keys come from the field names, so none of them is typed by hand, and a field I add to the class is part of the JSON the next time the code is generated.
   - **`@JsonKey(includeToJson: false)`** on `id` and `startedAt` leaves them out of `toJson()`, while `fromJson()` still reads them for the list and details pages. Django sets both itself when it saves an entry (a UUID and `auto_now_add`), so the `POST` body holds exactly the five fields the form fills in: `title`, `category`, `description`, `thumbnail` and `ended_at`.
   - **Defaults and enum values** follow the Django model. The constructor's `this.category = ExperienceCategory.fullTime` is used when the key is missing, like the model's `default="full-time"`, and `thumbnail` and `endedAt` are nullable, like `blank=True, null=True`. `@JsonEnum(valueField: 'value')` on `ExperienceCategory` sends each category as the value Django stores, such as `part-time`, instead of the Dart name `partTime`, which Django rejects with `"partTime" is not a valid choice.`.

   The bug this prevents in my Experience model is a silent one. DRF ignores keys it doesn't know, and `ended_at` is optional. If the form built the body by hand with the Dart name, `"endedAt": "2025-06-30T00:00:00"`, Django would answer 201 and save the entry without an end date, so a finished internship would show as "Ongoing" in the app and on the website, with no error anywhere to point at the mistake. Sending that body to my Django API really does return 201 with `"ended_at": null` and `"is_ongoing": true`. Reading has the same trap, since `json['endedAt']` is always `null`, so every entry would look ongoing. With the generated code, the key is always `ended_at`, and the tests check both directions: `test/experience_test.dart` checks the exact keys `toJson()` writes and what `fromJson()` reads, and a widget test checks the form's `POST` body.
2. Flutter can call `build()` many times while a page is open: when its parent rebuilds, when something it depends on changes (the theme, or the screen size when I resize the Chrome window or rotate the phone), and after every `setState`. If `build()` called `api.getExperienceList()`, every rebuild would send another `GET` to Django and give `FutureBuilder` a different `Future`. `FutureBuilder` then stops listening to the old one and waits for the new one, so resizing the window would send a stream of requests, and if the page kept rebuilding faster than Django answered, every answer would be ignored and the spinner would never go away. The page's `State` object, on the other hand, survives rebuilds, and `initState()` runs only once, when the page is created. So `_ExperienceListPageState` sends the request there and keeps the `Future` in `_entries`, and every rebuild gives `FutureBuilder` that same `Future`, whose result it already has. A new request only happens when I ask for one: `_reload()`, which pull-to-refresh, Retry, and coming back from the form or from a delete all use, creates a new `Future` and assigns it inside `setState`. That `setState` callback needs a block body, `setState(() { _entries = entries; })`. The arrow form, `setState(() => _entries = entries)`, returns the assigned `Future`, and Flutter rejects that in debug mode, which is exactly what failed Tutorial 10's CI (see the AI disclosure below).

   `ApiClient` throws an `ApiException` instead of returning `null`, because `null` throws away the reason for the failure:
   - **Different failures need different reactions.** A 401 means the token expired, a 403 that my role isn't allowed, a 400 that a field is invalid, and a 500 that the server broke. `ApiException` carries the status code and the server's message, so `requestWithLogin` catches only the 401 and asks for a new login, while the forms show the others, such as "Couldn't save (400): Title: This field can't contain only HTML tags.". A `null` would look the same in all four cases.
   - **`null` would look like success.** If `getExperienceList()` returned `null` when Django answered 500, `FutureBuilder` would finish without an error, and my page would say "No experience entries yet." while the server was actually broken. Because the `Future` fails instead, `snapshot.hasError` is true, and the page shows the error with its Retry button.
   - **An exception can't be forgotten.** Every caller of a method that may return `null` has to remember to check, and forgetting passes the `null` on until something crashes somewhere else. An exception travels up until code that knows what to do with it catches it, and the methods keep plain types like `Future<List<Experience>>` instead of `Future<List<Experience>?>`.
3. Both tell DRF who is making a request, but they carry that identity in different ways:
   - **`SessionAuthentication`** uses Django's login session from Tutorial 4, which my API has accepted since Tutorial 7. Logging in on the website saves a session on the server and gives the browser its id in the `sessionid` cookie, which the browser then attaches by itself to every request to my site, including requests that another site makes it send. That's why DRF checks a CSRF token on every unsafe request it authenticates this way: my Education page sends the `X-CSRFToken` header with the token from the `csrftoken` cookie (Assignment 6). Logging out ends the session.
   - **`TokenAuthentication`** uses a key instead of a cookie. The app sends the username and password once to `POST /api/v1/auth/token/`, Django returns that user's token (a random 40-character key stored in the `authtoken_token` table), and the app adds `Authorization: Token <key>` to each request that needs it. Nothing attaches that header automatically, so another site can't send a request with it, and DRF doesn't check CSRF on token requests: my Django test `test_owner_can_create_with_a_token_and_no_csrf_token` creates an entry through a client that enforces CSRF, without any CSRF token. A token stays valid until it's deleted, which my logout endpoint does, and so does deleting it in Django Admin.

   The mobile app uses tokens because it isn't a page served by my Django site. On Android, the `http` package doesn't keep cookies, so the app would have to read `Set-Cookie` itself, store `sessionid` and `csrftoken`, and send the CSRF header with every change. In Chrome, the app runs on a different origin from Django (`localhost` on another port), so the browser would only send the session cookie with credentialed CORS requests, which both the app and Django would have to allow. A token is just a header, so the same `ApiClient` code works on both. The order of the classes matters too: `TokenAuthentication` is the first of my `DEFAULT_AUTHENTICATION_CLASSES`, so DRF answers a missing or revoked token with 401 and a `WWW-Authenticate: Token` header. If `SessionAuthentication` came first, the answer would be 403, and the app couldn't tell "log in again" apart from "your role isn't allowed".

   `SessionAuthentication` stays enabled because the website still uses it. My Education page calls the same `/api/v1/education/` endpoints with `fetch()`, logged in through the session cookie, and DRF's browsable API pages, such as `/api/v1/education/` opened in a browser, use the session too. DRF tries the classes in order on every request: one with a token header is authenticated by the token, and one with a session cookie by the session, with its CSRF check. The permission classes only look at `request.user`, so the owner, an Editor, a regular user and a visitor get the same rules on the website and in the app, from one API instead of two.
4. `.github/workflows/main.yaml` runs on every push to `main` and every pull request, with two jobs:
   - **`build`** doesn't list its own steps: it calls very_good_workflows' reusable workflow, `flutter_package.yml@v2`, and passes it my inputs (Flutter 3.47.9, a setup command, the coverage settings and a 15-minute timeout). On a fresh Ubuntu runner, that workflow:
     1. checks out the repository and installs Flutter 3.47.9 with `subosito/flutter-action`
     2. installs Very Good CLI and runs `very_good packages get --recursive`, the `pub get` for every package in the repository
     3. runs my `setup` input: `dart run build_runner build --delete-conflicting-outputs` generates `education.g.dart` and `experience.g.dart`, and `dart format` formats just those files, so the next step doesn't fail on code I didn't write
     4. runs `dart format --set-exit-if-changed lib test`, which fails if any file isn't formatted
     5. runs `flutter analyze lib test`, which fails on any error, warning or lint from `flutter_lints`, since `flutter analyze` treats all three as failures by default
     6. runs `very_good test -j 4 --optimization --coverage --min-coverage 0 --exclude-coverage "**/*.g.dart" --report-on "lib" --show-uncovered --test-randomize-ordering-seed random`. `--optimization` imports every `*_test.dart` file into one generated file, so all 88 tests run in one process, which is faster, and the random order makes sure no test passes only because another one ran first. Coverage is measured on `lib` without the generated files, and with `min_coverage: 0` it's reported but never fails the job.
   - **`build_apk`** has `needs: build`, so it only starts after every check has passed. It installs the same Flutter version, runs `flutter pub get` and `build_runner` again, builds the app with `flutter build apk --release`, and uploads `build/app/outputs/flutter-apk/app-release.apk` as the `app-release-apk` artifact, which can be downloaded from the run's page on GitHub. `if-no-files-found: error` fails the job if no APK came out, instead of quietly uploading nothing.

   So `build` decides whether the code is right, and `build_apk` proves that the app can actually be built for release and hands over the result. `concurrency` cancels an older run on the same branch when I push again, and the badge at the top of this README shows the result of the latest run on `main`.

   The `*.g.dart` files are generated entirely from `education.dart` and `experience.dart`, so committing them would keep two copies of the same information that can drift apart. If I added an optional field to a model and forgot to run `build_runner`, the committed `.g.dart` would still compile but leave the new field out of the JSON, and CI would test that stale code without noticing. Generated files also clutter diffs, cause merge conflicts and change with every `json_serializable` version. CI needs them to compile the app, so it generates them from the committed models instead, in both jobs, because each job starts on a fresh runner with nothing left over from the other. That way, what CI analyzes, tests and builds always matches the models. `.gitignore` keeps the files out of commits, and `analysis_options.yaml` excludes them from `flutter analyze`, since lints in generated code aren't mine to fix. On my laptop, I run the same `build_runner` command after cloning (step 4 of Getting Started).

**What was implemented**

My Assignment 6 API is for Education, but my Assignment 8 form is for Experience, so no section matched both. Education was already connected in Tutorial 10, so this assignment connects Experience, the section of my Assignment 8 form, and starts by adding its API to Django.

1. Backend: `/api/v1/experience/` in my Django project, documented in its README. Listing the entries (newest first) and reading one are public. Adding (`POST`) and deleting (`DELETE`) need the `main.add_experience` and `main.delete_experience` permissions, which only my owner account has, and work with a token or a session. HTML is stripped from the title and description, as on Education, entries can't be edited through the API (405), and 12 new Django tests cover it.
2. JSON model: `Experience` in `lib/models/experience.dart` uses `@JsonSerializable(fieldRename: FieldRename.snake)`, with `@JsonKey(includeToJson: false)` on `id` and `startedAt`, which the server sets, Full-Time as the default category, and a nullable thumbnail and end date. `experience.g.dart` is generated with `build_runner`, kept out of Git by the `*.g.dart` line in `.gitignore`, and excluded in `analysis_options.yaml`. The date formats both models use moved into `lib/utils/api_dates.dart`.
3. `ApiClient`: `getExperienceList()` sends the public `GET /api/v1/experience/` without a token, `createExperience()` the authenticated `POST` with `Authorization: Token <key>`, and `deleteExperience()` the authenticated `DELETE`. The Education and Experience methods share the private helpers for reading a list, adding an entry and building the headers.
4. List page: `ExperienceListPage` creates its `Future` in `initState()` and shows it with a `FutureBuilder` inside a `RefreshIndicator`, with a loading state, an error state with a Retry button, and an empty state. It opens from the home page's new View Experience button and the drawer's new View Experience option.
5. Details page: tapping an entry opens `ExperienceDetailPage`, which shows every field.
6. Authenticated form: the Add Experience form from Assignment 8 now needs a login before it opens, from the home page, the drawer and the list's Add button (`ensureLoggedIn` and `loginIfNeeded`). Save posts the entry with the token from `AuthState`. A 401 clears the session, opens the login page and sends the entry again after the login; any other `ApiException`, or a failed connection, shows a snackbar and keeps the input. After a successful save, a dialog shows what the server saved. When the form was opened with the list's Add button, Back returns to the list, which loads again so the new entry appears, and pulling the list down refreshes it too.
7. CI/CD: the Tutorial 10 workflow checks this assignment's pull request and `main`, each run builds the `app-release-apk` artifact, and the CI badge is at the top of this README. Tutorial 10's own runs failed two widget tests because of a `setState` mistake in the education list; the first commit of this assignment fixes it, so CI passes again.
8. Extras beyond the checklist:
   - deleting an experience with an authenticated `DELETE`, after a confirmation dialog and with the same 401 handling as saving, followed by a reload of the list
   - an Add button on the Education list too, which also returns to a refreshed list
   - `requestWithLogin` in `lib/utils/auth_guard.dart`: one function for "send with the token, and on a 401 log out, log in again and try once more", used by both forms and by Delete; in Tutorial 10, this logic was written into the Education form
   - widgets and helpers the two sections share: `LoadErrorMessage`, `EmptyListMessage`, `DetailRow` and `showSnackBarMessage`
   - 88 tests, 28 more than in Tutorial 10: `MockClient` unit tests for the three new `ApiClient` methods, JSON tests for `Experience` and the date formats, and 21 widget tests for the Experience pages, which share their helpers with the Education tests through `test/test_helpers.dart`
9. Code quality: `dart format --output=none --set-exit-if-changed lib test` changes nothing, and `flutter analyze` reports no issues.
10. Git: the Django work was done on the `feature/experience-api` branch and the app on `feature/experience-integration`, both with conventional commits, and each was merged into `main` with a merge commit, the app only after CI had passed on its pull request. The app's branch starts with a separate `fix:` commit for the Tutorial 10 bug, so the fix is easy to find in the history.

Claude was used for me to learn or discover the following:
1. That DRF ignores keys it doesn't know, so a hand-written `endedAt` key would save a finished experience as ongoing with a 201 and no error, and that `fieldRename: FieldRename.snake` rules this out by deriving every key from the field names.
2. Making `json_serializable` write an enhanced enum as its Django value with `@JsonEnum(valueField: 'value')`, and that a constructor default such as `this.category = ExperienceCategory.fullTime` becomes the value `fromJson()` uses when the key is missing.
3. How Django's `DateField` and `DateTimeField` differ in JSON (`2025-06-30` against `2025-06-30T00:00:00Z`), that a time sent without a time zone is read in the server's `TIME_ZONE` (UTC in my settings), and reading back only the calendar date, so the dates don't depend on the device's time zone.
4. Why a `Future` kept in the `State` survives rebuilds while one created in `build()` sends a request on every rebuild, and reloading by assigning a new `Future` inside `setState`.
5. That DRF answers a missing or revoked token with 401 only when `TokenAuthentication` is the first authentication class, which is what lets the app tell "log in again" (401) apart from "not allowed" (403).
6. Passing the request itself as a callback (`Future<T> Function(String token)`), so one function, `requestWithLogin`, can repeat any request after a new login.
7. Building a fake API with `MockClient` that keeps state between requests (issued tokens, saved entries), and checking the exact headers and JSON body the app sends.
8. What very_good_workflows runs under the hood, including `very_good test --optimization` and the random test order, and that each GitHub Actions job starts on a fresh runner, so `build_apk` has to run `build_runner` again.
9. Mapping each HTTP method to a per-model Django permission (`main.<action>_<model>`) in one base class, so the Experience permissions stay separate from the Education ones.
10. That since `build_runner` 2.7, conflicting outputs are always deleted, so `--delete-conflicting-outputs` is ignored, and since 2.15 it prints a warning saying so. The command from the assignment still works, and CI's setup step runs it the same way.
11. That an arrow function returns the value of its expression, so `setState(() => _entries = entries)` hands the new `Future` back to `setState`, which throws "setState() callback argument returned a Future" in debug mode, and reading a failed CI log to find which test broke and why.
