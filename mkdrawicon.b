implement MkDrawIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkDrawIcon: module
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
	bg := display.rgb(214, 218, 226);
	icon.draw(all, bg, nil, Point(0,0));

	# White canvas.
	icon.draw(Rect(Point(3,3), Point(25,25)), display.rgb(80,80,80), nil, Point(0,0));
	icon.draw(Rect(Point(4,4), Point(24,24)), display.white, nil, Point(0,0));

	# Primitive shapes: yellow triangle (up), blue circle, red square.
	filltri(icon, Point(13,5), Point(7,14), Point(19,14), display.rgb(240,205,50));
	icon.fillellipse(Point(10,19), 4, 4, display.rgb(60,130,220), Point(0,0));
	icon.draw(Rect(Point(16,16), Point(23,23)), display.rgb(220,60,55), nil, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Draw/icons/!Draw.bit",  icon);
	writeimg("/usr/inferno/!Draw/icons/!Draw.mask", mask);
	sys->print("wrote !Draw\n");
}

filltri(img: ref Image, a, b, c: Point, src: ref Image)
{
	p := array[] of {a, b, c};
	ymin := a.y; ymax := a.y;
	for(k := 0; k < 3; k++) {
		if(p[k].y < ymin) ymin = p[k].y;
		if(p[k].y > ymax) ymax = p[k].y;
	}
	for(y := ymin; y <= ymax; y++) {
		xs := array[3] of int;
		nx := 0;
		for(k = 0; k < 3; k++) {
			p0 := p[k];
			p1 := p[(k+1)%3];
			if((p0.y <= y && p1.y > y) || (p1.y <= y && p0.y > y)) {
				xs[nx] = p0.x + (p1.x-p0.x)*(y-p0.y)/(p1.y-p0.y);
				nx++;
			}
		}
		if(nx >= 2) {
			lo := xs[0]; hi := xs[0];
			for(j := 1; j < nx; j++) {
				if(xs[j] < lo) lo = xs[j];
				if(xs[j] > hi) hi = xs[j];
			}
			img.draw(Rect(Point(lo,y), Point(hi+1,y+1)), src, nil, Point(0,0));
		}
	}
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
