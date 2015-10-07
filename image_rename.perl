#!/opt/local/bin/perl

#^^^ This should point to your system's perl, or which ever
#    custom perl you may have installed. Usually /usr/bin/perl
#
#       AUTHOR: Dan Reidy (dubkat), dubkat@gmail.com
#     HOMEPAGE: http://google.com/+DanReidy
#    MORE INFO: https://github.com/dubkat/misc-linux-tools
#      VERSION: v15.10.07
#      CREATED: 2015-07-24
#      LICENSE: GPL-2
#
# Perl Critic Level: 3
#
# Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS'
# AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED
# BY YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE
# USE OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# do we have any common sense?
#use if eval { require common::sense } == 1, "common::sense";
#use if eval { require common::sense } == 0, "strict";
#use if eval { require common::sense } == 0, "warnings";

use strict;
use warnings;
use Carp;
use feature qw(say);
use version; our $VERSION = 'v15.10.07';

use Image::ExifTool qw(:Public);
use HTTP::Date;
use Env qw(HOME);

my $root_path = shift @ARGV;
my $seq = 1;
my $output_dir = $ENV{'HOME'} ."/Pictures/sorted";

# if we want to make directories for year
my $group_by_year = 1;


sub file_processor {
  my $path = shift;
  $path =~ s/\/$//;

  opendir (DIR, $path) or die "Unable to open $path: $!\n";
  my @files = grep { !/^\./ } readdir (DIR);
  closedir(DIR);
  # prepend the pathname to files.
  @files = map { $path . '/' . $_ } @files;

  for (@files) {
    if ( -d $_ ) {
      file_processor($_);
    }
    else {
      next unless $_ =~ m/\.(jpe?g|png|tiff?|webm|webp|mkv|mp4|mov)$/ix;

      say "Processing file: $_";
      # lets look up it's exif data.
      my $year;
      my $output = $output_dir;
      my $info = ImageInfo($_);
      my $create = $info->{'CreateDate'};
      my $type = lc $info->{'FileType'};
      my ($date,$time) = split / +/, $create;
      $date =~ s/:/-/gx;
      my $stamp = str2time("$date $time");
      $time =~ s/:/-/gx;

      my ($sec,$min,$hour,$mday,$mon,$gyear,$wday,$yday,$isdst) = gmtime($stamp);
      my $media_touch = sprintf "%04d-%02d-%02d %02d:%02d:%02d UTC", $gyear+1900, $mon, $mday, $hour, $min, $sec;
      #print "DEBUG: stamp($stamp), media_touch($media_touch) \n";

      if ( $group_by_year ) {
        ($year) = $date =~ (m/(^\d{4})/x);
        if ( ! -d "$output_dir/$year" ) {
          mkdir("$output_dir/$year") or die "Failed to create directory $output_dir/$year\n";
        }
        $output = "$output_dir/$year";
      }

      $create = sprintf("%s_%s", $date, $time);
      next if $create eq "_";
      my $edited = "";
      my $basename = sprintf("%s/%s", $output, $create);

      if ( $_ =~ m/\-edited\./x ) {
        $edited = "-edited";
      }
      if ( $type =~ m/mov|3gp/x ) {
        $type = 'mp4';
      }

      my $newfile = sprintf("%s%s.%s", $basename, $edited, $type);
      while ( -e $newfile ) {
        my $sequence = sprintf("%04d", $seq);
        my $new_basename = $basename ."-". $sequence;
        $newfile = sprintf("%s%s.%s", $new_basename, $edited, $type);
        $seq++;
      }

      if ( $_ =~ m/\.(jpe?g|png|tiff?|webp)$/ix ) {
        my @cmd = qq(mv -v $_ $newfile);
        #say @cmd;
        system(@cmd);
        $seq = 1;
        #printf("%s -> %s\n", $_, $newfile);
      }

      #rename($_, $newfile);
      if ($_ =~ /\.(3gp|mov)$/ix ) {
        my $vinfo = ImageInfo($_);
        my $vcodec = undef;
        my $acodec = undef;
        require Data::Dumper;
        #print Dumper $info;
        if( $vinfo->{'CompressorID'} eq 'avc1' ) {
          #video is already mp4 compatable.
          $vcodec = "copy";
        } else {
          $vcodec = "libx264";
        }
        if ($vinfo->{'AudioFormat'} eq 'aac' ) {
          $acodec = "-acodec copy";
        } else {
          $acodec = "-strict -2";
        }

        my @cmd = qq(ffmpeg -i $_ -map 0 -metadata creation_time='$media_touch' -c:v $vcodec $acodec $newfile);
        say @cmd;
        system(@cmd);
        $seq = 1;

      }
    }
  }
  return;
}

if ( ! -d $root_path ) { croak "First arguement must be a directory."; }
if ( ! -d $output_dir ) { croak "Script setting \$output_dir is not a directory."; }

print "Attempting to open $root_path\n";
file_processor $root_path;
