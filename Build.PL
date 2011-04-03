{ use 5.006; }
use warnings;
use strict;

use Module::Build;

Module::Build->new(
	module_name => "Devel::CallChecker",
	dist_version => "0.000",
	license => "perl",
	configure_requires => {
		"Module::Build" => 0,
		"perl" => "5.006",
		"strict" => 0,
		"warnings" => 0,
	},
	build_requires => {
		"DynaLoader" => 0,
		"ExtUtils::CBuilder" => "0.15",
		"ExtUtils::ParseXS" => 0,
		"File::Spec" => 0,
		"IO::File" => "1.03",
		"Module::Build" => 0,
		"Test::More" => 0,
		"perl" => "5.006",
		"strict" => 0,
		"warnings" => 0,
	},
	requires => {
		"DynaLoader" => 0,
		"Exporter" => 0,
		"parent" => 0,
		"perl" => "5.006",
		"strict" => 0,
		"warnings" => 0,
	},
	dynamic_config => 0,
	meta_add => { distribution_type => "module" },
	create_makefile_pl => "passthrough",
	sign => 1,
)->create_build_script;

1;
