Name : Muhammad Reyhan Attarizky

NPM : 2506637086

Class : PBP KI

# MyPortfolio Mobile

The Flutter mobile client for my personal portfolio, the individual project of Platform-Based Programming (CSGE602022), Fasilkom UI, Odd Semester 2026/2027. Its portfolio sections are **Education** and **Experience**, and their forms match the models on my Django website. In later tutorials this app will load its data from the site's Django REST Framework API.

- Django website: https://muhammad-reyhan53-myportofolio.pws.cs.ui.ac.id
- Django repository: https://github.com/REYHANCSUI25/myportofolio

## Features

- **Info cards** show my NPM, full name and PBP class. The three cards always share the row equally and match each other's height, even when my name wraps onto several lines.
- **Action buttons** for View Education, Add Education, Add Experience and Logout. Each has its own icon and color: blue, green, purple and red, all Material shade 800. White text on each of these colors passes the WCAG AA contrast minimum of 4.5:1, which the plain `Colors.blue`, `Colors.green` and `Colors.red` don't.
- **Tooltips** describe each button when you hover over it, or long-press it on a phone.
- **Snackbar feedback**: pressing a button shows "You pressed the [button name] button!" in a floating snackbar with that button's color and icon and a close button. Pressing another button replaces the message right away.
- **Drawer navigation**: the ☰ button in the app bar opens the same drawer on every page, with Home, Add Education and Add Experience. The drawer highlights the page you're on, and choosing that page again just closes the drawer.
  - The Add Education and Add Experience buttons on the home page open their forms on top of it with `Navigator.push`.
  - The drawer's form options open the form on top of the home page too, and remove any other form in between (`Navigator.pushAndRemoveUntil` with `(route) => route.isFirst`).
  - Home in the drawer clears the navigation stack (`Navigator.pushAndRemoveUntil` with `(route) => false`), so there's never a second copy of the home page underneath.

  So however a form was opened, Back from it returns to the home page.
- **Add Education form** whose fields match my Django `Education` model: institution, degree, description, a start date and an optional end date, both picked from a calendar. Every field is checked: the required ones can't be left empty, institution and degree are limited to 255 characters, and the end date can't be before the start date. Errors disappear as soon as they're fixed. Save shows the entered data in a dialog, and closing the dialog clears the form for the next entry.
- **Add Experience form** whose fields match my Django `Experience` model:
  - a title, required and limited to 255 characters
  - a category picked from the model's six choices, defaulting to Full-Time
  - a description, required
  - an optional thumbnail link, which must start with http:// or https:// and is limited to the 200 characters of Django's `URLField`
  - an optional end date picked from a calendar, left empty while the experience is ongoing

  The model sets the start date itself when an entry is created, so the form doesn't ask for it. Save works the same way as on the Education form.
- **Protection for unsaved input**: on both forms, going Back (including the browser's Back button) or choosing another page in the drawer after typing something asks "Discard this entry?" first, so nothing is lost by accident. While the drawer is open, Back just closes the drawer.
- **Responsive layout**: on wide screens the content stays in a centered column at most 600 px wide, with the four action buttons in one row; on phones the buttons form a 2 × 2 grid. Short screens scroll, and button labels shrink instead of overflowing.
- **Light and dark mode** follow the device's setting. The app bar takes its text color from the theme, so it stays readable in both.

## Project Structure

| File | Contents |
| --- | --- |
| `lib/main.dart` | Entry point: `MyApp` builds the `MaterialApp` with the light and dark themes |
| `lib/screens/menu.dart` | `MyHomePage`: the info cards, the welcome text and the grid of action buttons |
| `lib/screens/education_form.dart` | `EducationFormPage`: the Add Education form |
| `lib/screens/experience_form.dart` | `ExperienceFormPage`: the Add Experience form |
| `lib/models/item_homepage.dart` | `ItemHomepage`: the name, icon, color and tooltip of one action button, plus the page it opens, if any |
| `lib/models/experience_category.dart` | `ExperienceCategory`: the six experience categories, with the same values and labels as the Django model |
| `lib/utils/validators.dart` | The validation rules both forms share: required text, optional web links, and the order of two dates |
| `lib/utils/unsaved_changes_guard.dart` | `UnsavedChangesGuard`: a mixin that makes a form ask before its unsaved input is discarded |
| `lib/widgets/info_card.dart` | `InfoCard`: a card with a title and its content |
| `lib/widgets/item_card.dart` | `ItemCard`: a colored action button that shows a snackbar and opens its page when pressed |
| `lib/widgets/left_drawer.dart` | `LeftDrawer`: the navigation drawer with Home, Add Education and Add Experience |
| `lib/widgets/date_form_field.dart` | `DateFormField`: a form field that picks a date from a calendar |
| `lib/widgets/form_decoration.dart` | The outlined input style both forms share |
| `test/widget_test.dart` | Widget tests for the home page, the drawer and both forms |
| `test/validators_test.dart` | Unit tests for the validation rules |

## Getting Started

You need the Flutter SDK on the stable channel (this app was built with Flutter 3.47.9 and Dart 3.13), Git, and Google Chrome. The Material widgets come from the `material_ui` package (`import 'package:material_ui/material_ui.dart';`), which replaces `package:flutter/material.dart` from Flutter 3.50 onward; `flutter pub get` installs it.

1. `git clone https://github.com/REYHANCSUI25/myportofolio_mobile.git`
2. `cd myportofolio_mobile`
3. `flutter pub get`
4. `flutter run -d chrome`. While it runs, press `r` in the terminal to hot reload, `R` to hot restart and `q` to quit.

Before committing, I run these three checks:

- `dart format lib test` formats the code in the standard Dart style.
- `flutter analyze` should print `No issues found!`.
- `flutter test` should end with `All tests passed!`.

## Running the Tests

`flutter test` runs 26 tests. The 20 widget tests in `test/widget_test.dart` check that:

- the info cards show my NPM, full name and class
- each action button is drawn in its own color
- pressing each of the four buttons shows its snackbar message (one test per button)
- the Add Education and Add Experience buttons open their forms
- the drawer opens each form, and Back from a form opened in the drawer returns to the home screen
- Home in the drawer takes a form back to the home screen, with nothing left underneath
- the drawer highlights the page you're on
- saving an empty Education form shows an error for every required field
- saving an invalid Experience entry (a title of only spaces, no description, a broken link) shows an error next to each of those fields
- a valid Experience entry is summarized in a dialog, and OK closes it and clears the form
- going Back with unsaved input asks before discarding it, and Discard returns to the home screen
- choosing another page in the drawer with unsaved input asks first, and Keep editing keeps the input
- the home page fits a 320 × 568 phone screen without overflowing
- on that phone size, with the on-screen keyboard open, the Experience form's Save button can still be reached and pressed
- the app switches to its dark theme when the device is in dark mode

The 6 unit tests in `test/validators_test.dart` check the shared validation rules on their own: blank text, web links, and the order of a start and end date.

## Weekly Progress

| Week | Work |
| --- | --- |
| Tutorial 8 | Installed Flutter 3.47.9 and the VS Code Flutter extension, created `myportofolio_mobile`, moved the home screen into `menu.dart`, converted `MyHomePage` into a `StatelessWidget`, built `InfoCard` and `ItemCard` with a snackbar, and checked the code with `flutter analyze` |
| Assignment 7 | My own NPM, name and class on the info cards; View Education, Add Education and Logout buttons in different colors; colored floating snackbars; tooltips; responsive layout; light and dark mode; `ItemHomepage`, `InfoCard` and `ItemCard` moved into `lib/models` and `lib/widgets`; 7 widget tests replacing the template's counter test |
| Tutorial 9 | Switched from `package:flutter/material.dart` to the `material_ui` package; added a navigation drawer (`LeftDrawer`) with Home and Add Education; built the Add Education form (`EducationFormPage`) with validation, calendar date pickers and a dialog that shows the entered data; made the Add Education button open the form; moved the screens into `lib/screens`; 3 more widget tests |
| Assignment 8 | Add Experience form matching my Django `Experience` model (title, category, description, thumbnail link, end date) with validation and a summary dialog; Add Experience action button and drawer option; forms always open above the home page, so Back returns to it, and Home in the drawer clears the navigation stack; the drawer highlights the current page; a "Discard this entry?" check before unsaved input is lost, on both forms; a responsive action grid; validators, input style and the unsaved-input check shared between the forms; 26 tests in all |

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
