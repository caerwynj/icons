implement MkDisManagerIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point, Font: import draw;

MkDisManagerIcon: module
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

	# Three stacked module cards (back to front) in different colours.
	modcard(icon, Rect(Point(3,4),  Point(18,15)), 60, 170, 110);	# green
	modcard(icon, Rect(Point(7,9),  Point(22,20)), 70, 150, 220);	# blue
	modcard(icon, Rect(Point(11,14),Point(26,25)), 240, 150, 56);	# orange

	# Tiny "M" label on the front module.
	f := Font.open(display, "/fonts/misc/ascii.5x7.font");
	if(f != nil)
		icon.text(Point(16,17), display.white, Point(0,0), f, "M");

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!DisManager/icons/!DisManager.bit",  icon);
	writeimg("/usr/inferno/!DisManager/icons/!DisManager.mask", mask);
	sys->print("wrote !DisManager\n");
}

# A module card: dark outline + filled body + a small top "header" strip.
modcard(img: ref Image, r: Rect, red, grn, blu: int)
{
	dark := display.rgb(red*2/3, grn*2/3, blu*2/3);
	body := display.rgb(red, grn, blu);
	img.draw(r, dark, nil, Point(0,0));
	img.draw(Rect(Point(r.min.x+1,r.min.y+1), Point(r.max.x-1,r.max.y-1)), body, nil, Point(0,0));
	img.draw(Rect(Point(r.min.x+1,r.min.y+1), Point(r.max.x-1,r.min.y+3)), dark, nil, Point(0,0));
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
