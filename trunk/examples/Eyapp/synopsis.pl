#!/usr/bin/perl -w
use strict;
use Parse::Eyapp;
use Parse::Eyapp::Treeregexp;

sub TERMINAL::info {
  $_[0]{attr}
}

my $grammar = q{
  %right  '='     # Lowest precedence
  %left   '-' '+' # + and - have more precedence than = Disambiguate a-b-c as (a-b)-c
  %left   '*' '/' # * and / have more precedence than + Disambiguate a/b/c as (a/b)/c
  %left   NEG     # Disambiguate -a-b as (-a)-b and not as -(a-b)
  %tree           # Let us build an abstract syntax tree ...


  %token NUM = /([0-9]+(?:\.[0-9]+)?)/
  %token VAR = /([A-Za-z][A-Za-z0-9_]*)/

  %%
  line: 
      exp <%name EXPRESSION_LIST + ';'>  
        { $_[1] } /* list of expressions separated by ';' */
  ;

  /* The %name directive defines the name of the
     class to which the node being built belongs */
  exp:
      %name NUM  
      NUM            
    | %name VAR   
      VAR         
    | %name ASSIGN 
      VAR '=' exp 
    | %name PLUS 
      exp '+' exp    
    | %name MINUS 
      exp '-' exp 
    | %name TIMES  
      exp '*' exp 
    | %name DIV     
      exp '/' exp 
    | %name UMINUS 
      '-' exp %prec NEG 
    | '(' exp ')'  
        { $_[2] }  /* Let us simplify a bit the tree */
  ;

  %%
}; # end grammar

our (@all, $uminus);

Parse::Eyapp->new_grammar( # Create the parser package/class
  input=>$grammar,    
  classname=>'Calc', # The name of the package containing the parser
  #firstline=>10,    # String $grammar starts at line 10 (for error diagnostics)
  #outputfile => 'main',
); 
my $parser = Calc->new();                # Create a parser
$parser->input("2*-3+b*0;--2\n");       # Set the input
my $t = $parser->Run;                    # Parse it!
local $Parse::Eyapp::Node::INDENT=2;
print "Syntax Tree:",$t->str;

# Let us transform the tree. Define the tree-regular expressions ..
my $p = Parse::Eyapp::Treeregexp->new( STRING => q{
    { #  Example of support code
      my %Op = (PLUS=>'+', MINUS => '-', TIMES=>'*', DIV => '/');
    }
    constantfold: /TIMES|PLUS|DIV|MINUS/:bin(NUM($x), NUM($y)) 
      => { 
        my $op = $Op{ref($bin)};
        $x->{attr} = eval  "$x->{attr} $op $y->{attr}";
        $_[0] = $NUM[0]; 
      }
    uminus: UMINUS(NUM($x)) => { $x->{attr} = -$x->{attr}; $_[0] = $NUM }
    zero_times_whatever: TIMES(NUM($x), .) and { $x->{attr} == 0 } => { $_[0] = $NUM }
    whatever_times_zero: TIMES(., NUM($x)) and { $x->{attr} == 0 } => { $_[0] = $NUM }
  },
  #OUTPUTFILE=> 'main.pm'
);
$p->generate(); # Create the tranformations

$t->s($uminus); # Transform UMINUS nodes
$t->s(@all);    # constant folding and mult. by zero

local $Parse::Eyapp::Node::INDENT=0;
print "\nSyntax Tree after transformations:\n",$t->str,"\n";
