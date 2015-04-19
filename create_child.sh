#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

simpleusage="$0 artifactId [parentDirectory] [-v]"

usage() {
    cat <<EOF
NAME
    $0 - Create a child pom in the given directory.

SYNOPSYS
    $0 [ -h ]
       [ --help ]
    or
    $simpleusage

DESCRIPTION
    For a java project, this creates an empty child pom in the specified
    directory.

    directory is the name or path that the project should be created in. If no
    directory is specified, the new project is created in the current directory.


BEHAVIOR
    * traverse to the directory, if set
    * execute a mvn incantation
    * exit 0

OPTIONS
    -h --help
        Display this message and exit 0
    -v --verbose
        Be verbose

ERRORS
    If any command fails, its error is written to standard output.

EXIT VALUE
    Returns 0 if successful, 1 otherwise.

EXAMPLE
    $ $0 code/foo/bar-parent -v

MORE
    See the maven documentation on naming conventions for packages:
        https://maven.apache.org/guides/mini/guide-naming-conventions.html

EOF
}

verbose=false;
logfile=/dev/null;

for arg in $@; do
    case $arg in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            verbose=true;
            logfile=/dev/tty
            ;;
    esac
done

# die if the wrong number of params.
if [ $# -lt 1 ] ; then
    echo "ERROR: expected at least one parameter. Use --help for more details."
    echo "Usage: $simpleusage"
    exit 1
fi

dir=$PWD;
artifactId=$1;

if [ $# -ge 2 ] ; then
    echo 'A directory was specified'
    dir=$2;
else
    if [ "$verbose" = true ] ; then
        echo "Defaulting to the current directory: '$pwd'"
    fi
fi

echo "Creating a child pom named '$artifactId' in '$dir'";

echo -n "pushd $dir" > $logfile
pushd $dir > $logfile

echo "Using maven to generate the file"

mvn \
    archetype:generate \
    -DarchetypeGroupId=org.apache.maven.archetypes \
    -DarchetypeArtifactId=maven-archetype-quickstart \
    -DarchetypeVersion=RELEASE \
    -DartifactId=$artifactId \
    -DgroupId="com.$USER.$artifactId" \
    -DinteractiveMode=false > $logfile

echo "Maven success!"
