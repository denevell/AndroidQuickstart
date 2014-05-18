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

if [ ! -d $ANDROID_HOME/extras/android/support/v7/appcompat/ ]; then
	echo "ERROR: The appcompat lib directory in ANDROID_HOME isn't there. Download it from the SDK Manager"
	exit 1;
fi

if [ ! -d $ANDROID_HOME/extras/google/google_play_services/libproject/google-play-services_lib/ ]; then
	echo "ERROR: The google play lib directory in ANDROID_HOME isn't there. Download it from the SDK Manager"
	exit 1;
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
mkdir -p src/main/java/$PROJECT_PACKAGE_BASE_DIRS/nav
mkdir -p src/main/java/$PROJECT_PACKAGE_BASE_DIRS/services
mkdir -p src/main/java/$PROJECT_PACKAGE_BASE_DIRS/networking
mkdir -p src/main/java/android/support/v4/app
mkdir -p src/otherBuildType/res/values/
if [ -h res ]; then 
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
        compile "com.android.support:appcompat-v7:19.1.0"
        compile 'com.android.support:support-v4:19.1.0'
        compile 'com.google.android.gms:play-services:4.3.23'
        compile 'com.google.code.gson:gson:2.2.4'
        compile 'com.squareup.dagger:dagger-compiler:1.2.1'
        compile 'com.squareup.dagger:dagger:1.2.1'
        compile 'com.squareup:otto:1.3.4'
	compile 'com.squareup.retrofit:retrofit:1.5.1'
	compile 'com.squareup.okhttp:okhttp:1.5.4'
        compile('org.simpleframework:simple-xml:2.7.+'){
            exclude module: 'stax'
            exclude module: 'stax-api'
            exclude module: 'xpp3'
        }
        compile('com.squareup.retrofit:converter-simplexml:1.5.1') {
            exclude module: 'stax'
            exclude module: 'stax-api'
            exclude module: 'xpp3'
        }
        compile 'com.astuetz:pagerslidingtabstrip:1.0.1'
        compile 'com.bugsense.trace:bugsense:3.6'
        compile 'org.mockito:mockito-all:1.9.5'
        //compile 'org.apache.commons:commons-lang3:3.1'
        //compile(group: 'org.bytedeco.javacpp-presets', name: 'opencv', version: '2.4.9-0.8', classifier: 'android-x86')
        //compile(group: 'org.bytedeco.javacpp-presets', name: 'opencv', version: '2.4.9-0.8')
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

        compileOptions {
            sourceCompatibility JavaVersion.VERSION_1_7
            targetCompatibility JavaVersion.VERSION_1_7
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
    <string name="goto_navmenu_button">Nav Drawer</string>
    <string name="preferences_option">Preferences</string>
    <string name="licences_option">Licences</string>
    <string name="settings_checkbox_key">settings_checkbox_key</string>
    <string name="settings_edittext_key">settings_edittext_key</string>
    <string name="google_play_licence_info_header">Google Play Services Licence Info</string>
    <string name="legal_text_and_licences">Legal text and licences</string>
    <string name="tab_viewpager_one">One</string>
    <string name="tab_viewpager_two">Two</string>
    <string name="nav_item1">Preferences stuff</string>
    <string name="nav_item2">View Pager</string>
    <string name="nav_item3">Google Maps</string>
    <string name="navigation_drawer_open">Open navigation drawer</string>
    <string name="navigation_drawer_close">Close navigation drawer</string>
    <string name="drawer_item_one_title">Preferences view</string>
    <string name="view_pager_title">View Pager</string>
</resources>
END_HEREDOC

cat << END_HEREDOC > src/otherBuildType/res/values/strings.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
	<string name="app_name">${PROJECT_NAME}-Other Build Type</string>
</resources>
END_HEREDOC



echo "###---> styles.xml"

cat << END_HEREDOC > src/main/res/values/styles.xml
<resources xmlns:android="http://schemas.android.com/apk/res/android">

    <style name="AppBaseTheme" parent="@style/Theme.AppCompat.Light">
    </style>

    <style name="AppTheme" parent="AppBaseTheme">
    </style>

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
		    android:name="$PROJECT_PACKAGE_BASE_JAVA.nav.NavManagerFragmentActivity"
		    android:theme="@style/AppTheme" 
		    android:label="@string/app_name" >
		    <intent-filter>
			<action android:name="android.intent.action.MAIN" />
			<category android:name="android.intent.category.LAUNCHER" />
		    </intent-filter>
		</activity>
		<activity
		    android:name="$PROJECT_PACKAGE_BASE_JAVA.PreferencesActivity"
		    android:theme="@style/AppTheme" 
		    android:label="@string/app_name" >
		</activity>
		<activity
		    android:name="$PROJECT_PACKAGE_BASE_JAVA.LicencesActivity"
		    android:theme="@style/AppTheme" 
		    android:label="@string/app_name" >
		</activity>
	</application>
</manifest>
END_HEREDOC



echo "###---> Application class"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/Application.java
package $PROJECT_PACKAGE_BASE_JAVA;

import com.squareup.otto.Bus;

public class Application extends android.app.Application {
    protected static final String TAG = "$PROJECT_NAME Application class";

    private static Bus sEventBus;

    public static Bus getEventBus() {
        if(sEventBus==null) {
            sEventBus = new com.squareup.otto.Bus();
        }
        return sEventBus;
    }

}
END_HEREDOC



echo "###---> Fix missing classpath in Fragment SavedState"

cat << END_HEREDOC > src/main/java/android/support/v4/app/FixedSavedState.java
package android.support.v4.app;

import android.os.Bundle;
import android.os.Parcel;

import $PROJECT_PACKAGE_BASE_JAVA.nav.NavManagerFragmentActivity;

/**
 * Fixed missing class loader problem
 */
public class FixedSavedState extends Fragment.SavedState {
    FixedSavedState(Bundle b) {
        super(b);
    }

    FixedSavedState(Parcel in, ClassLoader loader) {
        super(in, loader);
    }

    public FixedSavedState(Fragment.SavedState ss) {
        super(ss.mState);
        ss.mState.setClassLoader(NavManagerFragmentActivity.class.getClassLoader());
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

    private static final String TAG = LicencesActivity.class.getSimpleName();

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
        android:layout_height="wrap_content"
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

     <Button
        android:id="@+id/main_activity_gotomaps_button"
        android:layout_width="wrap_content"
        android:layout_below="@id/main_activity_customview"
        android:layout_centerHorizontal="true"
        android:layout_height="wrap_content"
        android:text="@string/goto_maps_button" />
     <Button
        android:id="@+id/main_activity_gotonavmenu_button"
        android:layout_width="wrap_content"
        android:layout_below="@id/main_activity_gotomaps_button"
        android:layout_centerHorizontal="true"
        android:layout_height="wrap_content"
        android:text="@string/goto_navmenu_button" />
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
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;

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

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/MapFragment.java
package $PROJECT_PACKAGE_BASE_JAVA;

import $PROJECT_PACKAGE_BASE_JAVA.utils.FixForBlackArtifactsMapFragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import org.denevell.AndroidProject.R;

import com.google.android.gms.maps.SupportMapFragment;

public class MapFragment extends Fragment {

    private static final String TAG = MapFragment.class.getSimpleName();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    	View v = inflater.inflate(R.layout.activity_map, container, false);
    	String mapTag = "mapTag";
    	FragmentManager supportFragManager = getChildFragmentManager();
    	SupportMapFragment possiblyExtantMap = (SupportMapFragment) supportFragManager.findFragmentByTag(mapTag);

    	if(possiblyExtantMap==null) {
    		possiblyExtantMap = new FixForBlackArtifactsMapFragment();
	    	FragmentTransaction fragmentTransaction = supportFragManager.beginTransaction();
        	fragmentTransaction.replace(R.id.maps_map_fragment_holder, possiblyExtantMap, mapTag);
        	fragmentTransaction.commit();
        	supportFragManager.executePendingTransactions();
    	}
    	return v;
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



echo "###---> ViewPager class"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/ViewPagerFragment.java
package $PROJECT_PACKAGE_BASE_JAVA;

import java.util.ArrayList;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.astuetz.PagerSlidingTabStrip;

public class ViewPagerFragment extends Fragment {

    private static final String TAG = ViewPagerFragment.class.getSimpleName();
    private ChildFragmentsManager mChildFragmentsManager;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        setHasOptionsMenu(true);
        View v = inflater.inflate(R.layout.viewpager_fragment, container, false);
        return v;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ViewPager pager = (ViewPager) view.findViewById(R.id.viewpager_activity_viewpager);
        pager.setOffscreenPageLimit(3);
        PagerSlidingTabStrip tabs = (PagerSlidingTabStrip) view.findViewById(R.id.viewpager_activity_pageslidingtabstrip);
        FragmentPageAdapter adapter = new FragmentPageAdapter(getChildFragmentManager());
        pager.setAdapter(adapter);
        tabs.setViewPager(pager);
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            mChildFragmentsManager = (ChildFragmentsManager) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException("Activity must implement ChildFragmentsManager.");
        }
    }

    /**
     * Setting the title here since, an options menu invalidation may change the title in the nav bar
     */
    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        if(mChildFragmentsManager!=null && mChildFragmentsManager.shouldChildSetOptionsMenuAndActionBar(ChildFragmentsManager.NORMAL_FRAGMENT, null)) {
            mChildFragmentsManager.setTitleFromChild(getString(R.string.view_pager_title));
        }
    }
    
    private class FragmentPageAdapter extends FragmentPagerAdapter {
        public FragmentPageAdapter(FragmentManager fm) {
            super(fm);
        }
        
        @Override
        public CharSequence getPageTitle(int position) {
            switch (position) {
                case 0:
                    return getString(R.string.tab_viewpager_one);
                case 1:
                    return getString(R.string.tab_viewpager_two);
                default:
                    return getString(R.string.tab_viewpager_one);
            }
        }

        @Override
	    public Fragment getItem(int position) {
            switch (position) {
                case 0:
                    return new ServiceExampleFragment();
                case 1:
                    return new GreenFragment();
                default:
                    return new GreenFragment();
            }
    	}

        @Override
        public Object instantiateItem(ViewGroup container, int position) {
            Object f = super.instantiateItem(container, position);
            return f;
        }

        @Override
    	public int getCount() {
    	    return 2;
    	}
    }
    
    public static class GreenFragment extends Fragment {
        public GreenFragment() {} 

    	@Override
    	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    		View v = inflater.inflate(R.layout.green, container, false);
    		return v;
    	}
    }
}
END_HEREDOC



echo "###---> ViewPager layout"

cat << END_HEREDOC > src/main/res/layout/viewpager_fragment.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/viewoager_activity_relativelayout"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    >

        <com.astuetz.PagerSlidingTabStrip
            android:id="@+id/viewpager_activity_pageslidingtabstrip"
            android:layout_width="match_parent"
            app:pstsShouldExpand="true"
            android:layout_height="48dip" />

        <android.support.v4.view.ViewPager
            android:id="@+id/viewpager_activity_viewpager"
            android:layout_below="@id/viewpager_activity_pageslidingtabstrip"
            android:layout_width="fill_parent"
            android:layout_height="fill_parent"
        />

</RelativeLayout>
END_HEREDOC



echo "###---> Fragment layouts for view pager"

cat << END_HEREDOC > src/main/res/layout/green.xml
    <LinearLayout
	xmlns:android="http://schemas.android.com/apk/res/android"
    	xmlns:tools="http://schemas.android.com/tools"
    	xmlns:app="http://schemas.android.com/apk/res-auto"
        android:layout_width="fill_parent"
        android:layout_height="fill_parent"
        android:background="#0f0"
        android:orientation="vertical" >
    </LinearLayout>
END_HEREDOC



echo "###---> Navigation Drawer's FragmentActivity, drawer fragment, interfaces, layout and option menu for main activity"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/nav/NavManagerFragmentActivity.java
package $PROJECT_PACKAGE_BASE_JAVA.nav;

import java.util.HashMap;

import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.app.Fragment;
import android.support.v4.app.Fragment.SavedState;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FixedSavedState;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Toast;
import android.content.Intent;

import $PROJECT_PACKAGE_BASE_JAVA.ChildFragmentsManager;
import $PROJECT_PACKAGE_BASE_JAVA.nav.NavigationDrawerCallbacks;
import $PROJECT_PACKAGE_BASE_JAVA.ViewPagerFragment;
import $PROJECT_PACKAGE_BASE_JAVA.PreferencesActivity;
import $PROJECT_PACKAGE_BASE_JAVA.MapFragment;
import $PROJECT_PACKAGE_BASE_JAVA.LicencesActivity;
import $PROJECT_PACKAGE_BASE_JAVA.PreferencesViewFragment;
import $PROJECT_PACKAGE_BASE_JAVA.R;

/**
 * We inflate a view with a DrawerLayout, a drawer fragment and a content FrameLayout holder, and we
 * wait for a method call from the drawer fragment that tells us to open a fragment relating to an
 * id, which we do by replacing the content holder's area with the new fragment.
 * 
 * Before going to a new fragment, we save the state of the old fragment in a HashMap according to 
 * the name of the Fragment, and when new fragments are started we check that HashMap for saved state
 * for that Fragment. This HashMap is saved in the lifecycle methods.
 * 
 * When a back press is issued, we check with the current fragment as to whether it has a backstack > 0
 * itself, and pops that instead if so.
 * 
 * We also implement an interface method that child fragments use to ascertain if they should set
 * their options menu etc, which we say yes to if the fragment is a normal fragment and the drawer is closed,
 * or if the drawer is open and the fragment is the navigation drawer fragment. We only set our options 
 * menu if the drawer is closed, too.
 * 
 * The Fragments we show are normal ones, except they use the methods herein to set the title (since 
 * we'd want to control that if this were a tablet layout) and ask us if they should set their options menu.
 */
public class NavManagerFragmentActivity extends FragmentActivity
	implements NavigationDrawerCallbacks, ChildFragmentsManager {

	private DrawerLayout mDrawerLayout;
	private View mNavDrawerView;
	// So we have a reference to the previously switched to fragment to save its state, or saving current state on onSaveInstanceState
	private Fragment mCurrentFragment; 
	// Save fragment states for when we switch to another one
	private HashMap<String, SavedState> mSavedStates = new HashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.nav_drawer_main_layout);

        mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        mNavDrawerView = findViewById(R.id.navigation_drawer);
    }
    
    @Override
    protected void onSaveInstanceState(Bundle outState) {
    	super.onSaveInstanceState(outState);
    	// Get the state of the currently active fragment and save it.
	SavedState savedState = getSupportFragmentManager().saveFragmentInstanceState(mCurrentFragment);
	mSavedStates.put(mCurrentFragment.getClass().getSimpleName(), savedState);
	// Now save all the saved fragment states
    	outState.putStringArray("savedStateStrings", mSavedStates.keySet().toArray(new String[0]));
    	outState.putParcelableArray("savedStateStates", mSavedStates.values().toArray(new Parcelable[0]));
    }
    
    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
    	super.onRestoreInstanceState(savedInstanceState);
    	// Restore all the fragment states back into the HashMap
    	Parcelable[] states = savedInstanceState.getParcelableArray("savedStateStates");
    	String[] strings = savedInstanceState.getStringArray("savedStateStrings");
    	for (int i = 0; i < strings.length; i++) {
    		mSavedStates.put(strings[i], (SavedState) states[i]);
	}
    }
    
    /**
     * If the current fragment has a backstack, pop that on backpress.
     */
    @Override
    public void onBackPressed() {
    	if(mCurrentFragment!=null && mCurrentFragment.getChildFragmentManager().getBackStackEntryCount()>0) {
    		mCurrentFragment.getChildFragmentManager().popBackStack();
    	} else {
	    	super.onBackPressed();
    	}
    }

    /**
     * Used to work out if child fragments should set their options menu / action bar stuff
     * @return
     */
     private boolean isDrawerVisible() {
        return mDrawerLayout != null && mNavDrawerView != null && mDrawerLayout.isDrawerVisible(mNavDrawerView);
     }

    /**
     * Set the options that are common among all the fragments.
     * If the drawer is open, don't bother setting it, since the drawer fragment should then do so.
     */
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (!isDrawerVisible()) {
            getMenuInflater().inflate(R.menu.nav_main_activity_options, menu);
            return true;
        }
        return super.onCreateOptionsMenu(menu);
    }
    
    /**
     * Define what happens when one of the options common to all fragments is pressed
     */
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	if (item.getItemId() == R.id.action_activity) {
    		Toast.makeText(this, "Act action.", Toast.LENGTH_SHORT).show();
    		return true;
    	} else if(item.getItemId() == R.id.preferences_option) {
    		startActivity(new Intent(this, PreferencesActivity.class));
    	} else if(item.getItemId() == R.id.licences_option) {
    		startActivity(new Intent(this, LicencesActivity.class));
    	}
        return super.onOptionsItemSelected(item);
    }

    /**
     * Only allow the child fragments to set their options menu / action bar stuff 
     * if the drawer menu is closed, unless the child is the drawer fragment itself.
     */
    @Override
    public boolean shouldChildSetOptionsMenuAndActionBar(int fragmentType, String fragmentName) {
    	if(fragmentType==ChildFragmentsManager.NORMAL_FRAGMENT && !isDrawerVisible()) {
    		return true;
    	} else if(fragmentType==ChildFragmentsManager.NAV_MENU_FRAGMENT && isDrawerVisible()) {
    		return true;
    	} else {
    		return false;
    	}
    }

    /**
     * Called by the drawer fragment if it thinks we haven't learnt it yet.
     */
    @Override
    public void onUserHasntLearntAboutDrawer() {
        if(mNavDrawerView!=null && mDrawerLayout != null) mDrawerLayout.openDrawer(mNavDrawerView);
    }
	
    /**
     * If we're a tablet design, this would likely not allow the fragment to set the title.
     */
    @Override
    public void setTitleFromChild(String title) {
        getActionBar().setTitle(title);
    }

    @Override
    public void onNavigationDrawerItemSelected(int resourceId) {
    	Fragment fragment = null;
	switch (resourceId) {
		case R.id.section_one_fragment:
    		fragment = new PreferencesViewFragment();
    	   	setFragmentsSavedState(fragment);
		break;
		case R.id.section_two_fragment:
    	   	fragment = new ViewPagerFragment();
    	   	setFragmentsSavedState(fragment);
		break;
		case R.id.section_three_fragment:
    	   	fragment = new MapFragment();
    	   	setFragmentsSavedState(fragment);
		break;
		default:
    		fragment = new ViewPagerFragment.GreenFragment();
			Log.e(getClass().getSimpleName(), "Couldn't match fragment id to fragment object.");
			break;
	}
	// Save the state of the old fragment from which we've just switched 
	if(mCurrentFragment!=null) {
		SavedState savedState = getSupportFragmentManager().saveFragmentInstanceState(mCurrentFragment);
		mSavedStates.put(mCurrentFragment.getClass().getSimpleName(), savedState);
	}
	getSupportFragmentManager().beginTransaction()
                .replace(R.id.container, fragment, fragment.getClass().getSimpleName())
                .commit();
	// Save a reference to the newly switched to fragment so we can save it's state on next switch
	mCurrentFragment = fragment;
	// Close the drawer if it's open so we can see the fragment
        if(mNavDrawerView!=null && mDrawerLayout != null) mDrawerLayout.closeDrawer(mNavDrawerView);
    }

    /**
     * Sets the fragments saved state by looking up its name in mSavedState.
     */
    private void setFragmentsSavedState(Fragment fragment) {
        SavedState savedState = mSavedStates.get(fragment.getClass().getSimpleName());
        if(savedState!=null) {
            FixedSavedState pp = new FixedSavedState(savedState);
            fragment.setInitialSavedState(pp);
        }
    }

}
END_HEREDOC

cat << END_HEREDOC > src/main/res/menu/nav_main_activity_options.xml
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"> 
    <item
        android:id="@+id/action_activity"
        android:orderInCategory="100"
        android:showAsAction="ifRoom|withText"
        android:title="Act action"/>
    <item
        android:id="@+id/preferences_option"
        android:orderInCategory="200"
        android:showAsAction="never"
        android:title="@string/preferences_option"/>
    <item
    	android:id="@+id/licences_option"
        android:showAsAction="never"
        android:title="@string/licences_option"/>
</menu>
END_HEREDOC

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/nav/NavigationDrawerFragment.java
package $PROJECT_PACKAGE_BASE_JAVA.nav;

import android.app.ActionBar;
import android.app.Activity;
import android.app.Fragment;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import $PROJECT_PACKAGE_BASE_JAVA.ChildFragmentsManager;
import $PROJECT_PACKAGE_BASE_JAVA.nav.NavigationDrawerCallbacks;
import $PROJECT_PACKAGE_BASE_JAVA.R;

/**
 * We inflate a ListView for the navigation drawer, set its adapter, and on list item click
 * we call a method which translates that position into a fragment id which we send to the 
 * host fragment or activity. It's current selected position is saved via the lifecycle methods
 * in order to restore it on rotation / configuration change.
 * 
 * Once the activity is attached, we get the overall DrawerLayout, set its shadow, calls a method on
 * the host if the user hasn't learnt about the drawer (which would normally open the drawer to show the
 * user), and sets a listener on the DrawerLayout which is a DrawerToggle, which sets an icon, invalidates the
 * host's option menus on open / close and ascertains if the user has learnt the drawer (i.e. opened it). 
 * 
 * We save the open / closed drawer state in the lifecycle methods, so if they say the drawer was already
 * opened then we open it in the onResume method call.
 * 
 * The option menu create method asks the host if it should set the options / title / actionbar, and the host
 * says yes, set it.
 */
public class NavigationDrawerFragment extends Fragment {

    private static final String STATE_SELECTED_POSITION = "selected_navigation_drawer_position";
    private static final String PREF_USER_LEARNED_DRAWER = "navigation_drawer_learned";
	private static final String STATE_DRAWER_OPEN = "drawer_open";
    private NavigationDrawerCallbacks mDrawerHolderCallbacks;
    private ChildFragmentsManager mChildFragmentManagerCallbacks;
    private ActionBarDrawerToggle mDrawerToggle;
    private ListView mDrawerListView;
    private int mCurrentSelectedPosition = 0;
    /**
     * If it is from saved instance, then we've just rotated or similar, so in this case
     * don't bother with doing something if the user hasn't learnt the navigation drawer, 
     * since we only do that on app start, else we may be opening the navigation drawer
     * to show the user it exists on each rotation -- which would be annoying to the user.
     */
    private boolean mFromSavedInstanceState;
    private boolean mUserLearnedDrawer;
	protected boolean mIsDrawerOpen;

    public NavigationDrawerFragment() {}

    /**
     * When we start, we restore 
     * - look if the user has learnt the drawer interaction, to do something if they have not.
     * - the last selected nav item position, to reselect it.
     * - the previous activity / fragment title, to reset it when the navigation drawer closes.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(getActivity());
        mUserLearnedDrawer = sp.getBoolean(PREF_USER_LEARNED_DRAWER, false);

        if (savedInstanceState != null) {
            mIsDrawerOpen = savedInstanceState.getBoolean(STATE_DRAWER_OPEN);
            mCurrentSelectedPosition = savedInstanceState.getInt(STATE_SELECTED_POSITION);
            mFromSavedInstanceState = true;
        }

    }
    
    @Override
    public void onResume() {
    	super.onResume();
        openNavivgationItem(mCurrentSelectedPosition);
        if(mIsDrawerOpen) {
        	View drawerView = getActivity().findViewById(R.id.navigation_drawer);
        	View drawerLayout = getActivity().findViewById(R.id.drawer_layout);
        	if(drawerView!=null && drawerLayout!=null && drawerLayout instanceof DrawerLayout) {
        		((DrawerLayout)drawerLayout).openDrawer(drawerView);
        	}
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putBoolean(STATE_DRAWER_OPEN, mIsDrawerOpen);
        outState.putInt(STATE_SELECTED_POSITION, mCurrentSelectedPosition);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mDrawerToggle.onConfigurationChanged(newConfig); // As specified by the DrawerToggle
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            mDrawerHolderCallbacks = (NavigationDrawerCallbacks) activity;
            mChildFragmentManagerCallbacks = (ChildFragmentsManager) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException("Activity must implement NavigationDrawerCallbacks and ChildFragmentManager.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mDrawerHolderCallbacks = null;
        mChildFragmentManagerCallbacks = null;
    }    

    /**
     * We inflate the layout for the drawer, a list view, set its adapter, 
     * when an item is pressed call selectItem(), and set its checked item if we've saved it.
     */
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mDrawerListView = (ListView) inflater.inflate(R.layout.fragment_navigation_drawer, container, false);
        mDrawerListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            		// Uncomment to prevent navigation drawer selecting the same fragment twice
            		//if(position == mCurrentSelectedPosition) {
            		//	return;
            		//}
            		mCurrentSelectedPosition = position;
            		if (mDrawerListView != null) {
            			mDrawerListView.setItemChecked(position, true);
            		}
            		openNavivgationItem(position);
            	}
        });
        mDrawerListView.setAdapter(new ArrayAdapter<String>(
                getActivity().getActionBar().getThemedContext(),
                android.R.layout.simple_list_item_activated_1,
                android.R.id.text1,
                new String[]{
                        getString(R.string.nav_item1),
                        getString(R.string.nav_item2),
                        getString(R.string.nav_item3),
                }));
        mDrawerListView.setItemChecked(mCurrentSelectedPosition, true);
        return mDrawerListView;
    }
    
    /**
     * When the parent activity is created, get grab the overall DrawerLayout, 
     * - set its shadow
     * - set up the DrawerToggle on it
     * - set the DrawerLayout's listener to the DrawerToggle
     * - and sync the DrawerToggle, and open it if the saved state tells us to.
     */
    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
    	super.onActivityCreated(savedInstanceState);

        DrawerLayout drawerLayout = (DrawerLayout) getActivity().findViewById(R.id.drawer_layout);
        drawerLayout.setDrawerShadow(R.drawable.drawer_shadow, GravityCompat.START);
        setupActionBarDrawerToggle(drawerLayout);

        if (!mUserLearnedDrawer && !mFromSavedInstanceState) {
        	mDrawerHolderCallbacks.onUserHasntLearntAboutDrawer();
        }

        drawerLayout.setDrawerListener(mDrawerToggle);

        // Defer code dependent on restoration of previous instance state.
        drawerLayout.post(new Runnable() {
            @Override
            public void run() {
                mDrawerToggle.syncState();
            }
        });
    }
    
    /**
     * - Setup the ActionBar's home as up
     * - Setup the ActionBar's home button as enabled
     * Then create the DrawerToggle, by 
     * - Setting its icon
     * - Telling it to invalidate the activity's options menu when the nav closes / opens, so to restore those 
     * And once we know the drawer is openeed, set the 'is learnt' preference to true.
     */
    private void setupActionBarDrawerToggle(DrawerLayout drawerLayout) {
		ActionBar actionBar = getActivity().getActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setHomeButtonEnabled(true);

        mDrawerToggle = new ActionBarDrawerToggle(
                getActivity(),                    
                drawerLayout,                    
                R.drawable.ic_drawer,             
                R.string.navigation_drawer_open,  
                R.string.navigation_drawer_close  
        ) {
            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                if (!isAdded()) {
                    return;
                }
                mIsDrawerOpen = false;
                getActivity().invalidateOptionsMenu(); // Restore context menus for fragments  + activity
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                if (!isAdded()) {
                    return;
                }

                if (!mUserLearnedDrawer) {
                    mUserLearnedDrawer = true;
                    SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(getActivity());
                    sp.edit().putBoolean(PREF_USER_LEARNED_DRAWER, true).apply();
                }

                mIsDrawerOpen = true;
                getActivity().invalidateOptionsMenu(); // Refresh, i.e. disable, context menus for fragments  + activity 
            }
        };
	}

    /**
     * When the drawer is open, set the title from the string resources, and save the old 
     * title in order to restore it later.
     * Else, if we have a previous activity title to restore, i.e. we've close the nav drawer,
     * and want to restore the previously visible fragment's title, restore it.
     */
    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        ActionBar actionBar = getActivity().getActionBar();
        if (mChildFragmentManagerCallbacks.shouldChildSetOptionsMenuAndActionBar(ChildFragmentsManager.NAV_MENU_FRAGMENT, null)) {
            inflater.inflate(R.menu.nav_drawer_fragment_options, menu);
            actionBar.setDisplayShowTitleEnabled(true);
            actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
            actionBar.setTitle(R.string.app_name);
        }
        super.onCreateOptionsMenu(menu, inflater);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (mDrawerToggle.onOptionsItemSelected(item)) { // As specified by the DrawerToggle's implementation
            return true;
        }
    	if (item.getItemId() == R.id.action_global) {
    		Toast.makeText(getActivity(), "Global action.", Toast.LENGTH_SHORT).show();
    		return true;
    	}
        return super.onOptionsItemSelected(item);
    }


    /**
     * From the position as passed from the ListView, select a fragment name, as represented
     * by a id resource, to then pass to the parent fragment / activity in order to open 
     * a navigation item.
     */
    private void openNavivgationItem(int position) {
        if (mDrawerHolderCallbacks != null) {
        	int fragmentResourceId = -1;
        	switch (position) {
			case 0:
				fragmentResourceId = R.id.section_one_fragment;
				break;
			case 1:
				fragmentResourceId = R.id.section_two_fragment;
				break;
			case 2:
				fragmentResourceId = R.id.section_three_fragment;
				break;
			default:
				fragmentResourceId = R.id.section_one_fragment;
				Log.e(getClass().getSimpleName(), "Couldn't match listview to fragment id.");
				break;
			}
            mDrawerHolderCallbacks.onNavigationDrawerItemSelected(fragmentResourceId);
        }
    }

}
END_HEREDOC

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/ChildFragmentsManager.java

package $PROJECT_PACKAGE_BASE_JAVA;

    /**
     * Implemented by fragments that are children of an FragmentActivity / parent Fragment
     *
     */
    public interface ChildFragmentsManager {
    public static int NORMAL_FRAGMENT = 0;
    public static int NAV_MENU_FRAGMENT = 1;
    /**
     * Used by the child fragment when it's about to show the options menu
     * @param fragmentType a static int on ChildFragmentsManager
     * @param fragmentName not currently used
     */
    boolean shouldChildSetOptionsMenuAndActionBar(int fragmentType, String fragmentName);
    /**
     * Used by the child instead of setTitle(), since the parent Fragment / FragmentActivity may want to control this itself.
     * @param title
     */
    void setTitleFromChild(String title);
}
END_HEREDOC

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/nav/NavigationDrawerCallbacks.java

package $PROJECT_PACKAGE_BASE_JAVA.nav;

    /**
     * Implemented by the Activity / Fragment that contains a navigation menu
     */
    public interface NavigationDrawerCallbacks {
    /**
     * Used by the navigation drawer fragment to tell the main Fragment / FragmentActivity what screen to show
     */
    void onNavigationDrawerItemSelected(int resourceId);
    /**
     * Used by the navigation drawer fragment to tell the main Fragment / FragmentActivity that the user
     * has not yet learnt of the drawer, the main Fragment, depending on implementation, then opens it to show the user.
     */
    void onUserHasntLearntAboutDrawer();
}

END_HEREDOC

cat << END_HEREDOC > src/main/res/layout/fragment_navigation_drawer.xml
<ListView xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#cccc"
    android:choiceMode="singleChoice"
    android:divider="@android:color/transparent"
    android:dividerHeight="0dp" />
END_HEREDOC

cat << END_HEREDOC > src/main/res/layout/nav_drawer_main_layout.xml
<android.support.v4.widget.DrawerLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/drawer_layout"
    android:layout_width="match_parent"
    android:layout_height="match_parent" >

    <FrameLayout
        android:id="@+id/container"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

    <fragment
        android:id="@+id/navigation_drawer"
        android:name="$PROJECT_PACKAGE_BASE_JAVA.nav.NavigationDrawerFragment"
        android:layout_width="@dimen/navigation_drawer_width"
        android:layout_height="match_parent"
        android:layout_gravity="left" />
</android.support.v4.widget.DrawerLayout>
END_HEREDOC

cat << END_HEREDOC > src/main/res/menu/nav_drawer_fragment_options.xml
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <item
        android:id="@+id/action_global"
        android:showAsAction="withText|ifRoom"
        android:title="global"/>

</menu>
END_HEREDOC

cat << END_HEREDOC > src/main/res/values/ids.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <item type="id" name="section_one_fragment" />
    <item type="id" name="section_two_fragment" />
    <item type="id" name="section_three_fragment" />
</resources>
END_HEREDOC

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/PreferencesViewFragment.java
package $PROJECT_PACKAGE_BASE_JAVA;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.Menu;
import android.widget.TextView;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;
import android.preference.PreferenceManager;

import $PROJECT_PACKAGE_BASE_JAVA.ChildFragmentsManager;
import $PROJECT_PACKAGE_BASE_JAVA.R;

public class PreferencesViewFragment extends Fragment {

    private ChildFragmentsManager mChildFragmentsManager;

	public PreferencesViewFragment() {}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    	setHasOptionsMenu(true);
        View rootView = inflater.inflate(R.layout.drawer_item_one_fragment, container, false);
        return rootView;
    }
    
    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
        	mChildFragmentsManager = (ChildFragmentsManager) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException("Activity must implement ChildFragmentsManager.");
        }
    }
    
    @Override
    public void onResume() {
    	super.onResume();
        mChildFragmentsManager.setTitleFromChild(getString(R.string.drawer_item_one_title));
        String preferenceString = PreferenceManager
          	.getDefaultSharedPreferences(getActivity().getApplicationContext())
           	.getString(getString(R.string.settings_edittext_key), "EditTextPreference preference not set yet.");
        TextView preferencesTextView = (TextView) getView().findViewById(R.id.main_activity_preferences_string_textview);
        preferencesTextView.setText(preferenceString);
    }
    
    /**
     * Setting the title here since, an options menu invalidation may change the title in the nav bar
     */
    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
    	super.onCreateOptionsMenu(menu, inflater);
        if (mChildFragmentsManager.shouldChildSetOptionsMenuAndActionBar(ChildFragmentsManager.NORMAL_FRAGMENT, null)) {
            inflater.inflate(R.menu.drawer_item_one_menu, menu);
            mChildFragmentsManager.setTitleFromChild(getString(R.string.drawer_item_one_title));
        }
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	if (item.getItemId() == R.id.drawer_item_one_menu_action) {
    		Toast.makeText(getActivity(), "Fragment one.", Toast.LENGTH_SHORT).show();
    		return true;
    	}
    	return super.onOptionsItemSelected(item);
    }

}
END_HEREDOC

cat << END_HEREDOC > src/main/res/layout/drawer_item_one_fragment.xml
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:id="@+id/frag1_rl"
    >

     <TextView
        android:id="@+id/main_activity_preferences_string_textview"
        android:layout_width="wrap_content"
        android:layout_below="@id/main_activity_customview"
        android:layout_centerHorizontal="true"
        android:layout_height="wrap_content"
        />

     <EditText
         android:id="@+id/section_label"
         android:inputType="text"
         android:layout_width="wrap_content"
         android:layout_height="wrap_content"
         android:layout_centerHorizontal="true"
         android:layout_below="@+id/main_activity_preferences_string_textview"
         android:text="1" >
     </EditText>

</RelativeLayout>
END_HEREDOC

cat << END_HEREDOC > src/main/res/menu/drawer_item_one_menu.xml
<menu xmlns:android="http://schemas.android.com/apk/res/android" >
    <item
        android:id="@+id/drawer_item_one_menu_action"
        android:orderInCategory="50"
        android:showAsAction="always"
        android:title="frag"/>
</menu>
END_HEREDOC




echo "###---> Creating Services code, including test fragment and Retrofit service classes"

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/ServiceExampleFragment.java
package $PROJECT_PACKAGE_BASE_JAVA;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import android.view.ViewGroup;

import com.squareup.otto.Subscribe;

import $PROJECT_PACKAGE_BASE_JAVA.services.RecentPostsService;
import $PROJECT_PACKAGE_BASE_JAVA.services.XmlTestService;

public class ServiceExampleFragment extends Fragment {

    private ChildFragmentsManager mChildFragmentsManager;
    private TextView mJsonTextView;
    private TextView mXmlTextView;

    public ServiceExampleFragment() {}
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    	setHasOptionsMenu(true);
        View rootView = inflater.inflate(R.layout.services_example_fragment, container, false);
        mJsonTextView = (TextView) rootView.findViewById(R.id.services_example_fragment_json_textview);
        mXmlTextView = (TextView) rootView.findViewById(R.id.services_example_fragment_xml_textview);
        return rootView;
    }
    
    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
        	mChildFragmentsManager = (ChildFragmentsManager) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException("Activity must implement ChildFragmentsManager.");
        }
        Application.getEventBus().register(this);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        Application.getEventBus().unregister(this);
    }

    @Override
    public void onResume() {
    	super.onResume();
        new RecentPostsService().fetch(0, 10);
        new XmlTestService().fetch();
    }

    @Subscribe
    public void onRecentPosts(RecentPostsService.RecentPosts posts) {
        if(mJsonTextView!=null && posts!=null && posts.getPosts()!=null) {
            String s = "";
            for (RecentPostsService.RecentPosts.Post p : posts.getPosts()) {
                s += "\nTitle: " + p.getContent() + "\n";
            }
            mJsonTextView.setText(s);
        }
    }

    @Subscribe
    public void onRecentPostsError(RecentPostsService.RecentPostsError error) {
        if(mJsonTextView!=null && error!=null) {
            mJsonTextView.setText("Error code: " + error.responseCode + ", isNetwork: " + error.isNetworkError);
        }
    }

    @Subscribe
    public void onXmlTest(XmlTestService.Hi posts) {
        // Always errors in this example
    }

    @Subscribe
    public void onXmlTestError(XmlTestService.HiError error) {
        if(mXmlTextView!=null) {
            mXmlTextView.setText("Error code: " + error.responseCode + ", isNetwork: " + error.isNetworkError);
        }
    }

}
END_HEREDOC

cat << END_HEREDOC > src/main/res/layout/services_example_fragment.xml
<ScrollView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:id="@+id/services_example_scrollview"
    >
    <RelativeLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:id="@+id/services_example_fragment_rl"
        >

        <TextView
            android:id="@+id/services_example_fragment_xml_title_textview"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Badly formatted xml:"
            android:textStyle="bold"
            android:layout_alignParentTop="true"
            android:layout_centerHorizontal="true" />

        <TextView
            android:id="@+id/services_example_fragment_xml_textview"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Loading..."
            android:freezesText="true"
            android:padding="20dp"
            android:layout_below="@+id/services_example_fragment_xml_title_textview"
            android:layout_centerHorizontal="true" />

        <TextView
            android:id="@+id/services_example_fragment_json_title_textview"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textStyle="bold"
            android:text="Valid Json:"
            android:layout_below="@+id/services_example_fragment_xml_textview"
            android:layout_centerHorizontal="true"
            />

        <TextView
            android:id="@+id/services_example_fragment_json_textview"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Loading..."
            android:freezesText="true"
            android:padding="20dp"
            android:layout_below="@+id/services_example_fragment_json_title_textview"
            android:layout_centerHorizontal="true"
            />

    </RelativeLayout>

</ScrollView>
END_HEREDOC

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/networking/ErrorResponse.java
package $PROJECT_PACKAGE_BASE_JAVA.networking;

public class ErrorResponse {
    public int responseCode;
    public String responseMessage;
    public String url;
    public boolean isNetworkError;

    public void fill(int httpCode, String errorMessage, String url, boolean isNetworkError) {
       this.responseCode = httpCode;
       this.responseMessage = errorMessage;
       this.url = url;
       this.isNetworkError = isNetworkError;
    }

    public int getResponseCode() {
        return responseCode;
    }

    public void setResponseCode(int responseCode) {
        this.responseCode = responseCode;
    }

    public String getResponseMessage() {
        return responseMessage;
    }

    public void setResponseMessage(String responseMessage) {
        this.responseMessage = responseMessage;
    }
}
END_HEREDOC

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/networking/MessageBusService.java
package $PROJECT_PACKAGE_BASE_JAVA.networking;

import android.os.AsyncTask;
import android.util.Log;

import com.google.gson.Gson;

import $PROJECT_PACKAGE_BASE_JAVA.Application;

import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.converter.Converter;
import retrofit.converter.GsonConverter;

/**
 * Perform a call on a RetroFit service and sends the result or error to the event bus.
 */
public class MessageBusService<ReturnResult, ServiceClass> {

    private static final String TAG = MessageBusService.class.getSimpleName();

    public static abstract class GetResult<ReturnResult, ServiceClass>  {
        public abstract ReturnResult getResult(ServiceClass mService);
    }

    public void fetch(String endPoint,
                     Class<ServiceClass> serviceClass,
                     ErrorResponse errorResponse,
                     final GetResult<ReturnResult, ServiceClass> getResult) {
        fetch(endPoint, serviceClass, errorResponse, new GsonConverter(new Gson()), getResult);
    }

    public void fetch(final String endPoint,
                      Class<ServiceClass> serviceClass,
                      final ErrorResponse errorResponse,
                      Converter converter,
                      final GetResult<ReturnResult, ServiceClass> getResult) {

        // Create the Retrofit adapter based on the service class
        final RestAdapter restAdapter = new RestAdapter.Builder()
                .setEndpoint(endPoint)
                .setConverter(converter)
                .build();
        final ServiceClass service = restAdapter.create(serviceClass);

        // Call the service in an async task, sending the success or error to the event bus
        new AsyncTask<Void, Void, ReturnResult>() {
            @Override
            protected ReturnResult doInBackground(Void... params) {
                try {
                    Log.d(TAG, "Attempting to fetch result from base url: " + endPoint);
                    ReturnResult res = getResult.getResult(service);
                    if(res!=null) {
                        Log.d(TAG, "Fetched : " + res.toString() + " from " + endPoint);
                    }
                    return res;
                } catch (RetrofitError e) {
                    errorResponse.fill(e.getResponse().getStatus(),
                                       e.getResponse().getReason(),
                                       e.getResponse().getUrl(),
                                       e.isNetworkError());
                    return null;
                } catch(Exception e1) {
                    Log.e(TAG, "Unknown error", e1);
                    return null;
                }
            }

            @Override
            protected void onPostExecute(ReturnResult res) {
                if(res!=null) {
                    super.onPostExecute(res);
                    Application.getEventBus().post(res);
                }  else if(res==null && errorResponse!=null) {
                    Application.getEventBus().post(errorResponse);
                }
            }
        }.execute();
    }
}
END_HEREDOC

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/services/RecentPostsService.java
package $PROJECT_PACKAGE_BASE_JAVA.services;

import $PROJECT_PACKAGE_BASE_JAVA.networking.ErrorResponse;
import $PROJECT_PACKAGE_BASE_JAVA.networking.MessageBusService;
import $PROJECT_PACKAGE_BASE_JAVA.networking.MessageBusService.GetResult;

import java.util.List;

import retrofit.http.GET;
import retrofit.http.Path;

public class RecentPostsService {

    private MessageBusService<RecentPosts, RecentPostsServiceInterface> mService;

    public RecentPostsService() {
        mService = new MessageBusService<>();
    }

    public void fetch(final int start, final int num) {
        mService.fetch(
            "https://android-manchester.co.uk/api/rest",
            RecentPostsServiceInterface.class,
            new RecentPostsError(),
            new GetResult<RecentPosts, RecentPostsServiceInterface>() {
                @Override public RecentPosts getResult(RecentPostsServiceInterface service) {
                    return service.go(start, num);
                }
            });
    }

    public static interface RecentPostsServiceInterface {
        @GET("/post/{start}/{num}")
        RecentPosts go(@Path("start") int start, @Path("num") int num);
    }

    public static class RecentPosts {

        private List<Post> posts;

        public List<Post> getPosts() {
            return posts;
        }

        public void setPosts(List<Post> posts) {
            this.posts = posts;
        }

        public static class Post {
            private String content;

            public String getContent() {
                return content;
            }

            public void setContent(String content) {
                this.content= content;
            }
        }
    }

    public static class RecentPostsError extends ErrorResponse {}
}
END_HEREDOC

cat << END_HEREDOC > src/main/java/$PROJECT_PACKAGE_BASE_DIRS/services/XmlTestService.java
package $PROJECT_PACKAGE_BASE_JAVA.services;

import $PROJECT_PACKAGE_BASE_JAVA.networking.ErrorResponse;
import $PROJECT_PACKAGE_BASE_JAVA.networking.MessageBusService;
import org.simpleframework.xml.Attribute;
import org.simpleframework.xml.Element;
import org.simpleframework.xml.Root;
import org.simpleframework.xml.Text;

import retrofit.converter.SimpleXMLConverter;
import retrofit.http.GET;

public class XmlTestService {

    private final MessageBusService<Hi, XmlServiceInterface> mService;

    public XmlTestService() {
        mService = new MessageBusService<>();
    }

    public void fetch() {
        mService.fetch(
            "http://denevell.org",
            XmlServiceInterface.class,
            new HiError(),
            new SimpleXMLConverter(),
            new MessageBusService.GetResult<Hi, XmlServiceInterface>() {
                    @Override public Hi getResult(XmlServiceInterface service) {
                        return service.list();
                    }
                });
    }

    public static interface XmlServiceInterface {
        @GET("/xml1.xml")
        Hi list();
    }

    @Root
    public static class Hi {
        @Element private There there;
        public There getThere() { return there; }
        public void setThere(There there) { this.there = there; }
        public static class There {
            @Attribute private String yo;
            @Text private String value;
            public String getYo() { return yo; }
            public void setYo(String yo) { this.yo = yo; }
            public String getValue() { return value; }
            public void setValue(String value) { this.value = value; }
        }
    }

    public static class HiError extends ErrorResponse {}
}
END_HEREDOC



echo "###---> Creating dimens.xml"

cat << END_HEREDOC > src/main/res/values/dimens.xml
<resources>
    <!--
         Per the design guidelines, navigation drawers should be between 240dp and 320dp:
         https://developer.android.com/design/patterns/navigation-drawer.html
    -->
    <dimen name="navigation_drawer_width">240dp</dimen>
</resources>
END_HEREDOC



echo "###---> Creating directory of projects for Eclipse to import (would be AARs in Gradle)"

mkdir eclipse_subprojects
cd eclipse_subprojects
# Android SDK library projects
if [ -h actionbar_appcompat ]; then 
	rm actionbar_appcompat 
fi
ln -s $ANDROID_HOME/extras/android/support/v7/appcompat/ actionbar_appcompat
if [ -h google_play ]; then 
	rm google_play
fi
ln -s $ANDROID_HOME/extras/google/google_play_services/libproject/google-play-services_lib/ google_play
# PagerSlidingTabStrip import
git clone https://github.com/astuetz/PagerSlidingTabStrip.git -b v1.0.1
echo "android.library.reference.1=../../actionbar_appcompat" >> PagerSlidingTabStrip/library/project.properties 
sed -i s/target=.*/target=android-19/g PagerSlidingTabStrip/library/project.properties
cat << END_HEREDOC > PagerSlidingTabStrip/library/.project
<?xml version="1.0" encoding="UTF-8"?>
<projectDescription>
	<name>PagerSlidingTabStrip</name>
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
cat << END_HEREDOC > PagerSlidingTabStrip/library/.classpath
<?xml version="1.0" encoding="UTF-8"?>
<classpath>
        <classpathentry kind="src" path="src"/>
        <classpathentry kind="src" path="gen"/>
        <classpathentry exported="true" kind="con" path="com.android.ide.eclipse.adt.LIBRARIES"/>
        <classpathentry exported="true" kind="con" path="com.android.ide.eclipse.adt.DEPENDENCIES"/>
        <classpathentry kind="con" path="com.android.ide.eclipse.adt.ANDROID_FRAMEWORK"/>
        <classpathentry kind="output" path="bin/classes"/>
</classpath>
END_HEREDOC
cd ..



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
android.library.reference.1=eclipse_subprojects/google_play
android.library.reference.2=eclipse_subprojects/actionbar_appcompat
android.library.reference.3=eclipse_subprojects/PagerSlidingTabStrip/library
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



