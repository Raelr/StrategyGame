extends Control
onready var turn = 0

func _ready():
	$BleedingShield/AnimationPlayer.play("Idle")
	turn = 1
	var world = get_tree().get_root().get_child(0)
	world.connect("on_turn_changed", self, "increment_turn")

func increment_turn():
	turn += 1
	$TurnLabel.text = str(turn)


