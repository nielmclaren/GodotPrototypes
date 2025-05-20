extends Node

# A refraction is considered an internal reflection instead if it's within ±(error) of ±π.
const MAX_CRITICAL_ANGLE_DETECTION_ERROR: float = 3.0


func get_wavelength(laser_color: Constants.LaserColor) -> float:
	match laser_color:
		Constants.LaserColor.RED:
			return 694.3  # Ruby
		Constants.LaserColor.GREEN:
			return 532  # Frequency-doubled Nd:YAG
		Constants.LaserColor.BLUE:
			return 355  # Frequency-trebled Nd:YAG
		_:
			print("ERROR Bad laser colour.")
			return 532


func is_internal_reflection(
	in_angle: float,
	wavelength: float,
	in_material: Constants.LaserMaterial,
	out_material: Constants.LaserMaterial
) -> bool:
	var angle_of_refraction: float = get_angle_of_refraction(
		in_angle, wavelength, in_material, out_material
	)
	return PI / 2 - abs(angle_of_refraction) < deg_to_rad(MAX_CRITICAL_ANGLE_DETECTION_ERROR)


func get_angle_of_refraction(
	in_angle: float,
	wavelength: float,
	in_material: Constants.LaserMaterial,
	out_material: Constants.LaserMaterial
) -> float:
	var in_refractive_index: float = _get_refractive_index(wavelength, in_material)
	var out_refractive_index: float = _get_refractive_index(wavelength, out_material)
	return asin(sin(in_angle) * in_refractive_index / out_refractive_index)


func _get_refractive_index(wavelength: float, material: Constants.LaserMaterial) -> float:
	match material:
		Constants.LaserMaterial.VACUUM:
			return 1.0
		Constants.LaserMaterial.GLASS:
			return _cauchys_equation(wavelength, 1.728, 13420)
		Constants.LaserMaterial.WATER:
			return _cauchys_equation(wavelength, 1.3223, 3552)
		_:
			print("ERROR Unexpected material")
			return 1.0


# Selected constants for Cauchy's Equation.
#a = 1.3223 # Water
#b = 3552
#
#a = 1.5220 # Hard crown glass
#b = 4590
#
#a = 1.458 # Fused Silica
#b = 3540
#
#a = 1.728 # Dense flint glass SF10
#b = 13420
#
#a = 1.67 # Barium flint glass BaF10
#b = 7430
#
func _cauchys_equation(wavelength: float, a: float, b: float) -> float:
	return a + b / pow(wavelength, 2)
