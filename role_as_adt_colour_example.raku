use v6;

# For a product type, we could for example create a type for an RGB colour triplet:

role RGBColour[Int \r, Int \g, Int \b] {
    has Int $.r = r;
    has Int $.g = g;
    has Int $.b = b; 
}


# The `RGB` label on the right-hand side is the constructor of the type. It takes three arguments of type `Int`:

my RGBColour \aquamarine = RGBColour[ 127, 255, 212].new;

say aquamarine;

# So `aquamarine` is a variable of type `RGBColour` with a value of `RGB 127 255 212`. 

# The constructor identifies the type. Suppose we also have an HSL colour type

role HSLColour[Int \h, Int \s, Int \l] {
    has Int $.h = h;
    has Int $.s = s;
    has Int $.l = l; 
}

# with a variable `chocolate` of that type:

my HSLColour \chocolate = HSLColour[25, 75, 47].new; 

say chocolate;

# then both `RGB` and `HSL` are triplets of `Int` but because of the different type constructors they are not the same type. 

# Let's say we create an RGB Pixel type:

role XYCoord[Int \x, Int \y] {
    has Int $.x=x; 
    has Int $.y=y;  
}

role RGBPixel[ RGBColour \rgb, XYCoord \xy ] {
    has RGBColour $.rgb = rgb;
    has XYCoord $.xy = xy;
} 

# then 

my RGBPixel \p = RGBPixel[ aquamarine, XYCoord[ 42, 24].new ].new;

say p;

# is fine but

# my RGBPixel \p_ = RGBPixel[ chocolate, XYCoord[ 42, 24] ].new;

# will be a type error because `chocolate` is of type `HSLColour`, not `RGBColour`. 

# We could support both RGB and HSL using a sum type:

role Colour {}
role HSL[ HSLColour \hsl] does Colour {
    has HSLColour $.hsl = hsl;
};
role RGB[ RGBColour \rgb] does Colour {
    has RGBColour $.rgb = rgb;
};

# and change make a Pixel type definition:

role Pixel[ Colour \c, XYCoord \xy ] {
    has Colour $.c = c;
    has XYCoord $.xy = xy;
}

# And now we can say 

my Pixel \p_rgb = Pixel[ RGB[ aquamarine].new , XYCoord[ 42, 24].new ].new;
my Pixel \p_hsl = Pixel[ HSL[ chocolate ].new , XYCoord[ 42, 24].new ].new;

say p_rgb;
say p_hsl;