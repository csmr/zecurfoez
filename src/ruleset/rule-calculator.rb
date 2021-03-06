#!/usr/bin/env ruby

puts 'RULE CALCULATOR'

# Design Doc chapter parameters
limits = {
  # • Time-limit vs Movement Turns: Number/time of moves required to visit of 33% of Sectors
  # DD 4.9.1. 12 minute time limit
  :time_max_s => 720,
  # DD 4.9.2
  :time_turn_len_s => 17,
  # DD 4.9.3
  :time_days_per_turn => 17,
  # DD 4.1.1. able to visit 33% of sectors
  :sectors_visited_min => 0.33,

}

defaults = {
  # • Sector size: the game board size, the world grid resolution.
  # DD 3.2.2. 40x40 game board
  :sector_grid => 36,

  # DD 4.1.
  # • Movement cost: negative multiplier from elevation (unit_v - elev_km * multi)
  :movement_elevation_multiplier_per_km => 66,

  # • Polar latitude cost: reduction multiplier unit_v * (multi * min(0, (deg-tres)))
  :movement_reduction_latitude_treshold => 60,
  :movement_reduction_latitude_per_degree => 2,

  # • Lidar resolution: the rendering elevation interval, and polygonal resolution, to ensure clear visuals.
  :reso_lidar_elev_m => 5
}

# Game instance parameters
Session = Struct.new(:view, :players, :rule_set, :turn)
Ruleset = Struct.new(:turn_mode, :turn_lenght, :session_lenght)
Vote = Struct.new(:last_powerstructure_bool, :head_of_chiefs_bool, :fast_mode_bool, :beginner_mode_bool, :turn_per_day_bool)

# In-game-object mocks
World = Struct.new(:size, :circumference_km)
Unit = Struct.new(:type, :society, :work_hours, :velocity_kmh)

# Instance mocks
worlds = {
  :small => World.new(40, 10000),
  :medium => World.new(160, 40000),
  :large => World.new(640, 120000)
}

# DD 4.3.
head = Unit.new("Head", nil, 14, 120)

puts "RESULTS"
puts "Iteration 1 result: sector size mapped on a World globe is a wack idea. Since the scenario is post-mini-apocalypse, and tech-tree doesn't allow fast travel, gameplay should not be based on units traveling a lot of ground. Emphasis on lidar & network capacities, charm ability and social dynamic, plus reducing entropy."
puts "Sectors should simply represent some angle of the World globe. For arena subdivision, 18x18 might be enough, 10 degree. Further, the sectors area is smaller towards the polar caps. The DD and rule calculator should be updated to represent this."
puts "_"
puts "DD 4.1.1. - time/moves required for minimum sectors"
sectors = defaults[:sector_grid]**2 
sector_side_km = worlds[:medium][:circumference_km]/defaults[:sector_grid]
sector_visit_min = sectors * limits[:sectors_visited_min]
travel_min_km = sector_side_km * sector_visit_min 
travel_time_min_d = travel_min_km / (head[:work_hours] * head[:velocity_kmh])
travel_time_min_turns = (travel_time_min_d/limits[:time_days_per_turn]).to_int
puts "Head-unit time to travel #{sector_visit_min.to_int} of #{sectors} sectors (no elevation/lati multi):"
puts "#{travel_time_min_d.to_int} days, #{travel_time_min_turns} turns, #{(limits[:time_turn_len_s]*travel_time_min_turns)/60} minutes."
puts "_"
puts "DD 4.9. - Temporal Mechanics"
turns_min = limits[:time_max_s]/limits[:time_turn_len_s]
puts "For a #{limits[:time_max_s]/60} minute game, #{turns_min*limits[:time_days_per_turn]} in-world days." 
puts "Minimum number of turns #{turns_min}."


#pseudo game logic to mock resultant gameplay
#f.ex. mock_gameplay(buildingRandomizer)
#      Society.new(players_head, building)

#ESTIMATE SCORE:
#  Unit travel score
#  memory & cpu req
#  rule sanity score
#  game_winnable