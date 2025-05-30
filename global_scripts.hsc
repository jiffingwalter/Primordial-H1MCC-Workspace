;matt's global scripts

(script static unit player0
  (unit (list_get (players) 0)))

(script static unit player1
  (unit (list_get (players) 1)))

(script static short player_count
  (list_count (players)))

(script static boolean cinematic_skip_start
	(cinematic_skip_start_internal)
	(game_save_totally_unsafe)
	(sleep_until (not (game_saving)) 1)
	(not (game_reverted)))

(script static void cinematic_skip_stop
	(cinematic_skip_stop_internal))

;USAGE:
;(if (cinematic_skip_start) (cinematic))
;(cinematic_skip_stop)

;jaime's global scripts
;========== Global Variables ==========
(global boolean global_dialog_on false)
(global boolean global_music_on false)
(global long global_delay_music (* 30 300))
(global long global_delay_music_alt (* 30 300))

;========== Misc Scripts ==========
(script static void script_dialog_start
	(sleep_until (not global_dialog_on))
	(set global_dialog_on true)
	(ai_dialogue_triggers off)
	)

(script static void script_dialog_stop
	(ai_dialogue_triggers on)
	(sleep 30)
	(set global_dialog_on false)
	)

;========== Damage Effect Scripts ==========

(script static void player_effect_impact
	(player_effect_set_max_translation .05 .05 .075)
	(player_effect_set_max_rotation 0 0 0)
	(player_effect_set_max_vibrate .4 1)
	(player_effect_start (real_random_range .7 .9) .1)
	)

(script static void player_effect_explosion
	(player_effect_set_max_translation .01 .01 .025)
	(player_effect_set_max_rotation .5 .5 1)
	(player_effect_set_max_vibrate .5 .4)
	(player_effect_start (real_random_range .7 .9) .1)
	)

(script static void player_effect_rumble
	(player_effect_set_max_translation .01 0 .02)
	(player_effect_set_max_rotation .1 .1 .2)
	(player_effect_set_max_vibrate .5 .3)
	(player_effect_start (real_random_range .7 .9) .5)
	)

(script static void player_effect_vibration
	(player_effect_set_max_translation .0075 .0075 .0125)
	(player_effect_set_max_rotation .01 .01 .05)
	(player_effect_set_max_vibrate .2 .5)
	(player_effect_start (real_random_range .7 .9) 1)
	)

; PRIMORDIALS GLOBAL SCRIPTS ----------
; support for extra players with alpha ring
(script static unit player2
    (unit (list_get (players) 2)))

(script static unit player3
    (unit (list_get (players) 3)))

; set passive ai alligences (animals n such)
(script static void prim_set_passive_alligence
	(ai_allegiance player unused6)
	(ai_allegiance human unused6)
	(ai_allegiance covenant unused6)
)

; debug shortcuts
(script static boolean pri_bump
	(print "toggling bump possession")
	(set cheat_bump_possession (not cheat_bump_possession))
)

(script static boolean pri_cheats
	(print "toggling cheats")
	(set cheat_deathless_player (not cheat_deathless_player))
	(set cheat_infinite_ammo (not cheat_infinite_ammo))
)

(script static void pri_vehs
	(print "spawning all vehicles")
	(set cheat_deathless_player (not cheat_deathless_player))
	(cheat_all_vehicles)
	(sleep 200)
	(set cheat_deathless_player (not cheat_deathless_player))
)

(script static void pri_weps
	(print "spawning all weapons")
	(cheat_all_weapons)
)

(script static void pri_equip
	(print "spawning all equipment")
	(cheat_all_powerups)
)

(script static boolean pri_debug_collision
	(print "toggling collison debug")
	(set debug_objects (not debug_objects))
	(set debug_objects_collision_models (not debug_objects_collision_models))
	(set collision_debug (not collision_debug))
)

(global boolean debugsafetosave_bool false)
(script static boolean pri_debug_safetosave
	(set debugsafetosave_bool (not debugsafetosave_bool))
)
(script continuous debugsafetosave_func
	(if debugsafetosave_bool (if (game_safe_to_save) (print "safe to save... true") (print "safe to save... false")))
	(sleep 10)
)

; **** misc scripts ****
; get a modulo value from two numbers
(global short modulo_value 0)
(script static short (modulo (short x) (short y))
  (set modulo_value (/ x y))
  (- x (* modulo_value y))
)

; check if an object currently exists in the game world
(script static boolean (object_exists (object obj))
	(!= (objects_distance_to_position obj 0 0 0) -1)
)