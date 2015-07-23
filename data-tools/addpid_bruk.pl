#! /usr/bin/env perl
#
# Andrew Janke - a.janke@gmail.com
#
# Add a project ID to a bruker subject file

use strict;
use warnings "all";
use Getopt::Long;
use Pod::Usage;
use File::Basename;

# until I get organised and do this properly
my $PACKAGE = &basename($0);
my $VERSION = '1.0.0';
my $PACKAGE_BUGREPORT = '"Andrew Janke" <a.janke@gmail.com>';

my($me, %opt, @indirs, $i);
 
$me = &basename($0);
%opt = ('verbose' => 0, 
        'fake' => 0,
        'id' => undef,
        'man' => 0, 
        'help' => 0,
        );
        
# Check arguments
&GetOptions(
   'help|?' => \$opt{'help'},
   'man' => \$opt{'man'},
   'v|verbose' => \$opt{'verbose'},
   'version' => sub { &print_version_info },
   'f|fake' => \$opt{'fake'},
   'i|id=s' => \$opt{'id'},
   ) or pod2usage('-verbose' => 1) && exit;

# handle -man, -help or missing args
pod2usage('-verbose' => 1) if $opt{'help'};
pod2usage('-exitstatus' => 0, -verbose => 2) if $opt{'man'};
pod2usage('-verbose' => 0) && exit if ($#ARGV < 0);

# get input arguments
@indirs = @ARGV;

my $proj_txt = '<CAI:' . $opt{'id'} . '>';
my $comm_txt = '##$SUBJECT_comment=( 2048 )';

foreach $i (@indirs){
   
   # slurp in file
   my @buf = split(/\n/, `cat $i/subject`);
   
   my @outbuf = ();
   my $found_comment = 0;
   # search for comments
   foreach $b (@buf){
      
      # if existing comments
      if($b =~ m/\#\#\$SUBJECT\_comment/){
         push(@outbuf, $b);
         
         # add project ID at start
         push(@outbuf, $proj_txt);
         
         $found_comment = 1;
         }
      
      # if no comments
      elsif($b =~ m/\#\#END\=/ && $found_comment == 0){
         push(@outbuf, $comm_txt);
         push(@outbuf, $proj_txt);
         push(@outbuf, $b);
         }
      
      # else simply copy
      else{
         push(@outbuf, $b);
         }
      
      }
   
   print "$i\n" . join("\n", @outbuf) . "\n" if $opt{'verbose'};
   
   open(FH, ">$i/subject") or die "Couldn't open $i/subject. Read only? [$!]\n";
   print FH join("\n", @outbuf) . "\n";
   close(FH);
   
   }



sub print_version_info {
   print STDOUT "\n$PACKAGE version $VERSION\n".
                "Comments to $PACKAGE_BUGREPORT\n\n";
   exit;
   }
 
__END__
 
=head1 NAME
 
B<voliso> - Adds a project ID to a bruker directory comments
 
=head1 SYNOPSIS
 
B<voliso> [options] -id 10001 <brukerdir> [[<dir2>] ... ]
 
B<voliso> takes an input volume and changes the steps and starts
in order that the output volume has isotropic sampling
 
=head1 DESCRIPTION

B<voliso> arose out of the need that tools such as N3 and minctracc prefer input
volumes to be isotropically sampled. The major difference between this command-
and autocrop is that it will only downsample the data if required. All files are-
also converted to short as part of this process (to aid minctracc) if you dont
like this, tough.  Change the code.
 
 eg:
    $ voliso -step 3 in.mnc out.mnc
 
=head1 OPTIONS
 
=over 4
 
=item B<-v>, B<--verbose>
 
Be noisy when doing things (most importantly this will echo the resulting script to the terminal)
 
=item B<--version>
 
Print version number and exit
 
=item B<-c>, B<--clobber>
 
Overwrite existing files
 
=item B<-h>, B<--help>
 
Dump some quick help output
 
=item B<--man>
 
Dump a man page                                                                                               
 
=item B<-f>, B<--fake>
 
Do a dry run. This is usually only useful if combined with --verbose so that you can see what is going on.
 
=item B<--maxstep>
 
The target maximum step desired in the output volume

=back
 
=head1 AUTHOR
 
Problems or Comments to: Andrew Janke - B<a.janke@gmail.com>
 
=cut
