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

int cflags() {
  string d = getdubpath();

  auto dub = execute(
    ["dub", "describe"],
    ParameterDefaults!execute[1],
    ParameterDefaults!execute[2],
    ParameterDefaults!execute[3],
    d
  );

  if (dub.status != 0) {
    stderr.writefln("Dub describe failed");
    return 1;
  }
  auto describe = dub.output;
  auto j = parseJSON(describe);
  bool first = true;
  foreach (p; j["packages"].array) {
    foreach (pa; p["importPaths"].array) {
      auto path = p["path"].str ~ pa.str;
      if (first) {
        first = false;
      } else {
        write(" ");
      }
      std.stdio.write("-I=", path);
    }
  }
  return 0;
}

int help() {
  writeln("Extracts the D library include paths from the dub package manager configuration file");
  writeln("options:");
  writeln("\t--help\tDisplay help");
  writeln("\t--cflags\tRetrieve a list of the include paths in the form: -I=path ...");
  writeln("\t--dubpath\tGet the dub path from a project subdirectory");

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

int main(char [][] args) {
  try {
    foreach (a; args) {
      if (a == "--help") return help();
      if (a == "--cflags") return cflags();
      if (a == "--dubpath") return dubpath();
    }

    return help();
  } catch (Exception e) {
    writeln(e.msg);
    return 1;
  }
}
