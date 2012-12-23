#!/usr/bin/env perl
use v5.10;
use Mojolicious::Lite;
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

    unless ($text) {
        return $self->render(text => "Missing input.", status => 400);
    }
    $text = decode_utf8 $text;

    $self->app->log->debug("Text: $text");

    $self->res->headers->header('Access-Control-Allow-Origin' => '*');
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

function replaceText(node) {
  var current = node.nodeValue;
  if (current.match(/^\s*$/)) return;

  var client = new XMLHttpRequest();
  client.open("GET", "http://<%= $hostname %>/s2t?t=" + encodeURI(current), true);
  client.onload = function() {
    if (client.status != 200 && client.status != 304) { return; }
    node.nodeValue = client.responseText;
  };
  client.send();
}

function traverse(node) {
  var children, childLen;

  if (!node.tagName || node.tagName.match(/^(script|style|link|embed|object|img)$/i)) return;

  children = node.childNodes;
  childLen = children.length;

  for(var i = 0; i < childLen; i++)
  {
    var child = children.item(i);
    if(child.nodeType == 3)//or if(child instanceof Text)
      replaceText(child);
    else
      traverse(child);
  }
}

traverse(document.body);
})();
