function res = voc_eval(path, comp_id, year, test_set, output_dir, rm_res)

VOCopts = get_voc_opts(path, year);
VOCopts.testset = test_set;
for i = 1:length(VOCopts.classes)
  cls = VOCopts.classes{i};
  res(i) = voc_eval_cls(path, cls, VOCopts, comp_id, output_dir, rm_res);
end

fprintf('\n~~~~~~~~~~~~~~~~~~~~\n');
fprintf('Results:\n');
aps = [res(:).ap]';
fprintf('%.1f\n', aps * 100);
fprintf('%.1f\n', mean(aps) * 100);
fprintf('~~~~~~~~~~~~~~~~~~~~\n');

function res = voc_eval_cls(path, cls, VOCopts, comp_id, output_dir, rm_res)
test_set = VOCopts.testset;
year = VOCopts.dataset(4:end);

if str2num(year) == 2007,
  addpath(fullfile(VOCopts.datadir, 'VOCcode07'));
else
  addpath(fullfile(VOCopts.datadir, 'VOCcode'));
end

%disp(VOCopts);
respath =['results/VOC',year,'/Main/'];
[oldpath,name,ext] = fileparts(VOCopts.detrespath);
VOCopts.detrespath =  [path,respath,'%s_det_', test_set, '_%s',ext]; %['/%s_det_' test_set '_%s.txt']; %[path,respath,name,ext]
[oldpath,name,ext] = fileparts(VOCopts.resdir);
VOCopts.resdir =  [path,respath,name,ext];

%disp(VOCopts.detrespath);

res_fn = sprintf(VOCopts.detrespath, comp_id, cls);

recall = [];
prec = [];
ap = 0;
ap_auc = 0;

do_eval = (str2num(year) <= 2007) | ~strcmp(test_set, 'test');
if do_eval
  % Bug in VOCevaldet requires that tic has been called first
  tic;
  [recall, prec, ap] = VOCevaldet(VOCopts, comp_id, cls, true);
  ap_auc = xVOCap(recall, prec);

  % force plot limits
  ylim([0 1]);
  xlim([0 1]);

  print(gcf, '-djpeg', '-r0', ...
        [output_dir '/' cls '_pr.jpg']);
end
fprintf('!!! %s : %.4f %.4f\n', cls, ap, ap_auc);

res.recall = recall;
res.prec = prec;
res.ap = ap;
res.ap_auc = ap_auc;

save([output_dir '/' cls '_pr.mat'], ...
     'res', 'recall', 'prec', 'ap', 'ap_auc');

if rm_res
  delete(res_fn);
end

if str2num(year) == 2007,
  rmpath(fullfile(VOCopts.datadir, 'VOCcode07'));
else
  rmpath(fullfile(VOCopts.datadir, 'VOCcode'));
end
