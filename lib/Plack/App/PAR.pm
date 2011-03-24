package Plack::App::PAR;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use parent qw(Plack::Component);
use Plack::Util::Accessor qw( file script );
use Carp ();
use PAR ();

sub prepare_app {
    my $self = shift;

    my $file   = $self->file or Carp::croak "'file' is not set";
    my $script = $self->script || "app.psgi";

    PAR->import({ file => $file });
    my $zip = PAR::par_handle($file);

    my $member = PAR::_first_member($zip, "script/$script", $script);

    my($fh, $is_new, $filename) = PAR::_tempfile($member->crc32String . ".psgi");

    if ($is_new) {
        my $file = $member->fileName;
        print $fh "#line 1 \"$file\"\n";
        $member->extractToFileHandle($fh);
        seek $fh, 0, 0;
    }

    $self->{_app} = Plack::Util::load_psgi($filename);
}

sub call {
    my($self, $env) = @_;
    $self->{_app}->($env);
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Plack::App::PAR - Run .par bundle as a PSGI application

=head1 SYNOPSIS

  % plackup -MPlack::App::PAR -e 'Plack::App::PAR->new(file => "/path/to/myapp.par")->to_app'

=head1 DESCRIPTION

Plack::App::PAR is a Plack endpoint to run L<PAR> bundle as a PSGI
application.

You can use the standard .par files - the only restriction is that you
have to have an I<entry point> PSGI script file as a C<app.psgi>
either in the root or inside C<script> directory (which can be changed
with the C<script> option - see below).

  % pp -I lib -p -o myapp.par app.psgi

This will create a C<myapp.par> bundle with C<app.psgi> as an entry
point.

=head1 WHY?

Inspired by L<http://www.modernperlbooks.com/mt/2011/03/what-perl-could-learn-from-java-wars.html> :)

=head1 OPTIONS

=over 4

=item file

The path to the PAR archive file you want to run. Required.

=item script

The name of the entry point script inside the PAR
archive. C<app.psgi> by default.

=back

=head1 TODO/BUGS

=over 4

=item *

There's no cleaner way to locate non-perl library files, for example
static files directory to use for Static middleware
path. I guess L<File::ShareDir::PAR> could be used.

=item *

I'm not sure what happens if you instantiate multiple applications of
this class for multiple .par files in the same web server
process. Because PAR's interface is based on C<import>, I won't be
surprised if you get an unexpected result.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 COPYRIGHT

Copyright 2011- Tatsuhiko Miyagawa

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<PAR>

=cut
