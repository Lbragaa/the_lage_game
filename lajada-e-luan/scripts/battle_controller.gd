extends Node2D

var player_hp = 10
var enemy_hp = 10
var player_guarding = false
var battle_over = false

@onready var player_hp_label = $UI/PlayerHPLabel
@onready var enemy_hp_label = $UI/EnemyHPLabel
@onready var status_label = $UI/StatusLabel
@onready var attack_button = $UI/AttackButton
@onready var guard_button = $UI/GuardButton

func _ready():
	reset_battle()
	update_ui()

func update_ui():
	player_hp_label.text = "Player HP: " + str(player_hp)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)

func player_attack():
	if battle_over:
		return

	enemy_hp -= 3
	# Updates directly into the HP Label
	status_label.text = "You attacked!"
	update_ui()

	if enemy_hp <= 0:
		end_battle("Victory!")
		return

	enemy_turn()

func player_guard():
	if battle_over:
		return

	player_guarding = true
	status_label.text = "You guarded!"
	enemy_turn()

func enemy_turn():
	if battle_over:
		return

	var damage = 3

	if player_guarding:
		damage = 1
		player_guarding = false

	player_hp -= damage
	status_label.text = "Enemy attacked for " + str(damage) + " damage!"
	update_ui()

	if player_hp <= 0:
		end_battle("Defeat!")
		return

	status_label.text = "Player Turn"

func end_battle(result_text):
	battle_over = true
	status_label.text = result_text
	attack_button.disabled = true
	guard_button.disabled = true


#Reset function

func reset_battle():
	player_hp = 10
	enemy_hp = 10
	player_guarding = false
	battle_over = false
	status_label.text = "Player Turn"
	attack_button.disabled = false
	guard_button.disabled = false
	
	update_ui()
	

#Button related stuff
func _on_attack_button_pressed():
	print("Attack button pressed")
	player_attack()

func _on_guard_button_pressed():
	print("Guard button pressed")
	player_guard()


func _on_reset_button_pressed() -> void:
	reset_battle()
