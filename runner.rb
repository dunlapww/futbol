require './lib/stat_tracker'

game_path = './data/games.csv'
team_path = './data/teams.csv'
game_teams_path = './data/game_teams.csv'

game_path_sample = './data/games_sample.csv'
team_path_sample = './data/teams_sample.csv'
game_teams_path_sample = './data/game_teams_sample.csv'

locations = {
  games: game_path,
  teams: team_path,
  game_teams: game_teams_path
}

locations_sample = {
  games: game_path_sample,
  teams: team_path_sample,
  game_teams: game_teams_path_sample
}

stat_tracker_sample = StatTracker.from_csv(locations_sample)
# stat_tracker = StatTracker.from_csv(locations)



# print stat_tracker_sample.total_home_goals
# print stat_tracker_sample.total_away_goals
# print stat_tracker_sample.total_games
# puts ""
# puts stat_tracker_sample.average_goals_per_game
# print stat_tracker_sample.season_group
print stat_tracker_sample.goals_by_season
puts  ""
print stat_tracker_sample.games_by_season
puts  ""
print stat_tracker_sample.average_goals_by_season
puts  ""
print stat_tracker_sample.total_avg_goals
