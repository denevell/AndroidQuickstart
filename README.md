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

Script to quickly setup an Android project

	PROJECT_NAME=AndroidProject PROJECT_PACKAGE_JAVA=org.denevell PROJECT_PACKAGE_NAME=AndroidProject bash quickstart.sh

Todo:

- Two fragments
- Button to go to other fragment
- Espresso imports
- Espresso test
- Robolectric tests
- Product flavours
- Push
- Production key for maps
- Google play services integration in eclipse
- Check for maps library project in $ANDROID_HOME
