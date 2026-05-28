implement MkPolyhedraIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkPolyhedraIcon: module
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

	c := Point(14,14);
	v := array[] of {
		Point(14,2), Point(24,8), Point(24,20),
		Point(14,26), Point(4,20), Point(4,8),
	};
	# Facet shades: lit from the top, darkening downward (3D gem look).
	sh := array[] of {
		display.rgb(150,200,245), display.rgb(95,155,222),
		display.rgb(52,104,182),  display.rgb(30,72,142),
		display.rgb(64,122,200),  display.rgb(112,176,236),
	};
	for(i := 0; i < 6; i++)
		filltri(icon, c, v[i], v[(i+1)%6], sh[i]);

	# Facet edges and outline.
	edge := display.rgb(20, 40, 80);
	for(i = 0; i < 6; i++) {
		icon.line(c, v[i], Draw->Endsquare, Draw->Endsquare, 0, edge, Point(0,0));
		icon.line(v[i], v[(i+1)%6], Draw->Endsquare, Draw->Endsquare, 0, edge, Point(0,0));
	}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Polyhedra/icons/!Polyhedra.bit",  icon);
	writeimg("/usr/inferno/!Polyhedra/icons/!Polyhedra.mask", mask);
	sys->print("wrote !Polyhedra\n");
}

# Scanline triangle fill (fillpoly is broken headless).
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
