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

;skull list
(script static void skulls
	(inspect debug_ice_cream_flavor_force_coop)
	(inspect debug_ice_cream_flavor_status_anger)
	(inspect debug_ice_cream_flavor_status_assassins)
	(inspect debug_ice_cream_flavor_status_bandanna)
	(inspect debug_ice_cream_flavor_status_black_eye)
	(inspect debug_ice_cream_flavor_status_bonded_pair)
	(inspect debug_ice_cream_flavor_status_boom)
	(inspect debug_ice_cream_flavor_status_catch)
	(inspect debug_ice_cream_flavor_status_eye_patch)
	(inspect debug_ice_cream_flavor_status_famine)
	(inspect debug_ice_cream_flavor_status_feather)
	(inspect debug_ice_cream_flavor_status_fog)
	(inspect debug_ice_cream_flavor_status_foreign)
	(inspect debug_ice_cream_flavor_status_ghost)
	(inspect debug_ice_cream_flavor_status_grunt_birthday_party)
	(inspect debug_ice_cream_flavor_status_grunt_funeral)
	(inspect debug_ice_cream_flavor_status_i_would_have_been_your_daddy)
	(inspect debug_ice_cream_flavor_status_iron)
	(inspect debug_ice_cream_flavor_status_malfunction)
	(inspect debug_ice_cream_flavor_status_masterblaster)
	(inspect debug_ice_cream_flavor_status_mythic)
	(inspect debug_ice_cream_flavor_status_pinata)
	(inspect debug_ice_cream_flavor_status_recession)
	(inspect debug_ice_cream_flavor_status_sputnik)
	(inspect debug_ice_cream_flavor_status_streaking)
	(inspect debug_ice_cream_flavor_status_thats_just_wrong)
	(inspect debug_ice_cream_flavor_status_thunderstorm)
)
