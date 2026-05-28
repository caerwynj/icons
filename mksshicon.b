implement MkSshIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point, Font: import draw;

MkSshIcon: module
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

	# Terminal (secure shell).
	icon.draw(Rect(Point(2,3),  Point(26,25)), display.rgb(60,64,72), nil, Point(0,0));
	icon.draw(Rect(Point(3,7),  Point(25,24)), display.rgb(20,24,30), nil, Point(0,0));

	# Green prompt in the corner.
	green := display.rgb(90, 230, 110);
	f := Font.open(display, "/fonts/misc/ascii.6x10.font");
	if(f != nil)
		icon.text(Point(5,8), green, Point(0,0), f, ">");
	icon.draw(Rect(Point(11,9), Point(14,12)), green, nil, Point(0,0));

	# Gold padlock (security).
	gold := display.rgb(238, 196, 70);
	dark := display.rgb(120, 96, 24);
	# shackle (inverted U)
	icon.draw(Rect(Point(11,13), Point(13,18)), dark, nil, Point(0,0));
	icon.draw(Rect(Point(17,13), Point(19,18)), dark, nil, Point(0,0));
	icon.draw(Rect(Point(11,12), Point(19,14)), dark, nil, Point(0,0));
	# body
	icon.draw(Rect(Point(9,17),  Point(21,25)), gold, nil, Point(0,0));
	# keyhole
	icon.fillellipse(Point(15,20), 1, 1, dark, Point(0,0));
	icon.draw(Rect(Point(14,20), Point(16,23)), dark, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!SSH/icons/!SSH.bit",  icon);
	writeimg("/usr/inferno/!SSH/icons/!SSH.mask", mask);
	sys->print("wrote !SSH\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
