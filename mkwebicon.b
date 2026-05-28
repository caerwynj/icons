implement MkWebIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkWebIcon: module
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
	bg := display.rgb(216, 220, 228);
	icon.draw(all, bg, nil, Point(0,0));

	c := Point(14,14);
	ocean := display.rgb(48, 120, 210);
	land  := display.rgb(70, 175, 90);
	grid  := display.rgb(210, 230, 245);
	rim   := display.rgb(30, 80, 150);

	# Ocean globe with a darker rim.
	icon.fillellipse(c, 12, 12, rim, Point(0,0));
	icon.fillellipse(c, 11, 11, ocean, Point(0,0));

	# Continent blobs.
	icon.fillellipse(Point(10,9), 3, 2, land, Point(0,0));
	icon.fillellipse(Point(18,11), 2, 3, land, Point(0,0));
	icon.fillellipse(Point(12,18), 3, 3, land, Point(0,0));
	icon.fillellipse(Point(19,18), 2, 2, land, Point(0,0));

	# Latitude/longitude lines.
	icon.draw(Rect(Point(3,13), Point(25,14)), grid, nil, Point(0,0));	# equator
	icon.draw(Rect(Point(5,8),  Point(23,9)),  grid, nil, Point(0,0));
	icon.draw(Rect(Point(5,18), Point(23,19)), grid, nil, Point(0,0));
	icon.ellipse(c, 5, 11, 0, grid, Point(0,0));	# meridian
	icon.ellipse(c, 11, 11, 0, grid, Point(0,0));	# outline

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Web/icons/!Web.bit",  icon);
	writeimg("/usr/inferno/!Web/icons/!Web.mask", mask);
	sys->print("wrote !Web\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
