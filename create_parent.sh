#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

simpleusage="$0 artifactId [directory [-c]] [-g] [-i] [-v]"

usage() {
    cat <<EOF
NAME
    $0 - Create a parent pom in the given directory.

SYNOPSYS
    $0 [ -h ]
       [ --help ]
    or
    $simpleusage

DESCRIPTION
    For a java project, this creates an empty parent pom in the specified
    directory.

    directory is the name or path that the project should be created in. If no
    directory is specified, the new project is created in the current directory.


BEHAVIOR
    * traverse to the directory, if set
    * execute a mvn incantation
    * exit 0

OPTIONS
    -c --create-dir
        Recursively create the directory if it doesnt exist. The command will
        fail otherwise.
    -g --github-gitignore
        Download the github sample Java gitignore. Useful when you don't have
        one setup.
    -h --help
        Display this message and exit 0
    -i --git-init
        Initialize a git repo in the directory that the parent exists in.
    -v --verbose
        Be verbose.

ERRORS
    If any command fails, its error is written to standard output.

EXIT VALUE
    Returns 0 if successful, 1 otherwise.

EXAMPLE
    $ $0 myproject-parent

MORE
    See the maven documentation on naming conventions for packages:
        https://maven.apache.org/guides/mini/guide-naming-conventions.html

EOF
}

create_dir=false;
github_gitignore=false;
git_init=false;
verbose=false;
logfile=/dev/null;

for arg in $@; do
    case $arg in
        -h|--help)
            usage
            exit 0
            ;;
        -c|--create-dir)
            create_dir=true;
            ;;
        -g|--github-gitignore)
            github_gitignore=true;
            ;;
        -i|--git-init)
            git_init=true;
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
    if [ "$create_dir" = true ] ; then
        echo "ERROR: '--create-dir' was specified when the directory wasn't set."
        echo "Usage: $simpleusage"
        exit 1
    fi
fi

echo "Creating a parent pom named '$artifactId' in '$dir'";

if [ "$create_dir" = true ] ; then
    mkdir -p $dir
fi

echo -n "pushd $dir" > $logfile
pushd $dir > $logfile

echo "Using maven to generate the file"

mvn \
  archetype:generate \
  -DarchetypeGroupId=org.codehaus.mojo.archetypes \
  -DarchetypeArtifactId=pom-root \
  -DarchetypeVersion=RELEASE \
  -DartifactId=$artifactId \
  -DgroupId="com.$USER.$artifactId" \
  -Dversion=0.0.1 \
  -DinteractiveMode=false > $logfile

echo "Maven successful"

if [ "$github_gitignore" = true ] ; then

    echo -n "pushd $artifactId " > $logfile
    pushd $artifactId > $logfile

    # Creates gitignore
    touch .gitignore
    echo "# Gitignore from Github's Java gitignore:" >> .gitignore
    echo '# https://raw.githubusercontent.com/github/gitignore/master/Java.gitignore' \
        >> .gitignore
    curl \
        --silent \
        'https://raw.githubusercontent.com/github/gitignore/master/Java.gitignore' \
        >> .gitignore

    echo -n "popd " > $logfile
    popd > $logfile
fi

if [ "$git_init" = true ] ; then

    echo -n "pushd $artifactId " > $logfile
    pushd $artifactId > $logfile

    git init

    git commit --allow-empty -m 'Initial Commit.'

    git add .

    git commit -m "Added the '$artifactId' maven artifact."

    echo -n "popd " > $logfile
    popd > $logfile
fi

echo "Success"
