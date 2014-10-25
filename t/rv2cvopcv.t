use warnings;
use strict;

use Test::More tests => 4;
use t::LoadXS ();
use t::WriteHeader ();

t::WriteHeader::write_header("callchecker0", "t");
ok 1;
require_ok "Devel::CallChecker";
t::LoadXS::load_xs("rv2cvopcv", "t");
ok 1;

t::rv2cvopcv::test_rv2cv_op_cv();
ok 1;

1;
