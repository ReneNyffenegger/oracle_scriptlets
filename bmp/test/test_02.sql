begin
  bmp.Init   (300, 200, 238, 238, 204);
  bmp.Ellipse(150, 100, 120, 80, 250, 100, 10);

  blob_wrapper.to_file('BMP_OUT_DIR', 'test_02.bmp', bmp.AsBlob);
end;
/
