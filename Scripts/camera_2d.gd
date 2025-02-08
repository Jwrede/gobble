extends Camera2D

var zoom_percentage = 30
var max_zoom = 6.5
var max_unzoom = 3.5
var edge_margin: float = 50
var movement_speed: float = 125

var drag_cursor_shape = false

func _input(event):
	if is_current():
		if event is InputEventMouseMotion:
			if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
				position -= event.relative / zoom
				drag_cursor_shape = true
			else:
				drag_cursor_shape = false

		if event is InputEventMouseButton:
			if event.is_pressed():
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					zoom += Vector2.ONE * zoom_percentage / 100
					if zoom.x > max_zoom:
						zoom = Vector2.ONE * max_zoom
						return
					position += get_local_mouse_position() / 10
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					zoom -= Vector2.ONE * zoom_percentage / 100
					if zoom.x < max_unzoom:
						zoom = Vector2.ONE * max_unzoom

func _process(delta):
	if is_current():
		if drag_cursor_shape:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_DRAG)
		else:
			handle_edge_movement(delta)
			handle_keyboard_movement(delta)
		

func handle_keyboard_movement(delta: float) -> void:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		global_translate(direction * movement_speed * delta)

func handle_edge_movement(delta: float) -> void:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var screen_rect = viewport.get_visible_rect()
	var direction = Vector2.ZERO

	if mouse_pos.x < edge_margin:
		direction.x -= 1
	elif mouse_pos.x > screen_rect.size.x - edge_margin:
		direction.x += 1

	if mouse_pos.y < edge_margin:
		direction.y -= 1
	elif mouse_pos.y > screen_rect.size.y - edge_margin:
		direction.y += 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		global_translate(direction * movement_speed * delta)
