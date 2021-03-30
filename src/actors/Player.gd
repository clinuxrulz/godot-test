extends Actor

func _physics_process(_delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released("jump") and velocity.y < 0.0
	velocity = calculate_move_velocity(velocity, get_direction(), speed, is_jump_interrupted)
	var is_move: = (get_node("AnimatedSprite").get("animation") as String) == "move-right";
	var is_playing_move: = get_node("AnimatedSprite").get("playing") as bool
	var is_facing_right: = !(get_node("AnimatedSprite").get("flip_h") as bool)
	var start_playing_move: = is_move && !is_playing_move and velocity.x != 0.0
	var stop_playing_move: = is_move && is_playing_move and velocity.x == 0.0
	var is_attacking: = (get_node("AnimatedSprite").get("animation") as String) == "attack"
	var start_attack = Input.is_action_just_pressed("attack") and !is_attacking
	var stop_attack: = (get_node("AnimatedSprite").get("frame") as int) == 4 and is_attacking
	if start_attack:
		get_node("AnimatedSprite").set("animation", "attack")
		get_node("AnimatedSprite").set("playing", true)
	if stop_attack:
		get_node("AnimatedSprite").set("animation", "move-right")
		get_node("AnimatedSprite").set("playing", false)
	if start_playing_move:
		get_node("AnimatedSprite").set("playing", true)
		if is_facing_right && velocity.x < 0.0:
			get_node("AnimatedSprite").set("flip_h", true)
		if !is_facing_right && velocity.x > 0.0:
			get_node("AnimatedSprite").set("flip_h", false)
	if stop_playing_move:
		get_node("AnimatedSprite").set("playing", false)
		get_node("AnimatedSprite").set("frame", 0)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)

func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0
	)

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var new_velocity: = linear_velocity
	new_velocity.x = speed.x * direction.x
	new_velocity.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		new_velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		new_velocity.y = 0.0
	return new_velocity
