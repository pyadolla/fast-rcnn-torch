local ok = pcall(require,'qt')
if not ok then
  error('You need to run visualize_detections using qlua')
end
require 'qttorch'
require 'qtwidget'

-- Demo for the CocoApi (see CocoApi.lua)
require 'torch'
require 'tds'
require 'xlua'
tablex=tablex or require'pl.tablex'

coco = coco or require 'coco'
image = image or require 'image'

-- initialize COCO api for instance annotations
dataDir, dataType = '/share/data/vision-greg/coco/', 'train2014'
annFile = dataDir..'/annotations/instances_'..dataType..'.json'
if not cocoApi then cocoApi=coco.CocoApi(annFile) end

-- get all image ids, select one at random
if not imgIds then imgIds = cocoApi:getImgIds() end
imgId = imgIds[torch.random(imgIds:numel())]

-- load attributes
print("load attributes")
if not attr then attr = torch.load('/share/data/vision-greg/coco/attributes/cocottributes_04042016.tds.t7') end
if not ann_to_patch then ann_to_patch = torch.load('/share/data/vision-greg/coco/attributes/ann_id_to_patch_id.t7') end

-- This part is to exclude all of the images without attributes
print("exclude images without attributes")
if not tmpIds then
	tmpIds = {}
	for index= 1,imgIds:size(1) do
        xlua.progress(index, imgIds:size(1))
		local annIds = cocoApi:getAnnIds({imgId=imgIds[index]})
		local anns = cocoApi:loadAnns(annIds)
		for i,_ in pairs(anns) do
			if anns[i]['bbox'] then
				local boxesId = anns[i]['id']
				annId = ann_to_patch[boxesId]
	 			if (attr['ann_vecs'][ tostring(annId)]) then
	 				-- imgIds[index] = nil
                    table.insert(tmpIds,imgIds[index])
                    break;
	 			end
			end
		end
	end

	imgIds = torch.DoubleTensor(tmpIds)
	--print(imgIds,imgIds:size())
end

-- choose an image at random
imgId = imgIds[torch.random(imgIds:numel())]

-- load image
print("load image")
img = cocoApi:loadImgs(imgId)[1]
I = image.load(dataDir..dataType..'/'..img.file_name,3)

-- load instance annotations
annIds = cocoApi:getAnnIds({imgId=imgId})
anns = cocoApi:loadAnns(annIds)

-- remove segmentation so it can display the bounding boxes
print("remove image segmentations")
boxesIds = {}
boxes = {}

for i,v in pairs(anns) do
	-- Making the segmentation to nil will display the boxes instead of segmentations
	anns[i]['segmentation'] = nil
	if anns[i]['bbox'] then
		boxes[i] = anns[i]['bbox']
	end
	boxesIds[i] = anns[i]['id']
	-- print(i,k,l)
end


-- display instance annotations
print("display image bboxes")
J = cocoApi:showAnns(I,anns)
-- image.save('RES_'..img.file_name,J:double())
local qtimg = qt.QImage.fromTensor(J)
local x,y = J:size(3),J:size(2)
local w = qtwidget.newwindow(x,y,"Fast R-CNN for Torch!")
w:image(0,0,x,y,qtimg)
local fontsize = 16

--sort attribute names
sortf=function(x,y) return x.id < y.id end
attrNames={}
for k,v in tablex.sortv(attr.attributes,sortf) do attrNames[#attrNames+1]=v.name end

qt.connect(w.listener,
  'sigMousePress(int,int,QByteArray,QByteArray,QByteArray)',
  function(x,y)
  	-- print("hello",boxes)
  	print("\nboxsize "..#boxes)
      for i,_ in pairs (boxes) do
      	-- print("do I get here?")
 
      	bx1 = boxes[i][1]
      	bx2 = boxes[i][3] + bx1
      	by1 = boxes[i][2]
      	by2 = boxes[i][4] + by1
      	-- print('i = ',i,boxes[i],"x = " .. x,'box x1 = ' .. bx1,"y = " .. y,'box y1 = ' .. by1)
        if x> bx1 and x < bx2 and y>by1 and y<by2 then
            print(i)
			w:setcolor(200/255,130/255,200/255,1)
			w:rectangle(20,20,120,55)
			w:fill()
			w:stroke()

			w:setcolor(0,0,0,1)
			w:fill(false)
			w:rectangle(20,20,120,55)
			w:stroke()

			w:moveto(30,40)
			w:setfont(qt.QFont{serif=true,italic=true,size=fontsize,bold=true})
			w:setcolor(qt.QColor("#000000"))
			-- print("attr annvec = ",attr['ann_vecs'][ tostring(boxesIds[i])])

			-- Not sure which is correct
			annId = ann_to_patch[boxesIds[i]]
			-- annId = boxesIds[i]
 			if (attr['ann_vecs'][ tostring(annId)]) then
				-- print("finally working")
			
				for k,v in ipairs(attr['ann_vecs'][ tostring(annId)]) do
					if (attr['ann_vecs'][ tostring(annId)][k] >=1) then
						print(attrNames[k])
					end
				end
			end
			w:moveto(30,40+fontsize+5)
			-- w:show(string.format('%2.2f',max_score[i]))
			w:stroke()
			w:fill(false)
        end
      end
  end );

return w
