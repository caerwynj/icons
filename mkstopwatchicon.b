implement MkStopwatchIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkStopwatchIcon: module
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

	c := Point(14,16);
	metal := display.rgb(70, 78, 92);
	face  := display.white;
	tick  := display.rgb(70, 70, 70);
	red   := display.rgb(214, 50, 50);
	black := display.rgb(20, 20, 20);

	# Top button and stem.
	icon.draw(Rect(Point(11,1), Point(17,4)), metal, nil, Point(0,0));
	icon.draw(Rect(Point(13,3), Point(15,6)), metal, nil, Point(0,0));
	# Side start/stop lugs.
	icon.draw(Rect(Point(3,7),  Point(6,10)),  metal, nil, Point(0,0));
	icon.draw(Rect(Point(22,7), Point(25,10)), metal, nil, Point(0,0));

	# Watch face with metal bezel.
	icon.fillellipse(c, 11, 11, metal, Point(0,0));
	icon.fillellipse(c, 9, 9, face, Point(0,0));

	# Ticks at 12/3/6/9.
	icon.draw(Rect(Point(c.x-1, c.y-9), Point(c.x+1, c.y-7)), tick, nil, Point(0,0));
	icon.draw(Rect(Point(c.x-1, c.y+7), Point(c.x+1, c.y+9)), tick, nil, Point(0,0));
	icon.draw(Rect(Point(c.x-9, c.y-1), Point(c.x-7, c.y+1)), tick, nil, Point(0,0));
	icon.draw(Rect(Point(c.x+7, c.y-1), Point(c.x+9, c.y+1)), tick, nil, Point(0,0));

	# Red hand pointing to ~2 o'clock, with a hub.
	icon.line(c, Point(c.x+6, c.y-5), Draw->Endsquare, Draw->Endsquare, 1, red, Point(0,0));
	icon.fillellipse(c, 1, 1, black, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Stopwatch/icons/!Stopwatch.bit",  icon);
	writeimg("/usr/inferno/!Stopwatch/icons/!Stopwatch.mask", mask);
	sys->print("wrote !Stopwatch\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
