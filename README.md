# `benchmark-runner`

This is a WIP benchmark runner for [`benchs.haxe.org`](https://benchs.haxe.org/). The library code is located in [`src`](src) and contains the main benchmark runner class as well as data structures to define Haxe versions, Haxe targets, benchmark compilations, and benchmark executions. Individual benchmarks are located in [`cases`](cases). This project requires `lix` (with shimmed `haxe` and `haxelib`) and `timeout` to be available in the `PATH`. The benchmark cases should be executed using at least Haxe 4.1, the runner then invokes `lix` to switch versions at runtime.

## Running a benchmark case - all versions and all targets

- `cd cases/<testcase>`
- `npx haxe run.hxml`

You will find test results in console output and in three JSON files inside subfolder `benchmark-run`.

For C++ and Hashlink targets you need environment variable `TOOLING_BASE` set to a folder that holds subfolders with different tool / library versions:

- `hashlink/hashlink-1.1` - installation of version 1.1 of Hashlink for Haxe 3
- `hashlink/hashlink-1.11` - installation of version 1.11 of Hashlink for Haxe 4
- `hashlink/hashlink-immix` - installation of immix GC branch of Hashlink for Haxe 4
- `hxcpp/hxcppHaxe3` - latest hxcpp with Cppia host compiled for Haxe 3
- `hxcpp/hxcppHaxe4` - latest hxcpp with Cppia host compiled for Haxe 4
- `hxcpp/hxcppHaxeNightly` - latest hxcpp with Cppia host compiled for Haxe nightly

You can edit `setup-*` files accordingly if you need a different setup to run benchmarks locally.
You might be able to ignore them and setup tooling in your path and then run specific version and target combinations. Benchmark-runner uses `*.sh` files since it runs on a Linux machine.

## Running a benchmark case with selected Haxe versions

- `cd cases/<testcase>`
- `export BENCHMARK_VERSIONS=haxe-nightly` or `set BENCHMARK_VERSIONS=haxe4,haxe-nightly`
- `npx haxe run.hxml`

Runs benchmark for all targets using Haxe 4.0.5 and Haxe nightly.

Available versions are:

- `haxe3` for Haxe 3.4.7
- `haxe4` for Haxe 4.0.5
- `haxe-nightly` for latest Haxe nightly build

## Running a benchmark case for specific targets

- `cd cases/<testcase>`
- `export BENCHMARK_TARGETS=java,jvm` or `set BENCHMARK_TARGETS=java,jvm`
- `npx haxe run.hxml`

Runs benchmark for `java` and `jvm` targets using all three Haxe versions.

You can use combinations of `BENCHMARK_VERSIONS` and `BENCHMARK_TARGETS`.

Available targets are:

- `cpp`
- `cppGCGen`
- `cppia`
- `cs`
- `eval`
- `hl`
- `hlc`
- `hlGCImmix`
- `hlcGCImmix`
- `java`
- `jvm`
- `js`
- `js-es6`
- `lua`
- `neko`
- `php`
- `python`

## stop benchmark runner from deleting out folder 

You can set `BENCHMARK_KEEP_BINARY=keep` to not delete binary folder after a run. 
Usually you want a clean out folder when switching between versions, but if you run a single version and / or target it can make sense to keep the binaries, 
so you can dissect them.
