#!/usr/bin/env perl
use v5.10;
use Mojolicious::Lite;

use Data::HanConvert::cn2tw;
use Data::HanConvert::cn2tw_characters;
use Convert::Moji;

helper s2t => sub {
    state $s2t_converter = Convert::Moji->new([ table => { %$Data::HanConvert::cn2tw, %$Data::HanConvert::cn2tw_characters } ]);
    my $self = shift;
    my $text = shift;

    return $s2t_converter->convert($text);
};


get '/s2t' => sub {
    my $self = shift;
    my $text = $self->param("t");
    $self->render_text(text => $self->s2t($text));
};

app->start;
