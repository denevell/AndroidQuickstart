#!/bin/bash

if [[ ! $PROJECT_NAME ]]; then
	echo "ERROR: PROJECT_NAME environement var isn't set, i.e MyProject"
	exit 1;
fi

if [ -z "$ANDROID_HOME" ]; then
	echo "ERROR: ANDROID_HOME is unset or empty"
	exit 1;
fi

if [ -d $PROJECT_NAME ]; then
	echo "WARNING: The project directory already exists"
	#exit 1;
fi

if [[ ! $PROJECT_PACKAGE_NAME ]]; then
	echo "ERROR: PROJECT_PACKAGE_NAME environement var isn't set, i.e. myproject"
	exit 1;
fi

if [[ ! $PROJECT_PACKAGE_JAVA ]]; then
	echo "ERROR: PROJECT_PACKAGE_JAVA environement var isn't set, i.e. com.example"
	exit 1;
fi

PROJECT_PACKAGE_DIRS=$(echo $PROJECT_PACKAGE_JAVA | sed 's#\.#/#')/
PROJECT_PACKAGE_BASE_JAVA=${PROJECT_PACKAGE_JAVA}.${PROJECT_PACKAGE_NAME}
PROJECT_PACKAGE_BASE_DIRS=${PROJECT_PACKAGE_DIRS}${PROJECT_PACKAGE_NAME}

echo "###---> Directory structure" 

mkdir $PROJECT_NAME 
cd $PROJECT_NAME 
mkdir -p src/main/java/$PROJECT_PACKAGE_BASE_DIRS/
mkdir -p src/otherBuildType/res/values/
if [ -h res ]; then 
	echo "Deleted symlink"
	rm res 
fi
cp -r ../res src/main/



echo "###---> Gradle build file"

cat << END_HEREDOC > build.gradle
buildscript {
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:0.9.+'
    }
}

repositories {
        mavenCentral()
        maven {
                url "http://www.bugsense.com/gradle/"
        } 
}

apply plugin: 'android'
dependencies {
        compile 'com.android.support:support-v4:19.1.0'
        compile 'com.google.android.gms:play-services:4.3.23'
        compile 'com.google.code.gson:gson:2.2.4'
        compile 'com.squareup.dagger:dagger-compiler:1.2.1'
        compile 'com.squareup.dagger:dagger:1.2.1'
        compile 'com.squareup:otto:1.3.4'
        compile 'com.bugsense.trace:bugsense:3.6'
        compile 'org.mockito:mockito-all:1.9.5'
        compile 'org.apache.commons:commons-lang3:3.1'
}

android {
        buildToolsVersion "19.0.3"                                                                                                     
        // Since the build tools auto fail on error, and we're getting werid erros with 0.7 of the build tools
        lintOptions {
	    disable 'InvalidPackage'
            abortOnError false
            textReport true
            textOutput 'stdout'
            htmlReport true
        }
        buildTypes {
		otherBuildType.initWith(buildTypes.debug);
		otherBuildType {
			packageNameSuffix ".otherBuildType"
		}
        }
        compileSdkVersion 19
}
END_HEREDOC



echo "###---> strings.xml file"

cat << END_HEREDOC > src/main/res/values/strings.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$PROJECT_NAME</string>
</resources>
END_HEREDOC

cat << END_HEREDOC > src/otherBuildType/res/values/strings.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">${PROJECT_NAME}-Other Build Type</string>
</resources>
END_HEREDOC



echo "###---> Gradle properities file, gradle daemon and parallel execution"

cat << END_HEREDOC > gradle.properties
org.gradle.daemon=true
org.gradle.parallel=true
END_HEREDOC



echo "###---> Android Manifest"

cat << END_HEREDOC > src/main/AndroidManifest.xml 
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="$PROJECT_PACKAGE_BASE_JAVA"
    android:versionCode="1"
    android:versionName="0.0.1" >

    <uses-sdk
        android:minSdkVersion="14"
        android:targetSdkVersion="19" />

    <application
        android:allowBackup="true"
        android:name="$PROJECT_PACKAGE_BASE_JAVA.Application"
	android:icon="@drawable/ic_launcher"
	>
        <activity
            android:name="$PROJECT_PACKAGE_BASE_JAVA.MainPageActivity"
            android:label="@string/app_name" >
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
END_HEREDOC



echo "###---> Copying libs/ directory since Eclipse can't deal with AAR files"

cp -r ../libs .



echo "###---> Symlinking Android Manifest to root for Eclipse (IntelliJ will complain)"

ln -s src/main/AndroidManifest.xml AndroidManifest.xml 



echo "###---> Symlinking res dir to root for Eclipse (IntelliJ will complain)"

ln -s src/main/res res



echo "###---> Adding .classpath for Eclipse"

cat << END_HEREDOC > .classpath
<?xml version="1.0" encoding="UTF-8"?>
<classpath>
	<classpathentry kind="src" path="src/main/java"/>
	<classpathentry kind="con" path="com.android.ide.eclipse.adt.ANDROID_FRAMEWORK"/>
	<classpathentry exported="true" kind="con" path="com.android.ide.eclipse.adt.LIBRARIES"/>
	<classpathentry exported="true" kind="con" path="com.android.ide.eclipse.adt.DEPENDENCIES"/>
	<classpathentry kind="src" path="gen"/>
	<classpathentry kind="output" path="bin/classes"/>
</classpath>
END_HEREDOC



echo "###---> project.properties for Eclipse"

cat << END_HEREDOC > project.properties
# This file is automatically generated by Android Tools.
# Do not modify this file -- YOUR CHANGES WILL BE ERASED!
#
# This file must be checked in Version Control Systems.
#
# To customize properties used by the Ant build system edit
# "ant.properties", and override values to adapt the script to your
# project structure.
#
# To enable ProGuard to shrink and obfuscate your code, uncomment this (available properties: sdk.dir, user.home):
#proguard.config=sdk.dir/tools/proguard/proguard-android.txt:proguard-project.txt

# Project target.
target=android-19
END_HEREDOC



echo "###---> .project for Eclipse"

cat << END_HEREDOC > .project
<?xml version="1.0" encoding="UTF-8"?>
<projectDescription>
	<name>AndroidProject</name>
	<comment></comment>
	<projects>
	</projects>
	<buildSpec>
		<buildCommand>
			<name>com.android.ide.eclipse.adt.ResourceManagerBuilder</name>
			<arguments>
			</arguments>
		</buildCommand>
		<buildCommand>
			<name>com.android.ide.eclipse.adt.PreCompilerBuilder</name>
			<arguments>
			</arguments>
		</buildCommand>
		<buildCommand>
			<name>org.eclipse.jdt.core.javabuilder</name>
			<arguments>
			</arguments>
		</buildCommand>
		<buildCommand>
			<name>com.android.ide.eclipse.adt.ApkBuilder</name>
			<arguments>
			</arguments>
		</buildCommand>
	</buildSpec>
	<natures>
		<nature>com.android.ide.eclipse.adt.AndroidNature</nature>
		<nature>org.eclipse.jdt.core.javanature</nature>
	</natures>
</projectDescription>
END_HEREDOC



echo "###---> Application class"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/Application.java
package $PROJECT_PACKAGE_BASE_JAVA;

import android.util.Log;

public class Application extends android.app.Application {
    protected static final String TAG = "$PROJECT_NAME Application class";

    @Override
    public void onCreate() {
	super.onCreate();
    }

}
END_HEREDOC



echo "###---> Main Activity"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/MainPageActivity.java
package $PROJECT_PACKAGE_BASE_JAVA;

import android.support.v4.app.FragmentActivity;
import $PROJECT_PACKAGE_BASE_JAVA.R;
import android.util.Log;
import android.os.Bundle;

public class MainPageActivity extends FragmentActivity {

    private static final String TAG = MainPageActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setContentView(R.layout.activity_main);
        } catch (Exception e) {
            Log.e(TAG, "Failed to parse activity", e);
            return;
        }
    }
}
END_HEREDOC



echo "###---> Main page layout"

cat << END_HEREDOC > src/main/res/layout/activity_main.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/main_fragment_holder"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    >

    <FrameLayout
        android:id="@+id/fragment_holder"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
    />

</RelativeLayout>
END_HEREDOC



echo "###---> .gitignore"

cat << END_HEREDOC > .gitignore
# Built application files
*.apk
*.ap_

# Files for the Dalvik VM
*.dex

# Java class files
*.class

# Generated files
bin/
gen/

# Gradle files
.gradle/
build/

# Local configuration file (sdk path, etc)
local.properties

# Proguard folder generated by Eclipse
proguard/
END_HEREDOC



echo "###---> Building"

gradle build 



