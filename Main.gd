extends Node
@export var mob_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var data = {"number": 1, "string": "test" }   

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	var file = FileAccess.open('res://leaderboard.txt',FileAccess.WRITE_READ)
	var prev_score = file.get_line()
	if int(prev_score)<score:
		file.store_string(str(score))
		$HUD.sync_highest_score(score)
		file.close()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game(): 
	if(!FileAccess.file_exists('res://leaderboard.txt')):
		var file = FileAccess.open('res://leaderboard.txt', 7)
		file.close()
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	get_tree().call_group("mobs", "queue_free")
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_mob_timer_timeout():
		# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

# func save(score): //used to save every result, now we save only the highest score
	#var file = FileAccess.open('res://leaderboard.txt',FileAccess.READ_WRITE)
	#file.seek_end()
	#file.store_string('Highest Score: ' + str(score) + '\n')
	#file.close()
