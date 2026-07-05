@tool
extends MeshInstance3D

@export var collision: bool = true

var mesh_node: MeshInstance3D
var prev_scale := Vector3.ZERO

static var FACE_UVS = [
	Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
]

func _ready():
	mesh_node = self
	mesh = create_cube_mesh()
	if collision:
		create_trimesh_collision()
	update()

func _process(_delta):
	if scale != prev_scale:
		prev_scale = scale
		update()

func update():
	var surface_array: Array = mesh_node.get_mesh().surface_get_arrays(0)

	# Adjust UV coordinates along the x-axis
	for i in [8, 9, 10, 11, 12, 13, 14, 15]: # Left and right
		surface_array[Mesh.ARRAY_TEX_UV][i] = FACE_UVS[i] * Vector2(scale.z, scale.y)

	# Adjust UV coordinates along the y-axis
	for i in [0, 1, 2, 3, 4, 5, 6, 7]: # Top and bottom
		surface_array[Mesh.ARRAY_TEX_UV][i] = FACE_UVS[i] * Vector2(-scale.x, -scale.z)

	# Adjust UV coordinates along the z-axis
	for i in [16, 17, 18, 19, 20, 21, 22, 23]: # Front and back
		surface_array[Mesh.ARRAY_TEX_UV][i] = FACE_UVS[i] * Vector2(scale.x, scale.y)

	# Create a new mesh with adjusted UV coordinates
	var new_mesh: ArrayMesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh_node.set_mesh(new_mesh)

func create_cube_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	
	# Define the 6 local normal directions for a cube
	var face_normals = [
		Vector3.UP,      # Top
		Vector3.DOWN,    # Bottom
		Vector3.LEFT,    # Left
		Vector3.RIGHT,   # Right
		Vector3.FORWARD, # Front (-Z)
		Vector3.BACK     # Back (+Z)
	]
	
	# Define localized vertex layouts for each face (relative to its normal direction)
	# Clockwise winding order ensures faces look outward toward the camera
	var face_vertices = [
		# Top Face (Y+)
		[Vector3(-0.5,  0.5, -0.5), Vector3( 0.5,  0.5, -0.5), Vector3( 0.5,  0.5,  0.5), Vector3(-0.5,  0.5,  0.5)],
		# Bottom Face (Y-)
		[Vector3(-0.5, -0.5,  0.5), Vector3( 0.5, -0.5,  0.5), Vector3( 0.5, -0.5, -0.5), Vector3(-0.5, -0.5, -0.5)],
		# Left Face (X-)
		[Vector3(-0.5,  0.5, -0.5), Vector3(-0.5,  0.5,  0.5), Vector3(-0.5, -0.5,  0.5), Vector3(-0.5, -0.5, -0.5)],
		# Right Face (X+)
		[Vector3( 0.5,  0.5,  0.5), Vector3( 0.5,  0.5, -0.5), Vector3( 0.5, -0.5, -0.5), Vector3( 0.5, -0.5,  0.5)],
		# Front Face (Z-)
		[Vector3( 0.5,  0.5, -0.5), Vector3(-0.5,  0.5, -0.5), Vector3(-0.5, -0.5, -0.5), Vector3( 0.5, -0.5, -0.5)],
		# Back Face (Z+)
		[Vector3(-0.5,  0.5,  0.5), Vector3( 0.5,  0.5,  0.5), Vector3( 0.5, -0.5,  0.5), Vector3(-0.5, -0.5,  0.5)]
	]
	
	# Standard 0 to 1 mapping for textures across a square face
	var face_uvs = [
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	]

	# Build data arrays side by side
	for i in range(6):
		var normal = face_normals[i]
		var verts = face_vertices[i]
		
		# Offset tracking for our index list tracker
		var vertex_offset = vertices.size()
		
		for j in range(4):
			vertices.append(verts[j])
			normals.append(normal)
			uvs.append(face_uvs[j])
			
		# Split our quad layout into two distinct render triangles
		# Triangle 1: Top-Left -> Top-Right -> Bottom-Right
		indices.append(vertex_offset + 0)
		indices.append(vertex_offset + 1)
		indices.append(vertex_offset + 2)
		# Triangle 2: Top-Left -> Bottom-Right -> Bottom-Left
		indices.append(vertex_offset + 0)
		indices.append(vertex_offset + 2)
		# Correct configuration ensures back-face culling works properly
		indices.append(vertex_offset + 3)

	# Package separate property streams into Godot's surface container format
	var surface_arrays := []
	surface_arrays.resize(Mesh.ARRAY_MAX)
	surface_arrays[Mesh.ARRAY_VERTEX] = vertices
	surface_arrays[Mesh.ARRAY_NORMAL] = normals
	surface_arrays[Mesh.ARRAY_TEX_UV] = uvs
	surface_arrays[Mesh.ARRAY_INDEX] = indices

	# Commit our constructed arrays directly into memory data pipelines
	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)
	return arr_mesh
