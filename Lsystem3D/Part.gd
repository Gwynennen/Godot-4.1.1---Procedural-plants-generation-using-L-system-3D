class_name Part extends Marker3D

var jointEnd := Marker3D.new()
var tween: Tween
var meshInst := MeshInstance3D.new()
const types = ["branch", "apple", "leaf"]

#consider using enum here instead of string
func _init(type:String, rota: Vector3, partLength: float, partWidth: float, color:Color) -> void:
	randomize()
	rotation += rota
	jointEnd.position.y += partLength
	add_child(jointEnd)
	if type not in types: return
	match type:
		types[0]: 
			make_mesh_tube(8, partLength, partWidth)
		types[1]:
			meshInst.set_mesh(SphereMesh.new())
			meshInst.mesh.radius = partWidth
			meshInst.mesh.height = 2*partWidth
			meshInst.position.z = 2*partWidth
		types[2]:
			meshInst.set_mesh(SphereMesh.new())
			meshInst.mesh.radius = partWidth
			meshInst.mesh.height = 0
			meshInst.position = Vector3(0, -0.5*partWidth, 1.5*partWidth)
	add_child(meshInst)
	set_color(color)

func set_color(color:Color) -> void:
	meshInst.set_material_override(StandardMaterial3D.new())
	meshInst.get_material_override().set_albedo(color)
	meshInst.get_material_override().set_shading_mode(BaseMaterial3D.SHADING_MODE_UNSHADED)

func make_mesh_tube(sidesCount: int, partLength: float, partWidth:float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	var angle := ((PI*2) / sidesCount)
	for i in sidesCount+1:
#		tube point top
		st.add_vertex(Vector3(partWidth*cos(angle*i), partLength, partWidth*sin(angle*i)))
# 		tube point base
		st.add_vertex(Vector3(partWidth*cos(angle*i), 0, partWidth*sin(angle*i)))
	meshInst.set_mesh(st.commit())

