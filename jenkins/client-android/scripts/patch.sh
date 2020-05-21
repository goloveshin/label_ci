#!/bin/bash

cd $(dirname "$(readlink -f "$0")")

source args_for_build.sh

cd $ARG__CHECKOUT_PATH

# patch gradle
sed -i "s@commandLine 'ndk-build'@commandLine project.android.ndkDirectory.absolutePath + '/ndk-build'@g" client/android/src/build.gradle

# patch build script
sed -i -e 's@./gradlew@./gradlew --offline@g' client/android/white_label/white_label.sh
sed -i -e 's@^build_@#build_@g' client/android/white_label/white_label.sh
sed -i -e 's@MAKEFLAGS=-j4@MAKEFLAGS=-j8@g' client/android/white_label/white_label.sh
sed -i -z 's@date_start=`date`\\n@date_start=`date`\\n${ARG__BUILD_FUNCTION}\\n@g' client/android/white_label/white_label.sh

# make global_data.sh
GLOBAL_DATA_SH=client/android/white_label/.global_data

echo "#!/bin/bash" > $GLOBAL_DATA_SH
echo "project_path=\$(dirname \"\$(readlink -f \"\$0\")\")/../../../../" >> $GLOBAL_DATA_SH
echo "sources_dir=\$project_path" >> $GLOBAL_DATA_SH
echo "working_dir=\$project_path/WORKING_DIR" >> $GLOBAL_DATA_SH
echo "mkdir -p \$working_dir" >> $GLOBAL_DATA_SH
echo "trunk_path=\$${ARG__CHECKOUT_PATH}" >> $GLOBAL_DATA_SH
echo "sdk_home=/home/jenkins/bin/sdk" >> $GLOBAL_DATA_SH
echo "ndk_home=/home/jenkins/bin/android-ndk-r19c" >> $GLOBAL_DATA_SH
echo "android_studio_home=/home/jenkins/bin/android-studio" >> $GLOBAL_DATA_SH
echo "java_home=/home/jenkins/bin/jdk1.8.0_201" >> $GLOBAL_DATA_SH
echo "bin_3rdparty_home=/home/jenkins/bin/Android_3rdparty_bin" >> $GLOBAL_DATA_SH

# make gradle.properties

GRADLE_PROPERTIES=client/android/src/gradle.properties

echo "org.gradle.parallel=true" > GRADLE_PROPERTIES
echo "org.gradle.daemon=true" >> GRADLE_PROPERTIES
echo "org.gradle.jvmargs=-Xmx6g" >> GRADLE_PROPERTIES
echo "org.gradle.configureondemand=true" >> GRADLE_PROPERTIES
