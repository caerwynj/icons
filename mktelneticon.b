implement MkTelnetIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point, Font: import draw;

MkTelnetIcon: module
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

	# Terminal (unsecured remote shell).
	icon.draw(Rect(Point(2,3),  Point(26,25)), display.rgb(60,64,72), nil, Point(0,0));
	icon.draw(Rect(Point(3,7),  Point(25,24)), display.rgb(20,24,30), nil, Point(0,0));

	green := display.rgb(90, 230, 110);
	f := Font.open(display, "/fonts/misc/ascii.6x10.font");
	if(f != nil)
		icon.text(Point(5,8), green, Point(0,0), f, ">");
	icon.draw(Rect(Point(11,9), Point(14,12)), green, nil, Point(0,0));

	# Small blue globe in the lower-right indicating a remote network host.
	ocean := display.rgb(60, 130, 220);
	land  := display.rgb(80, 180, 100);
	grid  := display.rgb(200, 220, 240);
	gc := Point(20, 19);
	icon.fillellipse(gc, 5, 5, ocean, Point(0,0));
	icon.fillellipse(Point(gc.x-1,gc.y-1), 2, 1, land, Point(0,0));
	icon.fillellipse(Point(gc.x+2,gc.y+1), 1, 1, land, Point(0,0));
	icon.draw(Rect(Point(gc.x-5,gc.y), Point(gc.x+6,gc.y+1)), grid, nil, Point(0,0));	# equator

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Telnet/icons/!Telnet.bit",  icon);
	writeimg("/usr/inferno/!Telnet/icons/!Telnet.mask", mask);
	sys->print("wrote !Telnet\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
