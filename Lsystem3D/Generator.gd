extends Node3D

var drawble = "F"
var actions = "-+[]|#!{}.<>&^/\\()`"
var rules
var starting
var current
var TW

func _ready():
	randomize()
	start("Tree1", 3)

func start(preset_name: String, steps):
	TW = create_tween()
	rules = load_settings(preset_name)
	set_current_state()
	calculate_state(steps)
	create_parts()

func set_current_state():
	current = starting.duplicate(true)
	current.rota = Vector3.ZERO
	current.parentJoint = self

func load_settings(presetName: String):
	var preset_data = {}
	var presets = ConfigFile.new()
	var err = presets.load("presets.cfg")

	if err != OK:
		return

	for p in presets.get_sections():
		if p == presetName:
			for key in presets.get_section_keys(p):
				match key:
					"values":
						starting = presets.get_value(p, key)
						starting.angle = deg_to_rad(starting.angle)
					_:
						preset_data[key] = presets.get_value(p, key)
						
			return preset_data
	push_error("No such preset in config")

func calculate_state(steps):
	for step in steps:
		var tmp = ""
		for part in current.state:
			if part in rules:
				if randi_range(0, 99) in range(0, rules[part].pbty):
					tmp += rules[part].main
				else:
					tmp += rules[part].second
			else:
				tmp += part
		current.state = tmp

func create_parts():
	var checkpoint = {"parentJoint": [], "rota": [], "length": []}
	for part in current.state:
		if part in drawble:
			make_part()
		elif part in actions:
			match part:
#				handle stack
				"[":
					for key in checkpoint:
						checkpoint[key].append(current[key])
				"]":
					for key in checkpoint:
						current[key] = checkpoint[key].pop_back()
# 				pitch
				"&":
					current.rota.x += current.angle
				"^":
					current.rota.x -= current.angle
#				roll
				"\\":
					current.rota.y += current.angle
				"/":
					current.rota.y -= current.angle
#				scale
				"`":
					current.length *= current.lengthMulti
					
				_:
					push_error("unknown symbol")

func make_part():
	var jointStart = Marker3D.new()
	jointStart.rotation += current.rota
	current.parentJoint.add_child(jointStart)
	current.parentJoint = jointStart
	
	var jointEnd = Marker3D.new()
	jointEnd.position = make_animated_mesh(8)
	current.parentJoint.add_child(jointEnd)
	current.parentJoint = jointEnd
		

func make_animated_mesh(sidesCount):
	var endPos = Vector3(0,current.length,0)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

#	st.add_vertex(Vector3.ZERO)
#	st.add_vertex(endPos)
	var angle = ((PI*2) / sidesCount)
	for i in sidesCount+1:
#		tube point top
		st.add_vertex(Vector3(current.width*cos(angle*i), endPos.y, current.width*sin(angle*i)))
# 		tube point base
		st.add_vertex(Vector3(current.width*cos(angle*i), 0, current.width*sin(angle*i)))
	
	var tube = MeshInstance3D.new()
	tube.set_mesh(st.commit())
	tube.scale = Vector3.ZERO
	TW.tween_property(tube, "scale", Vector3.ONE, 0.1)
	
	current.parentJoint.add_child(tube)
	return endPos

