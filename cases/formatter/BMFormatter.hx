import benchmark.Benchmark;
import sys.FileSystem;

// TODO: no IO variant
class BMFormatter {
	public static function main():Void {
		var dataSources = [
			{dir: "haxe", url: "https://github.com/HaxeFoundation/haxe.git", sub: "std"},
			{dir: "openfl", url: "https://github.com/openfl/openfl.git", sub: "src"},
			{dir: "lime", url: "https://github.com/openfl/lime.git", sub: "src"}
		];
		FileSystem.createDirectory("data");
		var args = [];
		for (source in dataSources) {
			args.push("-s");
			args.push('data/${source.dir}/${source.sub}');
			if (!FileSystem.exists('data/${source.dir}'))
				Sys.command('git clone ${source.url} --depth 1 data/${source.dir}');
		}
		Benchmark.benchmarkAll(
			// version setup
			(haxe) -> {
				installLibraries: haxe == "haxe3" ? [
					"benchmark-helper" => "gh://github.com/HaxeBenchmarks/benchmark-helper#90093c51193bf621a6a02910d45a341cef97820e",
					"formatter" => "haxelib:/formatter#1.9.1",
					"hashlink" => "haxelib:/hashlink#0.1.0",
					"haxeparser" => "gh://github.com/Simn/haxeparser#48160b190cacafb0003d0c8d085dca2c85e21e31",
					"hxargs" => "haxelib:/hxargs#3.0.2",
					"hxcpp" => "gh://github.com/HaxeFoundation/hxcpp",
					"hxcs" => "haxelib:/hxcs#3.4.0",
					"hxjava" => "haxelib:/hxjava#3.2.0",
					"hxjsonast" => "haxelib:/hxjsonast#1.0.1",
					"hxnodejs" => "haxelib:/hxnodejs#10.0.0",
					"hxparse" => "gh://github.com/Simn/hxparse#f61faa2021f2abb85360f997ff72c4156c891adc",
					"json2object" => "haxelib:/json2object#3.6.4",
					"tokentree" => "haxelib:/tokentree#1.0.23"
				] : [
					"benchmark-helper" => "gh://github.com/HaxeBenchmarks/benchmark-helper#90093c51193bf621a6a02910d45a341cef97820e",
					"formatter" => "haxelib:/formatter#1.9.1",
					"hashlink" => "haxelib:/hashlink#0.1.0",
					"haxeparser" => "gh://github.com/Simn/haxeparser#e5746bfc55c09a3694db42738ff575b91441971a",
					"hx3compat" => "haxelib:/hx3compat#1.0.3",
					"hxargs" => "haxelib:/hxargs#3.0.2",
					"hxcpp" => "gh://github.com/HaxeFoundation/hxcpp",
					"hxcs" => "haxelib:/hxcs#4.0.0-alpha",
					"hxjava" => "haxelib:/hxjava#4.0.0-alpha",
					"hxjsonast" => "haxelib:/hxjsonast#1.0.1",
					"hxnodejs" => "haxelib:/hxnodejs#10.0.0",
					"hxparse" => "gh://github.com/Simn/hxparse#f61faa2021f2abb85360f997ff72c4156c891adc",
					"json2object" => "haxelib:/json2object#3.6.4",
					"tokentree" => "haxelib:/tokentree#1.0.23"
				]
			},
			// target compile
			(haxe, target) -> {
				useLibraries: [
					"tokentree",
					"haxeparser",
					"hxparse",
					"json2object",
					"hxargs",
					"formatter",
					"benchmark-helper"
				],
				main: "formatter.Cli"
			},
			// target run
			(haxe, target) -> {
				var cwd = Sys.getCwd();
				for (source in dataSources) {
					Sys.setCwd('../data/${source.dir}');
					Sys.command('git checkout -- .');
					Sys.setCwd(cwd);
				}
				{
					args: args,
					timeout: 5 * 60
				};
			}
		);
	}
}
