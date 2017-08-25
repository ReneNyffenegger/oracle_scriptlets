declare

--    -------------------------------------------------
--
--    August 2017: Thanks to Brian McGinity for
--    demonstrating on how to
--    create a png
--
--    -------------------------------------------------

  srcImg     ordsys.ordImage; 
  readyImg   ordsys.ordImage;
begin

  bmp.Init   (300, 200, 238, 238, 204);
  bmp.Ellipse(150, 100, 120,  80, 250, 100, 10);


  srcImg  := ordsys.ordimage.init();
  srcImg.source.localdata := bmp.AsBlob;
  srcImg.setProperties();
 

  readyImg := ordsys.ordimage.init();
  dbms_lob.createtemporary(readyImg.source.localdata, true);

  ordsys.ordimage.processcopy(srcImg,'fileFormat=png', readyImg);

  blob_wrapper.to_file('BMP_OUT_DIR', 'test_03.png', readyImg.getContent());
  
end;
/
