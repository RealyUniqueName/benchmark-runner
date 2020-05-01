package benchmark;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Benchmark {
	public static final TARGET_FILTER:Array<String> = {
		var env = Sys.getEnv("BENCHMARK_TARGETS");
		env != null ? env.split(",") : null;
	};
	public static final VERSION_FILTER:Array<String> = {
		var env = Sys.getEnv("BENCHMARK_VERSIONS");
		env != null ? env.split(",") : null;
	};
	public static final SKIP:CompileParams = {};

	static function createTargets():Array<Target>
		return [
			// cpp
			{
				name: "C++",
				id: "cpp",
				compile: "-cpp out/cpp",
				run: "out/cpp/Main",
			},
			{
				name: "C++ (GC Gen)",
				id: "cppGCGen",
				compile: "-cpp out/cppGCGen",
				run: "out/cppGCGen/Main",
				defines: ["HXCPP_GC_GENERATIONAL" => ""]
			},
			{
				name: "Cppia",
				id: "cppia",
				compile: "-cppia out/cppia.cppia",
				run: "haxelib run hxcpp out/cppia.cppia"
			},
			// cs
			{
				name: "C#",
				id: "cs",
				compile: "-cs out/cs",
				run: "mono out/cs/bin/Main.exe"
			},
			// eval
			{
				name: "Eval",
				id: "eval",
				compile: "" // eval is handled separately
			},
			// hl
			{
				name: "HashLink",
				id: "hl",
				init: "./setup-hl-stable.sh",
				compile: "-hl out/hl.hl",
				run: "hl out/hl.hl",
				installLibraries: ["hashlink" => "haxelib:/hashlink#0.1.0"]
			},
			{
				name: "HashLink/C",
				id: "hlc",
				init: "./setup-hl-stable.sh",
				compile: "-hl out/hlc/hlc.c",
				postCompile: "gcc -O3 -std=c11 -o out/hlc/hlc out/hlc/hlc.c -I out/hlc -lhl",
				run: "out/hlc/hlc",
				installLibraries: ["hashlink" => "haxelib:/hashlink#0.1.0"]
			},
			{
				name: "HashLink",
				id: "hlGCImmix",
				init: "./setup-hl-immix.sh",
				compile: "-hl out/hl.hl",
				run: "hl out/hl.hl",
				installLibraries: ["hashlink" => "haxelib:/hashlink#0.1.0"]
			},
			{
				name: "HashLink/C",
				id: "hlcGCImmix",
				init: "./setup-hl-immix.sh",
				compile: "-hl out/hlc/hlc.c",
				postCompile: "gcc -O3 -std=c11 -o out/hlc/hlc out/hlc/hlc.c -I out/hlc -lhl",
				run: "out/hlc/hlc",
				installLibraries: ["hashlink" => "haxelib:/hashlink#0.1.0"]
			},
			// java
			{
				name: "Java",
				id: "java",
				compile: "-java out/java",
				run: "java -jar out/java/Main.jar"
			},
			{
				name: "JVM",
				id: "jvm",
				compile: "-java out/jvm",
				defines: ["jvm" => ""],
				run: "java -jar out/jvm/Main.jar"
			},
			// js
			{
				name: "NodeJS",
				id: "js",
				compile: "-js out/js.js",
				installLibraries: ["hxnodejs" => "haxelib:/hxnodejs#10.0.0"],
				useLibraries: ["hxnodejs"],
				run: "node out/js.js"
			},
			{
				name: "NodeJS (ES6)",
				id: "js-es6",
				compile: "-js out/js-es6.js",
				installLibraries: ["hxnodejs" => "haxelib:/hxnodejs#10.0.0"],
				useLibraries: ["hxnodejs"],
				defines: ["js-es" => "6"],
				run: "node out/js-es6.js"
			},
			// lua
			{
				name: "Lua",
				id: "lua",
				compile: "-lua out/lua.lua",
				run: "lua out/lua.lua"
			},
			// neko
			{
				name: "Neko",
				id: "neko",
				compile: "-neko out/neko.n",
				run: "neko out/neko.n"
			},
			// php
			{
				name: "PHP",
				id: "php",
				compile: "-php out/php",
				defines: ["php7" => ""],
				run: "php out/php/index.php"
			},
			// python
			{
				name: "Python",
				id: "python",
				compile: "-python out/python.py",
				run: "python3 out/python.py"
			}
		];

	public static var VERSIONS:Array<Version> = {
		var haxe3targets:Array<Target> = [
			for (target in createTargets()) {
				switch (target.id) {
					case "jvm" | "hl" | "hlc" | "hlGCImmix" | "hlcGCImmix":
						continue;
					case "cs":
						target.installLibraries = ["hxcs" => "haxelib:/hxcs#3.4.0"];
					case "java":
						target.installLibraries = ["hxjava" => "haxelib:/hxjava#3.2.0"];
					case "cppia" | "cpp" | "cppGCGen":
						target.init = "./setup-hxcpp-haxe3.sh";
					case _:
				}
				target;
			}
		].concat([
				{
					name: "HashLink",
					id: "hlGCImmix",
					init: "./setup-hl-1.1.sh",
					compile: "-hl out/hl.hl",
					run: "hl out/hl.hl",
					installLibraries: ["hashlink" => "haxelib:/hashlink#0.1.0"]
				},
				{
					name: "HashLink/C",
					id: "hlcGCImmix",
					init: "./setup-hl-1.1.sh",
					compile: "-hl out/hlc/hlc.c",
					postCompile: "gcc -O3 -std=c11 -o out/hlc/hlc out/hlc/hlc.c -I out/hlc -lhl",
					run: "out/hlc/hlc",
					installLibraries: ["hashlink" => "haxelib:/hashlink#0.1.0"]
				}
			]);
		var haxe4targets:Array<Target> = [
			for (target in createTargets()) {
				switch (target.id) {
					case "cs":
						target.installLibraries = ["hxcs" => "haxelib:/hxcs#4.0.0-alpha"];
					case "java":
						target.installLibraries = ["hxjava" => "haxelib:/hxjava#4.0.0-alpha"];
					case "cppia" | "cpp" | "cppGCGen":
						target.init = "./setup-hxcpp-haxe4.sh";
					case _:
				}
				target;
			}
		];
		var haxeNightlytargets:Array<Target> = [
			for (target in createTargets()) {
				switch (target.id) {
					case "cs":
						target.installLibraries = ["hxcs" => "haxelib:/hxcs#4.0.0-alpha"];
					case "java":
						target.installLibraries = ["hxjava" => "haxelib:/hxjava#4.0.0-alpha"];
					case "cppia" | "cpp" | "cppGCGen":
						target.init = "./setup-hxcpp-haxeNightly.sh";
					case _:
				}
				target;
			}
		];		
		var vers:Array<Version> = [
			{
				name: "Haxe 3",
				id: "haxe3",
				lixId: "3.4.7",
				env: [],
				jsonOutput: "haxe3.json",
				targets: haxe3targets
			},
			{
				name: "Haxe 4",
				id: "haxe4",
				lixId: "4.0.5",
				env: [],
				jsonOutput: "haxe4.json",
				targets: haxe4targets
			},
			{
				name: "Haxe nightly",
				id: "haxe-nightly",
				lixId: "nightly",
				env: [],
				jsonOutput: "haxe-nightly.json",
				targets: haxeNightlytargets
			}
		];
		vers;
	};

	static var logPrefix:Array<String> = [];

	static function log(msg:String):Void {
		if (logPrefix.length > 0) {
			Sys.println('[${logPrefix.join(",")}] $msg');
		} else {
			Sys.println(msg);
		}
	}

	static function scmd(cmd:String, ?args:Array<String>):Int {
		log('  * $cmd $args');
		return Sys.command(cmd, args);
	}

	static function mapConcat<T>(maps:Array<Null<Map<String, T>>>):Map<String, T> {
		var ret = new Map<String, T>();
		for (map in maps) {
			if (map != null) {
				for (k => v in map)
					ret[k] = v;
			}
		}
		return ret;
	}

	static function arrConcat<T>(arrs:Array<Null<Array<T>>>):Array<T> {
		var ret = [];
		for (arr in arrs) {
			if (arr != null) {
				ret = ret.concat(arr);
			}
		}
		return ret;
	}

	static function installLibraries(libraries:Null<Map<String, String>>):Void {
		if (libraries != null)
			for (lib => url in libraries) {
				scmd("lix", ["install", url]);
			}
	}

	static function measure(fn:Void->Void):Float {
		var start = haxe.Timer.stamp();
		fn();
		var end = haxe.Timer.stamp();
		return end - start;
	}

	static function compile(version:Version, versionParams:CompileParams, target:Target, compileParams:CompileParams, runParams:RunParams):Bool {
		log('compiling ${target.name} ...');
		var haxeArgs = [];
		installLibraries(compileParams.installLibraries);
		for (lib in arrConcat([
			version.useLibraries,
			versionParams.useLibraries,
			target.useLibraries,
			compileParams.useLibraries
		])) {
			haxeArgs.push("-lib");
			haxeArgs.push(lib);
		}
		for (define => val in mapConcat([version.defines, versionParams.defines, target.defines, compileParams.defines])) {
			haxeArgs.push("-D");
			haxeArgs.push(val == "" ? define : '$define=$val');
		}
		for (cp in arrConcat([
			version.classPaths,
			versionParams.classPaths,
			target.classPaths,
			compileParams.classPaths
		])) {
			haxeArgs.push("-cp");
			haxeArgs.push(cp);
		}
		if (target.id == "eval") {
			haxeArgs.push("--run");
			haxeArgs.push(compileParams.main);
			if (runParams.args != null)
				haxeArgs = haxeArgs.concat(runParams.args);
		} else {
			haxeArgs.push("-main");
			haxeArgs.push(compileParams.main);
			haxeArgs = haxeArgs.concat(target.compile.split(" "));
		}
		if (scmd("haxe", haxeArgs) != 0)
			return false;
		if (target.postCompile != null && scmd(target.postCompile) != 0)
			return false;
		return true;
	}

	static function run(target:Target, compileParams:CompileParams, runParams:RunParams):Bool {
		if (target.run == null)
			return true;
		log('running ${target.name} ...');
		var runArgs = target.run.replace("Main", compileParams.main.split(".").pop()).split(" ");
		if (runParams.timeout != null) {
			runArgs.unshift('${runParams.timeout}');
			runArgs.unshift('${runParams.timeout}');
			runArgs.unshift('-k');
			runArgs.unshift("timeout");
		}
		if (runParams.args != null)
			runArgs = runArgs.concat(runParams.args);
		var runCmd = runArgs.shift();
		return scmd(runCmd, runArgs) == 0;
	}

	public static function benchmarkAll(versionSetup:(haxe:String) -> CompileParams, compileParams:(haxe:String, target:String) -> CompileParams,
			runParams:(haxe:String, target:String) -> RunParams):Void {
		if (!FileSystem.exists("benchmark-run"))
			FileSystem.createDirectory("benchmark-run");
		Sys.setCwd("benchmark-run");
		for (version in VERSIONS) {
			logPrefix = [version.id];
			if (VERSION_FILTER != null && !VERSION_FILTER.contains(version.id)) {
				log('skipping ${version.name} (BENCHMARK_VERSIONS)');
				continue;
			}
			var versionParams = versionSetup(version.id);
			if (versionParams == SKIP)
				continue;
			var targets = [
				for (target in version.targets) {
					if (TARGET_FILTER != null && !TARGET_FILTER.contains(target.id)) {
						log('skipping ${target.name} (BENCHMARK_TARGETS)');
						continue;
					}
					target;
				}
			];
			if (targets.length == 0) {
				log('skipping ${version.name} (no targets)');
				continue;
			}
			// version prepare
			log('preparing ${version.name} ...');
			scmd("lix", ["scope", "create"]);
			scmd("lix", ["install", "haxe", version.lixId]);
			scmd("lix", ["use", "haxe", version.lixId]);
			var resolvedVersion = {
				var proc = new sys.io.Process("haxe", ["-version"]);
				proc.exitCode();
				var version = (proc.stdout.readAll().toString() + proc.stderr.readAll().toString()).trim();
				proc.close();
				version;
			};
			log('resolved version: $resolvedVersion');
			installLibraries(mapConcat([version.installLibraries, versionParams.installLibraries]));
			var versionOutputs = [];
			// target setup, compile, and run
			for (target in targets) {
				logPrefix[1] = target.id;
				var compileParams = compileParams(version.id, target.id);
				if (compileParams == SKIP)
					continue;
				var runParams = runParams(version.id, target.id);
				if (target.init != null) {
					log('initialising ${target.name} ...');
					scmd(target.init);
				}
				installLibraries(mapConcat([target.installLibraries, compileParams.installLibraries]));
				var compileTime = 0.0;
				var runTime = 0.0;
				var compileSuccess = true;
				var runSuccess = true;
				if (target.id == "eval") {
					runTime = measure(() -> runSuccess = compile(version, versionParams, target, compileParams, runParams));
					log('run time: $runTime s');
				} else {
					compileTime = measure(() -> compileSuccess = compile(version, versionParams, target, compileParams, runParams));
					log('compile time: $compileTime s (${compileSuccess ? "success" : "FAILED"})');
					runTime = measure(() -> runSuccess = run(target, compileParams, runParams));
					log('run time: $runTime s (${runSuccess ? "success" : "FAILED"})');
				}
				// TODO: record failures
				if (compileSuccess && runSuccess)
					versionOutputs.push({
						name: target.name,
						compileTime: compileTime,
						time: runTime
					});
			}
			logPrefix.splice(1, logPrefix.length);
			// cleanup
			scmd("lix", ["scope", "delete"]);
			scmd("rm", ["-rf", "haxe_libraries"]);
			// record data
			if (versionOutputs.length > 0) {
				var archive:Array<Dynamic> = FileSystem.exists(version.jsonOutput) ? Json.parse(File.getContent(version.jsonOutput)) : [];
				archive.push({
					date: Date.now().toString(),
					haxeVersion: resolvedVersion,
					targets: versionOutputs
				});
				File.saveContent(version.jsonOutput, Json.stringify(archive));
			}
		}
	}
}
