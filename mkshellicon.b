implement MkShellIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point, Font: import draw;

MkShellIcon: module
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

	# Terminal window: title bar + dark screen.
	icon.draw(Rect(Point(2,3),  Point(26,25)), display.rgb(60,64,72), nil, Point(0,0));
	icon.draw(Rect(Point(3,7),  Point(25,24)), display.rgb(20,24,30), nil, Point(0,0));

	green := display.rgb(90, 230, 110);
	# Prompt "> " drawn crisply with a font, plus a cursor block.
	f := Font.open(display, "/fonts/misc/ascii.6x10.font");
	if(f != nil)
		icon.text(Point(6,10), green, Point(0,0), f, ">");
	icon.draw(Rect(Point(13,11), Point(18,15)), green, nil, Point(0,0));
	# A dim output line.
	icon.draw(Rect(Point(6,19), Point(20,20)), display.rgb(80,120,90), nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Shell/icons/!Shell.bit",  icon);
	writeimg("/usr/inferno/!Shell/icons/!Shell.mask", mask);
	sys->print("wrote !Shell\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
