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

if [[ ! $MAPS_V2_KEY ]]; then
	echo "ERROR: MAPS_V2_KEY must be set, i.e. the key your get from the Google APIs console when entering your debug key."
	echo "Your debug key (from ~/.android/debug.keystore) is: "
	keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1 | sed 's/.*SHA1: \(.*\)$/\1/'
	echo "ERROR: Enter rubbish in this parameter and the map won't show"
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
mkdir -p src/main/java/$PROJECT_PACKAGE_BASE_DIRS/utils
mkdir -p src/otherBuildType/res/values/
if [ -h res ]; then 
	echo "Deleted symlink"
	rm res 
fi
cp -r ../res src/main/



echo "###---> Creating release keystore, release.keystore, and signing.properties"

keytool -genkey -v -keystore release.keystore -alias release.keystore -keyalg RSA -keysize 2048 -validity 10000 -keypass android -storepass android -dname "cn=Android Android, ou=Android, o=Android, c=AN"

cat << END_HEREDOC > signing.properties
keystore=release.keystore
keystore.password=android
keyAlias=release.keystore
keyPassword=android
END_HEREDOC



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

        Properties props = new Properties()
        props.load(new FileInputStream(file("signing.properties")))

        signingConfigs {
                release {
                        storeFile file(props['keystore'])
                        storePassword props['keystore.password']
                        keyAlias props['keyAlias']
                        keyPassword props['keyPassword']
                }
        }

        buildTypes {
                release {
                        signingConfig signingConfigs.release
                }
                otherBuildType.initWith(buildTypes.release);
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
    <string name="custom_view_checkbox_text">Hiya</string>
    <string name="custom_view_greeting">Why hello!</string>
    <string name="goto_maps_button">Map</string>
    <string name="preferences_option">Preferences</string>
    <string name="licences_option">Licences</string>
    <string name="settings_checkbox_key">settings_checkbox_key</string>
    <string name="settings_edittext_key">settings_edittext_key</string>
    <string name="google_play_licence_info_header">Google Play Services Licence Info</string>
    <string name="legal_text_and_licences">Legal text and licences</string>
</resources>
END_HEREDOC

cat << END_HEREDOC > src/otherBuildType/res/values/strings.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
<string name="app_name">${PROJECT_NAME}-Other Build Type</string>
</resources>
END_HEREDOC



echo "###---> Menu xml file for main activity"

cat << END_HEREDOC > src/main/res/menu/main_activity_options.xml
<menu 
	xmlns:android="http://schemas.android.com/apk/res/android" 
	xmlns:tools="http://schemas.android.com/tools">

		<item
		android:id="@+id/main_activity_options_action_preferences"
		android:showAsAction="never"
		android:title="@string/preferences_option" 
		/>
		<item
		android:id="@+id/main_activity_options_action_licences"
		android:showAsAction="never"
		android:title="@string/licences_option" 
		/>

	</menu>
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

	<uses-feature
		android:glEsVersion="0x00020000"
		android:required="true"/>

	<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
	<uses-permission android:name="android.permission.INTERNET"/>
	<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
	<uses-permission android:name="com.google.android.providers.gsf.permission.READ_GSERVICES"/>

	<application
		android:allowBackup="true"
		android:name="$PROJECT_PACKAGE_BASE_JAVA.Application"
		android:icon="@drawable/ic_launcher">

		<meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version" />
		<meta-data android:name="com.google.android.maps.v2.API_KEY" android:value="$MAPS_V2_KEY" />
		<activity
		    android:name="$PROJECT_PACKAGE_BASE_JAVA.MainPageActivity"
		    android:label="@string/app_name" >
		    <intent-filter>
			<action android:name="android.intent.action.MAIN" />
			<category android:name="android.intent.category.LAUNCHER" />
		    </intent-filter>
		</activity>
		<activity
		    android:name="$PROJECT_PACKAGE_BASE_JAVA.MapActivity"
		    android:label="@string/app_name" >
		</activity>
		<activity
		    android:name="$PROJECT_PACKAGE_BASE_JAVA.PreferencesActivity"
		    android:label="@string/app_name" >
		</activity>
		<activity
		    android:name="$PROJECT_PACKAGE_BASE_JAVA.LicencesActivity"
		    android:label="@string/app_name" >
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


echo "###---> Licences activity"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/LicencesActivity.java
package org.denevell.AndroidProject;

import com.google.android.gms.common.GooglePlayServicesUtil;

import android.app.AlertDialog;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;


public class LicencesActivity extends FragmentActivity {

    private static final String TAG = MainPageActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setContentView(R.layout.activity_licences);
            View tv = findViewById(R.id.licences_activity_google_play_licence_info_header_textview);
            tv.setOnClickListener(new OnClickListener() {
		@Override
		public void onClick(View v) {
                	String licenceInfo = GooglePlayServicesUtil.getOpenSourceSoftwareLicenseInfo(getApplicationContext());
                	AlertDialog.Builder licenceDialog = new AlertDialog.Builder(LicencesActivity.this);
			licenceDialog.setTitle(getString(R.string.google_play_licence_info_header));
			licenceDialog.setMessage(licenceInfo);
			licenceDialog.show();
		}
	    });
        } catch (Exception e) {
            Log.e(TAG, "Failed to parse activity", e);
            return;
        }
    }

}
END_HEREDOC



echo "###---> Licences layout file"

cat << END_HEREDOC > src/main/res/layout/activity_licences.xml
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/licences_activity_scrollview"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent" >

    <LinearLayout
        android:id="@+id/licences_activity_relativelayout"
        android:layout_width="fill_parent"
        android:layout_height="fill_parent"
        android:orientation="vertical" >

        <TextView
            android:id="@+id/textView1"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="@string/legal_text_and_licences"
            android:gravity="center"
            android:padding="5dp"
            android:textAppearance="?android:attr/textAppearanceLarge" />

        <Button
            android:id="@+id/licences_activity_google_play_licence_info_header_textview"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="@string/google_play_licence_info_header"
            android:textAppearance="?android:attr/textAppearanceMedium" 
            />

    </LinearLayout>

</ScrollView>
END_HEREDOC



echo "###---> Preferences activity"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/PreferencesActivity.java
package $PROJECT_PACKAGE_BASE_JAVA;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class PreferencesActivity extends PreferenceActivity{
    
    @SuppressWarnings("unused")
    private static final String TAG = PreferencesActivity.class.getSimpleName();

    @SuppressWarnings("deprecation")
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.preferences);
    }
}
END_HEREDOC


echo "###---> preferences.xml"

cat << END_HEREDOC > src/main/res/xml/preferences.xml
<?xml version="1.0" encoding="UTF-8"?>
<PreferenceScreen xmlns:android="http://schemas.android.com/apk/res/android">
<PreferenceCategory android:title="Settings category">
<CheckBoxPreference
	android:defaultValue="false"
	android:key="@string/settings_checkbox_key"
	android:title="Some checkbox"
	/>

</PreferenceCategory>   
<PreferenceCategory android:title="Another category">
<EditTextPreference
	android:title="Some edit text preference"
	android:selectable="true"
	android:key="@string/settings_edittext_key"
	/>
</PreferenceCategory>
</PreferenceScreen>
END_HEREDOC



echo "###---> Main Activity"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/MainPageActivity.java
package $PROJECT_PACKAGE_BASE_JAVA;

import $PROJECT_PACKAGE_BASE_JAVA.R;

import android.content.Intent;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.TextView;

public class MainPageActivity extends FragmentActivity {

    private static final String TAG = MainPageActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setContentView(R.layout.activity_main);

            Button b = (Button) findViewById(R.id.main_activity_gotomaps_button);
            b.setOnClickListener(new OnClickListener() {
				@Override public void onClick(View v) {
					startActivity(new Intent(MainPageActivity.this, MapActivity.class));
				}
			});
        } catch (Exception e) {
            Log.e(TAG, "Failed to parse activity", e);
            return;
        }
    }

    @Override
    protected void onResume() {
    	super.onResume();
        String preferenceString = PreferenceManager
          	.getDefaultSharedPreferences(this)
           	.getString(getString(R.string.settings_edittext_key), "EditTextPreference preference not set yet.");
        TextView preferencesTextView = (TextView) findViewById(R.id.main_activity_preferences_string_textview);
        preferencesTextView.setText(preferenceString);
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_activity_options, menu);
    	super.onCreateOptionsMenu(menu);
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	if(item.getItemId() == R.id.main_activity_options_action_preferences) {
    		startActivity(new Intent(MainPageActivity.this, PreferencesActivity.class));
    	} else if(item.getItemId() == R.id.main_activity_options_action_licences) {
    		startActivity(new Intent(MainPageActivity.this, LicencesActivity.class));
    	}
    	return super.onOptionsItemSelected(item);
    }

}
END_HEREDOC



echo "###---> Main page layout"

cat << END_HEREDOC > src/main/res/layout/activity_main.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/main_activity_relativelayout"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    >

    <$PROJECT_PACKAGE_BASE_JAVA.CustomView 
        android:id="@+id/main_activity_customview"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerInParent="true"
        app:my_attr="@string/custom_view_greeting"
        />
     <TextView
        android:id="@+id/main_activity_preferences_string_textview"
        android:layout_width="wrap_content"
        android:layout_below="@id/main_activity_customview"
        android:layout_centerHorizontal="true"
        android:layout_height="wrap_content"
        />

     <Button
        android:id="@+id/main_activity_gotomaps_button"
        android:layout_width="wrap_content"
        android:layout_below="@id/main_activity_preferences_string_textview"
        android:layout_centerHorizontal="true"
        android:layout_height="wrap_content"
        android:text="@string/goto_maps_button" />

</RelativeLayout>
END_HEREDOC



echo "###---> Custom View class"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/CustomView.java
package $PROJECT_PACKAGE_BASE_JAVA;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.FrameLayout;

import $PROJECT_PACKAGE_BASE_JAVA.R;

public class CustomView extends FrameLayout {

	public CustomView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}

	public CustomView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
		View v = LayoutInflater.from(context).inflate(R.layout.custom_view, this, true);
		TypedArray a = context.getTheme().obtainStyledAttributes(attrs, R.styleable.MyCustomView, 0, 0);
		CheckBox bx = (CheckBox) v.findViewById(R.id.custom_view_checkbox);
		try {
			String myString = a.getString(R.styleable.MyCustomView_my_attr);
			bx.setText(myString);
		} finally {
			a.recycle();
		}
	}

	public CustomView(Context context) {
		super(context);
	}

}

END_HEREDOC



echo "###---> Custom View layout "

cat << END_HEREDOC > src/main/res/layout/custom_view.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/custom_view_relativelayout"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    >

    <CheckBox
        android:id="@+id/custom_view_checkbox"
        android:checked="true"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerHorizontal="true"
        android:layout_centerVertical="true"
        android:text="@string/custom_view_checkbox_text" />

</RelativeLayout>
END_HEREDOC



echo "###---> Custom View xml attributs"

cat << END_HEREDOC > src/main/res/values/attrs.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    
     <declare-styleable name="MyCustomView">
        <attr name="my_attr" format="string"></attr>
     </declare-styleable>
    
</resources>
END_HEREDOC



echo "###---> Class that fixes black artifacts on maps fragment"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/utils/FixForBlackArtifactsMapFragment.java
package $PROJECT_PACKAGE_BASE_JAVA.utils;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;

import com.google.android.gms.maps.SupportMapFragment;

public class FixForBlackArtifactsMapFragment extends SupportMapFragment {
	
    @SuppressWarnings("deprecation")
    @Override
    public View onCreateView(LayoutInflater inflater, 
                             ViewGroup container, 
                             Bundle savedInstanceState) {

        View view = super.onCreateView(inflater, container, savedInstanceState);

        // Fix for black background on devices < 4.1
        if (android.os.Build.VERSION.SDK_INT < 
            android.os.Build.VERSION_CODES.JELLY_BEAN) {
            setMapTransparent((ViewGroup) view);
        }
        
        FrameLayout frameLayout = new FrameLayout(getActivity());
        frameLayout.setBackgroundColor(
            getResources().getColor(android.R.color.transparent));
        ((ViewGroup) view).addView(frameLayout, 0,
            new ViewGroup.LayoutParams(
                LayoutParams.FILL_PARENT, 
                LayoutParams.FILL_PARENT
            )
        );
        
        return view;
    }

    private void setMapTransparent(ViewGroup group) {
        int childCount = group.getChildCount();
        for (int i = 0; i < childCount; i++) {
            View child = group.getChildAt(i);
            if (child instanceof ViewGroup) {
                setMapTransparent((ViewGroup) child);
            } else if (child instanceof SurfaceView) {
                child.setBackgroundColor(0x00000000);
            }
        }
    }

}
END_HEREDOC



echo "###---> Maps activity"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/MapActivity.java
package $PROJECT_PACKAGE_BASE_JAVA;

import $PROJECT_PACKAGE_BASE_JAVA.utils.FixForBlackArtifactsMapFragment;

import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;

import com.google.android.gms.maps.SupportMapFragment;

public class MapActivity extends FragmentActivity {

    private static final String TAG = MapActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setContentView(R.layout.activity_map);

            String mapTag = "mapTag";
            FragmentManager supportFragManager = getSupportFragmentManager();
			SupportMapFragment possiblyExtantMap = (SupportMapFragment) supportFragManager.findFragmentByTag(mapTag);

            if(possiblyExtantMap==null) {
            	possiblyExtantMap = new FixForBlackArtifactsMapFragment();
				FragmentTransaction fragmentTransaction = supportFragManager.beginTransaction();
                fragmentTransaction.replace(R.id.maps_map_fragment_holder, possiblyExtantMap, mapTag);
                fragmentTransaction.commit();
                supportFragManager.executePendingTransactions();
            }

        } catch (Exception e) {
            Log.e(TAG, "Failed to parse activity", e);
            return;
        }
    }
}
END_HEREDOC



echo "###---> Layout for maps activity"

cat << END_HEREDOC > src/main/res/layout/activity_map.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/maps_relativelayout"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    >

    <FrameLayout
        android:id="@+id/maps_map_fragment_holder"
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



