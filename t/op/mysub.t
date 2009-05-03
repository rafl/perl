#!./perl

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

BEGIN { plan( tests => 11 ) }

{
    is(foo(), 42, 'sub can still be called at runtime, even before the declaration');

    my sub foo { 42 }

    BEGIN { ok(__PACKAGE__->can('foo'), 'sub exists at compile time') }
    ok(!__PACKAGE__->can('foo'), 'sub got removed for run time');

    is(foo(), 42, 'sub can still be called at runtime');
}

BEGIN { ok(!__PACKAGE__->can('foo'), 'sub got removed at end of scope during compile time') }
ok(!__PACKAGE__->can('foo'), "and doesn't exist at runtime either");

eval { foo() };
ok($@ =~ /^Undefined subroutine &main::foo called/, 'can not be called outside of its scope');

sub affe {
    my ($x) = @_;
    my sub tiger { $x }
    return tiger();
}

# my subs are created at compile time. they don't close over
# lexicals like anon subs.
is(affe(42), 42);
is(affe(23), 42);


sub fib { die 42; }

{
    my sub fib {
        my $n = shift;
        return $n < 2 ? $n : fib($n-1) + fib($n-2);
    }

    is(fib(8), 21, 'calls to itself within a mysub work');
}

eval { fib(8) };
ok($@ =~ /42/, 'normal sub still there after mysub is cleaned');
