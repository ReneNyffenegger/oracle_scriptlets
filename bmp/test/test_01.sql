begin
  bmp.Init(300, 200, 238, 238, 204);

  bmp.Line(  0,   0,   0, 199,  66, 166, 194);
  bmp.Line(  0, 199, 299, 199,  66, 166, 194);
  bmp.Line(299, 199, 299,   0,  66, 166, 194);
  bmp.Line(299,   0,   0,   0,  66, 166, 194);

  for i in 1 .. 36 loop 
    bmp.Line(150, 100, 150+sin(i/18*3.141)* 80, 100+cos(i/18*3.141)*80, 55, 0, 180);
  end loop;

  bmp.Circle(150, 100, 80, 255, 0, 0);

  blob_wrapper.to_file('BMP_OUT_DIR', 'test_01.bmp', bmp.AsBlob);
end;
/
