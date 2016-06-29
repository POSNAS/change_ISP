#!/usr/bin/perl -w

######################################################################
# ./change_iptables_rules.pl avantel
# ./change_iptables_rules.pl rtk
######################################################################

use strict;
use warnings;

#to clear screen
#system 'clear';

#get name of internet service provider
my $ISP = $ARGV[0];

if (not defined $ISP) 
{
    die "Need name of internet service provider, for example: avantel or rtk\n";
}

my $file_nat = "/etc/network/if-up.d/001enable-nat";
my $file_rules = "/etc/network/if-up.d/002iptables-rules";
my $file_route = "/iptables/select.route";

my $file_nat_new = "/etc/network/if-up.d/001enable-nat";
my $file_rules_new = "/etc/network/if-up.d/002iptables-rules";
my $file_route_new = "/iptables/select.route";

my $reload_full = "/bin/iptables-fullreload";

#to change - /etc/network/if-up.d/001enable-nat
&change_iptables_nat($ISP);

#to change - /etc/network/if-up.d/002iptables-rules
&change_iptables_rules($ISP);

#to change /iptables/select.route
&change_route($ISP);

system($reload_full);

print "*ISP: $ISP\n";
print "*nat: $file_nat\n";
print "*rules: $file_rules\n";
print "*route: $file_route\n";
print "*Done\n";

################################################################################
#
################################################################################
sub get_file_content()
{
    my ($mode) = @_; 
    my $fileContent;
    my $F;

    #open file
    if ($mode eq "nat")
    {
	open($F, '<', $file_nat) or die $!;
    }
    elsif($mode eq "rules")
    {
	open($F, '<', $file_rules) or die $!;
    }
elsif($mode eq "route")
    {
        open($F, '<', $file_route) or die $!;
    }

    binmode($F);
    {
        local $/;
        $fileContent = <$F>;
    }

    #close file
    close($F);

    return $fileContent;
}

################################################################################
#
################################################################################
sub replace_nat()
{
    my ($content) = @_;

    if ($ISP eq "avantel")
    {
        #$content =~ s/\$rtk/\$avantel/g;
	$content =~ s/\$rtk(?!(.*?)(#don't replace this line))/\$avantel/ig;
    }
    elsif ($ISP eq "rtk")
    {
        #$content =~ s/\$avantel/\$rtk/g;
	$content =~ s/\$avantel(?!(.*?)(#don't replace this line))/\$rtk/ig;
    }
    else
    {
        die "Don't know about '$ISP'";
    }

    &write_to_log($content, $file_nat_new);

    &save_result($content, $file_nat_new);
}

################################################################################
#
################################################################################
sub replace_rules()
{
    my ($content) = @_;

    if ($ISP eq "avantel")
    {
        $content =~ s/eth2/eth1/g;
    }
    elsif ($ISP eq "rtk")
    {
        $content =~ s/eth1/eth2/g;
    }
    else
    {
        die "Don't know about '$ISP'";
    }

    &write_to_log($content, $file_rules_new);

    &save_result($content, $file_rules_new);
}

################################################################################
#
################################################################################
sub replace_route()
{
    my ($content) = @_;

    if ($ISP eq "avantel")
    {
        $content =~ s/\$gw2(?!(.*?)(#don't replace this line))/\$gw1/ig;
    }
    elsif ($ISP eq "rtk")
    {
        $content =~ s/\$gw1(?!(.*?)(#don't replace this line))/\$gw2/ig;
    }
    else
    {
        die "Don't know about '$ISP'";
    }

    &write_to_log($content, $file_route_new);

    &save_result($content, $file_route_new);
}

################################################################################
#
################################################################################
sub save_result()
{
    my ($content, $file) = @_;

    #open file
    open(my $fh, '>', $file) or die "Don't open '$file' $!";

    #write to new file
    print $fh $content;

    #close file
    close $fh;
}

################################################################################
#
################################################################################
sub write_to_log()
{
    my ($log, $file) = @_;

    open(my $fh, '>>', "/var/log/change_iptables.log");

    my $date_time = localtime();

    print $fh "###########################################################\n";
    print $fh "START('$file')\n";
    print $fh "DATE: $date_time\n";
    print $fh "###########################################################\n\n";

    print $fh $log;

    print $fh "\n###########################################################\n";
    print $fh "END('$file')\n";
    print $fh "DATE: $date_time\n";
    print $fh "###########################################################\n\n";

    close $fh;
}

################################################################################
#
################################################################################
sub change_iptables_nat()
{
    my ($ISP) = @_;

    &replace_nat(&get_file_content("nat"));
}

################################################################################
#
################################################################################
sub change_iptables_rules()
{
    my ($ISP) = @_;

    &replace_rules(&get_file_content("rules"));
}

################################################################################
#
################################################################################
sub change_route()
{
    my ($ISP) = @_;

    &replace_route(&get_file_content("route"));
}
