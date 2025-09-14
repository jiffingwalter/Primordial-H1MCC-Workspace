;;; SUPER WACKY FUNWARE SCRIPT ;;;
; version 0.0.1
; created with love and autism by primordial <3

;;; ------------------------------------ GLOBALS ------------------------------------ ;;;
; Game options set by player on start 
(global short option_ai_infighting 1) ; Do different enemy factions fight each other? 0: disabled, 1: enabled, 2: conditional (enemies will fight but focus on the player)
(global short option_minigames_frequency 1) ; Minigame wave frequency: 0: none, 1: normal (every round), 2: less (every set), 3: many (every single wave)
(global short option_difficulty 1) ; Multiplier for how many harder enemies appear: 0: less (1.05), 1: normal (1.1), 2: more (1.2), 3: insane (1.3)
(global short option_weirdness 1) ; Multiplier for how fast the game gets weirder: 0: less (1.05), 1: normal (1.1), 2: more (1.2), 3: insane (1.3)
(global boolean option_spawn_friends true) ; Spawn friendly AI on each set?
(global boolean option_spawn_blocks true) ; Spawn question blocks on each set?
(global short option_starting_lives 10) ; Sets how many lives player starts with. 1, 5, 10, 15, 20, -1 (endless)
(global boolean option_use_checkpoints false) ; Use checkpoints instead of lives, auto-turns on endless mode
(global boolean option_disable_death false) ; Override for cheat_deathless_player life hack

; Functional vars
(global short global_life_count 0) ; number of player lives (disrgarded if 'use checkpoints' or endless mode options are set)
(global short global_game_status 0) ; 0: not started, 1: in progress, 2: lost
(global short global_wave_num 0) ; current wave
(global short global_round_num 0) ; current round
(global short global_set_num 0) ; current set
(global short global_total_difficulty_scale 0) ; all of the scales added into one number
(global short global_timer_elapsed 0) ; holds amount of seconds passed in the game
(global short timer_hud 150) ; default hud message timer (5 seconds)
(global boolean global_timer_on false) ; if we're running the timer or not
(global real game_difficulty_scale 1.0) ; how fast more dangerous enemies and vehicles appear, set based on option_difficulty_scale
(global real game_difficulty_level 0) ; current difficulty level, scales based on game_difficulty_scale
(global real game_weirdness_scale 1.0) ; how fast weirder stuff starts happening in the game, scales based on option_weirdness_scale
(global real game_weirdness_level 0) ; current weirdness level, scales based on game_weirdness_scale
(global starting_profile game_current_loadout "preset_default") ; the current loadout players should spawn into the game with
(global short game_hud_message_timer 0) ; dynamic timer for hud messages on the screen

; Debug vars
(global boolean ww_debug_all true)
(global boolean ww_debug_startup false)
(global boolean ww_debug_waves false)
(global boolean ww_debug_spawning false)
(global boolean ww_debug_powerups false)

; Wave management vars
(global boolean wave_spawner_on false) ; do we currently want to spawn bad guys?
(global boolean wave_is_minigame false) ; is the current wave a minigame wave?
(global boolean wave_is_boss false) ; is the current wave a boss wave?
(global boolean wave_in_progress false) ; is a wave currently in progress?
(global boolean wave_is_last_of_set false) ; is this wave the last of the current set?
(global short wave_enemies_spawn_delay 30) ; how fast to try to spawn enemies
(global short wave_next_delay (* 30 8)) ; how long to wait until spawning next wave
(global short wave_enemies_living_count 0) ; the last amount of living enemies we checked for
(global short wave_enemies_spawned 0) ; how many enemies placed for the wave so far (reset on wave ends) - TODO: change this to 'power' and relevant usages
(global short wave_enemies_per_wave 0) ; number of enemies to spawn for this wave, scales based on option_enemy_active_scale
(global short wave_enemies_active_max 0) ; the max amount of enemies allowed to be alive at one time, scales based on option_difficulty_scale

; AI lists
; functional encounters (contain actual firing positions, squads, logic, etc)
(global object_list ai_list_main (ai_actors "enc_main"))
; technical encounters (just buckets for squads to choose from for separation)
(global object_list ai_list_common (ai_actors "enc_common"))
(global object_list ai_list_uncommon (ai_actors "enc_uncommon"))
(global object_list ai_list_rare (ai_actors "enc_rare"))

; Spawner function vars
(global ai spawner_next_enc "null") ; ai reference of the next encounter we're going to spawn from
(global ai spawner_picker_override_enc "null") ; ai reference to override the spawner to pick from
(global ai spawner_picker_override_enc_to "null") ; ai reference the overrided encounter should be sent to
(global object_list spawner_last_placed (ai_actors "null")) ; object list for last ai placed
(global real spawner_dice_roll 0) ; stored spawner dice roll result used for choosing spawns
(global real spawner_dice_scale 0) ; scale that dice roll clamps should be increased by every round, scales based on option_difficulty_level
(global real spawner_dice_lower 0.01) ; lower limit for dice rolls, scales based on spawner_dice_scale
(global real spawner_dice_upper 0.65) ; upper limit for dice rolls, scales based on spawner_dice_scale
(global boolean spawner_condition_matched false) ; did the spawner match a condition when choosing a squad? (triggers skipping the rest of the if statements)
(global real spawner_enc_common_weight_min 0.3) ; least amount of weight the common encounter can have on the spawner
(global real spawner_enc_uncommon_weird_min 0.2) ; minimum weirdness level allows uncommon encounter to have weight in the spawner
(global real spawner_enc_rare_weird_min 0.4) ; minimum weirdness level that allows rare encounter to have weight in the spawner
(global real spawner_total_chance 0) ; all spawn encounter chances added up
(global real spawner_enc_common_weight 0) ; normalized chance of common encounter spawn
(global real spawner_enc_uncommon_weight 0) ; normalized chance of uncommon encounter spawn
(global real spawner_enc_rare_weight 0) ; normalized chance of rare encounter spawn

; Player management vars
(global boolean game_swapping_loadout false) ; override the player death listener to avoid accidential death detection when resetting starting profiles
(global boolean player0_respawning false)
(global boolean player1_respawning false)
(global boolean player2_respawning false)
(global boolean player3_respawning false)
(global short players_dead 0)
(global boolean players_all_dead false)
(global boolean player0_invincible false)
(global boolean player1_invincible false)
(global boolean player2_invincible false)
(global boolean player3_invincible false)

; Powerup management vars
(global real powerup_spawn_chance 0.03) ; initial chance of a powerup spawning on enemy death, SLIGHTLY scaled by game_weirdness_level
(global real powerup_reset_time (* 30 30)) ; the time it takes for a powerup to reset
(global real powerup_dice_roll 0) ; dice roll for testing to spawn powerups
(global real powerup_pickup_distance 0.5) ; how many world units players have to be to powerup items for powerups to register as picked up
(global boolean powerup_currently_active false) ; are any continuous powerups active?
; Individual powerup statuses in the game - 0 is standby, 1 is spawned and waiting, 2 is active
(global short powerup_status_invincibility 0)
(global short powerup_status_strength 0)
(global short powerup_status_bottomless 0)
(global short powerup_status_extralife 0)
(global short powerup_status_pow 0)
(global short powerup_status_refill 0)

; Scenery - question block spawns
(global short ww_qblocks_to_spawn 0) ; how many qblocks to try to spawn at the start of a new set, set from ww_qblocks_initial + current set count
(global short ww_qblocks_max 7) ; max amount of question blocks that can spawn on the map, level specific
(global short ww_qblocks_initial 3) ; initial amount of question blocks to spawn

;;; ------------------------------------ CORE GAME ------------------------------------ ;;;
; STARTUP SCRIPT - set up the game, start logic to collect options from the player, etc. once player confirms, make any changes needed for options and start the core game loop
(script startup game_setup
    (if (or ww_debug_all ww_debug_startup) (print "startup"))
    (set cheat_deathless_player 1) ; set players to invincible for respawn hack
    (game_set_loadout "preset_initial")

    ; handle options setting...
    ;todo: spawn and manage various device control checks here for each option...

    ;  *** wait for confirmation of options by player... ***
    (sleep_until (= 1 (device_get_position control_start_game)) 1)



    ; *** set final variables based on options ***

    ; ai alligences...
    (prim_set_passive_alligence)
    (ai_allegiance player human)
    (cond 
        ;none
        ((= option_ai_infighting 0)
        (begin 
            (ai_allegiance covenant flood)
            (ai_allegiance covenant sentinel)
            (ai_allegiance sentinel flood)
        ))
        ;conditional
        ((= option_ai_infighting 2)
        (ai_try_to_fight_player "enc_main"))
    )

    ; initial difficulty scale...
    (cond 
        ;less
        ((= option_difficulty 0)
        (set game_difficulty_scale 1.01))
        ;normal
        ((= option_difficulty 1)
        (set game_difficulty_scale 1.05))
        ;more
        ((= option_difficulty 2)
        (set game_difficulty_scale 1.1))
        ;insane
        ((= option_difficulty 3)
        (set game_difficulty_scale 1.2))
    )
    (set game_difficulty_level (- game_difficulty_scale 1))

    ; initial weirdness scale...
    (cond 
        ;less
        ((= option_weirdness 0)
        (set game_weirdness_scale 1.01))
        ;normal
        ((= option_weirdness 1)
        (set game_weirdness_scale 1.05))
        ;more
        ((= option_weirdness 2)
        (set game_weirdness_scale 1.1))
        ;insane
        ((= option_weirdness 3)
        (set game_weirdness_scale 1.2))
    )
    (set game_weirdness_level (- game_weirdness_scale 1))
    
    ; misc...
    (if (= option_use_checkpoints true)
        (begin 
            (set cheat_deathless_player 0)
            (set global_life_count -1)
        )
        (set global_life_count option_starting_lives)
    )

    ; wave vars...
    (set wave_enemies_per_wave (* 4 (* game_difficulty_scale 2)))
    (set wave_enemies_active_max (* wave_enemies_per_wave 0.25))
    
    ; spawn scales...
    ;todo: make these smarter based on initial difficulty/weirdness set
    (set spawner_enc_common_weight 1)
    (set spawner_enc_uncommon_weight 0)
    (set spawner_enc_rare_weight 0)

    ; debug...
    (if (or ww_debug_all ww_debug_startup) (dump 4))

    ; teleport players and start game...
    (set global_game_status 1)
    (fade_in 1 1 1 30)
    (object_teleport (player0) "player0_respawn_point")
    (object_teleport (player1) "player1_respawn_point")
    (object_teleport (player2) "player2_respawn_point")
    (object_teleport (player3) "player3_respawn_point")
    (game_set_loadout "preset_default")
    
    (ww_set_objective obj_welcome timer_hud)
    (ww_set_start_next)
)

; core script - observe game state and take actions as necessary (wave start and stopping, game over)
(script continuous game_main
    (if (= global_game_status 1);ACTIVE...
        ; IF current wave meets finish requirements, start the timer for the next one
        (if (and 
                (= wave_in_progress true)
                (< (wave_get_enemies_living_count) 5)
                (>= wave_enemies_spawned wave_enemies_per_wave)
                (= wave_is_last_of_set false)
            )
            (begin 
                (if (or ww_debug_all ww_debug_waves) (print "*** current wave ended ***"))
                (set wave_spawner_on false)
                (set wave_in_progress false)

                (sleep wave_next_delay)
                (wave_start_next)
            )
            ; ELSE... perform set completion logic and wait for extended delay to start next
            (if (and
                    (= wave_in_progress true)
                    (= (wave_get_enemies_living_count) 0)
                    (>= wave_enemies_spawned wave_enemies_per_wave)
                    (= wave_is_last_of_set true)
                )
                (begin 
                    (if (or ww_debug_all ww_debug_waves) (print "****** set completed! ******"))
                    (ww_set_objective set_completed timer_hud)
                    (set global_set_num (+ global_set_num 1))
                    (set wave_spawner_on false)
                    (set wave_in_progress false)
                    (set global_life_count (+ global_life_count 1))
                    (effect_new "swfce\scenery\fireworks\effects\presets\firework_preset_3shot_multicolor" fx_fireworks)

                    ;todo: set up logic to force player respawn here

                    (sleep wave_next_delay)
                    (ww_set_start_next)
                )
            )
        )
    )
    (if (= global_game_status 2) ;LOST...
        (begin 
            (print "***** GAME OVER! *****")
            ; TODO: put players back in the action unarmed, disable weapon drops, and let them get fukt
            (ww_set_objective game_over 1000)
            (sleep (* 10 30))
            (game_lost)
            (sleep -1)
        )
    )
)

; objective and hud message handlers
(script static void (ww_set_objective (hud_message hud_text) (short hide_after))
    (hud_set_objective_text hud_text)
    (enable_hud_help_flash true)
    (ww_print_hud_message hud_text hide_after)
)
(script static void (ww_print_hud_message (hud_message hud_text) (short hide_after))
	(hud_set_help_text hud_text)
    (show_hud_help_text true)
	(if (> hide_after 0)
        (begin 
            (set game_hud_message_timer hide_after)
            (wake ww_hide_hud_monitor)
        )
    )
)
(script continuous ww_hide_hud_monitor
    (if (= game_hud_message_timer 0)
        (begin 
            (show_hud_help_text false)
            (enable_hud_help_flash false)
            (sleep -1)
        )
        (set game_hud_message_timer (- game_hud_message_timer 1))
    )
)

; all set preparation logic, wipes game world clean for next set
(script static void ww_set_start_next
    (print "preparing for next set...")
    (ww_map_deep_clean)

    ; set qblock count to spawn based on current set number
    (if (<= (+ ww_qblocks_initial global_set_num) ww_qblocks_max)
        (set ww_qblocks_to_spawn (+ ww_qblocks_initial global_set_num))
        (set ww_qblocks_to_spawn ww_qblocks_max)
    )
    (ww_replace_qblocks)
    (if (> global_set_num 0) (ww_set_objective next_set timer_hud))

    (sleep wave_next_delay)
    (wave_start_next)
)

; deep clean the game world of all non player bullshit - gets rid of random stuff produced by qblocks, straggler vehicles and player buffoonary
(script static void ww_map_deep_clean
    (garbage_collect_now)
    (object_destroy_all)
)

(script static void wave_start_next
    (if (or ww_debug_all ww_debug_waves) (print "***** starting next wave *****"))
    (set wave_in_progress true)
    (garbage_collect_now)

    ; --- update global and wave state variables --- (incrementations and adjusting based on spawn scales)
    (if (= global_wave_num 0)
        ; IF its the first wave, only set the initial wave/round/set
        (begin
            (set global_wave_num 1)
            (set global_round_num 1)
            (set global_set_num 1)
        )
        ; ELSE, its any wave after, run incrementations
        (begin 
            ; update wave/round/set
            (set global_wave_num (+ global_wave_num 1))

            (if (= (modulo global_wave_num 3) 0)
                (begin 
                    (set global_round_num (+ global_round_num 1))
                    (if (or ww_debug_all ww_debug_waves) (print "** next round, incrementing stats... **"))
                    (if (or ww_debug_all ww_debug_waves) (print "round number:"))
                    (if (or ww_debug_all ww_debug_waves) (inspect global_round_num))
                    (ww_set_objective next_round timer_hud)

                    ; game values
                    (set game_difficulty_level (* game_difficulty_level game_difficulty_scale))
                    (set game_weirdness_level (* game_weirdness_level game_weirdness_scale))

                    ; wave values -- scale based on current difficulty level
                    (set wave_enemies_per_wave (* wave_enemies_per_wave (+ game_difficulty_level 1)))
                    (if (< wave_enemies_active_max 36)
                        (set wave_enemies_active_max (* wave_enemies_per_wave 0.4))
                        (set wave_enemies_active_max 36)
                    )
                    (if (not (< wave_next_delay (* 30 3)))
                        (set wave_next_delay (* wave_next_delay 0.99))
                    )
                    (if (not (< wave_enemies_spawn_delay 5))
                        (set wave_enemies_spawn_delay (* wave_enemies_spawn_delay 0.99))
                    )
                    
                    ; --- spawn chance vars ---
                    ; get spawn weights
                    (set spawner_enc_common_weight (max (- 1 game_weirdness_level) (- 1 spawner_enc_common_weight_min)))
                    (set spawner_enc_uncommon_weight (max (- game_weirdness_level (- 1 spawner_enc_uncommon_weird_min)) 0))
                    (set spawner_enc_rare_weight (max (- game_weirdness_level (- 1 spawner_enc_rare_weird_min)) 0))
                    ; add total chances for normalization
                    (set spawner_total_chance 0)
                    (set spawner_total_chance (+ spawner_total_chance spawner_enc_common_weight))
                    (set spawner_total_chance (+ spawner_total_chance spawner_enc_uncommon_weight))
                    (set spawner_total_chance (+ spawner_total_chance spawner_enc_rare_weight))
                    ; get normalized spawn weights
                    (set spawner_enc_common_weight (/ spawner_enc_common_weight spawner_total_chance))
                    (set spawner_enc_uncommon_weight (/ spawner_enc_uncommon_weight spawner_total_chance))
                    (set spawner_enc_rare_weight (/ spawner_enc_rare_weight spawner_total_chance))
                    
                    ; set spawner dice roll clamps
                    (set spawner_dice_scale (+ (* game_difficulty_level .25) 1))
                    (set spawner_dice_lower (* spawner_dice_lower spawner_dice_scale))
                    (if (> spawner_dice_lower .3) 
                        (set spawner_dice_lower .3)
                    )
                    (set spawner_dice_upper (* spawner_dice_upper spawner_dice_scale))
                    (if (> spawner_dice_upper 1)
                        (set spawner_dice_upper 1)
                    )
                )
            )
            (if (= (modulo global_wave_num 15) 0)
                (begin 
                    (if (or ww_debug_all ww_debug_waves) (print "***** LAST WAVE OF SET!! *****"))
                    (set wave_is_last_of_set true)
                    
                )
                (set wave_is_last_of_set false)
            )
        )
    )

    ; --- reset functional vars ---
    (set wave_enemies_spawned 0)

    ; check if its time for minigame or boss wave

    ; turn the wave spawner on
    (set wave_spawner_on true)
    (if (or ww_debug_all ww_debug_waves) (dump 0))
)

; wave spawn loop - if the spawner is active, keep rolling for encounters and squads to spawn enemies as long as max allowed enemies aren't spawned or wave limit threshold is reached
(script continuous wave_spawner
    (if wave_spawner_on
        ; check for current actors alive and if we're below the current max allowed actors, then...
        (if (and 
                (< (wave_get_enemies_living_count) wave_enemies_active_max) 
                (!= wave_enemies_spawned wave_enemies_per_wave)
            )
            (begin 
                ;(print "placing a bad guy!")

                ; roll for an encounter (enemy faction) to spawn from based on if the dice roll lands inside the encounter's current spawn interval
                (set spawner_dice_roll (real_random_range 0 1))

                (if (<= spawner_dice_roll spawner_enc_common_weight)
                    (set spawner_next_enc "enc_common")
                )
                (if (and 
                        (!= spawner_enc_uncommon_weight 0)
                        (> spawner_dice_roll spawner_enc_common_weight)
                        (<= spawner_dice_roll (+ spawner_enc_common_weight spawner_enc_uncommon_weight))
                    )
                    (set spawner_next_enc "enc_uncommon")
                )
                (if (and 
                        (!= spawner_enc_rare_weight 0)
                        (> spawner_dice_roll (+ spawner_enc_common_weight spawner_enc_uncommon_weight))
                        ;(< spawner_dice_roll 1)
                    )
                    (set spawner_next_enc "enc_rare")
                )
                ;(inspect spawner_next_enc)

                ; for the chosen encounter, roll again for a squad to spawn an enemy, or choose the overrided squad if set...
                ; actor spawn chances will all be hardcoded and normalized (use generate chance weights.py)
                ; actor spawn is decided on 3 conditions:
                    ; 1. did we roll high enough to spawn this enemy?
                    ; 2. is the current difficulty value high enough to spawn this enemy?
                    ; 3. did we already spawn an enemy?
                ; if first 2 aren't met, test the next one below. if 3rd is met, we skip the rest since that means we already placed one

                (set spawner_condition_matched false)
                (set spawner_dice_roll (real_random_range spawner_dice_lower spawner_dice_upper))

                ; COMMON - 9 squads
                (if (and 
                        (= spawner_next_enc "enc_common")
                        (= spawner_picker_override_enc "null")
                    )
                    (begin 
                        ; hunter - 1
                        (if (and 
                            (<= 1 spawner_dice_roll)
                            (>= game_difficulty_level .6)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/hunter" "enc_main/hunter" 3)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; elite hammer - .98
                        (if (and 
                            (<= .98 spawner_dice_roll)
                            (>= game_difficulty_level .5)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/elite_ham" "enc_main/elite_melee" 2)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; elite stealth - .96
                        (if (and 
                            (<= .96 spawner_dice_roll)
                            (>= game_difficulty_level .4)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/elite_stealth" "enc_main/elite_stealth" 2)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; bobomb carrier - .92
                        (if (and 
                            (<= .92 spawner_dice_roll)
                            (>= game_difficulty_level .3)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/bobomb_carrier" "enc_main/cov_carrier" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; elite needler - .87
                        (if (and 
                            (<= .87 spawner_dice_roll)
                            (>= game_difficulty_level .2)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/elite_ne" "enc_main/elite_normal" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; elite plasma rifle - .79
                        (if (and 
                            (<= .79 spawner_dice_roll)
                            (>= game_difficulty_level .1)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/elite_pr" "enc_main/elite_normal" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; jackal plasma pistol - .68
                        (if (and 
                            (<= .68 spawner_dice_roll)
                            (>= game_difficulty_level 0.05)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/jackal_pp" "enc_main/jackal_normal" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; grunt needler - .50
                        (if (and 
                            (<= .50 spawner_dice_roll)
                            (>= game_difficulty_level 0)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/grunt_ne" "enc_main/grunt_normal" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; grunt plasma pistol - other
                        (if (= spawner_condition_matched false)
                            (begin 
                                (wave_spawn_enemy "enc_common/grunt_pp" "enc_main/grunt_normal" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                    )
                )
                ; UNCOMMON - 11 squads
                (if (and 
                        (= spawner_next_enc "enc_uncommon")
                        (= spawner_picker_override_enc "null")
                    )
                    (begin 
                        ; flood flamethrower
                        (if (and 
                            (<= 1 spawner_dice_roll)
                            (>= game_difficulty_level .8)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_ft" "enc_main/flood_ranged" 4)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood plasmacannon
                        (if (and 
                            (<= .98 spawner_dice_roll)
                            (>= game_difficulty_level .75)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_pc" "enc_main/flood_ranged" 2)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood rocket launcher
                        (if (and 
                            (<= .96 spawner_dice_roll)
                            (>= game_difficulty_level .7)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_rl" "enc_main/flood_ranged" 2)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood sniper
                        (if (and 
                            (<= .94 spawner_dice_roll)
                            (>= game_difficulty_level .6)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_sr" "enc_main/flood_ranged" 2)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood hammer
                        (if (and 
                            (<= .92 spawner_dice_roll)
                            (>= game_difficulty_level .5)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_ham" "enc_main/flood_melee" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; ** flood misc guns **
                        ; flood shotgun
                        (if (and 
                            (<= 0.90 spawner_dice_roll)
                            (>= game_difficulty_level 0.26)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_sg" "enc_main/flood_ranged" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood human pistol
                        (if (and 
                            (<= 0.88 spawner_dice_roll)
                            (>= game_difficulty_level 0.24)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_hp" "enc_main/flood_ranged" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood plasma pistol
                        (if (and 
                            (<= 0.85 spawner_dice_roll)
                            (>= game_difficulty_level 0.22)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_pp" "enc_main/flood_ranged" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood needler
                        (if (and 
                            (<= 0.80 spawner_dice_roll)
                            (>= game_difficulty_level 0.2)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_ne" "enc_main/flood_ranged" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood plasma rifle
                        (if (and 
                            (<= 0.73 spawner_dice_roll)
                            (>= game_difficulty_level 0.18)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_pr" "enc_main/flood_ranged" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood assault rifle
                        (if (and 
                            (<= 0.63 spawner_dice_roll)
                            (>= game_difficulty_level 0.16)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_ar" "enc_main/flood_ranged" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood carrier
                        (if (and 
                            (<= 0.5 spawner_dice_roll)
                            (>= game_difficulty_level 0.14)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcrr_bob" "enc_main/flood_carrier" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood unarmed
                        (if (= spawner_condition_matched false)
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_unarmed" "enc_main/flood_melee" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                    )
                )
                ; RARE - ... squads
                (if (and 
                        (= spawner_next_enc "enc_rare")
                        (= spawner_picker_override_enc "null")
                    )
                    (begin 
                        ; sanic - should be rarest possible spawn
                        (if (and 
                            (<= 1 spawner_dice_roll)
                            (>= game_difficulty_level .99)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_rare/sanic" "enc_main/flood_melee" 10)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; shrek
                        (if (and 
                            (<= .98 spawner_dice_roll)
                            (>= game_difficulty_level .7)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_rare/shrek" "enc_main/flood_tank" 4)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; grabble carrier
                        (if (and 
                            (<= .96 spawner_dice_roll)
                            (>= game_difficulty_level .6)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_rare/grabble_carrier" "enc_main/flood_carrier" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus/knuckles plasma cannon
                        (if (and 
                            (<= .94 spawner_dice_roll)
                            (>= game_difficulty_level .55)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (if (< (real_random_range 0.0 1.0) 0.5)
                                    (wave_spawn_enemy "enc_rare/knuckles_pc" "enc_main/flood_ranged" 2)
                                    (wave_spawn_enemy "enc_rare/amogus_pc" "enc_main/flood_ranged" 2)
                                )
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus/knuckles rocket launcher
                        (if (and 
                            (<= .92 spawner_dice_roll)
                            (>= game_difficulty_level .5)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (if (< (real_random_range 0.0 1.0) 0.5)
                                    (wave_spawn_enemy "enc_rare/knuckles_rl" "enc_main/flood_ranged" 2)
                                    (wave_spawn_enemy "enc_rare/amogus_rl" "enc_main/flood_ranged" 2)
                                )
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus/knuckles shotgun
                        (if (and 
                            (<= .90 spawner_dice_roll)
                            (>= game_difficulty_level .26)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (if (< (real_random_range 0.0 1.0) 0.5)
                                    (wave_spawn_enemy "enc_rare/knuckles_sg" "enc_main/flood_ranged" 1)
                                    (wave_spawn_enemy "enc_rare/amogus_sg" "enc_main/flood_ranged" 1)
                                )
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus/knuckles human pistol
                        (if (and 
                            (<= .88 spawner_dice_roll)
                            (>= game_difficulty_level .24)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (if (< (real_random_range 0.0 1.0) 0.5)
                                    (wave_spawn_enemy "enc_rare/knuckles_hp" "enc_main/flood_ranged" 1)
                                    (wave_spawn_enemy "enc_rare/amogus_hp" "enc_main/flood_ranged" 1)
                                )
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus/knuckles plasma pistol
                        (if (and 
                            (<= .86 spawner_dice_roll)
                            (>= game_difficulty_level .22)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (if (< (real_random_range 0.0 1.0) 0.5)
                                    (wave_spawn_enemy "enc_rare/knuckles_pp" "enc_main/flood_ranged" 1)
                                    (wave_spawn_enemy "enc_rare/amogus_pp" "enc_main/flood_ranged" 1)
                                )
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus/knuckles needler
                        (if (and 
                            (<= .83 spawner_dice_roll)
                            (>= game_difficulty_level .2)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (if (< (real_random_range 0.0 1.0) 0.5)
                                    (wave_spawn_enemy "enc_rare/knuckles_ne" "enc_main/flood_ranged" 1)
                                    (wave_spawn_enemy "enc_rare/amogus_ne" "enc_main/flood_ranged" 1)
                                )
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus/knuckles plasma rifle
                        (if (and 
                            (<= .78 spawner_dice_roll)
                            (>= game_difficulty_level .18)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (if (< (real_random_range 0.0 1.0) 0.5)
                                    (wave_spawn_enemy "enc_rare/knuckles_pr" "enc_main/flood_ranged" 1)
                                    (wave_spawn_enemy "enc_rare/amogus_pr" "enc_main/flood_ranged" 1)
                                )
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus/knuckles assault rifle
                        (if (and 
                            (<= .72 spawner_dice_roll)
                            (>= game_difficulty_level .16)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (if (< (real_random_range 0.0 1.0) 0.5)
                                    (wave_spawn_enemy "enc_rare/knuckles_ar" "enc_main/flood_ranged" 1)
                                    (wave_spawn_enemy "enc_rare/amogus_ar" "enc_main/flood_ranged" 1)
                                )
                                (set spawner_condition_matched true)
                            )
                        )
                        ; amogus carrier
                        (if (and 
                            (<= .62 spawner_dice_roll)
                            (>= game_difficulty_level .14)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_rare/amogus_carrier" "enc_main/flood_carrier" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; joe carrier
                        (if (and 
                            (<= .48 spawner_dice_roll)
                            (>= game_difficulty_level .14)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_rare/joe_carrier" "enc_main/flood_carrier" 1)
                                (set spawner_condition_matched true)
                            )
                        )
                        ; halo 3 rats (or maybe a rat carrier???)
                        (if (= spawner_condition_matched false)
                            (begin 
                                (wave_spawn_enemy "enc_rare/rat" "enc_main/flood_inf" 0)
                                (set spawner_condition_matched true)
                            )
                        )
                    )
                )
                ; OVERRIDE
                (if (!= spawner_picker_override_enc "null")
                    (begin 
                        (wave_spawn_enemy spawner_picker_override_enc spawner_picker_override_enc_to 1)
                        (set spawner_condition_matched true)
                    )
                )
                (if
                    (= spawner_condition_matched false)
                    (begin 
                        (print "*** problem in wave_spawner: fell through all spawn cases ***")
                        (dump 3)
                    )
                )
            )
            ;(print "waiting to place a bad guy")
        )
    )
    (sleep wave_enemies_spawn_delay)
)

; spawn a specified enemy, move them to the specified encounter, increment enemy power count
(script static void (wave_spawn_enemy (ai enc_in) (ai enc_to) (short power_num))
    (ai_place enc_in)
    (if (!= enc_in "null")
        (begin 
            (set spawner_last_placed (ai_actors enc_in))
            (ai_free_units spawner_last_placed)
            (ai_attach (unit (list_get spawner_last_placed 0)) enc_to)
        )
    )
    (set wave_enemies_spawned (+ wave_enemies_spawned power_num))
)

; add every single encounter's current living actor count and return it
(script static short wave_get_enemies_living_count
    (set wave_enemies_living_count 0)
    (set wave_enemies_living_count (+ wave_enemies_living_count (ai_nonswarm_count "enc_main")))
    ;(set wave_enemies_living_count (+ wave_enemies_living_count (ai_nonswarm_count "enc_common")))
    ;(set wave_enemies_living_count (+ wave_enemies_living_count (ai_nonswarm_count "enc_uncommon")))
    ;(set wave_enemies_living_count (+ wave_enemies_living_count (ai_nonswarm_count "enc_rare")))
    ;(set wave_enemies_living_count (+ wave_enemies_living_count (ai_nonswarm_count "enc_superrare")))
)

;;; ------------------------------------ PLAYERS ------------------------------------ ;;;

; observers for each player, keeps track of them and any state based logic that might need to happen
(script continuous monitor_player0
    ; PLAYER 0
    ; watch for player death
    (if (and 
        (= (unit_get_health (player0)) 0)
        (= game_swapping_loadout false)
        (= option_use_checkpoints false)
        (= option_disable_death false)
    )
        (begin
            (print "PLAYER 0 DIED!")

            ; create and place fake dead body
            (object_create_anew biped_player0_dummy)
            (unit_set_current_vitality (unit biped_player0_dummy) 0 0)
            (objects_attach (player0) "" biped_player0_dummy "")
            (objects_detach (player0) biped_player0_dummy)

            ; kick off respawn sequence
            (set player0_respawning true)
            (player_respawn_sequence (player0))
        )
    )
    ; maintain invincibility if it's enabled for this player
    (if (= player0_invincible true)
        (unit_set_current_vitality (player0) 80 80)
    )
)
(script continuous monitor_player1
    ; PLAYER 1
    ; watch for player death
    (if (and 
        (= (unit_get_health (player1)) 0)
        (= game_swapping_loadout false)
        (= option_use_checkpoints false)
        (= option_disable_death false)
    )
        (begin
            (print "PLAYER 1 DIED!")

            ; create and place fake dead body
            (object_create_anew biped_player1_dummy)
            (unit_set_current_vitality (unit biped_player1_dummy) 0 0)
            (objects_attach (player1) "" biped_player1_dummy "")
            (objects_detach (player1) biped_player1_dummy)

            ; kick off respawn sequence
            (set player1_respawning true)
            (player_respawn_sequence (player1))
        )
    )
    ; maintain invincibility if it's enabled for this player
    (if (= player1_invincible true)
        (unit_set_current_vitality (player1) 80 80)
    )
)
(script continuous monitor_player2
    ; PLAYER 2
    ; watch for player death
    (if (and 
        (= (unit_get_health (player2)) 0)
        (= game_swapping_loadout false)
        (= option_use_checkpoints false)
        (= option_disable_death false)
    )
        (begin
            (print "PLAYER 2 DIED!")

            ; create and place fake dead body
            (object_create_anew biped_player2_dummy)
            (unit_set_current_vitality (unit biped_player2_dummy) 0 0)
            (objects_attach (player2) "" biped_player2_dummy "")
            (objects_detach (player2) biped_player2_dummy)

            ; kick off respawn sequence
            (set player2_respawning true)
            (player_respawn_sequence (player2))
        )
    )
    ; maintain invincibility if it's enabled for this player
    (if (= player2_invincible true)
        (unit_set_current_vitality (player2) 80 80)
    )
)
(script continuous monitor_player3
    ; PLAYER 3
    ; watch for player death
    (if (and 
        (= (unit_get_health (player3)) 0)
        (= game_swapping_loadout false)
        (= option_use_checkpoints false)
        (= option_disable_death false)
    )
        (begin
            (print "PLAYER 3 DIED!")

            ; create and place fake dead body
            (object_create_anew biped_player3_dummy)
            (unit_set_current_vitality (unit biped_player3_dummy) 0 0)
            (objects_attach (player3) "" biped_player3_dummy "")
            (objects_detach (player3) biped_player3_dummy)

            ; kick off respawn sequence
            (set player3_respawning true)
            (player_respawn_sequence (player3))
        )
    )
    ; maintain invincibility if it's enabled for this player
    (if (= player3_invincible true)
        (unit_set_current_vitality (player3) 80 80)
    )
)

; manage respawning the player
(script static void (player_respawn_sequence (unit dead_player))
    (print "starting player respawn sequence for player...")
    (inspect dead_player)
    
    ; snag player away from the action
    (damage_object "swfce\effects\damage effects\screen white flash" dead_player)
    (object_teleport dead_player "player_timeout_point")
    (player_set_loadout dead_player "wep_none")
    (unit_set_current_vitality dead_player 80 80)
    (object_cannot_take_damage dead_player)
    (ai_disregard dead_player 1)
    (if (and 
            (> global_life_count 0)
            (!= global_life_count -1)
        )
        (begin
            (set global_life_count (- global_life_count 1))
            (ww_print_remaining_lives)
        )
    )
    (set players_dead (+ players_dead 1))
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
            (object_can_take_damage dead_player)
            (player_set_loadout dead_player game_current_loadout)

            ; player-specific stuff
            (if (= dead_player (player0))
                (begin 
                    (object_teleport dead_player "player0_respawn_point")
                    (set player0_respawning false)
                )
            )
            (if (= dead_player (player1))
                (begin 
                    (object_teleport dead_player "player1_respawn_point")
                    (set player1_respawning false)
                )
            )
            (if (= dead_player (player2))
                (begin 
                    (object_teleport dead_player "player2_respawn_point")
                    (set player2_respawning false)
                )
            )
            (if (= dead_player (player3))
                (begin 
                    (object_teleport dead_player "player3_respawn_point")
                    (set player3_respawning false)
                )
            )
            (set players_dead (- players_dead 1))

            ; let player have 3 seconds of invulurability after spawning before turning it back off
            ; ...IF the invincibility powerup isn't active (so we don't fuck up the order)
            (if (!= powerup_status_invincibility 2) (player_set_invuln dead_player true))
            (sleep 90)
            (if (!= powerup_status_invincibility 2) (player_set_invuln dead_player false))
        )
        ; TODO: see if there's any way to make the players "spectate" the field or another player if there's no lives left so they can see what happens
    )
)

; set a player's invulnerability status and attach invuln object to them
(script static void (player_set_invuln (unit player_in) (boolean bool_in))
    (if (and 
        (object_exists (player0))
        (= player_in (player0))
    )
        (begin   
            (set player0_invincible bool_in)
            (if (= bool_in true)
                (begin 
                    (object_create "player0_invuln_effect")
                    (objects_attach player_in "body" "player0_invuln_effect" "smoker")
                    (object_cannot_take_damage player_in)
                )
                (begin 
                    (objects_detach player_in "player0_invuln_effect")
                    (object_destroy "player0_invuln_effect")
                    (effect_new_on_object_marker "swfce\effects\impulse\ww invuln fade" player_in "body")
                    (object_can_take_damage player_in)
                )
            )
        )
    )
    (if (and 
        (object_exists (player1))
        (= player_in (player1))
    )
        (begin   
            (set player1_invincible bool_in)
            (if (= bool_in true)
                (begin 
                    (object_create "player1_invuln_effect")
                    (objects_attach player_in "body" "player1_invuln_effect" "smoker")
                    (object_cannot_take_damage player_in)
                )
                (begin 
                    (objects_detach player_in "player1_invuln_effect")
                    (object_destroy "player1_invuln_effect")
                    (effect_new_on_object_marker "swfce\effects\impulse\ww invuln fade" player_in "body")
                    (object_can_take_damage player_in)
                )
            )
        )
    )
    (if (and 
        (object_exists (player2))
        (= player_in (player2))
    )
        (begin   
            (set player2_invincible bool_in)
            (if (= bool_in true)
                (begin 
                    (object_create "player2_invuln_effect")
                    (objects_attach player_in "body" "player2_invuln_effect" "smoker")
                    (object_cannot_take_damage player_in)
                )
                (begin 
                    (objects_detach player_in "player2_invuln_effect")
                    (object_destroy "player2_invuln_effect")
                    (effect_new_on_object_marker "swfce\effects\impulse\ww invuln fade" player_in "body")
                    (object_can_take_damage player_in)
                )
            )
        )
    )
    (if (and 
        (object_exists (player3))
        (= player_in (player3))
    )
        (begin   
            (set player3_invincible bool_in)
            (if (= bool_in true)
                (begin 
                    (object_create "player3_invuln_effect")
                    (objects_attach player_in "body" "player3_invuln_effect" "smoker")
                    (object_cannot_take_damage player_in)
                )
                (begin 
                    (objects_detach player_in "player3_invuln_effect")
                    (object_destroy "player3_invuln_effect")
                    (effect_new_on_object_marker "swfce\effects\impulse\ww invuln fade" player_in "body")
                    (object_can_take_damage player_in)
                )
            )
        )
    )
)

(script static boolean players_check_all_dead
    (if (= players_dead (player_count))
        (set players_all_dead true)
        (set players_all_dead false)
    )
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

; monitor current life count and trigger end game if = 0 and all players are dead
(script continuous game_monitor_lives
    (if (and 
            (= global_game_status 1)
            (= global_life_count 0)
            (= (players_check_all_dead) true)
            (!= option_use_checkpoints true)
        )
        (set global_game_status 2)
    )
)

(script static void ww_print_remaining_lives
    (cond 
        ((= global_life_count 0) (ww_set_objective lives_0 timer_hud))
        ((= global_life_count 1) (ww_set_objective lives_1 timer_hud))
        ((= global_life_count 2) (ww_set_objective lives_2 timer_hud))
        ((= global_life_count 3) (ww_set_objective lives_3 timer_hud))
        ((= global_life_count 4) (ww_set_objective lives_4 timer_hud))
        ((= global_life_count 5) (ww_set_objective lives_5 timer_hud))
        ((= global_life_count 6) (ww_set_objective lives_6 timer_hud))
        ((= global_life_count 7) (ww_set_objective lives_7 timer_hud))
        ((= global_life_count 8) (ww_set_objective lives_8 timer_hud))
        ((= global_life_count 9) (ww_set_objective lives_9 timer_hud))
        ((= global_life_count 10) (ww_set_objective lives_10 timer_hud))
        ((= global_life_count 11) (ww_set_objective lives_11 timer_hud))
        ((= global_life_count 12) (ww_set_objective lives_12 timer_hud))
        ((= global_life_count 13) (ww_set_objective lives_13 timer_hud))
        ((= global_life_count 14) (ww_set_objective lives_14 timer_hud))
        ((= global_life_count 15) (ww_set_objective lives_15 timer_hud))
        ((= global_life_count 16) (ww_set_objective lives_16 timer_hud))
        ((= global_life_count 17) (ww_set_objective lives_17 timer_hud))
        ((= global_life_count 18) (ww_set_objective lives_18 timer_hud))
        ((= global_life_count 19) (ww_set_objective lives_19 timer_hud))
        ((= global_life_count 20) (ww_set_objective lives_20 timer_hud))
        ((> global_life_count 20) (ww_set_objective lives_morethan_20 timer_hud))
    )
)

; set/replace the loadout for all players
(script static void (game_set_loadout (starting_profile loadout_in))
    (set game_current_loadout loadout_in)
    (set game_swapping_loadout true)
    (player_add_equipment (player0) loadout_in 1)
    (player_add_equipment (player1) loadout_in 1)
    (player_add_equipment (player2) loadout_in 1)
    (player_add_equipment (player3) loadout_in 1)
    (set game_swapping_loadout false)
)

;;; ------------------------------------ POWERUPS ------------------------------------ ;;;

;; generic logic to SET a powerup status based on the given object name
(script static void (powerup_set_status (object powerup) (short status))
    (cond 
        ((= powerup powerup_invincibility) (set powerup_status_invincibility status))
        ((= powerup powerup_strength) (set powerup_status_strength status))
        ((= powerup powerup_bottomless) (set powerup_status_bottomless status))
        ((= powerup powerup_extralife) (set powerup_status_extralife status))
        ((= powerup powerup_pow) (set powerup_status_pow status))
    )
)

;; generic logic to GET a powerup status based on the given object name
(script static short (powerup_get_status (object powerup))
    (cond 
        ((= powerup powerup_invincibility) (set powerup_status_invincibility powerup_status_invincibility))
        ((= powerup powerup_strength) (set powerup_status_strength powerup_status_strength))
        ((= powerup powerup_bottomless) (set powerup_status_bottomless powerup_status_bottomless))
        ((= powerup powerup_extralife) (set powerup_status_extralife powerup_status_extralife))
        ((= powerup powerup_pow) (set powerup_status_pow powerup_status_pow))
    )
)

;; generic powerup pickup logic
(script static void (powerup_pickup (object_name powerup))
    (effect_new_on_object_marker "swfce\effects\impulse\powerup flash" powerup "")
    (sound_impulse_start "swfce\sound\sfx\impulse\crash\pickup_life" powerup 1)
    (powerup_set_status powerup 2)
    (fade_in 1 1 1 15)
    (object_destroy powerup)
)

;; check if the specific given player is within pickup distance of the given powerup
(script static boolean (powerup_check_player_pickup (object player_in) (object powerup))
    (< (objects_distance_to_object player_in powerup) powerup_pickup_distance )
)

;; check any players are within pickup distance of the given powerup
(script static boolean (powerup_check_player_pickup_any (object powerup))
    (or
        (and (> (objects_distance_to_object (player0) powerup) 0 ) (< (objects_distance_to_object (player0) powerup) powerup_pickup_distance ))
        (and (> (objects_distance_to_object (player1) powerup) 0 ) (< (objects_distance_to_object (player1) powerup) powerup_pickup_distance ))
        (and (> (objects_distance_to_object (player2) powerup) 0 ) (< (objects_distance_to_object (player2) powerup) powerup_pickup_distance ))
        (and (> (objects_distance_to_object (player3) powerup) 0 ) (< (objects_distance_to_object (player3) powerup) powerup_pickup_distance ))
    )
)

;; roll if we're going to spawn a powerup on an murderized actor, then choose which powerup if so 
(script static void (powerup_roll_for_spawn (object actor))
    ; roll if we want to spawn a powerup based on current chance and scale of weirdness
    (set powerup_dice_roll (real_random_range 0 1))
    (if (or ww_debug_all ww_debug_powerups) (print "rolling for a powerup drop... result:"))
    (inspect powerup_dice_roll)
    (if (< powerup_dice_roll powerup_spawn_chance)
        ; choose a powerup to spawn, skipping powerups that are active or already currently spawned
        (begin 
            (set powerup_dice_roll (random_range 0 5))
            (if (or ww_debug_all ww_debug_powerups) (print "rolling for which powerup... result:"))
            ; invincibility
            (if (and 
                (= powerup_dice_roll 0)
                (= powerup_status_invincibility 0)
            )
                (begin 
                    (if (or ww_debug_all ww_debug_powerups) (print "invincibility"))
                    (powerup_spawn_on_object actor powerup_invincibility)
                )
            )
            ; strength
            (if (and 
                (= powerup_dice_roll 1)
                (= powerup_status_strength 0)
            )
                (begin 
                    (if (or ww_debug_all ww_debug_powerups) (print "strength"))
                    (powerup_spawn_on_object actor powerup_strength)
                )
            )
            ; bottomless
            (if (and 
                (= powerup_dice_roll 2)
                (= powerup_status_bottomless 0)
            )
                (begin 
                    (if (or ww_debug_all ww_debug_powerups) (print "bottomless"))
                    (powerup_spawn_on_object actor powerup_bottomless)
                )
            )
            ; extra life
            (if (and 
                (= powerup_dice_roll 3)
                (= powerup_status_extralife 0)
            )
                (begin 
                    (if (or ww_debug_all ww_debug_powerups) (print "extralife"))
                    (powerup_spawn_on_object actor powerup_extralife)
                )
            )
            ; pow
            (if (and 
                (= powerup_dice_roll 4)
                (= powerup_status_pow 0)
            )
                (begin 
                    (if (or ww_debug_all ww_debug_powerups) (print "pow"))
                    (powerup_spawn_on_object actor powerup_pow)
                )
            )
            ; refill
            (if (and 
                (= powerup_dice_roll 999)
                (= powerup_status_refill 0)
            )
                (begin 
                    (if (or ww_debug_all ww_debug_powerups) (print "refill"))
                    (powerup_spawn_on_object actor powerup_refill)
                )
            )
        )
    )
)

;; spawn a powerup into the play area and manage expiration timer
(script static void (powerup_spawn_on_object (object actor) (object_name powerup))
    (if (or ww_debug_all ww_debug_powerups) (print "spawned powerup on actor!"))
    (object_create_anew powerup)
    (powerup_set_status powerup 1)
    (objects_attach actor "" powerup "")
    (objects_detach actor powerup)
    (object_set_facing powerup north)
    (effect_new_on_object_marker "swfce\effects\impulse\powerup flash" powerup "")
    (sound_impulse_start "swfce\sound\sfx\impulse\crash\pickup_life" powerup 1)
)

;; reset a powerup back to standby status
(script static void (powerup_reset (object_name powerup))
    (if (or ww_debug_all ww_debug_powerups) (print "resetting powerup:"))
    (inspect powerup)
    (if (!= (powerup_get_status powerup) 2)
        (begin 
            (effect_new_on_object_marker "swfce\effects\impulse\powerup flash" powerup "")
            (sound_impulse_start "swfce\sound\sfx\impulse\crash\hit_item" powerup 1)
        )
    )
    (object_destroy powerup)
    (powerup_set_status powerup 0)
)

;;; powerup monitors ;;;
;; monitors for powerup statuses, reset timers, and pickups
(script continuous monitor_powerup_any_active
    (if (or 
        (= powerup_status_invincibility 2)
        (= powerup_status_strength 2)
        (= powerup_status_bottomless 2)
    )
        (set powerup_currently_active true)
        (set powerup_currently_active false)
    )
)
; watch for if powerup invincibility spawned & run reset timer
(script continuous monitor_powerup_invincibility_1
    (if (= powerup_status_invincibility 1)
        (begin 
            (sleep powerup_reset_time)
            (powerup_reset powerup_invincibility)
        )
    )
)
; watch for if powerup invincibility was picked up & run powerup logic
(script continuous monitor_powerup_invincibility_2
    ; listen for the powerup to be picked up to trigger the active sequence
    (if (and 
            (powerup_check_player_pickup_any powerup_invincibility)
            (!= powerup_status_invincibility 2)
        )
        (begin 
            (if (or ww_debug_all ww_debug_powerups) (print "picked up powerup invincibility!"))
            (ww_set_objective powerup_invin timer_hud)
            (powerup_pickup powerup_invincibility)

            (sound_looping_start "swfce\sound\sfx\cinematic\warioware\powerup_invin_active" none 1)
            (player_set_invuln (player0) true)
            (player_set_invuln (player1) true)
            (player_set_invuln (player2) true)
            (player_set_invuln (player3) true)
            (sleep (* 20 30))
            (player_set_invuln (player0) false)
            (player_set_invuln (player1) false)
            (player_set_invuln (player2) false)
            (player_set_invuln (player3) false)
            (sound_looping_stop "swfce\sound\sfx\cinematic\warioware\powerup_invin_active")

            (set powerup_status_invincibility 0)
            (if (or ww_debug_all ww_debug_powerups) (print "powerup invincibility ended"))
        )
    )
)
; watch for if powerup strength spawned & run reset timer
(script continuous monitor_powerup_strength_1
    (if (= powerup_status_strength 1)
        (begin 
            (sleep powerup_reset_time)
            (powerup_reset powerup_strength)
        )
    )
)
; watch for if powerup strength was picked up & run powerup logic
(script continuous monitor_powerup_strength_2
    (if (and 
            (powerup_check_player_pickup_any powerup_strength)
            (!= powerup_status_strength 2)
        )
        (begin 
            (if (or ww_debug_all ww_debug_powerups) (print "picked up powerup strength!"))
            (ww_set_objective powerup_strength timer_hud)
            (powerup_pickup powerup_strength)

            (sound_looping_start "swfce\sound\sfx\cinematic\warioware\powerup_strength_active" none 1)
            ; ai strength modification is handled in monitor_enemy_lists function
            (sleep (* 20 30))
            (sound_looping_stop "swfce\sound\sfx\cinematic\warioware\powerup_strength_active")
            (ai_renew enc_main)

            (set powerup_status_strength 0)
            (if (or ww_debug_all ww_debug_powerups) (print "powerup strength ended"))
        )
    )
)
; watch for if powerup bottomless spawned & run reset timer
(script continuous monitor_powerup_bottomless_1
    (if (= powerup_status_bottomless 1)
        (begin 
            (sleep powerup_reset_time)
            (powerup_reset powerup_bottomless)
        )
    )
)
; watch for if powerup bottomless was picked up & run powerup logic
(script continuous monitor_powerup_bottomless_2
    (if (and 
            (powerup_check_player_pickup_any powerup_bottomless)
            (!= powerup_status_bottomless 2)
        )
        (begin 
            (if (or ww_debug_all ww_debug_powerups) (print "picked up powerup bottomless!"))
            (ww_set_objective powerup_bottomless timer_hud)
            (powerup_pickup powerup_bottomless)

            (sound_looping_start "swfce\sound\sfx\cinematic\warioware\powerup_bottomless_active" none 1)
            (set cheat_bottomless_clip 1)
            (sleep (* 20 30))
            (set cheat_bottomless_clip 0)
            (sound_looping_stop "swfce\sound\sfx\cinematic\warioware\powerup_bottomless_active")

            (set powerup_status_bottomless 0)
            (if (or ww_debug_all ww_debug_powerups) (print "powerup bottomless ended"))
        )
    )
)
; watch for if powerup pow spawned & run reset timer
(script continuous monitor_powerup_pow_1
    (if (= powerup_status_pow 1)
        (begin 
            (sleep powerup_reset_time)
            (powerup_reset powerup_pow)
        )
    )
)
; watch for if powerup pow was picked up & run powerup logic
(script continuous monitor_powerup_pow_2
    (if (and 
            (powerup_check_player_pickup_any powerup_pow)
            (!= powerup_status_pow 2)
        )
        (begin 
            (if (or ww_debug_all ww_debug_powerups) (print "picked up powerup pow!"))
            (ww_set_objective powerup_pow timer_hud)
            (powerup_pickup powerup_pow)

            (sleep 30)
            (ai_kill enc_main)
            (sleep 30)
            (ai_kill enc_main)
            (sleep 30)
            (ai_kill enc_main)
            (sleep 30)
            (ai_kill enc_main)
            (sleep 30)
            (ai_kill enc_main)

            (set powerup_status_pow 0)
            (if (or ww_debug_all ww_debug_powerups) (print "powerup pow ended"))
        )
    )
)
; watch for if powerup extralife spawned & run reset timer
(script continuous monitor_powerup_extralife_1
    (if (= powerup_status_extralife 1)
        (begin 
            (sleep powerup_reset_time)
            (powerup_reset powerup_extralife)
        )
    )
)
; watch for if powerup extralife was picked up & run powerup logic
(script continuous monitor_powerup_extralife_2
    (if (and 
            (powerup_check_player_pickup_any powerup_extralife)
            (!= powerup_status_extralife 2)
        )
        (begin 
            (if (or ww_debug_all ww_debug_powerups) (print "picked up powerup extralife!"))
            (ww_set_objective powerup_life timer_hud)
            (powerup_pickup powerup_extralife)

            (sound_impulse_start "" none 1)
            (set global_life_count (+ global_life_count 1))

            (set powerup_status_extralife 0)
            ; (if (or ww_debug_all ww_debug_powerups) (print "powerup extralife ended"))
        )
    )
)

;;; ------------------------------------ AI MONITORING ------------------------------------ ;;;
;; refresh ai lists for the individual monitor scripts, perform any logic on all units
(script continuous monitor_enemy_lists
    (set ai_list_main (ai_actors "enc_main"))

    ; powerup strength modifier
    (if (= powerup_status_strength 2)
        (units_set_current_vitality ai_list_main 1 0)
    )

    (sleep 2)
)

;; individual enemy to run logic on
(script static void (monitor_individual_enemy (object actor_in))
    ; test if the actor is dead and roll for a powerup spawn
    ; NOTE: this PAUSES the thread for the calling script, so whatever enemy index monitor that rolled for a...
    ; ...powerup will be unusable once the next ai list is retrieved, UNTIL the powerup sequence or forced delay after roll has ended
    (if (= (unit_get_health (unit actor_in)) 0)
        (begin 
            (powerup_roll_for_spawn actor_in)
            (sleep 80) ; force this thread to sleep after rolling in case the actor is playing dead (prevents millions of rerolls while the actor is fake-dead)
        )
    )
)

;; monitor each living enemy index for gamestate effects -- TODO: increase this to the max the list allows (128 i think)
(script continuous monitor_ai_list_main_0
    (monitor_individual_enemy (list_get ai_list_main 0))
)
(script continuous monitor_ai_list_main_1
    (monitor_individual_enemy (list_get ai_list_main 1))
)
(script continuous monitor_ai_list_main_2
    (monitor_individual_enemy (list_get ai_list_main 2))
)
(script continuous monitor_ai_list_main_3
    (monitor_individual_enemy (list_get ai_list_main 3))
)
(script continuous monitor_ai_list_main_4
    (monitor_individual_enemy (list_get ai_list_main 4))
)
(script continuous monitor_ai_list_main_5
    (monitor_individual_enemy (list_get ai_list_main 5))
)
(script continuous monitor_ai_list_main_6
    (monitor_individual_enemy (list_get ai_list_main 6))
)
(script continuous monitor_ai_list_main_7
    (monitor_individual_enemy (list_get ai_list_main 7))
)
(script continuous monitor_ai_list_main_8
    (monitor_individual_enemy (list_get ai_list_main 8))
)
(script continuous monitor_ai_list_main_9
    (monitor_individual_enemy (list_get ai_list_main 9))
)
(script continuous monitor_ai_list_main_10
    (monitor_individual_enemy (list_get ai_list_main 10))
)
(script continuous monitor_ai_list_main_11
    (monitor_individual_enemy (list_get ai_list_main 11))
)
(script continuous monitor_ai_list_main_12
    (monitor_individual_enemy (list_get ai_list_main 12))
)
(script continuous monitor_ai_list_main_13
    (monitor_individual_enemy (list_get ai_list_main 13))
)
(script continuous monitor_ai_list_main_14
    (monitor_individual_enemy (list_get ai_list_main 14))
)
(script continuous monitor_ai_list_main_15
    (monitor_individual_enemy (list_get ai_list_main 15))
)
(script continuous monitor_ai_list_main_16
    (monitor_individual_enemy (list_get ai_list_main 16))
)
(script continuous monitor_ai_list_main_17
    (monitor_individual_enemy (list_get ai_list_main 17))
)
(script continuous monitor_ai_list_main_18
    (monitor_individual_enemy (list_get ai_list_main 18))
)
(script continuous monitor_ai_list_main_19
    (monitor_individual_enemy (list_get ai_list_main 19))
)
(script continuous monitor_ai_list_main_20
    (monitor_individual_enemy (list_get ai_list_main 20))
)
(script continuous monitor_ai_list_main_21
    (monitor_individual_enemy (list_get ai_list_main 21))
)
(script continuous monitor_ai_list_main_22
    (monitor_individual_enemy (list_get ai_list_main 22))
)
(script continuous monitor_ai_list_main_23
    (monitor_individual_enemy (list_get ai_list_main 23))
)
(script continuous monitor_ai_list_main_24
    (monitor_individual_enemy (list_get ai_list_main 24))
)
(script continuous monitor_ai_list_main_25
    (monitor_individual_enemy (list_get ai_list_main 25))
)
(script continuous monitor_ai_list_main_26
    (monitor_individual_enemy (list_get ai_list_main 26))
)
(script continuous monitor_ai_list_main_27
    (monitor_individual_enemy (list_get ai_list_main 27))
)
(script continuous monitor_ai_list_main_28
    (monitor_individual_enemy (list_get ai_list_main 28))
)
(script continuous monitor_ai_list_main_29
    (monitor_individual_enemy (list_get ai_list_main 29))
)
(script continuous monitor_ai_list_main_30
    (monitor_individual_enemy (list_get ai_list_main 30))
)
(script continuous monitor_ai_list_main_31
    (monitor_individual_enemy (list_get ai_list_main 31))
)
(script continuous monitor_ai_list_main_32
    (monitor_individual_enemy (list_get ai_list_main 32))
)
(script continuous monitor_ai_list_main_33
    (monitor_individual_enemy (list_get ai_list_main 33))
)
(script continuous monitor_ai_list_main_34
    (monitor_individual_enemy (list_get ai_list_main 34))
)
(script continuous monitor_ai_list_main_35
    (monitor_individual_enemy (list_get ai_list_main 35))
)

;;; ------------------------------------ scenery ------------------------------------ ;;;
;; step through qblock spawns and randomly spawn
(script static void ww_replace_qblocks
    (object_destroy_containing "qblock_")
    (begin_random 
        (ww_place_qblock qblock_0)
        (ww_place_qblock qblock_1)
        (ww_place_qblock qblock_2)
        (ww_place_qblock qblock_3)
        (ww_place_qblock qblock_4)
        (ww_place_qblock qblock_5)
        (ww_place_qblock qblock_6)
    )
)
(script static void (ww_place_qblock (object_name qblock_name))
    (if (> ww_qblocks_to_spawn 0) 
        (begin 
            (object_create qblock_name)
            (set ww_qblocks_to_spawn (- ww_qblocks_to_spawn 1))
        )
        (sleep -1 ww_replace_qblocks)
    )
)

;;; ------------------------------------ testing stuff ------------------------------------ ;;;
; dump variables for various things and stuff
(script static void (dump (short context))
    (cond 
        ((not (>= context 0));list
        (begin
            (print "dump indexes ********")
            (print "0: game state")
            (print "1: wave active status")
            (print "2: spawner")
            (print "3: spawn picker")
            (print "4: startup state")
        ))
        ((= context 0);game
        (begin 
            (print "dumping current game state variables ********")
            (print "global_game_status:")
            (inspect global_game_status)
            (print "global_life_count:")
            (inspect global_life_count)
            (print "global_wave_num:")
            (inspect global_wave_num)
            (print "global_round_num:")
            (inspect global_round_num)
            (print "global_set_num:")
            (inspect global_set_num)
            (print "wave_is_last_of_set:")
            (inspect wave_is_last_of_set)
            (print "game_difficulty_level:")
            (inspect game_difficulty_level)
            (print "game_weirdness_level:")
            (inspect game_weirdness_level)
        ))
        ((= context 1);wave
        (begin 
            (print "dumping wave live status ********")
            (print "wave_in_progress:")
            (inspect wave_in_progress)
            (print "wave_spawner_on:")
            (inspect wave_spawner_on)
            (print "wave_get_enemies_living_count:")
            (inspect (wave_get_enemies_living_count))
            (print "wave_enemies_spawned:")
            (inspect wave_enemies_spawned)
            (print "wave_enemies_per_wave:")
            (inspect wave_enemies_per_wave)
            (print "wave_enemies_active_max:")
            (inspect wave_enemies_active_max)
            (print "wave_enemies_spawn_delay:")
            (inspect wave_enemies_spawn_delay)
            (print "wave_next_delay:")
            (inspect wave_next_delay)
        ))
        ((= context 2);spawner
        (begin 
            (print "dumping current spawner values ********")
            (print "spawner_enc_common_weight:")
            (inspect spawner_enc_common_weight)
            (print "spawner_enc_uncommon_weight:")
            (inspect spawner_enc_uncommon_weight)
            (print "spawner_enc_rare_weight:")
            (inspect spawner_enc_rare_weight)
            (print "wave_enemies_spawn_delay:")
            (inspect wave_enemies_spawn_delay)
            (print "spawner_dice_lower:")
            (inspect spawner_dice_lower)
            (print "spawner_dice_upper:")
            (inspect spawner_dice_upper)
            ;(print "spawner_dice_scale")
            ;(inspect spawner_dice_scale)
        ))
        ((= context 3);spawnpicker
        (begin 
            (print "dumping last spawn picker values ********")
            (print "wave_spawner_on:")
            (inspect wave_spawner_on)
            (print "spawner_dice_roll:")
            (inspect spawner_dice_roll)
            (print "spawner_next_enc:")
            (inspect spawner_next_enc)
            (print "spawner_condition_matched:")
            (inspect spawner_condition_matched)
            (print "spawner_picker_override_enc:")
            (inspect spawner_picker_override_enc)
        ))
        ((= context 4);startup
        (begin 
            (print "dumping final startup values ********")
            (print "player_count:")
            (inspect (player_count))
            (print "option_ai_infighting:")
            (inspect option_ai_infighting)
            (print "option_difficulty:")
            (inspect option_difficulty)
            (print "game_difficulty_scale:")
            (inspect game_difficulty_scale)
            (print "option_weirdness:")
            (inspect option_weirdness)
            (print "game_weirdness_scale:")
            (inspect game_weirdness_scale)
            (print "option_use_checkpoints:")
            (inspect option_use_checkpoints)
            (print "option_starting_lives:")
            (inspect option_starting_lives)
        ))

        ((= context 100);template
        (begin 
            (print "dumping template, dummy ********")
            (print "variable:")
            (inspect (= 1 1))
        ))
    )
    (print "*************")
)

(script static void test_game
    (set run_game_scripts true)
    (sleep 1)
    (device_set_position control_start_game 1)
)

; repurpose this for the "start" button later
(script continuous test_start_wave
	; panel turned ON
	(sleep_until (= 1 (device_get_position control_start_game)) 1)
    (device_set_power control_start_game 0)
	
	; panel turned OFF
	(sleep_until (= wave_in_progress false) 30)
    (device_set_position control_start_game 0)
    (device_set_power control_start_game 1)
)