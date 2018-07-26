/*
  Extracts the D library include paths from the dub package manager configuration file
  Uses `dub describe` to get the paths
*/

module app;

import std.stdio;
import std.process;
import std.json;
import std.file;
import std.traits;
import std.path;

bool option_maindir = false;

string[] getcflags() {
  string[] r;
  string d = getdubpath();

  auto dub = execute(
    ["dub", "describe"],
    ParameterDefaults!execute[1],
    ParameterDefaults!execute[2],
    ParameterDefaults!execute[3],
    d
  );

  if (dub.status != 0) {
    throw new Exception("Dub describe failed");
  }
  auto describe = dub.output;
  auto j = parseJSON(describe);
  foreach (p; j["packages"].array) {
    foreach (pa; p["importPaths"].array) {
      auto path = p["path"].str ~ pa.str;
      r ~= "-I=" ~ path;
    }
  }
  return r;
}

int cflags() {
  string r;
  bool first = true;

  auto all = getcflags();
  foreach (f; all) {
    if (first) {
      first = false;
    } else {
      r ~= " ";
    }
    r ~= f;
  }

  writeln(r);
  return 0;
}

int help() {
  writeln("Extracts the D library include paths from the dub package manager configuration file");
  writeln("commands:");
  writeln("\t\t--help\tDisplay help");
  writeln("\t--cflags\tRetrieve a list of the include paths in the form: -I=path ...");
  writeln("\t--dubpath\tGet the dub configuration file path from a project subdirectory");
  writeln("\t--exec arg..\tRun the command specified by the remaining arguments while replacing:");
  writeln("\t\t\"DUB_CONFIG_DUBPATH\"\twith the dub configuration file path ");
  writeln("\t\t\"DUB_CONFIG_CFLAGS\"\twith the cflags arguments list");
  writeln("options:");
  writeln("\t--maindir\tChanges the current directory to dubpath before running any external commands");

  return 0;
}

string getdubpath() {
  string notFoundStr = "dub.json not found in this or any parent directory";

  string buf = "";
  while (true) {
    string cur = buf.length ? buf : ".";
    if (!std.file.isDir(cur) || !std.file.exists(cur)) {
      throw new Exception(notFoundStr);
    }

    if (std.file.exists(cur ~ "/dub.json"))
      return cur;

    string nextbuf = buf.length ? buf ~ "/.." : "..";
    buf = nextbuf;

    string curAbs = buildNormalizedPath(absolutePath(cur));
    string bufAbs = buildNormalizedPath(absolutePath(buf));
    if (curAbs == bufAbs) {
      // root directory was reached
      throw new Exception(notFoundStr);
    }

  }
}

int dubpath() {
  string d = getdubpath();
  writeln(d);
  return 0;
}

int exec(char [][] args) {
  string [] r;
  foreach(i, a; args) {
    switch(a) {
      case "DUB_CONFIG_CFLAGS":
        r ~= getcflags();
        break;
      case "DUB_CONFIG_DUBPATH":
        r ~= getdubpath();
        break;
      default:
        r ~= cast(string)(a);
    }
  }
  if (option_maindir) std.file.chdir(getdubpath());
  wait(spawnProcess(r));

  return 0;
}

int main(char [][] args) {
  try {
    foreach (i, a; args[1 .. $]) {
      switch(a) {
        case "--help": return help();
        case "--cflags": return cflags();
        case "--dubpath": return dubpath();
        case "--exec": return exec(args[i + 1 .. $]);
        case "--maindir": option_maindir = true; break;
        default:
          stderr.writeln("Invalid argument: " ~ cast(string)(a));
          help();
          return 1;
      }
    }

    return help();
  } catch (Exception e) {
    writeln(e.msg);
    return 1;
  }
}
