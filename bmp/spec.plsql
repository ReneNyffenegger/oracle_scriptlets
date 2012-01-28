create or replace package bmp as 

/* 
   Package bmp (spec.plsql and body.plsql)

   Copyright (C) René Nyffenegger

   This source code is provided 'as-is', without any express or implied
   warranty. In no event will the author be held liable for any damages
   arising from the use of this software.

   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:

   1. The origin of this source code must not be misrepresented; you must not
      claim that you wrote the original source code. If you use this source code
      in a product, an acknowledgment in the product documentation would be
      appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
      misrepresented as being the original source code.

   3. This notice may not be removed or altered from any source distribution.

   René Nyffenegger rene.nyffenegger@adp-gmbh.ch

*/

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
