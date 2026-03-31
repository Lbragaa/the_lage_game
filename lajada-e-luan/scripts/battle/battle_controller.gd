extends Node2D
# Esse export aqui que vai pegar do player data
@export var player_data: CharacterData

#Texture
const PLAYER_ALIVE_TEXTURE = preload("res://assets/characters/ArdenVale_thegame.png")
const PLAYER_DEAD_TEXTURE = preload("res://assets/characters/heroicaido.png")
const ENEMY_ALIVE_TEXTURE = preload("res://assets/characters/Sexo2_enemy.png")
const ENEMY_DEAD_TEXTURE = preload("res://assets/characters/enemy_cuiado.png")

const ENEMY_ATTACK_DAMAGE := 3
const GUARDED_DAMAGE := 1

var player_hp: int
var player_energy: int = 0
var enemy_hp: int = 10
var player_guarding: bool = false
var battle_over: bool = false
var overload_cooldown_remaining: int = 0

@onready var player_hp_label = $UI/PlayerHPLabel
@onready var enemy_hp_label = $UI/EnemyHPLabel
@onready var status_label = $UI/StatusLabel
@onready var energy_label = $UI/EnergyLabel
@onready var pulse_button = $UI/PulseButton
@onready var stabilize_button = $UI/StabilizeButton
@onready var reset_button = $UI/ResetButton
@onready var overload_button = $UI/OverloadButton
@onready var player_sprite = $UI/PlayerSprite
@onready var enemy_sprite = $UI/EnemySprite
# I know it is named fireball right now, i was just lazy to change to pulse ball in the rest of the code
@onready var fireball_sprite = $UI/PulseballSprite
@onready var discharge_button = $UI/DischargeButton
@onready var energy_bar = $UI/EnergyBar

# Functions to change the current sprite texture
func set_player_alive() -> void:
	player_sprite.texture = PLAYER_ALIVE_TEXTURE

func set_player_dead() -> void:
	player_sprite.texture = PLAYER_DEAD_TEXTURE

func set_enemy_alive() -> void:
	enemy_sprite.texture = ENEMY_ALIVE_TEXTURE

func set_enemy_dead() -> void:
	enemy_sprite.texture = ENEMY_DEAD_TEXTURE

# Helper functions for energy related stuff

func play_pulse_animation() -> void:
	fireball_sprite.visible = true
	fireball_sprite.global_position = player_sprite.global_position

	var tween = create_tween()
	tween.tween_property(
		fireball_sprite,
		"global_position",
		enemy_sprite.global_position,
		0.8
	)

	await tween.finished
	fireball_sprite.visible = false

func update_energy_bar() -> void:
	for child in energy_bar.get_children():
		child.queue_free()

	for i in range(player_data.max_energy):
		var square := ColorRect.new()
		square.custom_minimum_size = Vector2(18, 18)

		if i < player_energy:
			square.color = Color(0.2, 0.5, 1.0, 1.0)
		else:
			square.color = Color(0.15, 0.15, 0.15, 0.6)

		energy_bar.add_child(square)
	
func gain_energy(amount: int) -> void:
	player_energy += amount
	player_energy = min(player_energy, player_data.max_energy)

func spend_energy(amount: int) -> bool:
	if player_energy < amount:
		return false
	player_energy -= amount
	return true

func _ready() -> void:
	reset_battle()

func update_ui() -> void:
	player_hp_label.text = "Player HP: " + str(player_hp)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)
	energy_label.text = "Energy Level: " + str(player_energy) + "/" + str(player_data.max_energy)
	
	update_energy_bar()
	
	if overload_cooldown_remaining > 0:
		overload_button.text = "Overload (" + str(overload_cooldown_remaining) + ")"
	else:
		overload_button.text = "Overload"
		
func use_pulse() -> void:
	if battle_over:
		return
	
	gain_energy(player_data.pulse_energy_gain)
	
	await play_pulse_animation()
	enemy_hp -= player_data.pulse_damage
	enemy_hp = max(enemy_hp, 0)

	status_label.text = "You used Pulse!"
	update_ui()

	if enemy_hp <= 0:
		set_enemy_dead()
		end_battle("Victory!")
		
		return

	enemy_turn()
	

func use_stabilize() -> void:
	if battle_over:
		return

	player_guarding = true
	status_label.text = "You used Stabilize!"
	
	enemy_turn()

func update_cooldowns() -> void:
	
	if overload_cooldown_remaining > 0:
		overload_cooldown_remaining -= 1
	

func use_overload() -> void:
	
	if battle_over:
		return
		
	if overload_cooldown_remaining > 0:
		status_label.text = "Overload is on cooldown!"
		return
	
	if not spend_energy(player_data.overload_energy_cost):
		status_label.text = "Not enough energy for Overload!"
		return
	# Actual skill
	
	enemy_hp -= player_data.overload_damage
	enemy_hp = max(enemy_hp, 0)
	
	update_ui()
	
	if enemy_hp <= 0:
		#Enemy dead
		set_enemy_dead()
		end_battle("Electrifying Victory!")
		return
	
	overload_cooldown_remaining = player_data.overload_cooldown
	enemy_turn()

func use_discharge() -> void:
	
	if battle_over:
		return
		
	if not spend_energy(player_data.ultimate_energy_cost):
		status_label.text = "Not enough energy to use Discharge!"
		return
	
	#Went through
	
	enemy_hp -= player_data.ultimate_damage
	enemy_hp = max(enemy_hp, 0)
	
	status_label.text = "You used Discharge!"
	update_ui()
	
	if enemy_hp <= 0:
		set_enemy_dead()
		end_battle("Victory!")
		return
	
	enemy_turn()

func enemy_turn() -> void:
	if battle_over:
		return

	var damage: int = ENEMY_ATTACK_DAMAGE

	if player_guarding:
		damage -= player_data.stabilize_damage_reduction
		damage = max(damage, 0)
		player_guarding = false
		
		gain_energy(player_data.stabilize_energy_gain)

	player_hp -= damage
	player_hp = max(player_hp, 0)

	status_label.text = "Enemy attacked for " + str(damage) + " damage!"
	update_ui()

	if player_hp <= 0:
		
		set_player_dead()
		end_battle("Defeat!")
		return
		
	update_cooldowns()
	status_label.text = "Player Turn"

func end_battle(result_text: String) -> void:
	battle_over = true
	status_label.text = result_text
	pulse_button.disabled = true
	stabilize_button.disabled = true
	overload_button.disabled = true
	discharge_button.disabled = true


func reset_battle() -> void:
	player_hp = player_data.max_hp
	player_energy = 0
	enemy_hp = 10
	overload_cooldown_remaining = 0
	
	
	player_guarding = false
	battle_over = false
	
	set_player_alive()
	set_enemy_alive()

	status_label.text = "Player Turn"
	pulse_button.disabled = false
	stabilize_button.disabled = false
	overload_button.disabled = false
	discharge_button.disabled = false
	
	update_ui()


func _on_pulse_button_pressed() -> void:
	print("Pulse button pressed")
	use_pulse()

func _on_stabilize_button_pressed() -> void:
	print("Stabilize button pressed")
	use_stabilize()

func _on_overload_button_pressed() -> void:
	use_overload()

func _on_discharge_button_pressed() -> void:
	use_discharge()
	
func _on_reset_button_pressed() -> void:
	reset_battle()
	
