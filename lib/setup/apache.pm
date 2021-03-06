package  setup::apache;
use strict;
use Rex -base;
use Rex::Commands::Run;
use Rex::Commands::Fs;
use Rex::Commands::Upload;
use Rex::Commands::File;

desc 'add apache envvars from a local file(--file=[])';
task 'envvars' => sub {
    my ($param) = @_;
    die "no input file (--file) is given\n" if not exists $param->{file};

    my $content = do { local ( @ARGV, $/ ) = $param->{file}; <> };
    my $fh = file_append('/etc/sysconfig/httpd');
    $fh->write($content);
    $fh->close;

    if ( $content =~ /WEBAPPS_DIR=(\S+)/ ) {
        my $file = '/etc/httpd/conf.d/perl.conf';
        if ( is_file($file) ) {
            my $fh = file_append($file);
            $fh->write("PerlSetEnv WEBAPPS_DIR $1\n");
            $fh->close;
        }
    }
};

desc 'add mod_perl(--file==[]) code to apache configuration(perl.conf) file';
task 'perl-code' => sub {
    my ($param) = @_;
    die "no input file (--file) is given\n" if not exists $param->{file};

    my $content = do { local ( @ARGV, $/ ) = $param->{file}; <> };
    my $fh = file_append('/etc/httpd/conf.d/perl.conf');
    $fh->write($content);
    $fh->close;
};

desc
    'upload a local(--file=[]) apache configuration file(--name=[vhost_site.conf])';
task 'vhost' => sub {
    my ($param) = @_;
    die "no input file (--file) is given\n" if not exists $param->{file};
    my $name = $param->{name} || 'vhost_site.conf';
    my $content = do { local ( @ARGV, $/ ) = $param->{file}; <> };
    my $fh = file_write("/etc/httpd/conf.d/$name");
    $fh->write($content);
    $fh->close;
};

desc 'remove fastcgi wrapper line from fastcgi apache configuration file';
task 'fastcgi-fix' => sub {
    my $file = '/etc/httpd/conf.d/fastcgi.conf';	
	if (is_file($file)) {
		delete_lines_matching $file,  matching => qr{FastCgiWrapper On};
	}
};

desc 'make sure apache2 gets started at boot';
task 'startup' => sub {
	run 'chkconfig --level 2345 httpd on';
};

desc 'start apache2';
task 'start' => sub {
	run 'service httpd start';
};
desc 'restart apache2';
task 'restart' => sub {
	run 'service httpd restart';
};


1;
