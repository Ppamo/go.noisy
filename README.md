# go.noisy

This project is basically a docker image that contains a small binary application that write logs randomically every 12 seconds max, to stdout or stderr.

This project was generated as a tool to test log systems in Kubernetes.

## Usage:

### linux:
```shell
[FORCEIMAGEBUILD=1] [GOPATH=/path/to/go] bash run.sh
```

### cygwin:
```shell
[FORCEIMAGEBUILD=1] GOPATH=/c/Users/myuser/go bash run.sh
```

The script __run.sh__ calls the  script __build.sh__, this one runs a container based on _docker.io/golang:1.9.2_ to build the application, mounting the _GOPATH_ path as a volume to read the code and write the binary file.

Once the binary is generated, a new docker image is built from _scratch_, that contains only the application binary.   After the image is created the script runs a container.

If the md5sum from the binary does not change after the compilation, and the a docker image already exists, a new image is not built, but you can force the regeneration by setting __FORCEIMAGEBUILD=1__.

In __cygwin__ the _GOPATH_ variable should be compatible with __boot2docker__, so it should not contains the _"/cygdrive"_ prefix and should be in _"/c/Users/"_ since there is a default shared folder in virtualbox for this path.
