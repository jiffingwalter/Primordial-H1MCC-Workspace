;;; SUPER WACKY FUNWARE SCRIPT ;;;
; version 0.0.1
; created with love and autism by primordial

;; ---- Variables ---- ;;
; Game options set by player on start 
(global short option_ai_infighting 1) ; Do different enemy factions: (0) work together, (1) attack each other, or (2) only focus on the player if they're there
(global short option_minigames 1) ; Minigame wave frequency: (0) none, (1) normal, (2) less, (3) many
(global short option_enemy_active_scale 1) ; Multiplier for how fast enemy spawn scale increases: (0.5) less, (1) normal, (1.5) more, (2) insane
(global short option_difficulty_scale 1) ; Multiplier for how many harder enemies appear: (0.5) less, (1) normal, (1.5) more, (2) insane
(global short option_weirdness_scale 1) ; Multiplier for how many harder enemies appear: (0.5) less, (1) normal, (1.5) more, (2) insane
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
(global boolean wave_in_progress false) ; is a wave currently in progress?
(global short wave_enemies_living_count 0) ; current amount of living enemies of all types
(global short wave_enemies_spawn_delay 15) ; how fast to try to spawn enemies
(global short wave_enemies_spawned 0) ; how many enemies placed for the wave so far (reset on wave ends)
(global short wave_enemies_per_wave 0) ; number of enemies to spawn for this wave, scales based on option_enemy_active_scale
(global short wave_enemies_active_max 1) ; the max amount of enemies allowed to be alive at one time, scales based on option_difficulty_scale
(global real game_difficulty_level 0.0) ; effects chances of more dangerous enemies spawning and vehicles appearing - scales based on option_difficulty_scale
(global real game_weirdness_level 0.0) ; effects chances of rarer enemy faction encounters being chosen and weirder minigames, scales based on option_weirdness_scale
; spawner function vars
(global string spawner_next_enc "") ; the name of the next encounter we're going to spawn from
(global ai spawner_picker_override "enc_main") ; override the next spawn with an ai from this squad (enc_main acts as null)
(global ai spawner_last_placed "enc_main") ; the last encounter and squad we placed an enemy from. (enc_main acts as null)
(global real spawner_dice_roll 0) ; stored spawner dice roll result used for choosing spawns
(global real spawner_dice_lower 0) ; lower limit for dice rolls, scales based on option_difficulty_scale
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
(global boolean players_all_dead false)
(global boolean player0_invulnurable false)
(global boolean player1_invulnurable false)
(global boolean player2_invulnurable false)
(global boolean player3_invulnurable false)

;; ---- Game control scripts ---- ;;
; STARTUP SCRIPT - set up the game, start logic to collect options from the player, etc. once player confirms, make any changes needed for options and start the core game loop
(script startup game_setup
    (print "game setup script")
    (set global_game_status 1)

    ; setup...
    (set cheat_deathless_player 1) ; set players to invincible for respawn hack
    (game_set_loadout "preset_initial")

    ; get options...
    ;todo: various device control checks here for each option...

    ; wait for confirmation of options by player...
    (sleep_until (= 1 (device_get_position control_start_game)) 1)

    ; set default global variables and modify stuff based on final options...
    (set wave_enemies_active_max 5)
    (set wave_enemies_per_wave 10)
    (set global_life_count option_starting_lives)
    ; ai infighting alligences...
    ; initial enemy danger multiplier...
    ; initial enemy weirdness multiplier....
    ; calculate initial enemy spawn chances...

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
                (!= wave_enemies_spawned wave_enemies_per_wave)
            )
            (begin 
                ;(print "placing a bad guy!")
                
                ; TEMP FOR TESTING
                ;(wave_spawn_enemy "enc_common/grunt_pp")

                ; roll for an encounter (enemy faction) to spawn from based on if the dice roll lands inside the encounter's current spawn interval
                ; TODO: make calculation with normalized chances between the 3 encounters
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
                ;TODO: figure out if i can normalize whatever spawns are currently possible???
                (set spawner_condition_matched false)
                (set spawner_dice_roll (real_random_range spawner_dice_lower spawner_dice_upper))
                ;COVENANT - 9 squads
                (if (and 
                        (= spawner_next_enc "common")
                        (= spawner_picker_override "enc_main")
                    )
                    (begin 
                        ; 1. hunter - 1
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
                        ; 2. elite hammer - .98
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
                        ; 3. elite stealth - .96
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
                        ; 4. bobomb carrier - .92
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
                        ; 5. elite needler - .87
                        (if (and 
                            (<= .87 spawner_dice_roll)
                            (>= game_difficulty_level .2)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/elite_ne")
                                (set spawner_condition_matched true)
                            )
                        )
                        ; 6. elite plasma rifle - .79
                        (if (and 
                            (<= .79 spawner_dice_roll)
                            (>= game_difficulty_level .05)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/elite_pr")
                                (set spawner_condition_matched true)
                            )
                        )
                        ; 7. jackal plasma pistol - .68
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
                        ; 8. grunt needler - .50
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
                        ; 9. grunt plasma pistol - .50
                        (if (and 
                            ;(<= .40 spawner_dice_roll)
                            (>= game_difficulty_level 0)
                            (= spawner_condition_matched false)
                        )
                            (begin 
                                (wave_spawn_enemy "enc_common/grunt_pp")
                                (set spawner_condition_matched true)
                            )
                        )
                        (if
                            (= spawner_condition_matched false)
                            (begin 
                                (print "***spawner: fell through all spawn cases***")
                                (print "spawner dice roll:")
                                (inspect spawner_dice_roll)
                                (print "enemies danger scale:")
                                (inspect game_difficulty_level)
                                (print "condition matched:")
                                (inspect spawner_condition_matched)
                            )
                        )
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
    (inspect spawner_dice_roll)
    (inspect enc)
)

(script static void wave_start_next
    (print "starting next wave")
    (set wave_in_progress true)
    ; --- update global and wave state variables --- (incrementations and adjusting based on spawn scales)
    ; global wave num
    ; global round num
    ; global set num
    ; global next wave delay
    ; wave enemies per wave
    ; wave enemies spawn delay
    ; wave enemies active max
    ; wave game danger level
    ; wave game weirdness level
    ; spawner lower bound
    
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

    ; --- reset functional vars ---
    (set wave_enemies_spawned 0)

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
        (not (= game_swapping_loadout true))
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
            (object_can_take_damage dead_player)
            (player_set_loadout dead_player "preset_default")
            (object_teleport dead_player "player_respawn_point")
            ; reset dead player vars
            (if (= dead_player (player0)) (set player0_respawning false))
            (if (= dead_player (player1)) (set player1_respawning false))
            (if (= dead_player (player2)) (set player2_respawning false))
            (if (= dead_player (player3)) (set player3_respawning false))

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
    (if (and 
            (= player0_respawning true)
            (= player1_respawning true)
            (= player2_respawning true)
            (= player3_respawning true)
        )
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
            (= global_game_status 2)
            (<= global_life_count 0)
            (= (players_check_all_dead) true)
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

;; --- Debug/testing stuff --- ;;
(script static void test_game
    (set run_game_scripts true)
    (sleep 5)
    (device_set_position control_start_game 1)
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