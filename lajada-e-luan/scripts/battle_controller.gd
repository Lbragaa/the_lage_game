extends Node2D

const PLAYER_ATTACK_DAMAGE := 3
const ENEMY_ATTACK_DAMAGE := 3
const GUARDED_DAMAGE := 1
const STARTING_HP := 10

var player_hp: int = STARTING_HP
var enemy_hp: int = 10
var player_guarding: bool = false
var battle_over: bool = false

@onready var player_hp_label = $UI/PlayerHPLabel
@onready var enemy_hp_label = $UI/EnemyHPLabel
@onready var status_label = $UI/StatusLabel
@onready var attack_button = $UI/AttackButton
@onready var guard_button = $UI/GuardButton
@onready var reset_button = $UI/ResetButton

func _ready() -> void:
	reset_battle()

func update_ui() -> void:
	player_hp_label.text = "Player HP: " + str(player_hp)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)

func player_attack() -> void:
	if battle_over:
		return

	enemy_hp -= PLAYER_ATTACK_DAMAGE
	enemy_hp = max(enemy_hp, 0)

	status_label.text = "You attacked!"
	update_ui()

	if enemy_hp <= 0:
		end_battle("Victory!")
		return

	enemy_turn()

func player_guard() -> void:
	if battle_over:
		return

	player_guarding = true
	status_label.text = "You guarded!"
	enemy_turn()

func enemy_turn() -> void:
	if battle_over:
		return

	var damage: int = ENEMY_ATTACK_DAMAGE

	if player_guarding:
		damage = GUARDED_DAMAGE
		player_guarding = false

	player_hp -= damage
	player_hp = max(player_hp, 0)

	status_label.text = "Enemy attacked for " + str(damage) + " damage!"
	update_ui()

	if player_hp <= 0:
		end_battle("Defeat!")
		return

	status_label.text = "Player Turn"

func end_battle(result_text: String) -> void:
	battle_over = true
	status_label.text = result_text
	attack_button.disabled = true
	guard_button.disabled = true

func reset_battle() -> void:
	player_hp = 10
	enemy_hp = 10
	player_guarding = false
	battle_over = false

	status_label.text = "Player Turn"
	attack_button.disabled = false
	guard_button.disabled = false

	update_ui()

func _on_attack_button_pressed() -> void:
	print("Attack button pressed")
	player_attack()

func _on_guard_button_pressed() -> void:
	print("Guard button pressed")
	player_guard()

func _on_reset_button_pressed() -> void:
	reset_battle()
