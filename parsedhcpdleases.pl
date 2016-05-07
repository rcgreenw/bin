#! /usr/bin/perl -w
use strict;
use Data::Dump qw[ pp ];

sub parseLeases {
   my( $source, $depth, %config ) = @_;
   $depth++;
   while (my $line = shift(@$source)) {
      chomp($line);
      $line =~ m/(.*)([\{\};])/;
      my $data = $1;
      if (!defined($2)) {
      } elsif ($2 =~ m/}/) {
         return \%config;
      } elsif ($2 =~ m/{/) {
         if ($data =~ m/failover peer "(.*)" state/) {
            $data = $1;
            $config{'failover'}{$data} = parseLeases( $source, $depth );
         } elsif ($data =~ m/lease (.*) /) {
            $data = $1;
            my $lease = parseLeases( $source, $depth );
            $config{'leases'}{$data} = $lease;
#active
#backup
#free
#expired
#            if ($config{'leases'}{$data}{'binding state'} == "free") { 
#
#               $config{'freeleases'}{$data} = $lease;
#            }
         }
      } elsif ($2 =~ m/;/) {
         if ($data =~ m/(my|partner) state (.*) at (.*)/) {
            $config{"$1state"} = $2;
            $config{"$1timestamp"} = $3;
         } elsif ($data =~ m/\s+([a-z -]+) \"?([^\"]*)\"?/) {
            $config{$1} = $2;
         }
      } else {
      }
   }
   return \%config;
}

open FILE, "/var/lib/dhcpd/dhcpd.leases" or die $!;
my @file = <FILE>;

my $config = parseLeases( \@file );
#pp $config;
foreach my $key (keys %{ $config->{'leases'} }) {
   my $state = $config->{'leases'}->{$key}->{'binding state'};
   print "$key->$state\n";
}
