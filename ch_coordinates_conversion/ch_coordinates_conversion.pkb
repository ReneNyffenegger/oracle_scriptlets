create or replace package body ch_coordinates_conversion as

-- The MIT License (MIT) -- {
-- 
-- Copyright (c) 2014 Federal Office of Topography swisstopo, Wabern, CH and Joerg Schmidt, Rola AG, Zürich, CH
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--   THE SOFTWARE.
--

-- Source: http://www.swisstopo.admin.ch/internet/swisstopo/en/home/topics/survey/sys/refsys/projections.html (see PDFs under "Documentation")
--
-- Translated from python to oracle by Joerg Schmidt (Rola AG)
--
-- Please validate your results with NAVREF on-line service: http://www.swisstopo.admin.ch/internet/swisstopo/en/home/apps/calc/navref.html (difference ~ 1-2m) -- }

--
-- TODO Do the lat and lng really need to be in out parameters?
--

  function WGStoCHy(lat in out float, lng in out float) return float -- {
  -- Convert WGS lat/long (° dec) to CH y
  is
    lat_aux float;
    lng_aux float;
    y float;
   begin

    lat := DECtoSEX(lat);
    lng := DECtoSEX(lng);

    lat_aux := (lat - 169028.66)/10000;
    lng_aux := (lng - 26782.5  )/10000;


    y := (600072.37
         + 211455.93 * lng_aux
         - 10938.51 * lng_aux * lat_aux
         - 0.36 * lng_aux * power( lat_aux, 2 )
         - 44.54 * power( lng_aux, 3 ) );
    return y;

  end WGStoCHy; -- }

  function WGStoCHx(lat in out float, lng in out float) return float -- {
  -- Convert WGS lat/long (° dec) to CH x
  is
    lat_aux float;
    lng_aux float;
    x float;
   begin

    lat := DECtoSEX(lat);
    lng := DECtoSEX(lng);

    lat_aux := (lat - 169028.66)/10000;
    lng_aux := (lng - 26782.5  )/10000;

    x := (200147.07
         + 308807.95 * lat_aux
         + 3745.25 * power(lng_aux, 2 )
         + 76.63 * power( lat_aux, 2 )
         - 194.56 * power( lng_aux, 2) * lat_aux
         + 119.79 * power( lat_aux, 3) );

    return x;

  end WGStoCHx; -- }

  function CHtoWGSlat(y float, x float) return float -- {
  -- Convert CH y/x to WGS lat
  is
    y_aux float;
    x_aux float;
    lat   float;

  begin
    y_aux := (y - 600000)/1000000;
    x_aux := (x - 200000)/1000000;

    lat := (16.9023892
           + 3.238272 * x_aux
           - 0.270978 * power( y_aux, 2 )
           - 0.002528 * power( x_aux, 2 )
           - 0.0447 * power( y_aux, 2 ) * x_aux
           - 0.0140 * power( x_aux, 3 ) );

    lat := lat * 100/36;
    return lat;

  end CHtoWGSlat; -- }

  function CHtoWGSlng(y float, x float) return float -- {
  -- Convert CH y/x to WGS long
  is
    y_aux float;
    x_aux float;
    lng   float;
  begin

    y_aux := (y - 600000)/1000000;
    x_aux := (x - 200000)/1000000;

    lng := (2.6779094
          + 4.728982 * y_aux
          + 0.791484 * y_aux * x_aux
          + 0.1306   * y_aux * power( x_aux, 2 )
          - 0.0436   *         power( y_aux, 3 )
       );

    --  Unit 10000" to 1 " and converts seconds to degrees (dec)
    lng := lng * 100/36;
    return lng;

    end CHtoWGSlng; -- }

  function DECtoSEX(angle float) return float -- {
   -- Convert decimal angle to sexagesimal seconds
   is
     deg float;
     mnt float;
     sec float;
  begin

    deg := angle;
    mnt := (angle-deg)*60;
    sec := (((angle-deg)*60)-mnt)*60;


    return sec + mnt * 60 + deg * 3600;
  end DECtoSEX; -- }

end ch_coordinates_conversion;
/
