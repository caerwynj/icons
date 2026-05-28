implement MkCalendarIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkCalendarIcon: module
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
		sys->fprint(sys->fildes(2), "mkcalendaricon: no display: %r\n");
		return;
	}

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	bg := display.rgb(210, 214, 222);
	icon.draw(all, bg, nil, Point(0,0));

	border := display.rgb(70, 70, 70);
	page   := display.white;
	header := display.rgb(210, 60, 50);	# red month bar
	grid   := display.rgb(170, 175, 185);
	today  := display.rgb(70, 130, 220);	# highlighted day

	# Page with border.
	icon.draw(Rect(Point(4,5),  Point(24,25)), border, nil, Point(0,0));
	icon.draw(Rect(Point(5,6),  Point(23,24)), page,   nil, Point(0,0));
	# Red header.
	icon.draw(Rect(Point(5,6),  Point(23,11)), header, nil, Point(0,0));

	# Spiral binding above the header.
	icon.draw(Rect(Point(9,2),  Point(11,7)), border, nil, Point(0,0));
	icon.draw(Rect(Point(17,2), Point(19,7)), border, nil, Point(0,0));

	# Day grid lines on the white body (y 11..24, x 5..23).
	for(i := 1; i < 3; i++) {
		gy := 11 + i*4;
		icon.draw(Rect(Point(5,gy), Point(23,gy+1)), grid, nil, Point(0,0));
	}
	for(j := 1; j < 4; j++) {
		gx := 5 + j*5;
		icon.draw(Rect(Point(gx,11), Point(gx+1,24)), grid, nil, Point(0,0));
	}

	# Highlight one day cell.
	icon.draw(Rect(Point(11,16), Point(15,19)), today, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Calendar/icons/!Calendar.bit",  icon);
	writeimg("/usr/inferno/!Calendar/icons/!Calendar.mask", mask);
	sys->print("wrote !Calendar\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkcalendaricon: create %s: %r\n", path);
		return;
	}
	display.writeimage(fd, img);
}
