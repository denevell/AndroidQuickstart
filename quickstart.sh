#!/bin/bash

if [[ ! $PROJECT_NAME ]]; then
	echo "ERROR: PROJECT_NAME environement var isn't set, i.e MyProject"
	exit 1;
fi

if [ -d $PROJECT_NAME ]; then
	echo "ERROR: The project directory already exists"
	//exit 1;
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
cp -rf ../res src/main/



echo "###---> Gradle build file"

cat << END_HEREDOC > build.gradle
buildscript {
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:0.8.+'
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
        compile 'com.squareup.dagger:dagger-compiler:1.1.0'
        compile 'com.squareup.dagger:dagger:1.1.0'
        compile 'com.google.code.gson:gson:2.2.4'
        compile 'com.android.support:support-v4:19.1.0'
        compile 'com.bugsense.trace:bugsense:3.6'
        compile 'com.google.android.gms:play-services:4.2.42'
        compile 'org.mockito:mockito-all:1.9.5'
        compile 'com.squareup:otto:1.3.4'
        compile 'org.apache.commons:commons-lang3:3.1'
}

android {
        buildToolsVersion "19.0.1"                                                                                                     
        // Since the build tools auto fail on error, and we're getting werid erros with 0.7 of the build tools
        lintOptions {
            abortOnError false
            textReport true
            textOutput 'stdout'
            htmlReport true
        }
        compileSdkVersion 19
}
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
            android:label="APP NAME" >
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
END_HEREDOC



echo "###---> Application class"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/Application.java
package $PROJECT_PACKAGE_BASE_JAVA.Application;

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



