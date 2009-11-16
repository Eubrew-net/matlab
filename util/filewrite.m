function filewrite(file,matrix)
  f=fopen(file,'wb');
  c=fwrite(f,matrix);
  fclose(f);
  