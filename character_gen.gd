extends Node2D

onready var tf1 = get_node('HBoxContainer/TextureFrame1')
onready var tf2 = get_node('HBoxContainer/TextureFrame2')
onready var tf3 = get_node('HBoxContainer/TextureFrame3')
onready var tf4 = get_node('HBoxContainer/TextureFrame4')
onready var tf5 = get_node('HBoxContainer/TextureFrame5')

var validParts = [["feet",  "torso", "head", "helmet", "weapon", "shield"],
				  ["feet",  "torso", "head", "helmet", "weapon"],
				  ["feet",  "torso", "head", "hair",   "weapon"],
				  ["feet",  "torso", "head", "hair",   "weapon", "shield"],
				  ["feet",  "torso", "head", "helmet"],
				  ["feet",  "torso", "head", "hair"],
				  ["feet", "torso",  "head", "helmet", "bow"],
				  ["feet",  "torso", "head", "hair",   "bow"]
				]
				
func list_files_in_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()
    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(file)
    dir.list_dir_end()
    return files

func merge(src_img, img, palette):
	var img_size = src_img.get_size()
	var y = 0
	while y < img_size.y: 
		y += 1
		var x = 0
		while x < img_size.x:
			x += 1
			var pixel = src_img.get_data().get_pixel(x, y)
			if pixel.a > 0:
				pixel = palette.GetColor(pixel)
				if pixel != null:
					img.put_pixel(x, y, pixel)
	return img
		
class PaletteSet:
	var _mappings = {}
	var rand = randf()
	func GetColor(src): #color
		var rv = src
		if _mappings.has(src):
			if _mappings[src] == rv:
				return rv
			else:
				return _mappings[src]
		else:
			return rv
		
	func _init(palette):
		var src_img = ImageTexture.new()
		src_img.load(palette)
		var img_size = src_img.get_size()
		var start = -1
		var end = -1
		var y = 0
		while y < img_size.y: 
			y += 1
			if start == -1:
				if src_img.get_data().get_pixel(0, y).a > 0:
					start = y
					end = y
			else:
				if src_img.get_data().get_pixel(0, y).a == 0:
					self.readSet(src_img, start, end)
					start = -1
					end = -1
				else:
					end = y
						
	func readSet(src, start, end):
		var idx = rand_range(start + 1, end + 1)
		var x = 0
		while x < src.get_size().x:
			x += 1
			var srcPixel = src.get_data().get_pixel(x, start)
			if srcPixel.a == 0:
				return
			var dstPixel = src.get_data().get_pixel(x, idx)
			self._mappings[srcPixel] = dstPixel
			

func gen():
	var p = PaletteSet.new('res://Reference/colors.png')
	var vps = validParts.size()
	var parts = validParts[randi() % vps]
	var img 
	for item_name in parts:
		var path_dir = "res://Reference/" + item_name + '/'
		var files = list_files_in_directory(path_dir)
		var item_rnd_file = files[randi() % files.size()]
		
		var src_img = ImageTexture.new()
		src_img.load(path_dir + item_rnd_file)
		var img_size = src_img.get_size()
		var transPixel = Color(0, 0, 0, 0)
		if img == null:
			img = Image(img_size.x, img_size.y, false, 3)
			var y = 0
			while y < img_size.y:
				y += 1
				var x = 0
				while x < img_size.x:
					x += 1
					img.put_pixel(x, y, transPixel)
					
		img = merge(src_img, img, p)
		print (item_rnd_file)
	#img.save_png('npc.png')
	var imagetexture = ImageTexture.new()
	imagetexture.create_from_image(img)
	return imagetexture

func msss_gen():
	tf1.set_texture(gen())
	tf2.set_texture(gen())
	tf3.set_texture(gen())
	tf4.set_texture(gen())
	tf5.set_texture(gen())

func _ready():
	randomize()
	msss_gen()
	
func _on_Button_pressed():
	msss_gen()