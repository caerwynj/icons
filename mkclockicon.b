implement MkClockIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkClockIcon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	display = Display.allocate(nil);
	if(display == nil) {
		sys->fprint(sys->fildes(2), "mkclockicon: no display: %r\n");
		return;
	}

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	bg := display.rgb(214, 218, 226);
	icon.draw(all, bg, nil, Point(0,0));

	c := Point(14,14);
	rim   := display.rgb(40, 50, 70);
	face  := display.white;
	tick  := display.rgb(60, 60, 60);
	black := display.rgb(20, 20, 20);
	red   := display.rgb(210, 50, 50);

	# Face with a dark rim.
	icon.fillellipse(c, 12, 12, rim,  Point(0,0));
	icon.fillellipse(c, 10, 10, face, Point(0,0));

	# Hour ticks at 12/3/6/9.
	icon.draw(Rect(Point(c.x-1, c.y-10), Point(c.x+1, c.y-7)), tick, nil, Point(0,0));
	icon.draw(Rect(Point(c.x-1, c.y+7),  Point(c.x+1, c.y+10)), tick, nil, Point(0,0));
	icon.draw(Rect(Point(c.x-10, c.y-1), Point(c.x-7, c.y+1)), tick, nil, Point(0,0));
	icon.draw(Rect(Point(c.x+7, c.y-1),  Point(c.x+10, c.y+1)), tick, nil, Point(0,0));

	# Hands: hour points up, minute points right.
	icon.line(c, Point(c.x, c.y-6), Draw->Endsquare, Draw->Endsquare, 1, black, Point(0,0));
	icon.line(c, Point(c.x+8, c.y), Draw->Endsquare, Draw->Endsquare, 0, black, Point(0,0));
	# Centre hub.
	icon.fillellipse(c, 1, 1, red, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Clock/icons/!Clock.bit",  icon);
	writeimg("/usr/inferno/!Clock/icons/!Clock.mask", mask);
	sys->print("wrote !Clock\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkclockicon: create %s: %r\n", path);
		return;
	}
	display.writeimage(fd, img);
}
