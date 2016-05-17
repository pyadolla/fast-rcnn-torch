function VOCopts = get_voc_opts(path,year)

path = [path '../../VOCdevkit']
tmp = pwd;
cd(path);
try
  if year==2007,
    addpath('VOCcode07')
  else
    addpath('VOCcode');
  end
  VOCinit;%12;
catch
  if year==2007,
    rmpath('VOCcode07')
  else
    rmpath('VOCcode');
  end
  cd(tmp);
  error(sprintf('VOCcode directory not found under %s', path));
end
if year==2007,	
  rmpath('VOCcode07');
else
  rmpath('VOCcode');
end
cd(tmp);
