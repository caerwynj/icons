implement MkCharsIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point, Font: import draw;

MkCharsIcon: module
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
	bg := display.rgb(210, 214, 222);
	icon.draw(all, bg, nil, Point(0,0));

	# Character-map panel with a grid.
	icon.draw(Rect(Point(3,3),  Point(25,25)), display.rgb(80,80,80), nil, Point(0,0));
	icon.draw(Rect(Point(4,4),  Point(24,24)), display.white, nil, Point(0,0));
	grid := display.rgb(180, 185, 195);
	icon.draw(Rect(Point(14,4), Point(15,24)), grid, nil, Point(0,0));
	icon.draw(Rect(Point(4,14), Point(24,15)), grid, nil, Point(0,0));

	# Glyphs in each cell.
	black := display.rgb(20, 20, 20);
	f := Font.open(display, "/fonts/misc/ascii.6x10.font");
	if(f != nil) {
		icon.text(Point(7,5),  black, Point(0,0), f, "A");
		icon.text(Point(17,5), black, Point(0,0), f, "z");
		icon.text(Point(7,15), black, Point(0,0), f, "&");
		icon.text(Point(17,15),black, Point(0,0), f, "@");
	}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Chars/icons/!Chars.bit",  icon);
	writeimg("/usr/inferno/!Chars/icons/!Chars.mask", mask);
	sys->print("wrote !Chars\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
