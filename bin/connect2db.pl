#!/opt/perl-5.8.8/bin/perl -w

use strict;

my $entprs = $ARGV[0];
my $sql = $ARGV[1] if ( $ARGV[1] );

unless ( $entprs ) {
    warn "No entprs passed in\n";
    exit;
}

my $path = qq{/web/01/cust/$entprs/conf/entprs.ini};

my $result = `sudo egrep "DBHOST|DBPASSWORD" $path`;

my ($host, $pass);
for my $field ( split /\n/, $result ) {
    if ( $field =~ /^DBHOST/ ) {
        $field =~ s/DBHOST=(\w+)/$1/;
        $host = $field;
    } elsif ( $field =~ /^DBPASSWORD/ ) {
        $field =~ s/DBPASSWORD=(.*)/$1/;
        $pass = $field;
    }
}

#print "Host:$host, Pass:$pass\n";
#print "$pass\n";

unless ( $host && $pass) {
	print "No host / password defined!\n";
	exit;
}

#`export USER=jharasym`;
#$ENV{'USER'} = 'jharasym';
#system( '/bin/env' );

`echo '$host:5432:$entprs:$entprs:$pass' > ~/.pgpass`;
`chmod 0600 ~/.pgpass`;

if ( $sql ) {
	system ( '/opt/postgresql/bin/psql', '-U', $entprs, '-d', $entprs, '-h', $host, '-c', $sql );
} else {
	system ( '/opt/postgresql/bin/psql', '-U', $entprs, '-d', $entprs, '-h', $host );
}
