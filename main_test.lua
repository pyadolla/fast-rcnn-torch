-- Require the detection package
require 'detection'

torch.setheaptracking(true)
cutorch.setHeapTracking(true)

-- Paths
local year = config.year
local dataset_name = config.dataset
local image_set = config.test_img_set
local dataset_dir = config.dataset_path --paths.concat(config.dataset_path,dataset_name)
local ss_dir = './data/datasets/selective_search_data/'
--local ss_file =  paths.concat(ss_dir,dataset_name .. '_' .. image_set .. '.mat')
local param_path = config.model_weights
local model_path = config.model_def
local comp_id = 'comp4-4567'

-- Loading the dataset
local dataset = detection.DataSetPascal({image_set = image_set, year = year, datadir = dataset_dir, dataset_name = dataset_name, roidbdir = ss_dir , roidbfile = ss_file, comp_id = comp_id})

-- Creating the detection net
--model_opt = {}
--model_opt.test = true --false
--model_opt.nclass = dataset:nclass()
--model_opt.fine_tunning = not config.resume_training
local model_opt = {}
model_opt.fine_tuning = false
model_opt.test = true
if config.dataset== 'MSCOCO' then
   model_opt.nclass = 80
else
   model_opt.nclass = 20
end

network = detection.Net(model_path,param_path, model_opt)
collectgarbage()
collectgarbage()
-- Creating the wrapper
local network_wrapper = detection.NetworkWrapper()
-- Test the network
print('Testing the network on ' .. dataset.image_set ..  ' set...')
network_wrapper:testNetwork(dataset)
