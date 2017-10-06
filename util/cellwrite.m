function cellwrite(file,matrix)
  f=fopen(file,'wb');
  fprintf(f,'%s\n',matrix{:});
  fclose(f);
  