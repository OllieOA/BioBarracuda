extends Node

signal barracuda_head_left
signal barracuda_head_right
signal barracuda_bite
signal segment_killed

signal player_projectile_fired
signal enemy_projectile_fired

signal enemy_killed
signal barracuda_dead

signal biomass_consumed(amount)


# UI Signals
signal properties_updated
signal max_segment_increase

signal segment_cost_increase
signal upgrade_button_selected
signal upgrade_purchased(upgrade_selection)
signal biomass_threshold_met
signal biomass_spent

signal max_segments_updated
signal level_unlocked
