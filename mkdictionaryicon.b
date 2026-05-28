implement MkDictionaryIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point, Font: import draw;

MkDictionaryIcon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	display = Display.allocate(nil);
	if(display == nil) { sys->fprint(sys->fildes(2), "no display: %r\n"); return; }

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);
	bg := display.rgb(214, 218, 226);
	icon.draw(all, bg, nil, Point(0,0));

	cover := display.rgb(180, 40, 44);	# red hardcover
	spine := display.rgb(140, 26, 30);
	pages := display.rgb(244, 240, 226);
	mark  := display.rgb(240, 200, 60);	# bookmark ribbon
	wht   := display.white;

	# Closed book: page block on the right, then the cover over it.
	icon.draw(Rect(Point(7,4),  Point(24,24)), pages, nil, Point(0,0));
	icon.draw(Rect(Point(5,3),  Point(22,23)), cover, nil, Point(0,0));
	icon.draw(Rect(Point(5,3),  Point(9,23)),  spine, nil, Point(0,0));

	# Bookmark ribbon hanging from the top.
	icon.draw(Rect(Point(18,3), Point(20,11)), mark, nil, Point(0,0));

	# Title letter on the cover.
	f := Font.open(display, "/fonts/misc/ascii.6x10.font");
	if(f != nil)
		icon.text(Point(12,9), wht, Point(0,0), f, "A");
	# Title underline.
	icon.draw(Rect(Point(11,16), Point(19,17)), wht, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Dictionary/icons/!Dictionary.bit",  icon);
	writeimg("/usr/inferno/!Dictionary/icons/!Dictionary.mask", mask);
	sys->print("wrote !Dictionary\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
