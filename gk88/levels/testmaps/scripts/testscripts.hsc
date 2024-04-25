; mission quick starts
(script static void list
	(print "current level cheat sheet:")
	(print "c10 = Guilty Spark")
	(print "c20 = Library")
	(print "c40 = Two Betrayals")
	(print "d20 = Keyes")
	(print "d40 = Maw")
)
(script static void swfce
	(print "starting swfce test map...")
	(map_name swfce\levels\test)
)
(script static void c10
	(print "starting gk88 c10...")
	(map_name gk88\levels\singleplayer\c10\gkc10)
)
(script static void c20
	(print "starting gk88 c20...")
	(map_name gk88\levels\singleplayer\c20\gkc20)
)
(script static void c40
	(print "starting gk88 c40...")
	(map_name gk88\levels\singleplayer\c40\gkc40)
)
(script static void d20
	(print "starting gk88 d20...")
	(map_name gk88\levels\singleplayer\d20\gkd20)
)
(script static void d40
	(print "starting gk88 d40...")
	(map_name gk88\levels\singleplayer\d40\gkd40)
)

; debug shortcuts
(script static void bump
	(print "toggling bump possession")
	(if cheat_bump_possession (set cheat_bump_possession 0) (set cheat_bump_possession 1))
)
(script static void cheats
	(print "toggling cheats")
	(if cheat_deathless_player (set cheat_deathless_player 0) (set cheat_deathless_player 1))
	(if cheat_infinite_ammo (set cheat_infinite_ammo 0) (set cheat_infinite_ammo 1))
)
(script static void vehicles
	(print "spawning all vehicles")
	(if cheat_deathless_player (set cheat_deathless_player 0) (set cheat_deathless_player 1))
	(cheat_all_vehicles)
	(sleep 200)
	(if cheat_deathless_player (set cheat_deathless_player 0) (set cheat_deathless_player 1))
)
(script static void db_collision
	(print "toggling collison testing")
	(if debug_objects (set debug_objects 0) (set debug_objects 1))
	(if debug_objects_collision_models (set debug_objects_collision_models 0) (set debug_objects_collision_models 1))
	(if collision_debug (set collision_debug 0) (set collision_debug 1))
)

; test stuff
