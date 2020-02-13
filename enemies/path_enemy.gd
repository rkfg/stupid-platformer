extends Enemy

export var path_node: NodePath
var path: Path2D

var follow := PathFollow2D.new()

func _ready() -> void:
	if path_node:
		path = get_node(path_node)
		if path:
			path.add_child(follow)

func move(delta: float) -> void:
	if path:
		follow.offset += delta * speed * walking_direction.x

		$Sprite.flip_h = follow.global_position.x - position.x > 0
		position = follow.global_position
	else:
		.move(delta)
