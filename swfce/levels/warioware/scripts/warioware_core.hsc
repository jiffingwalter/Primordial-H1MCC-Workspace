;;; SUPER WACKY FUNWARE SCRIPT ;;;
; version 0.0.1
; created with love and autism by primordial

;; ---- Variables ---- ;;
; Game options set by player on start 
(global short option_ai_infighting 1) ; Do different enemy factions: (0) work together, (1) attack each other, or (2) only focus on the player if they're there
(global short option_minigames 1) ; Minigame wave frequency: (0) none, (1) normal, (2) less, (3) many
(global short option_enemy_amount_scale 1) ; Multiplier for how fast enemy spawn scale increases: (0.5) less, (1) normal, (1.5) more, (2) insane
(global short option_enemy_difficulty_scale 1) ; Multiplier for how many harder enemies appear: (0.5) less, (1) normal, (1.5) more, (2) insane
(global boolean option_spawn_friends true) ; Spawn friendly AI on each set?
(global boolean option_spawn_blocks true) ; Spawn question blocks on each set?
(global short option_starting_lives 10) ; Sets how many lives player starts with. 1, 5, 10, 20, -1 (endless)
(global boolean option_use_checkpoints false) ; Use checkpoints instead of lives, auto-turns on endless mode

; Functional vars
(global short global_life_count 0) ; number of player lives (disrgarded if 'use checkpoints' or endless mode options are set)
(global short global_game_status 0) ; 0 - not started, 1 - selecting options, 2 - in progress, 3 - GAME LOST
(global short global_wave_num 0) ; current wave
(global short global_round_num 0) ; current round
(global short global_set_num 0) ; current set
(global short global_next_wave_delay 90 ) ; how long to wait until next wave
(global short global_total_difficulty_scale 0) ; all of the scales added into one number
(global short global_timer_elapsed 0) ; holds amount of seconds passed in the game
(global boolean global_timer_on false) ; if we're running the timer or not

; Wave management vars
(global boolean wave_spawner_on false) ; do we currently want to spawn bad guys?
(global boolean wave_is_minigame false) ; is the current wave a minigame wave?
(global boolean wave_is_boss false) ; is the current wave a boss wave?
(global boolean wave_in_progress true) ; is a wave currently in progress?
(global short wave_enemies_living_count 0) ; current amount of living enemies - get dynamically by adding up all encounter enemy counts
(global short wave_enemies_per_wave 0) ; number of enemies to spawn for this wave, dynamically increases
(global short wave_enemies_spawn_delay 15) ; how fast to try to spawn enemies
(global short wave_enemies_spawned 0) ; how many enemies placed for the wave so far (reset on wave ends)
(global short wave_enemies_active_max 1) ; the max amount of enemies allowed to be alive at one time
(global short wave_enemies_active_scale 1) ; effects amount of enemies allowed to be active at one time
(global short wave_enemies_danger_scale 0) ; effects chances of more dangerous enemies spawning
(global short wave_enemies_weirdness_scale 0) ; effects chances of different enemy faction squads spawning
(global string wave_spawn_override_encounter "") ; the name of an encounter we're forcing to spawn from (none means random)
(global string wave_spawn_override_squad "") ; the name of a squad we're forcing to spawn from (none means random)
(global ai wave_spawner_last_placed "enc_main") ; the last encounter and squad we placed an enemy from. (enc_main acts as null)

; Player management vars
(global boolean game_swapping_loadout false) ; override the player death listener to avoid accidential death detection when resetting starting profiles
(global boolean player0_respawning false) ; is player 0 dead?
(global boolean player1_respawning false) ; is player 1 dead?
(global boolean player2_respawning false) ; is player 2 dead?
(global boolean player3_respawning false) ; is player 3 dead?

;; ---- Game control scripts ---- ;;
; STARTUP SCRIPT - set up the game, start logic to collect options from the player, etc. once player confirms, make any changes needed for options and start the core game loop
(script startup game_setup
    (print "game setup script")
    (set global_game_status 1)

    ; setup...
    (set cheat_deathless_player 1) ; set player to invincible for respawn hack
    (game_set_loadout "preset_initial")

    ; get options...
    ;todo: various device control checks here for each option...

    ; wait for confirmation of options by player...
    (sleep_until (= 1 (device_get_position control_start_game)) 1)

    ; set default global variables and modify stuff based on final options...
    (set wave_enemies_active_max 5)
    (set wave_enemies_per_wave 10)
    (set global_life_count option_starting_lives)

    ; initialize players and start game...
    (set global_game_status 2)
    (fade_in 1 1 1 30)
    (object_teleport (player0) "player_respawn_point")
    (game_set_loadout "preset_default")
)

; core script - observe game state and take actions as necessary (wave start and stopping, game over)
(script continuous game_main
    (if (= global_game_status 2) ; is the game active?
        ; wait for conditions...
        (begin 
            ; are all enemies of the current wave dead? (max were spawned and none are alive) - turn off spawner and trigger next wave if so
            ; TODO: modifiy this logic so that when the enemy count of the current wave is < 5 and we're not entering a new set, start a timer to begin the next wave automatically
            (if (and 
                    (= wave_enemies_living_count 0) 
                    (= wave_enemies_spawned wave_enemies_per_wave)
                    (= wave_in_progress true)
                )
                (begin 
                    (print "ALL ENEMIES VANQUISHED, WAVE OVER")
                    (set wave_spawner_on false)
                    (set wave_in_progress false)
                )
            )
            ; is a minigame completed or failed?
        )
    )
    (if (= global_game_status 3) ; status was set to lost, run lose game logic
        (begin 
            (print "GAME OVER!")

            (sleep (* 8 30))

            (game_lost)

            (sleep -1)
        )
    )
)

; wave spawn loop - if the spawner is active, keep rolling for encounters and squads to spawn enemies as long as max allowed enemies aren't spawned or wave limit threshold is reached
(script continuous wave_spawner
    (if wave_spawner_on
        ; check for current actors alive and if we're below the current max allowed actors, then...
        (if (and 
                (< wave_enemies_living_count wave_enemies_active_max) 
                (not (= wave_enemies_spawned wave_enemies_per_wave))
            )
            (begin 
                ; temp for test
                (print "placed a bad guy!")
                (wave_spawn_enemy "enc_common/grunt_pp")
                ; TODO: implement the rolling and danger spawn logic
                ; 1. roll for an encounter (enemy faction) to spawn from, or choose an overrided encounter if set

                ; 2. roll for a squad inside that encounter to spawn an enemy, or choose an overrided squad if set

            )
            (print "tried to place a bad guy...")
        )
    )
    (sleep wave_enemies_spawn_delay)
)

; spawn a specified enemy and run shared logic
(script static void (wave_spawn_enemy (ai enc))
    (ai_place enc)
    (set wave_spawner_last_placed enc)
    (ai_migrate wave_spawner_last_placed enc)
    (set wave_enemies_spawned (+ wave_enemies_spawned 1))
)

(script static void wave_start_next
    (print "starting next wave")
    (set wave_in_progress true)
    ; update global state variables (incrementations and adjusting based on spawn scales)

    ; clear spawner variables
    (set wave_enemies_spawned 0)

    ; check if its the next round and/or set

    ; check if its time for minigame or boss wave

    ; set wave spawner global to true
    (set wave_spawner_on true)
)

; add every single encounter's current living actor count and return it
(global short _wavemonitorlivingenemies_value 0)
(script continuous wave_monitor_living_enemies
    (set _wavemonitorlivingenemies_value 0)
    (set _wavemonitorlivingenemies_value (+ _wavemonitorlivingenemies_value (ai_living_count "enc_common")))
    (set _wavemonitorlivingenemies_value (+ _wavemonitorlivingenemies_value (ai_living_count "enc_uncommon")))
    ;(set _wavemonitorlivingenemies_value (+ _wavemonitorlivingenemies_value (ai_living_count "enc_rare")))
    ;(set _wavemonitorlivingenemies_value (+ _wavemonitorlivingenemies_value (ai_living_count "enc_superrare")))
    
    (set wave_enemies_living_count _wavemonitorlivingenemies_value)
)

; check if any players are "dead" and run respawn logic for them if so
(script continuous monitor_player0
    (if (and 
        (= (unit_get_health (player0)) 0)
        (not (= game_swapping_loadout true))
    )
        (begin
            (print "PLAYER 0 DIED!")
            ; todo: spawn a body on the player's current position to fake a death
            (player_respawn_sequence (player0))
        )
    )
)
(script continuous monitor_player1
    (if (= (unit_get_health (player1)) 0)
        (begin
            (print "PLAYER 1 DIED!")
            (player_respawn_sequence (player1))
        )
    )
)
(script continuous monitor_player2
    (if (= (unit_get_health (player2)) 0)
        (begin
            (print "PLAYER 2 DIED!")
            (player_respawn_sequence (player2))
        )
    )
)
(script continuous monitor_player3
    (if (= (unit_get_health (player3)) 0)
        (begin
            (print "PLAYER 3 DIED!")
            (player_respawn_sequence (player3))
        )
    )
)
; manage respawning the player
(script static void (player_respawn_sequence (unit dead_player))
    (print "starting player respawn sequence")
    
    ; snag player away from the action
    (damage_object "swfce\effects\damage effects\screen white flash" dead_player)
    (object_teleport dead_player "player_timeout_point")
    (player_set_loadout dead_player "wep_none")
    (unit_set_current_vitality dead_player 80 80)
    (object_cannot_take_damage dead_player)
    (ai_disregard dead_player 1)
    (set global_life_count (- global_life_count 1))
    (sleep 1)
    (sound_impulse_start "swfce\sound\dialog\player\death" dead_player 1)

    ; if there's still lives left, run the respawn logic
    (if (not (<= global_life_count 0))
        (begin 
            ; waiting in timeout
            (sleep 120)
            (sound_impulse_start "sound\sfx\ui\countdown_for_respawn" dead_player 1)
            (sleep 30)
            (sound_impulse_start "sound\sfx\ui\countdown_for_respawn" dead_player 1)
            (sleep 30)
            (sound_impulse_start "sound\sfx\ui\countdown_for_respawn" dead_player 1)
            (sleep 30)
            (sound_impulse_start "sound\sfx\ui\player_respawn" dead_player 1)

            ; put player back into the game
            (damage_object "swfce\effects\damage effects\screen white flash" dead_player)
            (ai_disregard dead_player 0)
            (object_teleport dead_player "player_respawn_point")
            (effect_new_on_object_marker "swfce\effects\impulse\ww invuln" dead_player "body")
 
            (player_add_weapon dead_player "wep_assaultrifle")
            (player_add_weapon dead_player "gre_frag")

            ; let player have 3 seconds of invulurability after spawning before turning it back off
            (sleep 90)
            (object_can_take_damage dead_player)
        )
    )
)

; monitor current life count and trigger end game if = 0
(script continuous game_monitor_lives
    (if (and 
            (= global_game_status 2)
            (<= global_life_count 0)
        )
        (set global_game_status 3)
    )
)

; set/replace the loadout for all players
(script static void (game_set_loadout (starting_profile loadout_in))
    (set game_swapping_loadout true)
    (player_add_equipment (player0) loadout_in 1)
    (player_add_equipment (player1) loadout_in 1)
    (player_add_equipment (player2) loadout_in 1)
    (player_add_equipment (player3) loadout_in 1)
    (set game_swapping_loadout false)
)

; set/replace the loadout for a single player
(script static void (player_set_loadout (unit player_in) (starting_profile loadout_in))
    (set game_swapping_loadout true)
    (player_add_equipment player_in loadout_in 1)
    (set game_swapping_loadout false)
)

; add a weapon or equipment to a single player
(script static void (player_add_weapon (unit player_in) (starting_profile loadout_in))
    (player_add_equipment player_in loadout_in 0)
)

;; --- Debug/testing stuff --- ;;
(script static void test_game
    (set run_game_scripts true)
    (set wave_spawner_on true)
)

; put button here to make the holo panel start the next wave
(script continuous test_start_wave
	; panel turned ON
	(sleep_until (= 1 (device_get_position control_start_game)) 1)
    (device_set_power control_start_game 0)
	(wave_start_next)
	
	; panel turned OFF
	(sleep_until (= wave_in_progress false) 30)
    (device_set_position control_start_game 0)
    (device_set_power control_start_game 1)
)

;; --- GPS script lifted from c20.net by Conscars --- ;;
; temporary variables for the calculation
(global real gps_tmp1 0)
(global real gps_tmp2 0)
(global real gps_tmp3 0)
(global real gps_tmp4 0)
; holds the output coordinates
(global real gps_x 0)
(global real gps_y 0)
(global real gps_z 0)

(script static void (get_gps_for_object (object_list input))
    (set gps_tmp1 (objects_distance_to_flag input gps1))
    (set gps_tmp2 (objects_distance_to_flag input gps2))
    (set gps_tmp3 (objects_distance_to_flag input gps3))
    (set gps_tmp4 (objects_distance_to_flag input gps4))
    (set gps_tmp1 (* gps_tmp1 gps_tmp1))
    (set gps_tmp2 (* gps_tmp2 gps_tmp2))
    (set gps_tmp3 (* gps_tmp3 gps_tmp3))
    (set gps_tmp4 (* gps_tmp4 gps_tmp4))
    (set gps_tmp1 (+ gps_tmp1 (* gps_tmp2 -1) 1))
    (set gps_tmp2 (- gps_tmp2 gps_tmp3))
    (set gps_tmp3 (- gps_tmp3 gps_tmp4))
    (set gps_x (/ gps_tmp1 2))
    (set gps_y (/ (+ gps_tmp1 gps_tmp2) 2))
    (set gps_z (/ (+ gps_tmp1 gps_tmp2 gps_tmp3) 2))

    (print "requested x/y/z:")
    (inspect gps_x)
    (inspect gps_y)
    (inspect gps_z)
)

; test script for coords
;(script continuous gps
;    (gps_trilateration)
;    (print "x/y/z:")
;    (inspect gps_x)
;    (inspect gps_y)
;    (inspect gps_z)
;    (sleep 30)
;)