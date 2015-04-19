# maven-helper-scripts
-------------------------------

I maintain a number of scripts that are just wrappers around maven incantations.

This repo is that.

## Documentation

```bash
$ ls -1 *.sh
create_child.sh
create_parent.sh
```

### create_parent and create_child

For maven projects, I find a parent-and-child project a very good architecture.

Sample usage of these two together:

```bash
$ /path/to/create_parent.sh hooli-parent ~/code -c -g -i
...
$ cd hooli-parent
$ /path/to/create_child.sh web-server
$ /path/to/create_child.sh compression-technology
$ /path/to/create_child.sh mini-bus
```

##
