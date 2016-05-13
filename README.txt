# how to run main_{train|test}

th_lua5.2
arg={'-model_def', './data/trained_models/MY_MODEL','-year',2012,'-dataset','VOC2012','-test_img_set','val'}
dofile'main_test'


# to run demo 

qlua
arg={'-model_weights', './data/trained_models/MY_MODEL'}
dofile'demo'


#VGG16 ross model
arg={'-model_def', './models/VGG16/VGG16_ross.lua','-model_weights','','-year',2012,'-dataset','VOC2012','-test_img_set','val'}  
