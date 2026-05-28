implement MkIrcIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkIrcIcon: module
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

	blue  := display.rgb(60, 130, 220);
	green := display.rgb(60, 180, 90);
	wht   := display.white;

	# Back speech bubble (blue) with a down-left tail.
	bubble(icon, Rect(Point(3,3), Point(19,14)), blue);
	for(i := 0; i < 5; i++)
		icon.draw(Rect(Point(5,12+i), Point(5+(5-i),13+i)), blue, nil, Point(0,0));
	dots(icon, 6, 8, wht);

	# Front speech bubble (green) with a down-right tail, overlapping.
	bubble(icon, Rect(Point(12,12), Point(26,23)), green);
	for(j := 0; j < 5; j++)
		icon.draw(Rect(Point(22-(5-j),21+j), Point(22,22+j)), green, nil, Point(0,0));
	dots(icon, 15, 17, wht);

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!IRC/icons/!IRC.bit",  icon);
	writeimg("/usr/inferno/!IRC/icons/!IRC.mask", mask);
	sys->print("wrote !IRC\n");
}

# Rounded speech bubble: rect body plus rounded corners via ellipses.
bubble(img: ref Image, r: Rect, src: ref Image)
{
	img.draw(Rect(Point(r.min.x+2,r.min.y), Point(r.max.x-2,r.max.y)), src, nil, Point(0,0));
	img.draw(Rect(Point(r.min.x,r.min.y+2), Point(r.max.x,r.max.y-2)), src, nil, Point(0,0));
	img.fillellipse(Point(r.min.x+2,r.min.y+2), 2, 2, src, Point(0,0));
	img.fillellipse(Point(r.max.x-3,r.min.y+2), 2, 2, src, Point(0,0));
	img.fillellipse(Point(r.min.x+2,r.max.y-3), 2, 2, src, Point(0,0));
	img.fillellipse(Point(r.max.x-3,r.max.y-3), 2, 2, src, Point(0,0));
}

# Three little message dots.
dots(img: ref Image, x, y: int, src: ref Image)
{
	for(i := 0; i < 3; i++)
		img.draw(Rect(Point(x+i*4,y), Point(x+i*4+2,y+2)), src, nil, Point(0,0));
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
