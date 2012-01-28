create or replace package body bmp as

  headersize constant pls_integer := 14;
  infosize   constant pls_integer := 40;
  offset     constant pls_integer := infosize + headersize;

  bmpWidth            pls_integer;
  bmpHeight           pls_integer;
  lineLen             pls_integer;
  filesize            pls_integer; 

  output_file         utl_file.file_type;

  the_bits            blob;


  function  unsigned_short(s in pls_integer) return raw is/*{*/
    ret raw(2);
    v   pls_integer;
    r   pls_integer;
  begin

    v := trunc (s/256); r := s-v; ret := utl_raw.cast_to_raw(chr(v));
    v := trunc (s    ); r := s-v; ret := utl_raw.cast_to_raw(chr(v)) || ret;
    
   return ret;

  end unsigned_short;/*}*/

  function  unsigned_rgb(r in pls_integer, g in pls_integer, b in pls_integer) return raw is /*{*/
    ret raw(3);
  begin

    ret := utl_raw.cast_to_raw(chr(r));
    ret := utl_raw.cast_to_raw(chr(g)) || ret;
    ret := utl_raw.cast_to_raw(chr(b)) || ret;
    
   return ret;

  end unsigned_rgb;/*}*/

  function  unsigned_int(i in pls_integer) return raw is /*{*/

    /* i = ret(4) * 256*256*256  +
           ret(3) * 256*256      +
           ret(2) * 256          +
           ret(1)                   */


--  ret raw(4);
--  v   pls_integer;
--  r   pls_integer;
  begin

--  v := trunc (i/256/256/256); r := i-v; ret := utl_raw.cast_to_raw(chr(v));
--  v := trunc (i/256/256    ); r := i-v; ret := utl_raw.cast_to_raw(chr(v)) || ret;
--  v := trunc (i/256        ); r := i-v; ret := utl_raw.cast_to_raw(chr(v)) || ret;
--  v := trunc (i            ); r := i-v; ret := utl_raw.cast_to_raw(chr(v)) || ret;

    return utl_raw.cast_from_binary_integer(i, utl_raw.little_endian);
    
-- return ret;

  end unsigned_int;/*}*/

  procedure WriteHeader is /*{*/
    imagesize pls_integer;
  begin
    imagesize := bmpHeight * lineLen;
    filesize  := imagesize + offset;

    -- Header
    dbms_lob.append(the_bits, utl_raw.cast_to_raw('BM')); -- Pos  0

    dbms_lob.append(the_bits, unsigned_int(filesize));    -- Pos  2

    dbms_lob.append(the_bits, unsigned_short(0));         -- Pos  6, reserved 1
    dbms_lob.append(the_bits, unsigned_short(0));         -- Pos  8, reserved 2
    dbms_lob.append(the_bits, unsigned_int(offset));      -- Pos 10, offset to image

    -- Information
    dbms_lob.append(the_bits, unsigned_int(infosize));    -- Pos 14
    dbms_lob.append(the_bits, unsigned_int(bmpWidth));    -- Pos 18
    dbms_lob.append(the_bits, unsigned_int(bmpHeight));   -- Pos 22

    dbms_lob.append(the_bits, unsigned_short( 1));        -- Pos 26, planes
    dbms_lob.append(the_bits, unsigned_short(24));        -- Pos 28, bits per pixel
    dbms_lob.append(the_bits, unsigned_int  ( 0));        -- Pos 30, no compression
    dbms_lob.append(the_bits, unsigned_int  (imagesize)); -- Pos 34

    dbms_lob.append(the_bits, unsigned_int  (7874));      -- Pos 38, x pixels/meter (???)
    dbms_lob.append(the_bits, unsigned_int  (7874));      -- Pos 42, y pixels/meter (???)
    dbms_lob.append(the_bits, unsigned_int  (0));         -- Pos 46, Number of colors
    dbms_lob.append(the_bits, unsigned_int  (0));         -- Pos 50, Important colors
  end WriteHeader;/*}*/

  procedure Init(width pls_integer, height pls_integer, r in pls_integer, g in pls_integer, b in pls_integer) is/*{*/
    bgColor raw(3);
  begin
    bmpWidth  := width;
    bmpHeight := height;

    -- lineLen must be divisible by 4
    lineLen := 4*ceil(3*bmpWidth/4);

    bgColor  := unsigned_rgb(r,g,b);
    the_bits := empty_blob();
    dbms_lob.createTemporary(the_bits, true);
    dbms_lob.open(the_bits, dbms_lob.lob_readwrite);

    WriteHeader;

    for x in 0 .. bmpWidth-1 loop for Y in 0 .. bmpHeight-1 loop
      dbms_lob.append(the_bits, bgColor);
    end loop; end loop;

  end Init;/*}*/

  function  AsBlob return blob is begin/*{*/
    return the_bits;
  end AsBlob;/*}*/

  procedure PixelAt(x in pls_integer, y in pls_integer, rgb in raw) is begin/*{*/
    
    if x < 0 or y < 0 or x >= bmpWidth or y >= bmpHeight then
      return;
    end if;

    dbms_lob.write(the_bits, 3, 1+offset+ (bmpHeight-y-1)*lineLen + x*3, rgb);
  end PixelAt;/*}*/

  procedure PixelAt(x pls_integer, /*{*/
                    y pls_integer, 
                    r pls_integer, 
                    g pls_integer, 
                    b pls_integer) is 
    rgb raw(3); 
  begin
    rgb := unsigned_rgb(r,g,b); 

    PixelAt(x, y, rgb);
  end PixelAt;/*}*/
 
  procedure Line (xFrom pls_integer, /*{*/
                  yFrom pls_integer, 
                  xTo   pls_integer, 
                  yTo   pls_integer, 
                  r     pls_integer, 
                  g     pls_integer, 
                  b     pls_integer) 
  is

    rgb    raw(3); 
    c      pls_integer;
    m      pls_integer;
    x      pls_integer;
    y      pls_integer;
    D      pls_integer;
    HX     pls_integer;
    HY     pls_integer;
    xInc   pls_integer;
    yInc   pls_integer;

  begin 

    rgb := unsigned_rgb(r,g,b); 

    x    :=       xFrom;
    y    :=       yFrom;
    D    :=           0;
    HX   := xTo - xfrom;
    HY   := yTo - yfrom;
    xInc :=           1;
    yInc :=           1;

    if HX < 0 then xInc := -1; HX   := -HX; end if;
    if HY < 0 then yInc := -1; HY   := -HY; end if;

    if HY <= HX then
      c := 2*HX;
      M := 2*HY;

      loop
        PixelAt(x, y, rgb);
        exit when x = xTo;

        x := x + xInc;
        D := D + M; 

        if D > HX then y := y+yInc; D := D-c; end if;
      end loop;

    else

      c := 2*HY;
      M := 2*HX;

      loop
        PixelAt(x, y, rgb);
        exit when y = yTo;

        y := y + yInc;
        D := D + M; 

        if D > HY then
          x := x + xInc;
          D := D - c;
        end if;
      end loop;

    end if;
  end Line;/*}*/

  procedure Circle_(x      pls_integer,/*{*/
                    y      pls_integer,
                    xx     pls_integer,
                    yy     pls_integer, 
                    rgb    raw)         
  is begin

    if xx = 0 then

      PixelAt(x      , y + yy , rgb);
      PixelAt(x      , y - yy , rgb);
      PixelAt(x  + yy, y      , rgb);
      PixelAt(x  - yy, y      , rgb);

    elsif xx = yy then

      PixelAt(x  + xx , y + yy , rgb);
      PixelAt(x  - xx , y + yy , rgb);
      PixelAt(x  + xx , y - yy , rgb);
      PixelAt(x  - xx , y - yy , rgb);

    elsif xx < yy then

      PixelAt(x  + xx , y + yy , rgb);
      PixelAt(x  - xx , y + yy , rgb);
      PixelAt(x  + xx , y - yy , rgb);
      PixelAt(x  - xx , y - yy , rgb);

      PixelAt(x  + yy , y + xx , rgb);
      PixelAt(x  - yy , y + xx , rgb);
      PixelAt(x  + yy , y - xx , rgb);
      PixelAt(x  - yy , y - xx , rgb);

    end if;
  end Circle_;/*}*/

  procedure Circle (x      pls_integer,/*{*/
                    y      pls_integer,
                    radius pls_integer,
                    r      pls_integer, 
                    g      pls_integer, 
                    b      pls_integer) 
  is

    xx  pls_integer := 0;
    yy  pls_integer := radius;
    pp  pls_integer := (5-radius*4)/4;
    rgb raw(3);

  begin

    rgb := unsigned_rgb(r,g,b); 

    Circle_(x, y, xx, yy, rgb);

    while xx < yy loop

      xx := xx+1;

      if pp < 0 then
        pp := pp + 2*xx+1;
      else
        yy := yy - 1;
        pp := pp + 2*(xx-yy) + 1;
      end if;

      Circle_(x, y, xx, yy, rgb);

    end loop;

  end Circle;/*}*/

  procedure Ellipse (/*{*/
  -------------------------------------------
  -- 
  --        Thanks to Thierry Vergote
  --        for implementing ellipse
  --        and fixing an endian bug 
  --        in unsigned_int.
  --
  -------------------------------------------
    x       pls_integer,
    y       pls_integer,
    xradius pls_integer,
    yradius pls_integer,
    r       pls_integer,
    g       pls_integer,
    b       pls_integer
  ) is
    x_           pls_integer;
    y_           pls_integer;
    xchange      pls_integer;
    ychange      pls_integer;
    ellipseerror pls_integer;
    twoasquare   pls_integer;
    twobsquare   pls_integer;
    stoppingx    pls_integer;
    stoppingy    pls_integer;
    rgb          raw(3);

    procedure plot4ellipsepoints (/*{*/
      xp4 pls_integer,
      yp4 pls_integer
    ) IS
    begin
      PixelAt(x + xp4, y + yp4, rgb); -- point in quadrant 1
      PixelAt(x - xp4, y + yp4, rgb); -- point in quadrant 2
      PixelAt(x - xp4, y - yp4, rgb); -- point in quadrant 3
      PixelAt(x + xp4, y - yp4, rgb); -- point in quadrant 4
    end plot4ellipsepoints;/*}*/

  begin
    rgb          := unsigned_rgb(r,g,b); 
    twoasquare   := 2 * xradius * xradius;
    twobsquare   := 2 * yradius * yradius;
    x_           := xradius;
    y_           := 0;
    xchange      := yradius * yradius * (1 - 2 * xradius);
    ychange      := xradius * xradius;
    ellipseerror := 0;
    stoppingx    := twobsquare * xradius;
    stoppingy    := 0;
    while stoppingx >= stoppingy loop/*{*/
      -- 1st set of points, y_' > 1
      plot4ellipsepoints(x_, y_); 
      y_           := y_ + 1;
      stoppingy    := stoppingy    + twoasquare;
      ellipseerror := ellipseerror + ychange;
      ychange      := ychange      + twoasquare;
      if 2 * ellipseerror + xchange > 0 then
        x_           := x_ - 1; 
        stoppingx    := stoppingx - twobsquare; 
        ellipseerror := ellipseerror + xchange;
        xchange      := xchange + twobsquare; 
      end if;
    end loop;/*}*/
    -- 1st point set is done; start the 2nd set of points 
    x_            := 0;
    y_            := yradius;
    xchange      := yradius * yradius;
    ychange      := xradius * xradius * (1 - 2 * yradius);
    ellipseerror := 0;
    stoppingx    := 0;
    stoppingy    := twoasquare * yradius;
    while stoppingx <= stoppingy loop/*{*/
      -- 2nd set of points, y_'< 1
      plot4ellipsepoints(x_, y_); 
      x_            := x_ + 1; 
      stoppingx    := stoppingx + twobsquare; 
      ellipseerror := ellipseerror + xchange; 
      xchange      := xchange + twobsquare;
      if 2 * ellipseerror + ychange > 0 then
        y_            := y_ - 1; 
        stoppingy    := stoppingy - twoasquare; 
        ellipseerror := ellipseerror + ychange; 
        ychange      := ychange + twoasquare; 
      end if;
    end loop;/*}*/
  end Ellipse;/*}*/

end bmp;
/
