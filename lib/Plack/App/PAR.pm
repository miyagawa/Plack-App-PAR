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
    my $script = $self->script || "script/app.psgi";

    PAR->import({ file => $file });
    my $app = eval PAR::read_file($script);

    Carp::croak "Couldn't compile '$script': $@" if $@;
    Carp::croak "'$script' didn't return a CODE: $app" if ref($app) ne 'CODE';

    $self->{_app} = $app;
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

When you build a new PAR archive, you have to have C<app.psgi> inside
C<script> directory, like:

  % pp -I lib -p -o myapp.par app.psgi

=head1 OPTIONS

=over 4

=item file

The path to the PAR archive file you want to run. Required.

=item script

The name of the script inside the PAR archive. I<script/app.psgi> by default.

=back

=head1 TODO/BUGS

=over 4

=item *

There's no cleaner way to locate non-perl library files, for example
to use for Static middleware path. L<File::ShareDir::PAR> could be used.

=item *

I'm not sure what happens if you instantiate multiple applications of
this class for multiple .par files in the same web server process.

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