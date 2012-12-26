#!/usr/bin/env perl
use v5.10;
use Mojolicious::Lite;
use Mojo::UserAgent;
use Encode qw(decode_utf8);
use Data::HanConvert::cn2tw;
use Data::HanConvert::cn2tw_characters;
use Convert::Moji;

helper s2t => sub {
    state $s2t_converter = Convert::Moji->new([ table => { %$Data::HanConvert::cn2tw, %$Data::HanConvert::cn2tw_characters } ]);
    my $self = shift;
    my $text = shift;

    return $text =~ /\p{Han}/ ? $s2t_converter->convert($text) : $text;
};

helper get_feed => sub {
    my $self = shift;
    my $url  = shift;


    my $ua = Mojo::UserAgent->new;
    my $tx = $ua->get($url);
    my $res = $tx->success or return $self->render(text => "failed to retrieve the url", status => 501);

    my $feed_ct = $res->headers->content_type;

    $self->app->log->debug($feed_ct);

    unless ($feed_ct =~ m{^(text/|application/xml$)}) {
        return;
    }

    my $text = $res->body;

    my $encname = qr{[A-Za-z] ([A-Za-z0-9._] | '-')*}x;
    my $encattr = qr{\sencoding=(["'])($encname)(\1)};
    $text =~ s/\A([^\n]+\n)//;
    my $first_line = $1;
    my (undef, $encoding) = $first_line =~ m/$encattr/;

    $first_line =~ s{$encattr}{ encoding="utf-8"};

    return (Encode::decode($encoding, $first_line) . Encode::decode($encoding, $text), $feed_ct);
};


get '/bs2t' => [format => ['js']] => sub {
    my $self = shift;
    $self->stash(hostname => "".$self->req->headers->header("Host"));
};

options '/s2t' => sub {
    my $self = shift;
    $self->res->headers->header('Access-Control-Request-Method' => 'GET, POST, OPTIONS');
    $self->res->headers->header('Access-Control-Allow-Origin' => '*');
    $self->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type');
    $self->render(text => "");
};

any ['GET','POST'] => '/s2t' => sub {
    my $self = shift;
    my $text = $self->param("t") || $self->req->body;

    if ($text) {
        $text = decode_utf8 $text;
    }
    elsif (my $url = $self->param("u")) {
        ($text, my $feed_ct) = $self->get_feed($url);
        unless ($text && $feed_ct) {
            $self->render(text => "cannot convert non-text.", status => 501);
            return;
        }
        $self->res->headers->content_type($feed_ct);
    }

    unless ($text) {
        return $self->render(text => "Missing input.", status => 400);
    }

    $self->res->headers->header('Access-Control-Request-Method' => 'GET, POST, OPTIONS');
    $self->res->headers->header('Access-Control-Allow-Origin' => '*');
    $self->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type');
    $self->render_text(text => $self->s2t($text));
};

get '/' => sub {
    my $self = shift;
    $self->stash(hostname => "".$self->req->headers->header("Host"));
} => 'index';

app->secret("roonbienfleshmentcanoodlerbidimensionalOphidiobatrachiapharyngalgicSyngnathidaelaroidHyperotretisymbologyHoloptychiidae");
app->start;

__DATA__

@@ index.html.ep
<html>
    <head>
        <meta charset="utf-8">
        <title>Bookmarklet</title>
    </head>
    <body>
        <a href="javascript:(function(){ var s = document.createElement('script'); s.setAttribute('src', 'http://<%= $hostname %>/bs2t.js'); document.body.appendChild(s); })()">轉繁體</a>
    </body>
</html>

@@ bs2t.js.ep
(function() {
    var allTextNodes = [];

    function replaceAllText() {
        var i, len, texts, client;
        len = allTextNodes.length;
        texts = [];
        for(i = 0; i < len; i++) {
            texts.push( allTextNodes[i].nodeValue );
        }
        client = new XMLHttpRequest();
        client.open("POST", "http://<%= $hostname %>/s2t", true);
        client.onload = function() {
            var texts;
            if (client.status != 200 && client.status != 304) return;
            texts = JSON.parse(client.responseText);
            for(i = 0; i < len; i++) {
                allTextNodes[i].nodeValue = texts[i];
            }
        };
        client.send( JSON.stringify(texts) );
    }

    function traverse(node) {
        var children, childLen;
        if (!node.tagName || node.tagName.match(/^(script|style|link|embed|object|img)$/i)) return;
        children = node.childNodes;
        childLen = children.length;
        for(var i = 0; i < childLen; i++) {
            var child = children.item(i);
            if(child.nodeType == 3) {
                if(child.nodeValue.match(/^\s*$/) == null) {
                    allTextNodes.push(child);
                }
            } else {
                traverse(child);
            }
        }
    }

    traverse(document.body);
    replaceAllText();
})();
