;   Script:		Halo Mission C20 Cinematics
; Synopsis:		Cinematics subroutines for C20 script

;- History ---------------------------------------------------------------------

; 05/17/01 - Initial version
; 07/31/01 - Added dialog


;- Globals ---------------------------------------------------------------------

; Print useful debugging text
(global boolean cinematics_debug false)

; Sound control parameters
(global real monitor_dialogue_scale 1)


;- Cinematics ------------------------------------------------------------------

; Beginning of the level
(script stub void cutscene_insertion (print "cutscene_insertion"))
(script static void cinematic_intro
	; Run cinematic in blocking mode
	(cutscene_insertion)
)


; Floor 1, door 1 has finished opening
(script stub void cutscene_extraction (print "cutscene_extraction"))
(script static void cinematic_floor1_door1_opened
	; Run cinematic in blocking mode
	(cutscene_extraction)
)


;- Floor 1 Dialogue Hooks ----------------------------------------------------

(script static void C20_010_Monitor ;;
	(if debug (print "C20_010_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_020_Monitor ;;
	(if debug (print "C20_020_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_040_Monitor ;;
	(if debug (print "C20_040_Monitor - departure"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_depart (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_depart) 60)))
)

(script static void C20_050_Monitor ;;
	(if debug (print "C20_050_Monitor - arrival"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_arrive (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_arrive) 30)))
)

(script static void C20_060_Monitor ;;
	(if debug (print "C20_060_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_flavor_010_Monitor ;;
	(if debug (print "C20_flavor_010_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_flavor_020_Monitor ;;
	(if debug (print "C20_flavor_020_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_flavor_040_Monitor ;;
	(if debug (print "C20_flavor_040_Monitor - amish rant 1"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_flavor_040_Monitor (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (+ (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_flavor_040_Monitor) 30)))
)

(script static void C20_flavor_050_Monitor ;;
	(if debug (print "C20_flavor_050_Monitor - amish rant 2"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_flavor_050_Monitor (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_flavor_050_Monitor) 30)))
)

(script static void C20_130_Monitor ;; I'm reusing this!
	(if debug (print "C20_130_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_flavor_110_Monitor ;;
	(if debug (print "C20_flavor_110_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_070_Monitor ;;
	(if debug (print "C20_070_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_090_Monitor ;;
	(if debug (print "C20_090_Monitor - departure"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_depart (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_depart) 30)))
)

(script static void C20_180_Monitor
	(if debug (print "C20_180_Monitor - player lost"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_180_Monitor (list_get (ai_actors bsp0_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_180_Monitor) 30)))
)


;- Floor 2 Dialogue Hooks ------------------------------------------------------

(script static void C20_120_Monitor ;;
	(if debug (print "C20_120_Monitor - arrival"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_arrive (list_get (ai_actors bsp1_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_arrive) 30)))
)

(script static void C20_140_Monitor ;;
	(if debug (print "C20_140_Monitor - departure"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_depart (list_get (ai_actors bsp1_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_depart) 90)))
)

(script static void C20_flavor_030_Monitor ;;
	(sleep 30)
	(if debug (print "C20_flavor_030_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp1_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_200_Monitor ;;
	(if debug (print "C20_200_Monitor - departure"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_depart (list_get (ai_actors bsp1_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_depart) 30)))
)

(script static void C20_190_Monitor ;;
	(if debug (print "C20_190_Monitor - arrival"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_arrive (list_get (ai_actors bsp1_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_arrive) 30)))
)

(script static void C20_flavor_070_Monitor ;;
	(if debug (print "C20_flavor_070_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp1_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_flavor_060_Monitor ;;
	(if debug (print "C20_flavor_060_Monitor - goat cheese 1"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_flavor_060_Monitor (list_get (ai_actors bsp1_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_flavor_060_Monitor) 30)))
)

(script static void C20_flavor_080_Monitor ;;
	(if debug (print "C20_flavor_080_Monitor - goat cheese 2"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_flavor_080_Monitor (list_get (ai_actors bsp1_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_flavor_080_Monitor) 30)))
)

;- Floor 3 Dialogue Hooks ------------------------------------------------------

(script static void C20_flavor_090_Monitor ;;
	(if debug (print "C20_flavor_090_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp2_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_flavor_150_Monitor ;;
	(if debug (print "C20_flavor_150_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp2_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_135_Monitor ;; I'm reusing this!
	(if debug (print "C20_135_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp2_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_flavor_130_Monitor ;;
	(if debug (print "C20_flavor_130_Monitor - meat grinder 1"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_flavor_130_Monitor (list_get (ai_actors bsp2_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_flavor_130_Monitor) 30)))
)

(script static void C20_flavor_140_Monitor ;;
	(if debug (print "C20_flavor_140_Monitor - meat grinder 2"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_flavor_140_Monitor (list_get (ai_actors bsp2_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_flavor_140_Monitor) 30)))
)

(script static void C20_210_Monitor ;;
	(if debug (print "C20_210_Monitor - departure"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_depart (list_get (ai_actors bsp2_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_depart) 30)))
)

(script static void C20_125_Monitor ;; I'm reusing this!
	(if debug (print "C20_125_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp2_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)


;- Floor 4 Dialogue Hooks ------------------------------------------------------

(script static void C20_flavor_100_Monitor ;;
	(if debug (print "C20_flavor_100_Monitor - random"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_random (list_get (ai_actors bsp3_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_random) 30)))
)

(script static void C20_310_Monitor ;;
	(if debug (print "C20_310_Monitor - wtf is happening"))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_310_Monitor (list_get (ai_actors bsp3_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_310_Monitor) 30)))
)

(script static void C20_320_Monitor ;;
	(if debug (print "C20_320_Monitor - if you think im gonna eat this..."))
	(sound_impulse_start swfce\sound\dialog\jerma\c20\C20_320_Monitor (list_get (ai_actors bsp3_monitor) 0) monitor_dialogue_scale)
	(sleep (max 0 (- (sound_impulse_time swfce\sound\dialog\jerma\c20\C20_320_Monitor) 30)))
)


;- Flavor Dialogue Hooks -------------------------------------------------------

(script static void C20_flavor_120_Monitor 
	(print "Monitor: This Construct's research facilities are, of course, most impressive. Perhaps you will have time to reaquaint yourself to them soon.")
)

(script static void C20_195_Monitor ; I'm reusing this(?)
	(print "Monitor: I am gratified to see you. You should remain with me. ")
)


;- Music Control ---------------------------------------------------------------

; Scale controls
(global real music_01_scale 1)
(global real music_02_scale 1)
(global real music_03_scale 1)
(global real music_04_scale 1)

; Play controls
(global boolean music_01_base false)
(global boolean music_02_base false)
(global boolean music_03_base false)
(global boolean music_04_base false)

(script static void music_01 
	; Wait for it... waaaait for it... then begin music
	(sleep_until music_01_base)
	(if debug (print "Music O1 Start"))
	(sound_looping_start "swfce\levels\c20\music\c20_01" none music_01_scale)

	; Stop?
	(sleep_until (not music_01_base))
	(if debug (print "Music O1 End"))
	(sound_looping_stop "swfce\levels\c20\music\c20_01")
)

(script static void music_02 
	; Wait for it... waaaait for it... then begin music
	(sleep_until music_02_base)
	(if debug (print "Music O2 Start"))
	(sound_looping_start "swfce\levels\c20\music\c20_02" none music_02_scale)

	; Stop?
	(sleep_until (not music_02_base))
	(if debug (print "Music O2 End"))
	(sound_looping_stop "swfce\levels\c20\music\c20_02")
)

(script static void music_03 
	; Wait for it... waaaait for it... then begin music
	(sleep_until music_03_base)
	(if debug (print "Music O3 Start"))
	(sound_looping_start "swfce\levels\c20\music\c20_03" none music_03_scale)

	; Stop?
	(sleep_until (not music_03_base))
	(if debug (print "Music O3 End"))
	(sound_looping_stop "swfce\levels\c20\music\c20_03")
)

(script static void music_04 
	; Wait for it... waaaait for it... then begin music
	(sleep_until music_04_base)
	(if debug (print "Music O4 Start"))
	(sound_looping_start "swfce\levels\c20\music\c20_04" none music_04_scale)

	; Stop?
	(sleep_until (not music_04_base))
	(if debug (print "Music O4 End"))
	(sound_looping_stop "swfce\levels\c20\music\c20_04")
)

(script dormant music_control
	(music_01)
	(music_02)
	(music_03)
	(music_04)
)

