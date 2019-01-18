# nmap-http-screenshot

Simple Perl script takes an nmap scan output xml file and
takes screenshots of the http services.

Inspired by a [similar tool](https://github.com/SpiderLabs/Nmap-Tools) from [SpiderLabs](https://github.com/SpiderLabs).

## Dependencies

* recent Perl install, preferably on some Linux distro (tested on Kali, Gentoo)
* [Nmap::Parser](https://metacpan.org/pod/Nmap::Parser) Perl module (tested with version 1.36)
* [wkhtmltopdf](https://wkhtmltopdf.org/) (wkhtmltoimage binary exactly)
* [Xvfb](https://en.wikipedia.org/wiki/Xvfb) (X virtual framebuffer) for using in headless mode (without X display, e.g. through SSH terminal)

## Using

Just download the script and use it.

Help:
```
Grab screenshots of http services found in an nmap scan.

Usage: nmap-http-screenshot.pl [switches]
   -x [file]     specify nmap scan XML output file (MANDATORY)
   -o [dir]      target folder of screenshot images (MANDATORY; created if not exists)
   -w [path]     wkhtmltoimage binary path (default: /usr/bin/wkhtmltoimage)
   -t [fileext]  output file extension defining image type (default: png)
   -q [quality]  quality of image in precentage (default: 60)
   -h            show this help

Pro-Tip for using without an X display: xvfb-run nmap-http-screenshot.pl [switches]

Please note that the capturing ability is limited to the ability of wkhtmltoimage.
```

The script parses the nmap XML file, searches for http services,
renders and captures the html pages of the http services and
puts the screenshots in the specified output directory.

An index.html file is also created for easy browsing of the
images.
