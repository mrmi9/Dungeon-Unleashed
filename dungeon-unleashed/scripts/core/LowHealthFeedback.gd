extends RefCounted
class_name LowHealthFeedback

const LOW_RATIO := 0.35
const CRITICAL_RATIO := 0.18
const MIN_FEEDBACK_INTENSITY := 0.0
const DEFAULT_FEEDBACK_INTENSITY := 1.0
const MAX_FEEDBACK_INTENSITY := 1.0


static func get_health_ratio(current_hp: int, max_hp: int) -> float:
	var safe_max_hp := maxi(max_hp, 1)
	return clampf(float(maxi(current_hp, 0)) / float(safe_max_hp), 0.0, 1.0)


static func get_low_health_threshold(max_hp: int) -> int:
	return maxi(1, ceili(float(maxi(max_hp, 1)) * LOW_RATIO))


static func is_low_health(current_hp: int, max_hp: int) -> bool:
	return current_hp > 0 and current_hp <= get_low_health_threshold(max_hp)


static func get_critical_weight_from_ratio(health_ratio: float) -> float:
	if health_ratio <= CRITICAL_RATIO:
		return 1.0
	var ratio_span := maxf(LOW_RATIO - CRITICAL_RATIO, 0.01)
	return clampf((LOW_RATIO - health_ratio) / ratio_span, 0.0, 1.0)


static func interpolate_by_ratio(health_ratio: float, low_value: float, critical_value: float) -> float:
	return lerpf(low_value, critical_value, get_critical_weight_from_ratio(health_ratio))


static func interpolate_by_health(current_hp: int, max_hp: int, low_value: float, critical_value: float) -> float:
	return interpolate_by_ratio(get_health_ratio(current_hp, max_hp), low_value, critical_value)


static func clamp_feedback_intensity(value: float) -> float:
	return clampf(value, MIN_FEEDBACK_INTENSITY, MAX_FEEDBACK_INTENSITY)
