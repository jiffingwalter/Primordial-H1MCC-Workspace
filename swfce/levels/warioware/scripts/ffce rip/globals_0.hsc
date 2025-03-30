; Extracted with Reclaimer


; scenario names(each sorted alphabetically)

;   object names:
;     bridge
;     bridge_control
;     cov_equipment_frg1
;     cov_equipment_needler1
;     cov_equipment_needler2
;     cov_equipment_needler3
;     cov_equipment_needler4
;     cov_equipment_needler_ammo1
;     cov_equipment_needler_ammo10
;     cov_equipment_needler_ammo11
;     cov_equipment_needler_ammo2
;     cov_equipment_needler_ammo3
;     cov_equipment_needler_ammo4
;     cov_equipment_needler_ammo5
;     cov_equipment_needler_ammo6
;     cov_equipment_needler_ammo7
;     cov_equipment_needler_ammo8
;     cov_equipment_needler_ammo9
;     cov_equipment_plasma1
;     cov_equipment_plasma10
;     cov_equipment_plasma11
;     cov_equipment_plasma12
;     cov_equipment_plasma13
;     cov_equipment_plasma14
;     cov_equipment_plasma15
;     cov_equipment_plasma2
;     cov_equipment_plasma3
;     cov_equipment_plasma4
;     cov_equipment_plasma5
;     cov_equipment_plasma6
;     cov_equipment_plasma7
;     cov_equipment_plasma8
;     cov_equipment_plasma9
;     cov_equipment_pp1
;     cov_equipment_pp2
;     cov_equipment_pp3
;     cov_equipment_pp4
;     cov_equipment_pp5
;     cov_equipment_pr1
;     cov_equipment_pr2
;     cov_equipment_pr3
;     cov_equipment_pr4
;     cov_equipment_pr5
;     custom_equipment_sentinelbeam1
;     custom_equipment_sentinelbeam2
;     custom_equipment_sword_inf1
;     custom_equipment_sword_inf2
;     custom_equipment_sword_lim1
;     custom_equipment_sword_lim2
;     device_coop_hack
;     digsite_equipment_chain1
;     digsite_equipment_chain2
;     digsite_equipment_ma5ar1
;     digsite_equipment_ma5ar2
;     digsite_equipment_ma5ar3
;     digsite_equipment_ma5ar4
;     digsite_equipment_ma5ar5
;     digsite_equipment_smg1
;     digsite_equipment_smg2
;     digsite_equipment_smg3
;     digsite_equipment_smg4
;     digsite_equipment_smg5
;     digsite_equipment_smg6
;     dropship1
;     dropship2
;     first_beam_emitter
;     hazard_banshee
;     hazard_ghost
;     hazard_wraith
;     intro_tree
;     pod_of_death
;     rifle
;     special_vehicle_banshee
;     special_vehicle_kestrel
;     special_vehicle_scorpion
;     special_vehicle_spectre
;     special_vehicle_wraith
;     starting_equipment_ar1
;     starting_equipment_ar2
;     starting_equipment_ar3
;     starting_equipment_ar4
;     starting_equipment_ar5
;     starting_equipment_ar6
;     starting_equipment_ar_ammo1
;     starting_equipment_ar_ammo2
;     starting_equipment_ar_ammo3
;     starting_equipment_ar_ammo4
;     starting_equipment_ar_ammo5
;     starting_equipment_ff_ammo1
;     starting_equipment_ff_ammo2
;     starting_equipment_ff_ammo3
;     starting_equipment_flame1
;     starting_equipment_frag1
;     starting_equipment_frag10
;     starting_equipment_frag11
;     starting_equipment_frag12
;     starting_equipment_frag13
;     starting_equipment_frag14
;     starting_equipment_frag2
;     starting_equipment_frag3
;     starting_equipment_frag4
;     starting_equipment_frag5
;     starting_equipment_frag6
;     starting_equipment_frag7
;     starting_equipment_frag8
;     starting_equipment_frag9
;     starting_equipment_health1
;     starting_equipment_health2
;     starting_equipment_health3
;     starting_equipment_health4
;     starting_equipment_health5
;     starting_equipment_health6
;     starting_equipment_pist1
;     starting_equipment_pist2
;     starting_equipment_pist3
;     starting_equipment_pist4
;     starting_equipment_pist5
;     starting_equipment_pist6
;     starting_equipment_pist_ammo1
;     starting_equipment_pist_ammo2
;     starting_equipment_pist_ammo3
;     starting_equipment_pist_ammo4
;     starting_equipment_pist_ammo5
;     starting_equipment_rock1
;     starting_equipment_rockets1
;     starting_equipment_rockets2
;     starting_equipment_rockets3
;     starting_equipment_rockets4
;     starting_equipment_shot1
;     starting_equipment_shot2
;     starting_equipment_shot3
;     starting_equipment_shot_ammo1
;     starting_equipment_shot_ammo2
;     starting_equipment_shot_ammo3
;     starting_equipment_shot_ammo4
;     starting_equipment_shot_ammo5
;     starting_equipment_sniper1
;     starting_equipment_sr_ammo1
;     starting_equipment_sr_ammo2
;     starting_equipment_sr_ammo3
;     starting_vehicle_ghost1
;     starting_vehicle_ghost2
;     starting_vehicle_rhog
;     starting_vehicle_warthog

;   trigger volumes:
;     death_barrier_1
;     death_barrier_2
;     death_barrier_3
;     death_barrier_soft_1
;     death_barrier_soft_2
;     spawn_a1_blocker
;     spawn_a2_blocker
;     spawn_b1_blocker
;     spawn_b2_blocker
;     spawn_c1_blocker
;     spawn_c2_blocker
;     spawn_d1_blocker
;     spawn_d2_blocker
;     spawn_e1_blocker
;     spawn_e2_blocker
;     spawn_f1_blocker
;     spawn_f2_blocker
;     spawn_g1_blocker
;     spawn_g2_blocker
;     spawn_h1_blocker
;     spawn_h2_blocker
;     spawn_i1_blocker
;     spawn_i2_blocker
;     spawn_j1_blocker
;     spawn_j2_blocker

;   device groups:
;     bridge_control_position
;     device_coop_hack
;     first_beam_emitter_power_group

;   globals:
(global boolean 1_ai_announced 0)

(global boolean 2_ai_announced 0)

(global boolean 5_ai_announced 0)

(global boolean ai_equipment_drops 1)

(global boolean ai_grenade_use 1)

(global boolean ai_unified_team 0)

(global short allied_weapon_set 0)

(global boolean allies_supported 0)

(global short baze_hazard_chance 20)

(global short blocked_zones_count 0)

(global boolean bonus_enemies_placed_1 0)

(global boolean bonus_enemies_placed_2 0)

(global boolean bonus_enemies_placed_3 0)

(global boolean bonus_enemies_placed_4 0)

(global boolean bonus_random_each_spawn 0)

(global short bonus_squad1_mode_id 1)

(global short bonus_squad1_random_id 0)

(global short bonus_squad2_mode_id 1)

(global short bonus_squad2_random_id 0)

(global short bonus_squad3_mode_id 1)

(global short bonus_squad3_random_id 0)

(global boolean boss_squad_1_mig 0)

(global boolean boss_squad_2_mig 0)

(global short building_squad_number 0)

(global boolean coop_game_chosen 0)

(global boolean coop_p0_dead 0)

(global boolean coop_p1_dead 0)

(global boolean coop_p2_dead 0)

(global boolean coop_p3_dead 0)

(global boolean coop_vehicle_chosen 0)

(global boolean custom_content_enabled 0)

(global boolean digsite_content_enabled 0)

(global short dropship1_dest 0)

(global short dropship2_dest 0)

(global boolean dropships_supported 0)

(global boolean elite_commander_spawned 0)

(global boolean enable_bonus_enemy_spawns 0)

(global boolean enable_bonus_round 0)

(global boolean enable_boss_wave 0)

(global boolean enable_squad_placer 0)

(global boolean enable_wave_manager 0)

(global short final_squad1_mode_id 12)

(global short final_squad2_mode_id 16)

(global short final_squad3_mode_id 18)

(global boolean game_customisation_disabled 0)

(global boolean game_menu_confirm_selection 0)

(global short game_menu_id 0)

(global short game_menu_option_id 0)

(global short game_mode_id 0)

(global boolean game_over_flag 0)

(global long global_delay_music (* 30 300))

(global long global_delay_music_alt (* 30 300))

(global boolean global_dialog_on 0)

(global boolean global_music_on 0)

(global short hazard_chance 20)

(global short hazard_chance_increment 5)

(global short hazard_random_number 0)

(global boolean hazard_spawned 0)

(global boolean hazards_supported 0)

(global boolean hunters_spawned 0)

(global boolean increased_enemy_count_final 0)

(global boolean increased_enemy_count_initial 0)

(global boolean indestructible_vehicles 0)

(global short initial_squad1_mode_id 3)

(global short initial_squad2_mode_id 3)

(global short initial_squad3_mode_id 3)

(global boolean initial_squad_1_mig 0)

(global boolean initial_squad_2_mig 0)

(global boolean invincible_allies 0)

(global short lives_mode_id 3)

(global short lives_remaining 10)

(global boolean marines_use_flashlight 0)

(global short mid_squad1_mode_id 0)

(global short mid_squad2_mode_id 0)

(global short mid_squad3_mode_id 0)

(global short mid_squad4_mode_id 0)

(global short mid_squad5_mode_id 0)

(global short mid_squad6_mode_id 0)

(global short mid_squad7_mode_id 0)

(global short music_track 0)

(global short new_skulls_activated 0)

(global boolean player_active_camo 0)

(global short player_inf_ammo_mode_id 0)

(global short player_pri_weap_id 0)

(global short player_sec_weap_id 1)

(global short player_start_gren_mode_id 1)

(global boolean round_limit_enabled 0)

(global short round_mode_id 0)

(global short round_number 0)

(global short rounds_limit -1)

(global short sarge_1_weapon_id 0)

(global short sarge_2_weapon_id 0)

(global boolean sec_skull_assassins 0)

(global short set_number 0)

(global short shared_random_squad_all_mode 0)

(global short shared_random_squad_cov_mode 0)

(global short shared_random_squad_flood_mode 0)

(global boolean skull_anger_active 0)

(global boolean skull_black_eye_active 0)

(global boolean skull_catch_active 0)

(global boolean skull_cloud_active 0)

(global boolean skull_famine_active 0)

(global short skull_mode_id 1)

(global boolean skull_mythic_active 0)

(global boolean skull_thunderstorm_active 0)

(global boolean skull_tjw_active 0)

(global short skulls_to_activate 0)

(global short soft_kill_counter_p0 0)

(global short soft_kill_counter_p1 0)

(global short soft_kill_counter_p2 0)

(global short soft_kill_counter_p3 0)

(global boolean softkill_barriers_enabled 0)

(global boolean spawn_a_block 0)

(global boolean spawn_b_block 0)

(global boolean spawn_blocks_checked 0)

(global boolean spawn_c_block 0)

(global boolean spawn_d_block 0)

(global boolean spawn_e_block 0)

(global boolean spawn_f_block 0)

(global boolean spawn_g_block 0)

(global boolean spawn_h_block 0)

(global boolean spawn_i_block 0)

(global boolean spawn_j_block 0)

(global boolean spec_elite_spawned 0)

(global boolean squad_a_spawn 0)

(global boolean squad_assigner 0)

(global boolean squad_b_spawn 0)

(global boolean squad_builder_enabled 0)

(global boolean squad_c_spawn 0)

(global boolean squad_customisation_disabled 0)

(global boolean squad_d_spawn 0)

(global boolean squad_e_spawn 0)

(global boolean squad_f_spawn 0)

(global boolean squad_g_spawn 0)

(global boolean squad_h_spawn 0)

(global boolean squad_i_spawn 0)

(global short squad_id_to_spawn 0)

(global boolean squad_j_spawn 0)

(global short squad_menu_string 0)

(global boolean squad_placed 0)

(global boolean squad_selector 0)

(global boolean squads_built_and_assigned 0)

(global boolean start_coop_setup 0)

(global boolean start_game_setup 0)

(global long start_tick_time 0)

(global boolean stealth_elites_spawned 0)

(global boolean suppress_time_announcement 1)

(global long time_limit 3600)

(global boolean time_limit_enabled 0)

(global short time_mode_id 0)

(global boolean unique_bonus_squads 0)

(global boolean use_built_in_enemy_spawns 1)

(global boolean uses_dropships_bonus 1)

(global boolean uses_dropships_final 1)

(global boolean uses_dropships_initial 1)

(global boolean uses_hazards 1)

(global boolean uses_lives 1)

(global short vehicle_mode_id 1)

(global boolean vehicles_supported 0)

(global boolean warned_game_over 0)

(global boolean warned_lives_0 0)

(global boolean warned_lives_1 0)

(global boolean warned_lives_5 0)

(global short wave_number 0)

(global short wave_spawns_random_number 0)

(global short weapon_drops 1)

