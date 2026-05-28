implement MkEPubIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkEPubIcon: module
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

	bezel  := display.rgb(48, 52, 62);
	screen := display.white;
	text   := display.rgb(150, 156, 168);
	accent := display.rgb(70, 150, 90);	# green title line

	# E-reader tablet: bezel, screen, home button.
	icon.draw(Rect(Point(6,2),  Point(22,26)), bezel, nil, Point(0,0));
	icon.draw(Rect(Point(8,4),  Point(20,21)), screen, nil, Point(0,0));
	icon.fillellipse(Point(14,23), 1, 1, display.rgb(150,156,168), Point(0,0));

	# Title line + body text on the page.
	icon.draw(Rect(Point(9,6),  Point(17,8)),  accent, nil, Point(0,0));
	for(i := 0; i < 4; i++) {
		y := 11 + i*2;
		w := 10;
		if(i == 3) w = 6;
		icon.draw(Rect(Point(9,y), Point(9+w,y+1)), text, nil, Point(0,0));
	}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!EPub/icons/!EPub.bit",  icon);
	writeimg("/usr/inferno/!EPub/icons/!EPub.mask", mask);
	sys->print("wrote !EPub\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
