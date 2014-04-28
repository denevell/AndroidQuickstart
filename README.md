Android Quickstart
==================

Features:

- Gradle setup
- Google Maps V2
- Custom view with attributes
- Build types / variants
- Signing release build
- Eclipse integration (two symlinks in the root folder will mean Android Studio will complain)
- Main Activity Fragment class and layout
- Application class

Running:

	PROJECT_NAME=AndroidProject PROJECT_PACKAGE_JAVA=org.denevell PROJECT_PACKAGE_NAME=AndroidProject bash quickstart.sh

Eclipse integration:

- You can import the project into Eclipse as an Android project as normal.
- You must also import google_maps_project from $ANDROID_HOME/extras/google/google_play_services/libproject/google-play-services_lib into your workspace and add it as a library into the main project

Todo:

- Two fragments
- Button to go to other fragment
- Espresso imports
- Espresso test
- Robolectric tests
- Product flavours
- Push
- Production key for maps
- Check for maps library project in $ANDROID_HOME
- Make a new eclipse workspace with the main project and google play services
