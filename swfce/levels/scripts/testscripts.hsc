; mission quick starts
(script static void list
	(print "current level cheat sheet:")
	(print "a30 = Halo")
	(print "b30 = Silent Cartographer")
	(print "c20 = Library")
)
(script static void a30
	(print "starting swft a30...")
	(map_name swfce\levels\a30\swfta30)
)
(script static void b30
	(print "starting swft b30...")
	(map_name swfce\levels\b30\swftb30)
)
(script static void c20
	(print "starting swft c20...")
	(map_name swfce\levels\c20\swftc20)
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
	(map_name swfce\levels\mp\swft_deathisland)
)

; test stuff
(script static void indextest
	(scenery_animation_start index swfce\scenery\index_holder\index_holder C20GrabIndex)
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