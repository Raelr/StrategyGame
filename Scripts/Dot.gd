extends Sprite

func _ready():
	$AnimationPlayer.current_animation = "expand"
	$AnimationPlayer.play()
