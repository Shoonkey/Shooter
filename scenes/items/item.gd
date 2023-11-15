extends CharacterBody2D

@export var rotation_speed: int = 4
@export var growth_speed: int = 2
@export var friction: int = 140
@export var move_speed: int = 350

var available_options = ["laser", "laser", "laser", "laser", "grenade", "health"]
var type = available_options[randi()%len(available_options)]
var direction: Vector2

@onready var audio_player = $AudioStreamPlayer2D
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var retrieval_hurtbox_shape = $RetrievalHurtbox/CollisionShape2D

func _ready():
	if type == "laser":
		$Sprite2D.modulate = Color(0.1, 0.2, 0.8)
	
	if type == "grenade":
		$Sprite2D.modulate = Color(0.8, 0.2, 0.1)
	
	if type == "health":
		$Sprite2D.modulate = Color(0.1, 0.8, 0.1)
	
	scale = Vector2.ZERO
	velocity = direction * move_speed


func _process(delta):
	rotation += rotation_speed * delta
	velocity = velocity.move_toward(Vector2.ZERO, delta * friction)
	scale = scale.move_toward(Vector2(1, 1), delta * growth_speed)
	move_and_slide()


func _on_retrieval_hurtbox_body_entered(_body: Node2D):
	if type == "health":
		Globals.health += 10
	
	if type == "laser":
		Globals.laser_amount += 5
	
	if type == "grenade":
		Globals.grenade_amount += 1
	
	audio_player.play()
	sprite.hide()

	# disable collision shapes on next frame so it stops processing collision
	# after the item has disappeared but the object hasn't been freed yet
	# as it is waiting for the audio to finish playing
	collision_shape.set_deferred("disabled", true)
	retrieval_hurtbox_shape.set_deferred("disabled", true)
	
	await audio_player.finished
	queue_free()
