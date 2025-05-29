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
(script continuous gps
    (gps_trilateration)
    (print "x/y/z:")
    (inspect gps_x)
    (inspect gps_y)
    (inspect gps_z)
    (sleep 30)
)