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

sub run_fib {
    my ($bin, $xx) = @_;
    my $yy = `timeout -s 9 5 ./$bin "$xx"`;
    chomp $yy;
    $yy =~ /^\s*fib\((\d+)\)\s*=\s*(\d+)\s*$/ or return -99;
    $1 == $xx or return -2;
    $yy = $2;
    return int($yy);
}

ok(run_fib("cfib", 0) == 0, "cfib(0)");
ok(run_fib("cfib", 1) == 1, "cfib(1)");
ok(run_fib("cfib", 5) == 5, "cfib(5)");
ok(run_fib("cfib", 10) == 55, "cfib(10)");
ok(run_fib("cfib", 25) == 75025, "cfib(25)");

# For bad input, print a message starting "Usage:"
ok(run_bad("./cfib") =~ /Usage/i, "cfib()");
ok(run_bad("./cfib -7") =~ /Usage/i, "cfib(-7)");

ok(run_fib("afib", 0) == 0, "afib(0)");
ok(run_fib("afib", 1) == 1, "afib(1)");
ok(run_fib("afib", 5) == 5, "afib(5)");
ok(run_fib("afib", 10) == 55, "afib(10)");
ok(run_fib("afib", 25) == 75025, "afib(25)");

# For bad input, print a message starting "Usage:"
ok(run_bad("./afib") =~ /Usage/i, "afib()");
ok(run_bad("./afib -7") =~ /Usage/i, "afib(-7)");
