-- Require the detection package
require 'detection'

-- Paths
local year = config.year
local dataset_name = config.dataset
local image_set = config.test_img_set
local dataset_dir = config.dataset_path --paths.concat(config.dataset_path,dataset_name)
local ss_dir = './data/datasets/selective_search_data/'
--local ss_file =  paths.concat(ss_dir,dataset_name .. '_' .. image_set .. '.mat')
local param_path = config.model_weights
local model_path = config.model_def


-- Loading the dataset
local dataset = detection.DataSetPascal({image_set = image_set, year = year, datadir = dataset_dir, dataset_name = dataset_name, roidbdir = ss_dir , roidbfile = ss_file})

if not paths.filep(config.detection_file) then
  error('need to provide detection file')
end

if not paths.filep(config.threshold_file) then
  error('need to provide threshold file')
end

local all_detections=torch.load(config.detection_file)
local thresholds = torch.load(config.threshold_file)

-- Creating the wrapper
local network_wrapper = detection.NetworkWrapper()
network_wrapper:writeDetections(dataset,all_detections,thresholds,true)
