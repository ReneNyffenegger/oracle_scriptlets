create or replace package bmp as 

  procedure Init   (width  pls_integer, 
                    height pls_integer,
                    r      pls_integer := 0, 
                    g      pls_integer := 0, 
                    b      pls_integer := 0);

  procedure PixelAt(x      pls_integer, 
                    y      pls_integer, 
                    r      pls_integer, 
                    g      pls_integer, 
                    b      pls_integer);

  procedure Line   (xFrom  pls_integer, 
                    yFrom  pls_integer, 
                    xTo    pls_integer, 
                    yTo    pls_integer, 
                    r      pls_integer, 
                    g      pls_integer, 
                    b      pls_integer);

  procedure Circle (x      pls_integer,
                    y      pls_integer,
                    radius pls_integer,
                    r      pls_integer, 
                    g      pls_integer, 
                    b      pls_integer);

  procedure Ellipse (/*{*/
  -------------------------------------------
  -- 
  --        Thanks to Thierry Vergote
  --        for implementing ellipse
  --        and fixing an endian bug 
  --        in this package.
  --
  -------------------------------------------
                   x       pls_integer,
                   y       pls_integer,
                   xradius pls_integer,
                   yradius pls_integer,
                   r       pls_integer,
                   g       pls_integer,
                   b       pls_integer);/*}*/

  function  AsBlob return blob;

end bmp;
/
