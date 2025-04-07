; mission quick starts
(script static void maplist
	(print "current level cheat sheet:")
	(print "a30 = Halo")
	(print "b30 = Silent Cartographer")
	(print "c10 = 343 Guilty Spark")
	(print "c20 = Library")
	(print "c40 = Two Betrayals")
	(print "ww = Warioware")
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
(script static void ww
	(print "starting swft ww...")
	(map_name swfce\levels\warioware\warioware_test)
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

;sandbox test script
(script static void test_effect
    (effect_new_on_object_marker  "swfce\effects\impulse\ww invuln" (player0) "body")
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

(script static void test_blocks
	(object_create_anew_containing "qblock")
)

;music testing
(global looping_sound test_music_ref "swfce\levels\a30\music\a30_06")
(global boolean play_test_music false)
(global boolean play_test_music_alt false)
(script dormant test_music_func
	(sleep_until play_test_music)
	(print "test music in...")
	(sound_looping_start test_music_ref none 1)

	(sleep_until 
		(or 
			play_test_music_alt 
			(not play_test_music)
		)
	1)
	(if play_test_music_alt
		(begin
			(sound_looping_set_alternate test_music_ref 1)
			(print "test music alt...")
			(sleep_until (not play_test_music) 1)
			(set play_test_music_alt false)
		)
	)
	(set play_test_music false)
	(print "test music out...")
	(sound_looping_stop test_music_ref)
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