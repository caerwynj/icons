implement MkColoursIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkColoursIcon: module
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
	bg := display.rgb(70, 72, 80);
	icon.draw(all, bg, nil, Point(0,0));

	# 3x2 palette of rainbow swatches with bevels.
	r := array[] of {220, 235, 240,  70,  60, 160};
	g := array[] of { 50, 140, 210, 190, 120,  70};
	b := array[] of { 50,  40,  50,  90, 220, 200};
	k := 0;
	for(row := 0; row < 2; row++)
		for(col := 0; col < 3; col++) {
			x := 3 + col*8;
			y := 4 + row*11;
			swatch(icon, x, y, 7, 9, r[k], g[k], b[k]);
			k++;
		}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Colours/icons/!Colours.bit",  icon);
	writeimg("/usr/inferno/!Colours/icons/!Colours.mask", mask);
	sys->print("wrote !Colours\n");
}

swatch(img: ref Image, x, y, w, h, red, grn, blu: int)
{
	base := display.rgb(red, grn, blu);
	lite := display.rgb(clamp(red+60), clamp(grn+60), clamp(blu+60));
	dark := display.rgb(clamp(red-60), clamp(grn-60), clamp(blu-60));
	img.draw(Rect(Point(x,y), Point(x+w,y+h)), base, nil, Point(0,0));
	img.draw(Rect(Point(x,y), Point(x+w,y+1)), lite, nil, Point(0,0));
	img.draw(Rect(Point(x,y), Point(x+1,y+h)), lite, nil, Point(0,0));
	img.draw(Rect(Point(x,y+h-1), Point(x+w,y+h)), dark, nil, Point(0,0));
	img.draw(Rect(Point(x+w-1,y), Point(x+w,y+h)), dark, nil, Point(0,0));
}

clamp(v: int): int
{
	if(v < 0) return 0;
	if(v > 255) return 255;
	return v;
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
