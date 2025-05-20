class_name LaserableLookup
extends Node

# Keys are CollisionObject2Ds and values are Laserables
var laserables: Dictionary = {}


func init(scene: Node2D) -> void:
	_init_top_level_lasers(scene)
	_register_collidables(scene)


func register_laserable(laserable: Laserable) -> void:
	var collision_object: CollisionObject2D = laserable.collision_object
	laserables[collision_object] = laserable


func register_laser_hit(collision_object: Object) -> Constants.LaserHitResponse:
	var laserable: Laserable = laserables.get(collision_object)
	if laserable:
		return laserable.register_laser_hit()

	return Constants.LaserHitResponse.ABSORB


func get_laser_material(collision_object: Object) -> Constants.LaserMaterial:
	var laserable: Laserable = laserables.get(collision_object)
	return laserable.laser_material


func _init_top_level_lasers(scene: Node2D) -> void:
	var children: Array[Node] = scene.get_children()
	for child: Node in children:
		if child is Laser:
			var laser: Laser = child
			laser.laserable_lookup = self

		elif child is Node2D:
			_init_top_level_lasers(child as Node2D)


func _register_collidables(scene: Node2D) -> void:
	var children: Array[Node] = scene.get_children()
	for child: Node in children:
		if child is Laserable:
			var laserable: Laserable = child
			var collision_object: CollisionObject2D = laserable.collision_object
			laserables[collision_object] = laserable

		elif child is Node2D:
			_register_collidables(child as Node2D)
