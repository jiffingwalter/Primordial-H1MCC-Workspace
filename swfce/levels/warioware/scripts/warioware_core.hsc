;;; SUPER WACKY FUNWARE SCRIPT ;;;
; version 0.0.1
; created with love and autism by primordial <3

;; ---- Variables ---- ;;
; Game options set by player on start 
(global string option_ai_infighting "enabled") ; Do different enemy factions fight each other? enabled, disabled, conditional (enemies will fight but focus on the player)
(global string option_minigames_frequency "normal") ; Minigame wave frequency: none, normal (every round), less (every 2 rounds), many (every single wave)
(global string option_difficulty "normal") ; Multiplier for how many harder enemies appear: normal (1.1), less (1.05), more (1.2), insane (1.3)
(global string option_weirdness "normal") ; Multiplier for how fast the game gets weirder: normal (1.1), less (1.05), more (1.2), insane (1.3)
(global boolean option_spawn_friends true) ; Spawn friendly AI on each set?
(global boolean option_spawn_blocks true) ; Spawn question blocks on each set?
(global short option_starting_lives 10) ; Sets how many lives player starts with. 1, 5, 10, 15, 20, -1 (endless)
(global boolean option_use_checkpoints false) ; Use checkpoints instead of lives, auto-turns on endless mode

; Functional vars
(global short global_life_count 0) ; number of player lives (disrgarded if 'use checkpoints' or endless mode options are set)
(global short global_game_status 0) ; 0 - not started, 1 - in progress, 2 - lost
(global short global_wave_num 0) ; current wave
(global short global_round_num 0) ; current round
(global short global_set_num 0) ; current set
(global short global_total_difficulty_scale 0) ; all of the scales added into one number
(global short global_timer_elapsed 0) ; holds amount of seconds passed in the game
(global boolean global_timer_on false) ; if we're running the timer or not
(global real game_difficulty_scale 1.0) ; how fast more dangerous enemies and vehicles appear, set based on option_difficulty_scale
(global real game_difficulty_level 0.1) ; current difficulty level, scales based on game_difficulty_scale
(global real game_weirdness_scale 1.0) ; how fast weirder stuff starts happening in the game, scales based on option_weirdness_scale
(global real game_weirdness_level 0.1) ; current weirdness level, scales based on game_weirdness_scale

; Wave management vars
(global boolean wave_spawner_on false) ; do we currently want to spawn bad guys?
(global boolean wave_is_minigame false) ; is the current wave a minigame wave?
(global boolean wave_is_boss false) ; is the current wave a boss wave?
(global boolean wave_in_progress false) ; is a wave currently in progress?
(global short wave_enemies_spawn_delay 15) ; how fast to try to spawn enemies
(global short wave_next_delay (* 30 12)) ; how long to wait until spawning next wave
(global short wave_enemies_living_count 0) ; current amount of living enemies of all types
(global short wave_enemies_spawned 0) ; how many enemies placed for the wave so far (reset on wave ends)
(global short wave_enemies_per_wave 0) ; number of enemies to spawn for this wave, scales based on option_enemy_active_scale
(global short wave_enemies_active_max 0) ; the max amount of enemies allowed to be alive at one time, scales based on option_difficulty_scale

; spawner function vars
(global string spawner_next_enc "") ; the name of the next encounter we're going to spawn from
(global ai spawner_picker_override "null") ; override the next spawn with an ai from this squad
(global ai spawner_last_placed "null") ; the last encounter and squad we placed an enemy from
(global real spawner_dice_roll 0) ; stored spawner dice roll result used for choosing spawns
(global real spawner_dice_lower 0.08) ; lower limit for dice rolls, scales based on option_difficulty_scale
(global real spawner_dice_upper 1) ; upper limit for dice rolls
(global boolean spawner_condition_matched false) ; did the spawner match a condition when choosing a squad? (triggers skipping the rest of the if statements)
(global real spawner_enc_common_chance 0.9) ; initial chance of spawning an enemy from the common encounter
(global real spawner_enc_uncommon_chance 0.4) ; initial chance of spawning an enemy from the uncommon encounter
(global real spawner_enc_rare_chance 0.2) ; initial chance of spawning an enemy from the rare encounter
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
(global boolean player0_invulnurable false)
(global boolean player1_invulnurable false)
(global boolean player2_invulnurable false)
(global boolean player3_invulnurable false)

;; ---- Game control scripts ---- ;;
; STARTUP SCRIPT - set up the game, start logic to collect options from the player, etc. once player confirms, make any changes needed for options and start the core game loop
(script startup game_setup
    (print "startup")
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
    (if (= option_ai_infighting "disabled")
        (begin 
            (ai_allegiance covenant flood)
            (ai_allegiance covenant sentinel)
            (ai_allegiance sentinel flood)
        )
    )
    (if (= option_ai_infighting "conditional")
        (ai_try_to_fight_player "enc_main")
    )

    ; initial difficulty scale...
    (if (= option_difficulty "normal")
        (set game_difficulty_scale 1.1)
    )
    (if (= option_difficulty "less")
        (set game_difficulty_scale 1.05)
    )
    (if (= option_difficulty "more")
        (set game_difficulty_scale 1.2)
    )
    (if (= option_difficulty "insane")
        (set game_difficulty_scale 1.3)
    )
    ; initial weirdness scale...
    (if (= option_weirdness "normal")
        (set game_weirdness_scale 1.1)
    )
    (if (= option_weirdness "less")
        (set game_weirdness_scale 1.05)
    )
    (if (= option_weirdness "more")
        (set game_weirdness_scale 1.2)
    )
    (if (= option_weirdness "insane")
        (set game_weirdness_scale 1.3)
    )
    
    ; misc...
    (if (= option_use_checkpoints true)
        (begin 
            (set cheat_deathless_player 0)
            (set global_life_count -1)
        )
        (set global_life_count option_starting_lives)
    )

    ; wave vars...
    (set wave_enemies_per_wave (* 8 (* game_difficulty_scale 2)))
    (set wave_enemies_active_max (* wave_enemies_per_wave 0.4))

    ; teleport players and start game...
    (set global_game_status 1)
    (fade_in 1 1 1 30)
    (object_teleport (player0) "player0_respawn_point")
    (object_teleport (player1) "player1_respawn_point")
    (object_teleport (player2) "player2_respawn_point")
    (object_teleport (player3) "player3_respawn_point")
    (game_set_loadout "preset_default")
    
    (sleep 90)
    (wave_start_next)
)

; core script - observe game state and take actions as necessary (wave start and stopping, game over)
(script continuous game_main
    (if (= global_game_status 1) ; is the game active?
        ; wait for conditions...
            ; are all enemies of the current wave dead? (max were spawned and none are alive) - turn off spawner and trigger next wave if so
            ; TODO: modifiy this logic so that when the enemy count of the current wave is < 5 and we're not entering a new set, start a timer to begin the next wave automatically
        (if (and 
                (< wave_enemies_living_count 5)
                (= wave_enemies_spawned wave_enemies_per_wave)
                (= wave_in_progress true)
            )
            (begin 
                (print "*** current wave ended ***")
                (set wave_spawner_on false)
                (set wave_in_progress false)

                (sleep wave_next_delay)
                (wave_start_next)
            )
            ; else, if its a new set, run unique logic for finished wave
            ;(if (= (wave_is_last) true)
            ;    
            ;)
        )
    )
    (if (= global_game_status 2) ; status was set to lost, run lose game logic
        (begin 
            (print "GAME OVER!")

            (sleep (* 8 30))

            (game_lost)

            (sleep -1)
        )
    )
)

(script static void wave_start_next
    (print "*** starting next wave ***")
    (set wave_in_progress true)
    (garbage_collect_now)

    ; --- update global and wave state variables --- (incrementations and adjusting based on spawn scales)
    (if (= global_wave_num 0)
        (begin ; if its the first wave, set the initial wave/round/set
            (set global_wave_num 1)
            (set global_round_num 1)
            (set global_set_num 1)
        )
        (begin ; if its any wave after, run incrementations
            ; update wave/round/set
            (set global_wave_num (+ global_wave_num 1))

            (if (= (modulo global_wave_num 3) 0)
                (set global_round_num (+ global_round_num 1))
            )
            (if (= (modulo global_round_num 5) 0)
                (set global_set_num (+ global_set_num 1))
            )

            ; game values
            (set game_difficulty_level (* game_difficulty_level game_difficulty_scale))
            (set game_weirdness_level (* game_weirdness_level game_weirdness_scale))

            ; wave values -- scale based on current difficulty level
            (set wave_enemies_per_wave (* wave_enemies_per_wave (+ game_difficulty_level 1)))
            (set wave_enemies_active_max (* wave_enemies_per_wave 0.4))
            (if (not (< wave_next_delay (* 30 3)))
                (set wave_next_delay (* wave_next_delay 0.99))
            )
            (if (not (< wave_enemies_spawn_delay 5))
                (set wave_enemies_spawn_delay (* wave_enemies_spawn_delay 0.99))
            )
            
        )
    )
    
    ; --- spawn chance vars ---
    ; get initial spawn weights
    (set spawner_enc_common_weight (max (- 1 game_weirdness_level) (- 1 spawner_enc_common_chance)))
    (set spawner_enc_uncommon_weight (min game_weirdness_level (- 1 spawner_enc_uncommon_chance)))
    (set spawner_enc_rare_weight (max (- game_weirdness_level (- 1 spawner_enc_rare_chance)) 0))
    ; add total chances for normalization
    (set spawner_total_chance 0)
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_common_weight))
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_uncommon_weight))
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_rare_weight))
    ; get normalized spawn weights
    (set spawner_enc_common_weight (/ spawner_enc_common_weight spawner_total_chance))
    (set spawner_enc_uncommon_weight (/ spawner_enc_uncommon_weight spawner_total_chance))
    (set spawner_enc_rare_weight (/ spawner_enc_rare_weight spawner_total_chance))
    (set spawner_dice_lower (* spawner_dice_lower (+ game_difficulty_level 1)))

    ; --- reset functional vars ---
    (set wave_enemies_spawned 0)

    ; check if its time for minigame or boss wave

    ; turn the wave spawner on
    (set wave_spawner_on true)
    (wave_dump)
)

; dump current wave state variables
(script static void wave_dump
    (print "wave in progress:")
    (inspect wave_in_progress)
    (print "wave number:")
    (inspect global_wave_num)
    (print "round number:")
    (inspect global_round_num)
    (print "set number:")
    (inspect global_set_num)
    (print "difficulty scale:") ; move this a global dump function
    (inspect game_difficulty_scale)
    (print "difficulty level:")
    (inspect game_difficulty_level)
    (print "weirdness scale: ") ; move this a global dump function
    (inspect game_weirdness_scale)
    (print "weirdness level:")
    (inspect game_weirdness_level)
    (print "enemies per wave:")
    (inspect wave_enemies_per_wave)
    (print "enemies active max:")
    (inspect wave_enemies_active_max)
    (print "currently living enemies:")
    (inspect wave_enemies_living_count)
    (print "enemies spawned this wave:")
    (inspect wave_enemies_spawned)
    (print "enemy spawn delay:")
    (inspect wave_enemies_spawn_delay)
    (print "next wave delay:")
    (inspect wave_next_delay)
)

; wave spawn loop - if the spawner is active, keep rolling for encounters and squads to spawn enemies as long as max allowed enemies aren't spawned or wave limit threshold is reached
(script continuous wave_spawner
    (if wave_spawner_on
        ; check for current actors alive and if we're below the current max allowed actors, then...
        (if (and 
                (< wave_enemies_living_count wave_enemies_active_max) 
                (!= wave_enemies_spawned wave_enemies_per_wave)
            )
            (begin 
                ;(print "placing a bad guy!")

                ; roll for an encounter (enemy faction) to spawn from based on if the dice roll lands inside the encounter's current spawn interval
                (set spawner_dice_roll (real_random_range 0 1))

                (if (<= spawner_dice_roll spawner_enc_common_weight)
                    (set spawner_next_enc "common")
                )
                (if (and 
                        (!= spawner_enc_uncommon_chance 0)
                        (> spawner_dice_roll spawner_enc_common_weight)
                        (<= spawner_dice_roll (+ spawner_enc_common_weight spawner_enc_uncommon_weight))
                    )
                    (set spawner_next_enc "uncommon")
                )
                (if (and 
                        (!= spawner_enc_rare_weight 0)
                        (> spawner_dice_roll (+ spawner_enc_common_weight spawner_enc_uncommon_weight))
                        ;(< spawner_dice_roll 1)
                    )
                    (set spawner_next_enc "rare")
                )
                ;(inspect spawner_next_enc)

                ; for the chosen encounter, roll again for a squad to spawn an enemy, or choose the overrided squad if set...
                ; actor spawn chances will all be hardcoded and normalized (use generate chance weights.py)
                ; actor spawn is decided on 3 conditions:
                    ; 1. did we roll high enough to spawn this enemy?
                    ; 2. is the current danger value high enough to spawn this enemy?
                    ; 3. did we already spawn an enemy?
                ; if first 2 aren't met, test the next one below. if 3rd is met, we skip the rest since that means we already placed one

                (set spawner_condition_matched false)
                (set spawner_dice_roll (real_random_range spawner_dice_lower spawner_dice_upper))

                ; COMMON - 9 squads
                (if (and 
                        (= spawner_next_enc "common")
                        (= spawner_picker_override "null")
                    )
                    (begin 
                        ; hunter - 1
                        (if (and 
                            (<= 1 spawner_dice_roll)
                            (>= game_difficulty_level .6)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/hunter")
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
                                (wave_spawn_enemy "enc_common/elite_ham")
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
                                (wave_spawn_enemy "enc_common/elite_stealth")
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
                                (wave_spawn_enemy "enc_common/bobomb_carrier")
                                (set spawner_condition_matched true)
                            )
                        )
                        ; elite needler - .87
                        (if (and 
                            (<= .87 spawner_dice_roll)
                            (>= game_difficulty_level .25)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/elite_ne")
                                (set spawner_condition_matched true)
                            )
                        )
                        ; elite plasma rifle - .79
                        (if (and 
                            (<= .79 spawner_dice_roll)
                            (>= game_difficulty_level .15)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/elite_pr")
                                (set spawner_condition_matched true)
                            )
                        )
                        ; jackal plasma pistol - .68
                        (if (and 
                            (<= .68 spawner_dice_roll)
                            (>= game_difficulty_level 0)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/jackal_pp")
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
                                (wave_spawn_enemy "enc_common/grunt_ne")
                                (set spawner_condition_matched true)
                            )
                        )
                        ; grunt plasma pistol - .50
                        (if (= spawner_condition_matched false)
                            (begin 
                                (wave_spawn_enemy "enc_common/grunt_pp")
                                (set spawner_condition_matched true)
                            )
                        )
                    )
                )
                ; UNCOMMON - 11 squads
                (if (and 
                        (= spawner_next_enc "uncommon")
                        (= spawner_picker_override "null")
                    )
                    (begin 
                        ; flood flamethrower
                        (if (and 
                            (<= 1 spawner_dice_roll)
                            (>= game_difficulty_level .8)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_ft")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_pc")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_rl")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_sr")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_ham")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_sg")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_hp")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_pp")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_ne")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_pr")
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
                                (wave_spawn_enemy "enc_uncommon/floodcmb_ar")
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
                                (wave_spawn_enemy "enc_uncommon/floodcrr_bob")
                                (set spawner_condition_matched true)
                            )
                        )
                        ; flood unarmed
                        (if (= spawner_condition_matched false)
                            (begin 
                                (wave_spawn_enemy "enc_uncommon/floodcmb_unarmed")
                                (set spawner_condition_matched true)
                            )
                        )
                    )
                )
                ; RARE - ... squads
                (if (and 
                        (= spawner_next_enc "rare")
                        (= spawner_picker_override "null")
                    )
                    (begin 
                        ; sanic - should be rarest possible spawn
                        (if (and 
                            (<= 1 spawner_dice_roll)
                            (>= game_difficulty_level .99)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_rare/sanic")
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
                                (wave_spawn_enemy "enc_rare/shrek")
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
                                (wave_spawn_enemy "enc_rare/grabble_carrier")
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
                                    (wave_spawn_enemy "enc_rare/knuckles_pc")
                                    (wave_spawn_enemy "enc_rare/amogus_pc")
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
                                    (wave_spawn_enemy "enc_rare/knuckles_rl")
                                    (wave_spawn_enemy "enc_rare/amogus_rl")
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
                                    (wave_spawn_enemy "enc_rare/knuckles_sg")
                                    (wave_spawn_enemy "enc_rare/amogus_sg")
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
                                    (wave_spawn_enemy "enc_rare/knuckles_hp")
                                    (wave_spawn_enemy "enc_rare/amogus_hp")
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
                                    (wave_spawn_enemy "enc_rare/knuckles_pp")
                                    (wave_spawn_enemy "enc_rare/amogus_pp")
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
                                    (wave_spawn_enemy "enc_rare/knuckles_ne")
                                    (wave_spawn_enemy "enc_rare/amogus_ne")
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
                                    (wave_spawn_enemy "enc_rare/knuckles_pr")
                                    (wave_spawn_enemy "enc_rare/amogus_pr")
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
                                    (wave_spawn_enemy "enc_rare/knuckles_ar")
                                    (wave_spawn_enemy "enc_rare/amogus_ar")
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
                                (wave_spawn_enemy "enc_rare/amogus_carrier")
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
                                (wave_spawn_enemy "enc_rare/joe_carrier")
                                (set spawner_condition_matched true)
                            )
                        )
                        ; halo 3 rats (or maybe a rat carrier???)
                        (if (= spawner_condition_matched false)
                            (begin 
                                (wave_spawn_enemy "enc_rare/rat")
                                (set spawner_condition_matched true)
                            )
                        )
                    )
                )
                ; OVERRIDE
                (if (!= spawner_picker_override "null")
                    (begin 
                        (wave_spawn_enemy spawner_picker_override)
                        (set spawner_condition_matched true)
                    )
                )
                (if
                    (= spawner_condition_matched false)
                    (begin 
                        (print "*** problem in wave_spawner: fell through all spawn cases ***")
                        (print "**spawner dice roll:")
                        (inspect spawner_dice_roll)
                        (print "**enemies danger scale:")
                        (inspect game_difficulty_level)
                        (print "**next enc chosen:")
                        (inspect spawner_next_enc)
                        (print "**overrided encounter (or null):")
                        (inspect spawner_picker_override)
                    )
                )
            )
            ;(print "waiting to place a bad guy")
        )
    )
    (sleep wave_enemies_spawn_delay)
)

; spawn a specified enemy and run shared logic
(script static void (wave_spawn_enemy (ai enc))
    (ai_place enc)
    (set spawner_last_placed enc)
    (ai_migrate spawner_last_placed "enc_main")
    (set wave_enemies_spawned (+ wave_enemies_spawned 1))
    ; debug
    ;(inspect spawner_dice_roll)
    ;(inspect enc)
)

; add every single encounter's current living actor count and return it
(global short _wavemonitorlivingenemies_value 0)
(script continuous wave_monitor_living_enemies
    (set _wavemonitorlivingenemies_value 0)
    (set _wavemonitorlivingenemies_value (+ _wavemonitorlivingenemies_value (ai_living_count "enc_common")))
    (set _wavemonitorlivingenemies_value (+ _wavemonitorlivingenemies_value (ai_living_count "enc_uncommon")))
    (set _wavemonitorlivingenemies_value (+ _wavemonitorlivingenemies_value (ai_living_count "enc_rare")))
    ;(set _wavemonitorlivingenemies_value (+ _wavemonitorlivingenemies_value (ai_living_count "enc_superrare")))
    
    (set wave_enemies_living_count _wavemonitorlivingenemies_value)
)

; observers for each player
; TODO: copy changes from monitor_player0 to other players as well
(script continuous monitor_player0
    ; watch for player death
    (if (and 
        (= (unit_get_health (player0)) 0)
        (!= game_swapping_loadout true)
        (!= option_use_checkpoints true)
    )
        (begin
            (print "PLAYER 0 DIED!")
            ; todo: spawn a body on the player's current position to fake a death
            (set player0_respawning true)
            (player_respawn_sequence (player0))
        )
    )
    ; maintain invincibility if it's enabled for this player
    (if (= player0_invulnurable true)
        (unit_set_current_vitality (player0) 80 80)
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
    (if (and 
            (> global_life_count 0)
            (!= global_life_count -1)
        )
        (set global_life_count (- global_life_count 1))
        ;todo: hud_objective of life count here
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
            (player_set_loadout dead_player "preset_default")

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
            (player_set_invuln dead_player true)
            (sleep 90)
            (player_set_invuln dead_player false)
        )
        ; TODO: see if there's any way to make the players "spectate" the field or another player if there's no lives left so they can see what happens
    )
)

; set a player's invulnerability status and attach invuln object to them
(script static void (player_set_invuln (unit player_in) (boolean bool_in))
    (if (= player_in (player0))
        (begin   
            (set player0_invulnurable bool_in)
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
    (if (= player_in (player1))
        (begin   
            (set player1_invulnurable bool_in)
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
    (if (= player_in (player2))
        (begin   
            (set player2_invulnurable bool_in)
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
    (if (= player_in (player3))
        (begin   
            (set player3_invulnurable bool_in)
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

; set/replace the loadout for all players
(script static void (game_set_loadout (starting_profile loadout_in))
    (set game_swapping_loadout true)
    (player_add_equipment (player0) loadout_in 1)
    (player_add_equipment (player1) loadout_in 1)
    (player_add_equipment (player2) loadout_in 1)
    (player_add_equipment (player3) loadout_in 1)
    (set game_swapping_loadout false)
)

;; --- testing stuff --- ;;
(script static void test_game
    (set run_game_scripts true)
    (sleep 5)
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

(script static void test_randspawn
    (set spawner_dice_roll (real_random_range 0 1))
    (inspect spawner_dice_roll)

    (if (<= spawner_dice_roll spawner_enc_common_chance)
        (print "spawning common");(set spawner_next_enc "common")
    )
    (if (and 
            (not (= spawner_enc_uncommon_chance 0))
            (> spawner_dice_roll spawner_enc_common_chance)
            (<= spawner_dice_roll (+ spawner_enc_common_chance spawner_enc_uncommon_chance))
        )
        (print "spawning uncommon");(set spawner_next_enc "uncommon")
    )
    (if (and 
            (not (= spawner_enc_rare_chance 0))
            (> spawner_dice_roll (+ spawner_enc_common_chance spawner_enc_uncommon_chance))
            ;(< spawner_dice_roll 1)
        )
        (print "spawning rare");(set spawner_next_enc "rare")
    )
)
(script static void (test_spawnscales (real scale))
    (print "chances...")
    (set spawner_enc_common_weight (max (- 1 scale) (- 1 spawner_enc_common_chance)))
    (inspect spawner_enc_common_weight)
    (set spawner_enc_uncommon_weight (min scale (- 1 spawner_enc_uncommon_chance)))
    (inspect spawner_enc_uncommon_weight)
    (set spawner_enc_rare_weight (max (- scale (- 1 spawner_enc_rare_chance)) 0))
    (inspect spawner_enc_rare_weight)

    (print "total chance...")
    (set spawner_total_chance 0)
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_common_weight))
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_uncommon_weight))
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_rare_weight))
    (inspect spawner_total_chance)

    (print "normalized weights...")
    (set spawner_enc_common_weight (/ spawner_enc_common_weight spawner_total_chance))
    (inspect spawner_enc_common_weight)
    (set spawner_enc_uncommon_weight (/ spawner_enc_uncommon_weight spawner_total_chance))
    (inspect spawner_enc_uncommon_weight)
    (set spawner_enc_rare_weight (/ spawner_enc_rare_weight spawner_total_chance))
    (inspect spawner_enc_rare_weight)

    (print "final total weight...")
    (set spawner_total_chance 0)
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_common_weight))
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_uncommon_weight))
    (set spawner_total_chance (+ spawner_total_chance spawner_enc_rare_weight))
    (inspect spawner_total_chance)
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