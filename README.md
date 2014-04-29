Android Quickstart
==================

Features:

- Gradle setup
- Google Maps V2
- Custom view with attributes
- Build types / variants
- Signing release build
- Eclipse integration (two symlinks in the root folder will mean Android Studio will complain)
- Preferences activity
- Main Activity Fragment class and layout
- Application class

Running:

	PROJECT_NAME=AndroidProject PROJECT_PACKAGE_JAVA=org.denevell PROJECT_PACKAGE_NAME=AndroidProject bash quickstart.sh

Eclipse integration:

- You can import the project into Eclipse as an Android project as normal.
- You must also import google_maps_project from $ANDROID_HOME/extras/google/google_play_services/libproject/google-play-services_lib into your workspace and add it as a library into the main project

Android studio integration:

- You import the project as a Gradle project
- You must remove the 'res' and 'AndroidManifest.xml' symlinks else IntelliJ will complain 

Todo:

- Fragments navigation
- Espresso imports
- Espresso test
- Robolectric tests
- Product flavours
- Push messaging
- Production key for maps
- Support library actionbar
- Navigation bar
- Styles / themes
