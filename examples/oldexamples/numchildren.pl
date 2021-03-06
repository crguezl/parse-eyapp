#!/usr/bin/perl -w
use strict;
use Rule6;
use Parse::Eyapp::Treeregexp;

sub TERMINAL::info { $_[0]{attr} }

my $severity = shift || 0;
my $parser = new Rule6();
$parser->YYData->{INPUT} = shift || '0*2';
my $t = $parser->Run;

my $transform = Parse::Eyapp::Treeregexp->new( 
  STRING => q{
    zero_times_whatever: TIMES(NUM($x)) and { $x->{attr} == 0 } => { $_[0] = $NUM }
  },
  SEVERITY => $severity,
  FIRSTLINE => 14,
)->generate;

$t->s(our @all);

print $t->str,"\n";
