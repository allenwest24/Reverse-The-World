#!/usr/bin/perl
use v5.16.0;
use warnings FATAL => 'all';
use autodie qw(:all);

use Test::Simple tests => 26;
use IO::Handle;

sub run_bad {
    my ($cmd) = @_;
    my $yy = `timeout -s 9 5 bash -c '$cmd'`;
    if ($? == 0) {
        say("# expected non-zero exit code");
        return "fail";
    }
    chomp $yy;
    #say "cmd = $cmd; yy = $yy";
    return $yy;
}

sub run_calc {
    my ($bin, $op, $xx, $yy) = @_;
    my $zz = -99;
    open my $calc, "-|",
        qq{timeout -s 9 5 ./$bin "$xx" "$op" "$yy"};
    while (<$calc>) {
        chomp;
        next unless /^\s*$xx\s+([\+\-\*\/])\s+$yy\s+=\s+(\d+)$/;
        next unless ($1 eq $op);
        $zz = int($2);
        last;
    }
    return $zz;
}

ok(run_calc("ccalc", "+", 5, 6) == 11, "c 5 + 6 = 11");
ok(run_calc("ccalc", "-", 30, 25) == 5, "c 30 - 25 = 5");
ok(run_calc("ccalc", "*", 7, 3) == 21, "c 7 * 3 == 21");
ok(run_calc("ccalc", "/", 11, 5) == 2, "c 11 / 5 == 2");

# For bad input, print a message starting "Usage:"
ok(run_bad("./ccalc 4 '%' 7") =~ /Usage/i, "c 4 % 7 = error");
ok(run_bad("./ccalc") =~ /Usage/i, "c no args = error");

ok(run_calc("acalc", "+", 5, 6) == 11, "a 5 + 6 = 11");
ok(run_calc("acalc", "-", 30, 25) == 5, "a 30 - 25 = 5");
ok(run_calc("acalc", "*", 7, 3) == 21, "a 7 * 3 == 21");
ok(run_calc("acalc", "/", 11, 5) == 2, "a 11 / 5 == 2");

# For bad input, print a message starting "Usage:"
ok(run_bad("./acalc 4 '%' 7") =~ /Usage/i, "a 4 % 7 = error");
ok(run_bad("./acalc") =~ /Usage/i, "a no args = error");
