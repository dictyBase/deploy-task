package perl;

use strict;
use Rex -base;
use Rex::Commands::Run;
use Rex::Commands::Tail;
use Rex::Commands::Fs;
use Rex::Commands::File;

# Other modules:

# Module implementation
#

desc 'install perl using perlbrew (--version=[perl-5.10.1])';
task 'install' => sub {
        my ($param) = @_;
        needs perlbrew 'check';

        # start perl install and put it in the background
        my $version = $param->{version} || 'perl-5.10.1';
        run "nohup \$PERLBREW_ROOT/bin/perlbrew install -j 3 $version </dev/null >perlbrew.log 2>&1 &";
 };


desc 'install perl using perlbrew without running the unit test(--version=[perl-5.10.1])';
task 'install-notest' => sub {
        my ($param) = @_;
        needs perlbrew 'check';

        # start perl install and put it in the background
        my $version = $param->{version} || 'perl-5.10.1';
        run "nohup \$PERLBREW_ROOT/bin/perlbrew install -n -j 3 $version </dev/null >perlbrew.log 2>&1 &";
 };

desc 'install threaded perl using perlbrew';
task 'install-threaded' => sub {
        my ($param) = @_;
        needs perlbrew 'check';

        # start perl install and put it in the background
        my $version = $param->{version} || 'perl-5.10.1';
        run "nohup \$PERLBREW_ROOT/bin/perlbrew install -j 3 $version -Dusethread </dev/null >perlbrew.log 2>&1 &";
 };


desc 'get running status of perl installation process';
task 'install-status' => sub {
    needs perlbrew 'check';
	my $path = run 'echo $PERLBREW_ROOT';
	tail "$path/build.log";	   
};

desc 'install perl modules(toolchain) for managing dependencies'; 
task 'install-toolchain' => sub {
    needs perlbrew 'check';
    my $tmpfile = run 'mktemp';
    chmod 744,  $tmpfile; 
    my $fh = file_write($tmpfile);
    $fh->write("#!/bin/sh\n"); 
    $fh->write("source \${PERLBREW_ROOT}/etc/bashrc\n");
    $fh->write("\${PERLBREW_ROOT}/bin/cpanm -n Devel::Loaded App::cpanoutdated App::pmuninstall Carton\n");
    $fh->write("trap \'rm -f $tmpfile\' EXIT\n");
    $fh->close;
	say run "nohup $tmpfile > cpanm.log 2>&1 &";
};

1;    # Magic true value required at end of module
