#!/usr/bin/perl 
# Casper Joost Eyckelhof (Titanhead)
# joost@dnd.utwente.nl
# Haalt het meest recente file-nieuws van tt op en scrijft deze naar STDOUT
# Niet kort of heel efficient, maar werkt prima :)

use HTML::Entities();
use LWP::UserAgent;
$ua = new LWP::UserAgent;

#Set agent name, vooral niet laten weten dat we een script zijn
$agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

sub get_url {
    my $url = shift;
    $request = new HTTP::Request( 'GET', $url );
    $request->referer('http://portal.omroep.nl/');
    $request->header( "Accept" =>
        'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,text/css,*/*;q=0.1'
    );
    $request->header( "Accept-Encoding" => "gzip, deflate, compress" );
    $request->header( "Accept-Language" => "en-us, en;q=0.80, ko;q=0.60, zh;q=0.40, ja;q=0.20" );
    $request->header( "Accept-Charset"  => "utf-8, *" );
    $content = $ua->request($request)->content;
    return $content;
}

sub parse_page {
    #get everything between <pre> </pre>
    if ( $content =~ /<pre>/ ) {
        $content =~ s/^.*?<pre>.*?\n(.*?)<\/pre>.*?$/$1/si;
        $content =~ s/\*+//g;
        $content =~ s/<font .*?>//sgi;
        $content =~ s/<\/font>//sgi;
        $content =~ s/<A HREF=".*?html">(\d{3})<\/A>/($1),/gi;
        $content =~ s/\n+//g;
        $content =~ s/\.{2,}//g;
        $content =~ s/([,.])/$1 /g;
        $content =~ s/\s{2,}/ /g;
        $content =~ s/^\s//;
        $content =~ s/<A HREF=".*?html">(\d{3})<\/A>/($1),/gi;
        $content =~ s/volgende nieuws index.*$//i;
        $content =~ s|binnenland \d/\d VERKEERSINFORMATIE actueel .*? uur||gi;

        $content = HTML::Entities::decode($content);
        return $content;
    } else {
        return undef;
    }
}

my $result;

my $base_url   = "http://teletekst.nos.nl/tekst/730-0";
my $page_index = 1;

$url = $base_url . $page_index . ".html";

my $next = 1;
while ($next) {
    my $content = parse_page( get_url($url) );
    if ( defined $content ) {
        $result .= $content;
    } else {
        $next = 0;
    }
    $page_index++;
    $url = $base_url . $page_index . ".html";
}

print $result , "\n";
