%facts
circle(_Radius).
rectangle(_Width, _Height).
triangle(_Base, _Height).


%rules
area(circle(Radius), Area) :- Area is pi * Radius * Radius.
area(rectangle(Width, Height), Area) :- Area is Width * Height.
area(triangle(Base, Height), Area) :- Area is  0.5 * Height * Base.
