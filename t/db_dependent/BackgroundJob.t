#!/usr/bin/perl

use Modern::Perl;
use C4::Auth qw( get_session );
use CGI qw ( -utf8 );
use Test::More tests => 18;

use Koha::Database;

BEGIN {
    use_ok('C4::BackgroundJob', qw( get id fetch name invoker progress status size set finish results clear ));
}
my $query = CGI->new;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $session = C4::Auth::get_session;
$session->flush;
my $sessionID = $session->id;
my $job;
ok( $job = C4::BackgroundJob->new($sessionID), "making job" );
ok( $job->id, "fetching id number" );

$job->name("George");
is( $job->name, "George", "testing name" );

$job->invoker("enjoys");
is( $job->invoker, "enjoys", "testing invoker" );

$job->progress("testing");
is( $job->progress, "testing", "testing progress" );

ok( $job->status, "testing status" );

$job->size("56");
is( $job->size, "56", "testing size" );

ok( C4::BackgroundJob->fetch( $sessionID, $job->id ), "testing fetch" );
$job->set( { key1 => 'value1', key2 => 'value2' } );
is( $job->get('key1'), 'value1', 'fetched extra value for key key1' );
is( $job->get('key2'), 'value2', 'fetched extra value for key key2' );

$job->set( { size => 666 } );
is( $job->size, "56", '->set() does not scribble over private object data' );

$job->finish("finished");
is( $job->status, 'completed', "testing finished" );

ok( $job->results, 'Test if we have results' );

my $second_job = C4::BackgroundJob->new( $sessionID, "making new job" );
is( ref( C4::BackgroundJob->fetch( $sessionID, $job->id ) ),        "C4::BackgroundJob", 'job_$jobid should be a C4::BackgroundJob for uncleared job 1' );
is( ref( C4::BackgroundJob->fetch( $sessionID, $second_job->id ) ), "C4::BackgroundJob", 'job_$jobid should be a C4::BackgroundJob for uncleared job 2' );
$job->clear;
is( C4::BackgroundJob->fetch( $sessionID, $job->id ), undef, 'After clearing it, job 1 should not exist anymore in the session' );
is( ref( C4::BackgroundJob->fetch( $sessionID, $second_job->id ) ), "C4::BackgroundJob", 'After clear on job 1, job 2 should still be a C4::BackgroundJob' );
