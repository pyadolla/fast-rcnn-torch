# how to run main_{train|test}

th_lua5.2
arg={'-model_def', './data/trained_models/MY_MODEL','-year',2012,'-dataset','VOC2012','-test_img_set','val','-exp_id',1}
dofile'main_test'
#need to add ss_dir to README

# to run demo 

qlua
arg={'-model_weights', './data/trained_models/MY_MODEL'}
dofile'demo'


#VGG16 ross model to test on 2007
arg={'-model_def', './models/VGG16/VGG16_ross.lua','-model_weights','','-year',2007,'-dataset','VOC2007','-test_img_set','val'}  


#testing running COCO main_test
arg={'-model_def', './models/VGG16/VGG16_ross_COCO.lua','-model_weights','','-year',2014,'-dataset','COCO','-test_img_set','val'}
####Still debugging it

