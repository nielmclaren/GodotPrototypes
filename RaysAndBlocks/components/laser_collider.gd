extends Node

class_name LaserCollider

# Keys are CollisionObject2Ds and values are LaserCollidables
var laser_collidables: Dictionary = {}


func init(scene: Node2D) -> void:
	_init_top_level_lasers(scene)
	_register_collidables(scene)


func register_laser_collision(collision_object: Object) -> Constants.LaserCollisionResponse:
	var collidable: LaserCollidable = laser_collidables.get(collision_object)
	if collidable:
		if collidable.sensor:
			collidable.sensor.register_laser_collision()
		return collidable.collision_response

	return Constants.LaserCollisionResponse.ABSORB


func _init_top_level_lasers(scene: Node2D) -> void:
	var children: Array[Node] = scene.get_children()
	for child: Node in children:
		if child is Laser:
			var laser: Laser = child
			laser.set_laser_collider(self)

		elif child is Node2D:
			_init_top_level_lasers(child as Node2D)


func _register_collidables(scene: Node2D) -> void:
	var children: Array[Node] = scene.get_children()
	for child: Node in children:
		if child is LaserCollidable:
			var collidable: LaserCollidable = child
			var collision_object: CollisionObject2D = collidable.collision_object
			laser_collidables[collision_object] = collidable

		elif child is Node2D:
			_register_collidables(child as Node2D)
