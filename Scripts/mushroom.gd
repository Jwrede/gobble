class_name Mushroom extends HarvestableResource

var respawn_time = 15

func _init():
	resources_start = 3
	resources_left = resources_start
	collect_amount = 1

func harvest():
	if resources_left - collect_amount <= 0:
		$RespawnTimer.start(respawn_time)
		visible(false)
		var return_amount = resources_left
		resources_left = 0
		return return_amount
	resources_left -= collect_amount
	return collect_amount
	
func visible(toggle: bool):
	$ResourceArea.monitorable = toggle
	$ResourceArea.monitoring = toggle
	$MushroomSprite.visible = toggle
	

func outline(toggle: bool):
	$MushroomSprite.material.set_shader_parameter("width", toggle)


func _on_respawn_timer_timeout() -> void:
	resources_left = resources_start
	visible(true)
