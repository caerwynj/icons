implement MkTorrentIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkTorrentIcon: module
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

	# Solid green badge (the classic torrent download disc).
	green := display.rgb(54, 168, 86);
	icon.fillellipse(Point(14,13), 12, 12, green, Point(0,0));

	# Bold white download arrow: wide stem + large arrowhead.
	wht := display.white;
	icon.draw(Rect(Point(11,4), Point(17,12)), wht, nil, Point(0,0));	# stem
	# Arrowhead as stacked shrinking rows (robust vs fillpoly).
	for(dy := 0; dy <= 8; dy++) {
		hw := 8 - dy;
		icon.draw(Rect(Point(14-hw,12+dy), Point(14+hw,13+dy)), wht, nil, Point(0,0));
	}

	# White baseline tray under the arrow.
	icon.draw(Rect(Point(8,22), Point(20,24)), wht, nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Torrent/icons/!Torrent.bit",  icon);
	writeimg("/usr/inferno/!Torrent/icons/!Torrent.mask", mask);
	sys->print("wrote !Torrent\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
