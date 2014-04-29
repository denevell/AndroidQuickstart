Android Quickstart
==================

Features:

- Gradle setup
- Google Maps V2
- Actionbar from compatibility project
- Custom view with attributes
- Build types / variants
- Signing release build
- Eclipse integration (two symlinks in the root folder will mean Android Studio will complain)
- Preferences activity
- Licences activity
- Main Activity Fragment class and layout
- Application class

Requirements:

- Unix-like OS (Tested on Debian Linux) 
- Android SDK installed (API 19, Google respositories, Android repository, SDK tools, SDK build tools, SDK platform tools, Support library, Google play services)

Running:

	PROJECT_NAME=AndroidProject PROJECT_PACKAGE_JAVA=org.denevell PROJECT_PACKAGE_NAME=AndroidProject bash quickstart.sh

Eclipse integration:

- You can import the project into Eclipse as an Android project as normal.
- You must also import (and have built) all the projects in eclipse_subprojects into your workspace.

Android Studio integration:

- You import the project as a Gradle project
- You must remove the 'res' and 'AndroidManifest.xml' symlinks else IntelliJ will complain 

Todo:

- View pager
- Swipe to refresh
- Espresso imports
- Espresso test
- Robolectric tests
- Product flavours
- Push messaging
- Production key for maps
- Navigation menu 
- Rotating the maps fragment / extant fragment
- Figure out best navigation (fragments, activities) pattern
- Image downloading and caching
- List view with images
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
