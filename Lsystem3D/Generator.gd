extends Node3D

var drawble := "FRL"
var actions := "[]&^/\\`:"
var rules := {}
var current := {}
var animationSpeed := 0.2
var colorLighteningFactor := 0.01
var TW: Tween
const JointsPart = preload("res://Part.gd")

func _ready() -> void:
	randomize()
	start("Tree1", 2, Vector3.ZERO, Vector3.ZERO, [Color.SADDLE_BROWN.darkened(0.8)])

func start(preset_name: String, steps: int, startingPos: Vector3, startingRota: Vector3, colors: Array) -> void:
	TW = create_tween()
	load_preset(preset_name)
	set_current(startingPos, startingRota, colors)
	calculate_state(steps)
	set_parts()

func load_preset(presetName: String) -> void:
	var presets := ConfigFile.new()
	var err := presets.load("presets.cfg")

	if err != OK:
		return

	for p in presets.get_sections():
		if p == presetName:
			for key in presets.get_section_keys(p):
				match key:
					"values":
						current = presets.get_value(p, key)
					_:
						rules[key] = presets.get_value(p, key)
			return
	print("No such preset in config")
	
func set_current(startingPos: Vector3, startingRota: Vector3, colors: Array) -> void:
	current.angle = deg_to_rad(current.angle)
	current.rota = startingRota
	current.color = colors[0]
	#init empty as parent holder
	current.parentPart = JointsPart.new("", Vector3.ZERO, 0, 0, current.color)
	current.parentPart.position = startingPos
	add_child(current.parentPart)

func calculate_state(steps: int) -> void:
	for step in steps:
		var tmp := ""
		for part in current.state:
			if part in rules:
				if randi_range(0, 99) in range(0, rules[part].pbty):
					tmp += rules[part].main
				else:
					tmp += rules[part].second
			else:
				tmp += part
		current.state = tmp

func set_parts() -> void:
	var checkpoint := {"parentPart": [], "rota": [], "length": [], "width": [], "color": []}
	for part in current.state:
		if part in drawble:
			if part == "F":
				var newPart = JointsPart.new("branch", current.rota, current.length, current.width, current.color)
				newPart.meshInst.scale = Vector3.ZERO
				TW.tween_property(newPart.meshInst, "scale", Vector3.ONE, animationSpeed)
				current.parentPart.jointEnd.add_child(newPart)
				current.parentPart = newPart
				
				current.color = current.color.lightened(colorLighteningFactor)
				current.rota = Vector3.ZERO
			elif part == "R":
				var newPart = JointsPart.new("apple", current.rota, current.length, current.width, Color.CRIMSON)
				newPart.meshInst.scale = Vector3.ZERO
				TW.tween_property(newPart.meshInst, "scale", Vector3.ONE, animationSpeed)
				current.parentPart.jointEnd.add_child(newPart)
			elif part == "L":
				var newPart = JointsPart.new("leaf", current.rota, current.length, current.width, Color.SEA_GREEN)
				newPart.meshInst.scale = Vector3.ZERO
				TW.tween_property(newPart.meshInst, "scale", Vector3.ONE, animationSpeed)
				current.parentPart.jointEnd.add_child(newPart)
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
				":":
					current.width *= current.widthMulti
				_:
					print("unknown symbol in state")


