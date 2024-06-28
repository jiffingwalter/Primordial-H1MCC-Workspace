(script startup next_mission
    (sleep_until (= (device_get_position nextmission) 1))
    (game_won)
)