Name : Muhammad Reyhan Attarizky

NPM : 2506637086

Class : PBP KI

# MyPortfolio Mobile

The Flutter mobile client for my personal portfolio, the individual project of Platform-Based Programming (CSGE602022), Fasilkom UI, Odd Semester 2026/2027. As on my Django website, the portfolio section is **Education**. In later tutorials this app will load its data from the site's Django REST Framework API.

- Django website: https://muhammad-reyhan53-myportofolio.pws.cs.ui.ac.id
- Django repository: https://github.com/REYHANCSUI25/myportofolio

## Features

- **Info cards** show my NPM, full name and PBP class. The three cards always share the row equally and match each other's height, even when my name wraps onto several lines.
- **Action buttons** for View Education, Add Education and Logout. Each has its own icon and color: blue, green and red, all Material shade 800. White text on each of these colors passes the WCAG AA contrast minimum of 4.5:1, which the plain `Colors.blue`, `Colors.green` and `Colors.red` don't.
- **Tooltips** describe each button when you hover over it, or long-press it on a phone.
- **Snackbar feedback**: pressing a button shows "You pressed the [button name] button!" in a floating snackbar with that button's color and icon and a close button. Pressing another button replaces the message right away.
- **Responsive layout**: on wide screens the content stays in a centered column at most 600 px wide, on short screens the page scrolls, and on narrow phones the button labels shrink instead of overflowing.
- **Light and dark mode** follow the device's setting. The app bar takes its text color from the theme, so it stays readable in both.

## Project Structure

| File | Contents |
| --- | --- |
| `lib/main.dart` | Entry point: `MyApp` builds the `MaterialApp` with the light and dark themes |
| `lib/menu.dart` | `MyHomePage`: the info cards, the welcome text and the grid of action buttons |
| `lib/models/item_homepage.dart` | `ItemHomepage`: the name, icon, color and tooltip of one action button |
| `lib/widgets/info_card.dart` | `InfoCard`: a card with a title and its content |
| `lib/widgets/item_card.dart` | `ItemCard`: a colored action button that shows a snackbar when pressed |
| `test/widget_test.dart` | Widget tests for the home page |

## Getting Started

You need the Flutter SDK on the stable channel (this app was built with Flutter 3.47.9 and Dart 3.13), Git, and Google Chrome.

1. `git clone https://github.com/REYHANCSUI25/myportofolio_mobile.git`
2. `cd myportofolio_mobile`
3. `flutter pub get`
4. `flutter run -d chrome`. While it runs, press `r` in the terminal to hot reload, `R` to hot restart and `q` to quit.

Before committing, I run these three checks:

- `dart format lib test` formats the code in the standard Dart style.
- `flutter analyze` should print `No issues found!`.
- `flutter test` should end with `All tests passed!`.

## Running the Tests

`flutter test` runs 7 widget tests from `test/widget_test.dart`:

- the info cards show my NPM, full name and class
- each action button is drawn in its own color
- pressing each of the three buttons shows its snackbar message (one test per button)
- the page fits a 320 × 568 phone screen without overflowing
- the app switches to its dark theme when the device is in dark mode

## Weekly Progress

| Week | Work |
| --- | --- |
| Tutorial 8 | Installed Flutter 3.47.9 and the VS Code Flutter extension, created `myportofolio_mobile`, moved the home screen into `menu.dart`, converted `MyHomePage` into a `StatelessWidget`, built `InfoCard` and `ItemCard` with a snackbar, and checked the code with `flutter analyze` |
| Assignment 7 | My own NPM, name and class on the info cards; View Education, Add Education and Logout buttons in different colors; colored floating snackbars; tooltips; responsive layout; light and dark mode; `ItemHomepage`, `InfoCard` and `ItemCard` moved into `lib/models` and `lib/widgets`; 7 widget tests replacing the template's counter test |

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
