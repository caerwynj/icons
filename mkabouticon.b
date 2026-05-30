implement MkAboutIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkAboutIcon: module
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

	rim   := display.rgb(40, 80, 150);
	blue  := display.rgb(60, 140, 230);
	wht   := display.white;

	# Blue info disc with a darker rim.
	icon.fillellipse(Point(14,14), 12, 12, rim, Point(0,0));
	icon.fillellipse(Point(14,14), 11, 11, blue, Point(0,0));

	# White "i": dot on top, vertical bar below.
	icon.fillellipse(Point(14,8), 1, 1, wht, Point(0,0));
	icon.draw(Rect(Point(13,11), Point(15,21)), wht, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!About/icons/!About.bit",  icon);
	writeimg("/usr/inferno/!About/icons/!About.mask", mask);
	sys->print("wrote !About\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
