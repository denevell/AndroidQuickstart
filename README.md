Android Quickstart
==================

Features:

- Gradle setup
- Google Maps V2
- Actionbar from compatibility project
- Custom view with attributes
- View Pager
- Preferences activity
- Licences activity
- Main Activity and layout
- Application class
- Build types / variants
- Signing release build
- Eclipse integration

Requirements:

- Unix-like OS (Tested on Debian Linux) 
- Android SDK installed (at least API 19, Google respositories, Android repository, SDK tools, SDK build tools, SDK platform tools, Support library, Google play services)

Running:

	PROJECT_NAME=AndroidProject PROJECT_PACKAGE_JAVA=org.denevell PROJECT_PACKAGE_NAME=AndroidProject bash quickstart.sh

Eclipse integration:

- You must import (and have built) all the projects in eclipse_subprojects into your workspace.
- You then import the project into Eclipse as an Android project as normal.

Android Studio integration:

- You must remove the 'res' and 'AndroidManifest.xml' symlinks else IntelliJ will complain 
- Then import the project as a Gradle project

Todo:

- Smooth view pager transitions
- Navigation menu, left and right
- List view with images
- Swipe to refresh
- Rotating the maps fragment / extant fragment
- Espresso imports
- Espresso test
- Robolectric tests
- Product flavours
- Push messaging
- Production key for maps
- Figure out best navigation (fragments, activities) pattern
- Image downloading and caching
- Retrofit and Okhttp for networking
- Intent service
- Service
- Endless listview
- Staggered listview
- Pull to refresh
- Form validation
- Checks for connectivity
- Wizard Page adapter
- Actionbar action menu
- Actionbar tabs
- Actionbar share provider 
- Actionbar navigate up
- Actionbar split bar
- Fading actionbar
