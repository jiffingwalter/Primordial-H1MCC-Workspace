(script startup next_mission
    (sleep_until (= (device_get_position nextmission) 1) 30 120)
    (game_won)
)