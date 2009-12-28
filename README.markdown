# iconoclast

Finds favorites icons for web pages on the world wide internets by checking the HTML head or the standard favicon location. Then, do with them what you will.

### Usage

To get the favicon for a page, do:

`favicon = Iconoclast.extract('www.website.com')`

This will go and do a bunch of GETs (two or three, actually) on the url given. If you've already got the content and want to skip one of the GETs, you can pass the content in as the second argument.

`content = get_some_content('www.website.com')
favicon = Iconoclast.extract('www.website.com', content)`

`Iconoclast.extract` returns an `Iconoclast::Favicon` instance, from which you can get the URL, content type, size, or access the binary image data. By calling `valid?`, you can check if the favicon is valid based on whatever my standards were when I wrote this (basically, whether or not it's actually an image).

You can save the image to a tempfile using `favicon.save`, or more usefully, to a file at `favicon.save('path/to/file')`. Fun times had by all.

## Copyright

Copyright (c) 2009 Sander Hartlage. See LICENSE for details.