; mission quick starts
(script static void maplist
	(print "current level cheat sheet:")
	(print "a30 = Halo")
	(print "b30 = Silent Cartographer")
	(print "c10 = 343 Guilty Spark")
	(print "c20 = Library")
	(print "c40 = Two Betrayals")
)
(script static void a30
	(print "starting swft a30...")
	(map_name swfce\levels\a30\swfta30)
)
(script static void b30
	(print "starting swft b30...")
	(map_name swfce\levels\b30\swftb30)
)
(script static void c10
	(print "starting swft c10...")
	(map_name swfce\levels\c10\swftc10)
)
(script static void c20
	(print "starting swft c20...")
	(map_name swfce\levels\c20\swftc20)
)
(script static void c40
	(print "starting swft c40...")
	(map_name swfce\levels\c40\swftc40)
)
;mp
(script static void bloodgulch
	(print "starting swft bloodgulch in multiplayer...")
	(multiplayer_map_name swfce\levels\mp\swft_bloodgulch)
)
(script static void beavercreek
	(print "starting swft beavercreek in multiplayer...")
	(multiplayer_map_name swfce\levels\mp\swft_beavercreek)
)
(script static void putput
	(print "starting swft putput in multiplayer...")
	(multiplayer_map_name swfce\levels\mp\swft_putput)
)
(script static void boardingaction
	(print "starting swft boarding action in multiplayer...")
	(multiplayer_map_name swfce\levels\mp\swft_boardingaction)
)
(script static void hangemhigh
	(print "starting swft hangemhigh in multiplayer...")
	(multiplayer_map_name swfce\levels\mp\swft_hangemhigh)
)
(script static void deathisland
	(print "starting swft death island in multiplayer...")
	(multiplayer_map_name swfce\levels\mp\swft_deathisland)
)

; debug shortcuts
; (script static void bump
; 	(print "toggling bump possession")
; 	(if cheat_bump_possession (set cheat_bump_possession 0) (set cheat_bump_possession 1))
; )
; (script static void cheats
; 	(print "toggling cheats")
; 	(if cheat_deathless_player (set cheat_deathless_player 0) (set cheat_deathless_player 1))
; 	(if cheat_infinite_ammo (set cheat_infinite_ammo 0) (set cheat_infinite_ammo 1))
; )
; (script static void vehicles
; 	(print "spawning all vehicles")
; 	(if cheat_deathless_player (set cheat_deathless_player 0) (set cheat_deathless_player 1))
; 	(cheat_all_vehicles)
; 	(sleep 200)
; 	(if cheat_deathless_player (set cheat_deathless_player 0) (set cheat_deathless_player 1))
; )
; (script static void db_collision
; 	(print "toggling collison debug")
; 	(if debug_objects (set debug_objects 0) (set debug_objects 1))
; 	(if debug_objects_collision_models (set debug_objects_collision_models 0) (set debug_objects_collision_models 1))
; 	(if collision_debug (set collision_debug 0) (set collision_debug 1))
; )

(script static void test_dropship
	(print "spawning test dropship")
	(object_destroy osprey)
	(object_create osprey)
	(vehicle_hover osprey 1)
	(ai_place test_dropship/passengers)
	(vehicle_load_magic osprey "passenger" (ai_actors test_dropship/passengers))
)

(script continuous cheat_allweapons_control
	; panel turned ON
	(sleep_until (= 1 (device_get_position control_allweapons)) 1)
	(cheat_all_weapons)
	
	; panel turned OFF
	(sleep_until (= 0 (device_get_position control_allweapons)) 1)
	(cheat_all_weapons)
	; REPEAT
)

(script static void respawnblocks
	(object_create_anew_containing "qblock")
)

;music testing
(global string test_music_ref "swfce\levels\a30\music\a30_01")
(global boolean play_test_music false)
(global boolean play_test_music_alt false)
(script dormant test_music_func
	(sleep_until play_test_music)
	(print "test music in...")
	(sound_looping_start "swfce\levels\a30\music\a30_01" none 1)

	(sleep_until 
		(or 
			play_test_music_alt 
			(not play_test_music)
		)
	1 global_delay_music)
	(if play_test_music_alt
		(begin
			(sound_looping_set_alternate "swfce\levels\a30\music\a30_01" 1)
			(print "test music alt...")
			(sleep_until (not play_test_music) 1 global_delay_music)
			(set play_test_music_alt false)
		)
	)
	(set play_test_music false)
	(print "test music out...")
	(sound_looping_stop "swfce\levels\a30\music\a30_01")
	(sleep -1)
)
(script static void test_music
	(wake test_music_func)
	(set play_test_music true)
)
(script static void test_music_alt
	(set play_test_music_alt true)
)
(script static void test_music_out
	(set play_test_music false)
)