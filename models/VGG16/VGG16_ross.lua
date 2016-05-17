require'inn'
require'loadcaffe'
require'detection'
local function create_model()
    local name = 'frcnn_vgg16_ross'
    modelfile='./data/trained_models/VGG16test.prototxt'
    weightfile='./data/trained_models/vgg16_fast_rcnn_iter_40000.caffemodel'

    local net=loadcaffe.load(modelfile,weightfile,'cudnn');

    local shared=net:clone()
    for i=40,31,-1 do
        shared:remove(i)
    end

    local shared_roi_info=nn.ParallelTable()
    shared_roi_info:add(shared)
    shared_roi_info:add(nn.Identity())

    --local ROIPooling = inn.ROIPooling(7,7):setSpatialScale(1/16)
    local ROIPooling = detection.ROIPooling(7,7):setSpatialScale(1/16)

    local classifier = net:get(38)
    local regressor = net:get(40)
    local output=nn.ConcatTable()
    output:add(classifier)
    output:add(regressor)

    local model=nn.Sequential()
    model:add(shared_roi_info)
    model:add(ROIPooling)
    for i=31,37 do --linear part
       model:add(net:get(i))
    end
    model:add(output)
    model:cuda()

    return model,classifier,regressor,name
end
return create_model
