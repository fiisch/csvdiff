#!/usr/bin/perl

# TODO:
#   * possibility to include/ignore some columns
#   * drop requirement to have csv files sorted by uid column
#   * drop requirement to have columns of csv files in same order
#
# Revision history:
#
# 2020-09-24  - Fiisch
#   * Added tests for comparing columns with internal structure. To have a baseline.
# 2020-09-09  - Fiisch
#   * Added option to specify CSV columns with internal structure and to
#     make script aware of it - so it does not report identical data structures
#     that manifest as differrent strings in the CSV file.
#     Options: --struct-cols (comma-separated list of columns with internal structure)
#              --struct-sep (separator of field of the internal column structure)
#   * Changed internal sorting of structured columns to case insensitive. General
#     behavior is not affected by this change.
# 2018-04-29  - Fiisch
#   * Added case-insensitive comparison (--no-case).
# 2018-04-26  - Fiisch
#   * ARGS are now parsed into one hash instead to many variables.
# 2018-04-25  - Fiisch
#   * Added simple test to check functionality.
#   * Added arguments parsing using Getopt::Long.
#   * Added --no-color option to suppress colorized output.
# 2018-03-01  - Fiisch
#   * First dirty version.

use strict;
use warnings;

use Text::CSV;
use Data::Dumper;
use Term::ANSIColor;
use Getopt::Long;
use feature 'fc';

# Set up and parse command line arguments.
# store ARGS here
my %opts=();
# optional --colsep1 , --colsep2 , --colsep-out
# default ,
$opts{'colsep1'}=',';
$opts{'colsep2'}=',';
$opts{'colsep-out'}=',';
# optional --no-color
# default false
$opts{'no-color'}=0;
# optional --no-case
# default value
$opts{'no-case'}=0;
# list of columns with internal structure. comma-separated list
$opts{'struct-cols'}='';
# separator of fields inside the structured column. default: comma
$opts{'struct-sep'}=',';

GetOptions ( \%opts,
  # mandatory --file1
  "file1=s",
  # mandatory --file2
  "file2=s",
  # mandatory --idcol
  "idcol=s",
  "colsep1=s",
  "colsep2=s",
  "colsep-out=s",
  "no-color",
  "no-case",
  "struct-cols=s",
  "struct-sep=s",
) or die("Error in command line arguments\n");

if(!defined $opts{'file1'}) {
  die "CSV file --file1 not specified.\n";
}
if(!defined $opts{'file2'}) {
  die "CSV file --file2 not specified.\n";
}
if(!defined $opts{'idcol'}) {
  die "Id column --idcol not specified.\n";
}

# Do the real work

our $csvout = undef;

sub printRed {
  my $string = shift;
  print color('red');
  print("$string");
  print color('reset');
}

sub printGreen {
  my $string = shift;
  print color('green');
  print("$string");
  print color('reset');
}

sub csvifyPrintLt {
  my $arr = shift;
  $csvout->combine(@$arr);
  if($opts{'no-color'}) {
    print("< " . $csvout->string() . "\n");
  } else {
    printRed("< " . $csvout->string() . "\n");
  }
}

sub csvifyPrintGt {
  my $arr = shift;
  $csvout->combine(@$arr);
  if($opts{'no-color'}) {
    print("> " . $csvout->string() . "\n");
  } else {
    printGreen("> " . $csvout->string() . "\n");
  }
}

sub csvifyPrint {
  my $arr = shift;
  $csvout->combine(@$arr);
  print("  " . $csvout->string() . "\n");
}

my $idcolumn = $opts{'idcol'};
my $colsep1 = $opts{'colsep1'};
my $colsep2 = $opts{'colsep2'};
my $colsep_out = $opts{'colsep-out'};
my $file1 = $opts{'file1'};
my $file2 = $opts{'file2'};
my $ignorecase = $opts{'no-case'};
my @structcols = split(',',$opts{'struct-cols'});
my $structsep = $opts{'struct-sep'};
my $structsepout = $opts{'struct-sep'};
# pipe is a special character in split, so we have to escape it
# we also need special structsep output var which we don't edit
if ($structsep eq '|') {
  $structsep = '\|';
}

# create parsers, open files
my $csv1 = Text::CSV->new ({binary=>1,auto_diag=>1,sep_char=>$colsep1});
my $csv2 = Text::CSV->new ({binary=>1,auto_diag=>1,sep_char=>$colsep2});
# cvsv writer for output, not bound to file, used only for STDOUTing
$csvout = Text::CSV->new ({binary=>1,auto_diag=>1,always_quote=>1,sep_char=>$colsep_out});
# open files with utf8, set STDOUT to utf8
open(my $fh1, '<:encoding(utf8)', $file1) or die "Cannot not open '$file1' $!.\n";
open(my $fh2, '<:encoding(utf8)', $file2) or die "Cannot not open '$file2' $!.\n";
binmode(STDOUT, ":utf8");

# get id column of file 1
my $header1 = $csv1->getline($fh1);
if (! defined $header1) {
  die "Cannot read header from '$file1' $!\n";
}
my $id1pos = undef;
my $tmp = 0;
foreach my $f (@$header1) {
  if ($f eq $idcolumn) {
    $id1pos = $tmp;
    last;
  }
  $tmp++;
}
if (! defined $id1pos) {
  die "Cannot find id column in header of '$file1' $!.\n";
}

# get id column of file 2
my $header2 = $csv2->getline($fh2);
if (! defined $header2) {
  die "Cannot read header from '$file2' $!.\n";
}
my $id2pos = undef;
$tmp = 0;
foreach my $f (@$header1) {
  if ($f eq $idcolumn) {
    $id2pos = $tmp;
    last;
  }
  $tmp++;
}
if (! defined $id1pos) {
  die "Cannot find id column in header of '$file2' $!.\n";
}

# init line buffers and helper vars
my $f1line = undef;
my $f2line = undef;
my $f1empty = 'false';
my $f2empty = 'false';
# compare
while (1) {
  # if file not empty, get another line
  if ($f1empty eq 'false') {
    $f1line = $csv1->getline($fh1);
  }
  if ($f2empty eq 'false') {
    $f2line = $csv2->getline($fh2);
  }
  # if line is undef, the file is empty (hides errors but we do not care)
  if (! defined $f1line) {
    $f1empty = 'true';
  }
  if (! defined $f2line) {
    $f2empty = 'true';
  }

  if ($f1empty eq 'false' and $f2empty eq 'true') {
    # file 2 at eof, print line from file 1
    print("$idcolumn: $f1line->[$id1pos]\n");
    csvifyPrintLt($f1line);
  } elsif ($f1empty eq 'true' and $f2empty eq 'false') {
    # file 1 at eof, print line from file 2
    print("$idcolumn: $f2line->[$id2pos]\n");
    csvifyPrintGt($f2line);
  } elsif ($f1empty eq 'true' and $f2empty eq 'true') {
    # both files at eof, break the loop
    last;
  } else {
    # both files have another line, compare the ID fields
    # if it is ok, compare other fields as well
    # if ID fileds do not match, write "whole line differs" kinda message
    if ($f1line->[$id1pos] ne $f2line->[$id2pos]) {
      # quick hack to get the IDs to output
      print("$idcolumn: $f1line->[$id1pos]\n");
      csvifyPrintLt($f1line);
      csvifyPrintGt($f2line);
      #those can be completely different lines so we do not compare fields
      next;
    }
    # IDs are the same, we compare the fields
    my @tmparr1 = ();
    my @tmphead1 = ();
    my @tmparr2 = ();
    for (my $ind = 0; $ind < scalar @$f1line; $ind++) {

      my $f1field = $f1line->[$ind];
      my $f2field = $f2line->[$ind];

      # if field has internal structure, we preprocess it for the compare
      if (grep(/^$header1->[$ind]$/, @structcols)) {
        # explode both fields to arrays, sort them alphabetically,
        # and join them together to make a string which will be passed
        # to standard compare below
        my @tmpa1 = split(/$structsep/, $f1field);
        my @tmpa2 = split(/$structsep/, $f2field);
        # sorting is generally case-insensitive and it does not matter for case-sensitive
        # comparison. original values of sorted fields are not changed so if they
        # differ in their case-ness, the final comparison will catch that
        my @tmpstruct1 = sort {fc($a) cmp fc($b)} @tmpa1;
        my @tmpstruct2 = sort {fc($a) cmp fc($b)} @tmpa2;

        $f1field = join($structsepout, @tmpstruct1);
        $f2field = join($structsepout, @tmpstruct2);
      }

      # if we are doing case-insensitive comparison.
      # de-case cannot be before sort, because it could invalidate separators
      # inside the structured field
      if ($ignorecase) {
        # we use fc because of unicode folding
        $f1field = fc($f1field);
        $f2field = fc($f2field);
      }

      # do the compare
      if ($f1field ne $f2field) {
        #write differences to temporary arrays
        push(@tmphead1,$header1->[$ind]);
        push(@tmparr1,$f1line->[$ind]);
        push(@tmparr2,$f2line->[$ind]);
      }
    }
    # if there were any differences, print the diff
    if (@tmparr1 or @tmparr2) {
      # quick hack to get the IDs to output
      print("$idcolumn: $f1line->[$id1pos]\n");
      csvifyPrint(\@tmphead1);
      csvifyPrintLt(\@tmparr1);
      csvifyPrintGt(\@tmparr2);
    }
  }
}

# cleanup
if (! $csv1->eof) {
  $csv1->error_diag();
}
close $fh1;

if (! $csv2->eof) {
  $csv2->error_diag();
}
close $fh2;
