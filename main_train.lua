-- Require the detection package
require 'detection'

torch.setheaptracking(true)
cutorch.setHeapTracking(true)

-- Paths
local year = config.year
local dataset_name = config.dataset
local image_set = config.train_img_set
local dataset_dir = config.dataset_path --paths.concat(config.dataset_path,dataset_name)
local roi_path = config.roi_path  --'./data/datasets/selective_search/'
--local ss_file =  paths.concat(ss_dir, dataset_name .. '_' .. image_set .. '.mat')
local param_path = config.pre_trained_file
local model_path = config.model_def
local comp_id = 'comp4-4567'

-- Loading the dataset
local dataset
if dataset_name == 'COCO' then
    print('COCO')
    dataset = detection.DataSetCoco({image_set = image_set, year = year, datadir = dataset_dir, dataset_name = dataset_name, roidbdir = roi_path , roidbfile = ss_file})
else
    dataset = detection.DataSetPascal({image_set = image_set, year = year, datadir = dataset_dir, dataset_name = dataset_name, roidbdir = roi_path , roidbfile = ss_file, comp_id = comp_id})
end

-- Creating the detection net
local model_opt = {}
model_opt.fine_tuning = not confir.resume_training
model_opt.test = false
--model_opt.nclass = dataset:nclass()
if config.dataset== 'COCO' then
    model_opt.nclass = 80
else
    -- Pascal
    model_opt.nclass = 20
end

network = detection.Net(model_path,param_path,model_opt)
collectgarbage()
collectgarbage()
-- Creating the network wrapper
local network_wrapper = detection.NetworkWrapper() -- This adds train and test functionality to the global network

-- Train the network on the dataset
print('Training the network...')
network_wrapper:trainNetwork(dataset)
