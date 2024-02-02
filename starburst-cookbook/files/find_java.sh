#!/usr/bin/env bash
###############################################################################
# Find the appropriate Java binary folder and display it to stdout.
# This is used by the install.yml playbook to set JAVA_HOME.
# Parameters:
#  $1: The Java Major Version - i.e. "11" or "17"
# Example:
#   find_java.sh 17
# If found, outputs the path to stdout and returns with exit code 0
# If not found, outputs an error message to stderr and returns with exit code 1
#
# Copyright Starburst Data, Inc. All rights reserved.
#
# THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF STARBURST DATA.
# The copyright notice above does not evidence any
# actual or intended publication of such source code.
#
# Redistribution of this material is strictly prohibited.
###############################################################################

java_version() {
    # The one argument is the location of java (either $JAVA_HOME or a potential
    # candidate for JAVA_HOME.
    JAVA="$1"/bin/java
    "$JAVA" -version 2>&1 | grep "\(java\|openjdk\) version" | awk '{ print substr($3, 2, length($3)-2); }'
}

check_if_correct_java_version() {
    # Parameters:
    #   $1: The target Java major version (i.e. "17")
    #   $2: The the location of java (either $JAVA_HOME or a potential
    #       candidate for JAVA_HOME)
    # If $2 is empty return non-zero code.  We don't want false positives if /bin/java is
    # a valid java version because that will leave JAVA_HOME unset and the init.d scripts will
    # use the default java version, which may not be the correct version.
    if [ -z "$2" ]; then
        return 1
    fi
    # Get the version number of Java that's installed in the specified dir.
    JAVA_VERSION=$(java_version "$2")
    JAVA_MAJOR=$(echo "$JAVA_VERSION" | cut -d'.' -f1)
    # Determine if the Java version is acceptable.
    if [ "$JAVA_MAJOR" -eq "$1" ]; then
        printf "%s" "$2"
        return 0
    else
        return 1
    fi
}

###############################################################################
# Main routine
###############################################################################
if [ -z "$1" ]; then
    echo "Please provide a target Java major version (i.e. '11')."
    return 1
else
    TARGET_VER=$1
fi
# If Java version of $JAVA_HOME is not correct, then try to find it
# by looping through candidate Java directories.
if ! check_if_correct_java_version "$TARGET_VER" "$JAVA_HOME"; then
    java_found=false
    for candidate in \
        /usr/lib/jvm/java-11-* \
        /usr/lib/jvm/zulu-11 \
        /usr/lib/jvm/java-17-* \
        /usr/lib/jvm/zulu-17 \
        /usr/lib/jvm/default-java \
        /usr/java/default \
        / \
        /usr; do
        if [ -e "$candidate"/bin/java ]; then
            if check_if_correct_java_version "$TARGET_VER" "$candidate"; then
                java_found=true
                break
            fi
        fi
    done
fi
# If no appropriate java found then display error.
if [ "$java_found" = false ]; then
    echo "Required Java version could not be found, please install JDK $TARGET_VER" 1>&2
    exit 1
fi
