implement MkFilerIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkFilerIcon: module
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

	edge := display.rgb(170, 130, 30);
	tab  := display.rgb(220, 178, 70);
	body := display.rgb(238, 200, 96);

	# Folder tab (back) and body, with a darker outline.
	icon.draw(Rect(Point(3,7),  Point(13,11)), edge, nil, Point(0,0));
	icon.draw(Rect(Point(3,8),  Point(12,11)), tab,  nil, Point(0,0));
	icon.draw(Rect(Point(3,10), Point(25,23)), edge, nil, Point(0,0));
	icon.draw(Rect(Point(4,11), Point(24,22)), body, nil, Point(0,0));

	# Front flap highlight to suggest an open folder.
	icon.draw(Rect(Point(4,13), Point(24,15)), tab, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Filer/icons/!Filer.bit",  icon);
	writeimg("/usr/inferno/!Filer/icons/!Filer.mask", mask);
	sys->print("wrote !Filer\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
