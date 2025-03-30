;;; SUPER WACKY FUNWARE SCRIPT ;;;
; version 0.0
; created with love and autism by primordial


;; ---- Variables ---- ;;
; Game options set by player on start 
(global short option_ai_infighting 1) ; Do different enemy factions: (0) work together, (1) attack each other, or (2) only focus on the player if they're there
(global short option_minigames 1) ; Minigame wave frequency: (0) none, (1) normal, (2) less, (3) many
(global short option_enemy_amount_scale 1) ; Multiplier for how fast enemy spawn scale increases: (0.5) less, (1) normal, (1.5) more, (2) insane
(global short option_enemy_difficulty_scale 1) ; Multiplier for how many harder enemies appear: (0.5) less, (1) normal, (1.5) more, (2) insane
(global boolean option_spawn_friends true) ; Spawn friendly AI on each set?
(global boolean option_spawn_blocks true) ; Spawn question blocks on each set?
; Functional vars
(global short global_game_status 0) ; 0 - not started, 1 - selecting options, 2 - in progress
(global short global_wave_num 0) ; current wave
(global short global_round_num 0) ; current round
(global short global_set_num 0) ; current set
(global short global_enemies_active_max 0) ; the max amount of enemies to be alive at one time
(global short global_enemies_active_scale 0) ; effects amount of enemies allowed to be active at one time
(global short global_enemies_danger_scale 0) ; effects chances of more dangerous enemies spawning
(global short global_enemies_variation_scale 0) ; effects chances of different enemy faction squads spawning
(global short global_total_difficulty_scale 0) ; all of the scales added into one number
; Wave management vars
(global boolean wave_spawner_on false) ; do we currently want to spawn bad guys?
(global boolean wave_is_minigame false) ; is the current wave a minigame wave?
(global boolean wave_is_boss false) ; is the current wave a boss wave?
(global short wave_enemies_living_count 0) ; current amount of living enemies
(global string wave_spawn_override_encounter "") ; the name of an encounter we're forcing to spawn from (none means random)
(global string wave_spawn_override_squad "") ; the name of a squad we're forcing to spawn from (none means random)


;; ---- Game control scripts ---- ;;
; STARTUP SCRIPT - set up the game, start logic to collect options from the player, etc. once player confirms, make any changes needed for options and start the core game loop
(script startup game_setup
    ; setup...
    ; get options...
    ; wait for confirmation...
    ; start game...
)

; core script - observe game state and take actions as necessary (wave start and stopping, game over)
(script continuous game_loop
    (if (= (global_game_status) 2)
        ; wait for conditions...
    )
    
)

; wave spawn loop - if the spawner is active, roll for encounters and squads to spawn an enemy until the 
(script continuous wave_spawning_loop
    (if (wave_spawner_on)
        ; check for current actors alive, if we're below the current max allowed actors, then...
        ; 1. roll for an encounter (enemy faction) to spawn from
        ; 2. roll for a squad inside that encounter to spawn an enemy
    )
    (sleep 1)
)

(script static void wave_start_next
    ; update global state variables
    ; check if its the next round and/or set
    ; check if its time for minigame or boss wave
    ; re/start wave spawning loop
    ; 
)