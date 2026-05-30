implement MkDateIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point, Font: import draw;

MkDateIcon: module
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

	border := display.rgb(70, 70, 80);
	header := display.rgb(208, 60, 50);
	page   := display.white;
	black  := display.rgb(20, 20, 24);
	wht    := display.white;

	# Page-a-day tile with a red header.
	icon.draw(Rect(Point(4,3),  Point(24,25)), border, nil, Point(0,0));
	icon.draw(Rect(Point(5,4),  Point(23,24)), page,   nil, Point(0,0));
	icon.draw(Rect(Point(5,4),  Point(23,9)),  header, nil, Point(0,0));

	# Day-name in header + big day number below.
	fs := Font.open(display, "/fonts/misc/ascii.5x7.font");
	fb := Font.open(display, "/fonts/misc/latin1.8x13.font");
	if(fs != nil)
		icon.text(Point(8,4),  wht,   Point(0,0), fs, "MON");
	if(fb != nil)
		icon.text(Point(8,11), black, Point(0,0), fb, "30");

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Date/icons/!Date.bit",  icon);
	writeimg("/usr/inferno/!Date/icons/!Date.mask", mask);
	sys->print("wrote !Date\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
