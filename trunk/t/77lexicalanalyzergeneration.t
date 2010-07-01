#!/usr/bin/perl -w
use strict;
my $nt;

BEGIN { $nt = 5 }
use Test::More tests=> 3*$nt;

SKIP: {
  skip "t/numlist.eyp not found", $nt unless ($ENV{DEVELOPER} && -r "t/numlist.eyp" && -x "./eyapp");

  unlink 't/numlist.pl';

  my $r = system(q{perl -I./lib/ eyapp -TC -s -o t/numlist.pl t/numlist.eyp});
  
  ok(!$r, "standalone option");

  ok(-s "t/numlist.pl", "modulino standalone exists");

  ok(-x "t/numlist.pl", "modulino standalone has execution permits");

  local $ENV{PERL5LIB};
  my $eyapppath = shift @INC; # Supress ~/LEyapp/lib from search path
  eval {

    $r = qx{t/numlist.pl -t -i -c '4 a b'};

  };

  ok(!$@,'t/numlist.eyp executed as standalone modulino');

  my $expected = q{
A_is_A_B(A_is_A_B(A_is_B(B_is_NUM(TERMINAL[4])),B_is_a(TERMINAL[a])),B_is_ID(TERMINAL[b]))
};
  $expected =~ s/\s+//g;
  $expected = quotemeta($expected);
  $expected = qr{$expected};

  $r =~ s/\s+//g;


  like($r, $expected,'AST for "4 a b"');

  unlink 't/numlist.pl';

}

SKIP: {
  skip "t/simplewithwhites.eyp not found", $nt unless ($ENV{DEVELOPER} && -r "t/simplewithwhites.eyp" && -r "t/inputfor77" && -x "./eyapp");

  unlink 't/simplewithwhites.pl';

  my $r = system(q{perl -I./lib/ eyapp -TC -s -o t/simplewithwhites.pl t/simplewithwhites.eyp});
  
  ok(!$r, "standalone option");

  ok(-s "t/simplewithwhites.pl", "modulino standalone exists");

  ok(-x "t/simplewithwhites.pl", "modulino standalone has execution permits");

  local $ENV{PERL5LIB};
  my $eyapppath = shift @INC; # Supress ~/LEyapp/lib from search path
  eval {

    $r = qx{t/simplewithwhites.pl -t -i -f t/inputfor77};

  };

  ok(!$@,'t/simplewithwhites.eyp executed as standalone modulino');

  my $expected = q{
A_is_A_d(A_is_a(TERMINAL[a]),TERMINAL[d])
};
  $expected =~ s/\s+//g;
  $expected = quotemeta($expected);
  $expected = qr{$expected};

  $r =~ s/\s+//g;


  like($r, $expected,'AST for file "t/inputfor77"');

  unlink 't/simplewithwhites.pl';

}

SKIP: {
  skip "t/tokensemdef.eyp not found", $nt unless ($ENV{DEVELOPER} && -r "t/tokensemdef.eyp" && -r "t/input2for77" && -x "./eyapp");

  unlink 't/tokensemdef.pl';

  my $r = system(q{perl -I./lib/ eyapp -TC -s -o t/tokensemdef.pl t/tokensemdef.eyp});
  
  ok(!$r, "standalone option");

  ok(-s "t/tokensemdef.pl", "modulino standalone exists");

  ok(-x "t/tokensemdef.pl", "modulino standalone has execution permits");

  local $ENV{PERL5LIB};
  my $eyapppath = shift @INC; # Supress ~/LEyapp/lib from search path
  eval {

    $r = qx{t/tokensemdef.pl -t -i -f t/input2for77};

  };

  ok(!$@,'t/tokensemdef.eyp executed as standalone modulino');

  my $expected = q{
A_is_A_B(A_is_A_B(A_is_B(B_is_NUM(TERMINAL[4])),B_is_a(TERMINAL[a])),B_is_ID(TERMINAL[b]))
};
  $expected =~ s/\s+//g;
  $expected = quotemeta($expected);
  $expected = qr{$expected};

  $r =~ s/\s+//g;


  like($r, $expected,'AST for file "t/input2for77"');

  unlink 't/tokensemdef.pl';

}
