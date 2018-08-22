# dub-config
[![Build Status](https://travis-ci.org/kkontosis/dub-config.svg?branch=master)](https://travis-ci.org/kkontosis/dub-config)

D language helper build utility that extracts library include paths from the dub package manager configuration

## Usage

The main usage of `dub-config` is to get the include paths for an existing project with the `--cflags` parameter.

For example, if we have a dub project file in the following path:

`/Users/myself/Documents/Dev/myproject/dub.json`

with the following content:

```json
{
  "name": "Myproject",
  "description": "...",
  "authors": ["Myself"],
  "homepage": "https://github.com/myself/myproject",
  "license": "GPL-3.0",
  "dependencies": {
    "vibe-d": "~>0.7.23",
    "string-transform-d": "~>1.0.0"
  }
}
```

Running `dub-config --cflags` would yield the following result:

```bash
$ dub-config --cflags
-I=/Users/myself/Documents/Dev/myproject/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/openssl-1.1.6_1.0.1g/openssl/. -I=/Users/myself/.dub/packages/libevent-2.0.2_2.0.16/libevent/. -I=/Users/myself/.dub/packages/libasync-0.8.3/libasync/source/ -I=/Users/myself/.dub/packages/memutils-0.4.11/memutils/source/ -I=/Users/myself/.dub/packages/diet-ng-1.5.0/diet-ng/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/vibe-d-0.7.33/vibe-d/source/ -I=/Users/myself/.dub/packages/string-transform-d-1.0.0/string-transform-d/source/
```

We could chain `dub-config` with `dmd` to perform a custom build:

```bash
dmd -c $(dub-config --cflags) file.d
```

Other parameters of `dub-config` are documented by running `dub-config --help`.

## Compiling

Using a terminal type:

```bash
dub build
```

## Installation

After compiling `dub-config` copy the produced binary to any directory in PATH.

For Linux and Mac this could be:

```bash
sudo cp ./dub-config /usr/local/bin
```

For Windows we could copy `dub-config.exe` to any directory in PATH.
For example to: `C:\Windows\System32`

## License

`dub-config` is licensed under the `MIT License`

