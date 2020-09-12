require "csv"
require_relative "./teams_manager"
require_relative "./games_manager"
require_relative "./game_teams_manager"

class StatTracker
  attr_reader :teams_manager, :games_manager, :game_teams_manager

  def initialize(locations)
    load_managers(locations)
  end

  def self.from_csv(locations = {games: './data/games_sample.csv', teams: './data/teams_sample.csv', game_teams: './data/game_teams_sample.csv'})
    StatTracker.new(locations)
  end

  def load_managers(locations)
    @teams_manager = TeamsManager.new(load_csv(locations[:teams]), self)
    @games_manager = GamesManager.new(load_csv(locations[:games]), self)
    @game_teams_manager = GameTeamsManager.new(load_csv(locations[:game_teams]), self)
  end

  def load_csv(path)
    CSV.read(path, headers: true, header_converters: :symbol)
  end

# ~~~ Helper Methods ~~~~
  # move to GameManager
  def total_games(filtered_games = @games)
    filtered_games.count
  end

  # potential module (math?)
  def find_percent(numerator, denominator)
    return 0.0 if denominator == 0
    (numerator / denominator.to_f * 100).round(2)
  end

  # # move to GameManager call on score sum for each game
  # # maybe remove season filter?
  # # add method in game class that sums total game score
  # def sum_game_goals(season = nil)
  #   game_goals_hash = {}
  #   season_games = filter_by_season(season)
  #   season_games.each do |game|
  #     game_goals_hash[game.game_id] = (game.away_goals + game.home_goals)
  #   end
  #   game_goals_hash
  # end

  # potential module, perhaps GameTeams
  def season_group
    @games.group_by do |row|
      row.season
    end
  end

  # move to GameManager
  def total_goals(filtered_games = @games)
    filtered_games.reduce(0) do |sum, game|
      sum += (game.home_goals + game.away_goals)
    end
  end

  # potential module (math?)
  def ratio(numerator, denominator)
    (numerator.to_f / denominator).round(2)
  end

  # Move to GameManager
  def seasonal_game_data
    seasonal_game_data = @games.group_by do |game|
      game.season
    end
    seasonal_game_data
  end

  # Move to GameTeamsManager
  def total_scores_by_team
    base = Hash.new(0)
    @game_teams.each do |game|
      key = game.team_id.to_s
      base[key] += game.goals
    end
    base
  end

  # Move to GameTeamsManager
  # I don't think this method is doing what it is supposed to be doing
  def average_scores_by_team
    total_scores_by_team.merge(games_containing_team){|team_id, scores, games_played| (scores.to_f / games_played).round(2)}
  end

  # Move to GameTeamsManager
  def games_containing_team
    games_by_team = Hash.new(0)
    @game_teams.each do |game|
      games_by_team[game.team_id.to_s] += 1
    end
    games_by_team
  end

  # Move to TeamsManager
  # This method has a duplicate (team_id_to_team_name)
  def team_names_by_team_id(id)
    team_id_hash = {}
    @teams.each do |team|
      team_id_hash[team.team_id.to_s] = team.team_name
    end
    team_id_hash[id.to_s]
  end

  # Move to GamesManager
  def filter_by_season(season)
    @games.find_all do |game|
      game.season == season
    end
  end

  # Move to GameTeamsManager
  def team_wins_as_home(team_id, season)
    season_group[season].find_all do |game|
      (game.home_team_id == team_id) && (game.home_goals > game.away_goals)
    end.count
  end

  # Move to GameManager
  def team_wins_as_away(team_id, season)
    season_group[season].find_all do |game|
      (game.away_team_id == team_id) && (game.away_goals > game.home_goals)
    end.count
  end

  # Move to GameManager
  def total_team_wins(team_id, season)
    team_wins_as_home(team_id, season) + team_wins_as_away(team_id, season)
  end

  # Move to GamesManager
  def total_team_games_per_season(team_id, season)
    season_group[season].select do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end.count
  end

  # Move to GamesManager
  def season_win_percentage(team_id, season)
    find_percent(total_team_wins(team_id, season), total_team_games_per_season(team_id, season))
  end

  # Move to Team
  def team_ids
    @teams.map do |team|
      team.team_id
    end.sort
  end

  # Move to GameTeamsManager for team_id purposes
  # season is pulled from Game, however
  def all_teams_win_percentage(season)
    percent_wins = {}
    team_ids.each do |team_id|
      percent_wins[team_id] = season_win_percentage(team_id, season)
    end
    percent_wins
  end

  # Move to GamesManager
  def winningest_team(season)
    all_teams_win_percentage(season).max_by do |team_id, win_percentage|
      win_percentage
    end.first
  end

  # Move to GamesManager
  def worst_team(season)
    all_teams_win_percentage(season).min_by do |team_id, win_percentage|
      win_percentage
    end.first
  end

  # Move to GameTeamsManager
  # Doesn't have a test
  def total_game_teams(filtered_game_teams = @game_teams)
    filtered_game_teams.count
  end

  # Move to GameTeamsManager
  # Doesn't have a test
  def avg_score(filtered_game_teams = @game_teams)
    ratio(total_score(filtered_game_teams), total_game_teams(filtered_game_teams))
  end

  # Move to TeamManager
  # This method has duplicates (team_names_by_team_id, team_id_to_team_name)
  def team_id_to_team_name(id)
    team_obj = @teams.select do |team|
      team.team_id == id
    end
    team_obj[0].team_name
  end

  # This could potentially be replaced by sum_game_goals or vise versa
  # Doesn't have test
  def total_score(filtered_game_teams = @game_teams)
    total_score = filtered_game_teams.reduce(0) do |sum, game_team|
      sum += game_team.goals
    end
  end

  # Move to GameTeamsManager
  # THIS METHOD PENDING DELETION
  # using instead: home_or_away_games
  def home_games
    @game_teams.select do |game|
      game.hoa == "home"
    end
  end

  # Move to GameTeamsManager
  # THIS METHOD PENDING DELETION
  # using instead: home_or_away_games
  def away_games
    @game_teams.select do |game_team|
      game_team.hoa == "away"
    end
  end

  #Move to GameTeamsManager
  #Need a vertical call up for Team_ID
  # home_games method used inside will be changed to: home_or_away_games
  def home_games_by_team
    home_games.group_by do |game_team|
      game_team.team_id
    end
  end

  #Move to GameTeamsManager
  #Need a vertical call up for Team_ID
  # away_games method used inside will be changed to: home_or_away_games
  def away_games_by_team
    away_games.group_by do |game_team|
      game_team.team_id
    end
  end

  # This should be refactored fo sho  (takes a long time to run)
  # Currently it cycles through all games just to return an arrray
  # of unique seasons
  # But, should be moved to GamesManger
  def all_seasons
    unique_seasons = []
    @games.each do |game|
      if !unique_seasons.include?(game.season)
        unique_seasons << game.season
      end
    end
    unique_seasons.sort
  end

  # Also needs refactored - maybe don't need to return hash?
  # Or use reduce?
  # Move to GamesManager
  def all_teams_all_seasons_win_percentages
    win_percentages_by_season = {}
    all_seasons.each do |season|
      team_ids.each do |team_id|
        if win_percentages_by_season[team_id] == nil
          win_percentages_by_season[team_id] = {season =>
            season_win_percentage(team_id, season)}
        else
          win_percentages_by_season[team_id][season] =
          season_win_percentage(team_id, season)
        end
      end
    end
    win_percentages_by_season
  end

  # This looks like it combines home_games and away_games - keep this one?
  # Move to GameTeams Manager
  # Doesn't have a test
  def home_or_away_games(where = "home")
    @game_teams.select do |game|
      game.hoa == where
    end
  end

  # Move to GamesTeamsManager
  def hoa_games_by_team_id(hoa)
    home_or_away_games(hoa).group_by do |game_team|
      game_team.team_id
    end
  end

  # Move to GameTeamsManager
  def lowest_scoring_team_id(hoa)
    hoa_games_by_team_id(hoa).min_by do |team_id, details|
      avg_score(details)
    end[0]
  end

  # Move to TeamsManager
  # This method has duplicates (team_names_by_team_id, team_id_to_team_name)
  def team_id_to_team_name(id)
    @teams.each do |team|
      return team.team_name if team.team_id == id
    end
  end

  # Move to GameTeamsManager
  def total_wins(game_teams_filtered = @game_teams)
    game_teams_filtered.count do |gameteam|
      gameteam.result == "WIN"
    end
  end

  # Move to GameTeamsManager
  # Duplicate method to get_game method except pulls from GameTeams instead of
  # Games
  def filter_by_teamid(id)
    @game_teams.select do |game_team|
      game_team.team_id == id
    end
  end

  # Move to GameTeamsManager
  # Need to convert to common naming convention
  def avg_win_perc_by_opp(teamid)
    awp_by_opp = {}
    game_teams_by_opponent(teamid).each do |opponent, gameteams|
      awp_by_opp[opponent] = find_percent(total_wins(gameteams), total_game_teams(gameteams))
    end
    awp_by_opp
  end

  # Move to GameTeamsManager
  def fave_opponent_id(teamid)
    avg_win_perc_by_opp(teamid).max_by do |opponent, win_perc|
      win_perc
    end[0]
  end

  # Move to GameTeamsManager
  def rival_id(teamid)
    avg_win_perc_by_opp(teamid).min_by do |opponent, win_perc|
      win_perc
    end[0]
  end

  # Move to GameTeamsManager
  def game_teams_by_opponent(teamid)
    gt_by_opp = {}
    filter_by_teamid(teamid).each do |gameteam|
      if gt_by_opp[get_opponent_id(get_game(gameteam.game_id), teamid)]
        gt_by_opp[get_opponent_id(get_game(gameteam.game_id), teamid)] << gameteam
      else
        gt_by_opp[get_opponent_id(get_game(gameteam.game_id), teamid)] = [gameteam]
      end
    end
    gt_by_opp
  end

  # Move to GamesManger
  # This is a duplicate method to filter_by_teamid except pulls from games
  # instead of GameTeams
  def get_game(gameid)
    @games.find do |game|
      game.game_id == gameid
    end
  end

  # Move to GameTeamsManager
  #Duplicate method to filter_by_teamid
  def games_by_team(team_id)
    @game_teams.select do |game|
      game.team_id == team_id
    end
  end

  def get_opponent_id(game, teamid)
    game.away_team_id == teamid ? game.home_team_id : game.away_team_id
  end

  def game_ids_per_season(season)
    specific_season = season_group[season]
    specific_season.map do |games|
      games.game_id
    end
  end

  def find_game_teams(game_ids)
    game_ids.flat_map do |game_id|
      @game_teams.find_all do |game|
        game_id == game.game_id
      end
    end
  end

  def shots_per_team_id(season)
    game_search = find_game_teams(game_ids_per_season(season))
    game_search.reduce(Hash.new(0)) do |results, game|
      results[game.team_id.to_s] += game.shots
      results
    end
  end

  def season_goals(season)
    specific_season = season_group[season]
    specific_season.reduce(Hash.new(0)) do |season_goals, game|
      season_goals[game.away_team_id.to_s] += game.away_goals
      season_goals[game.home_team_id.to_s] += game.home_goals
      season_goals
    end
  end

  def shots_per_goal_per_season(season)
    season_goals(season).merge(shots_per_team_id(season)) do |team_id, goals, shots|
      (shots.to_f / goals).round(2)
    end
  end

  # Move to GamesManager
  def get_opponent_id(game, teamid)
    game.away_team_id == teamid ? game.home_team_id : game.away_team_id
  end

  def game_ids_by_season(season)
    filter_by_season(season).map do |game|
      game.game_id
    end.sort
  end

  # Move to GameTeamsManager
  def team_tackles(season)
    team_season_tackles = {}
    games = @game_teams.find_all do |game|
      game_ids_by_season(season).include?(game.game_id)
    end
    games.each do |game|
      if team_season_tackles[game.team_id]
        team_season_tackles[game.team_id] += game.tackles
      else
        team_season_tackles[game.team_id] = game.tackles
      end
    end
    team_season_tackles
  end

  # Move to Teams Manager
  def team_identifier(team_id)
    @teams.find do |team|
      team.team_id == team_id
    end.team_name
  end

  # Move to GameTeamsManager
  def team_goals_by_game(team_id)
    games_by_team(team_id).map do |game|
      game.goals
    end
  end

# ~~~ Game Methods ~~~
  def lowest_total_score
    @games_manager.lowest_total_score
  end

  def highest_total_score
    @games_manager.highest_total_score
  end

  #Rename to percentage_visitor_wins
  def percentage_visitor_wins
    wins = @games.find_all { |game| game.away_goals > game.home_goals}
    find_percent(wins.count, total_games)
  end

  def percentage_ties
    ties = @games.find_all { |game| game.away_goals == game.home_goals}
    find_percent(ties.count, total_games)
  end

  def percentage_home_wins
    wins = @games.find_all { |game| game.away_goals < game.home_goals}
    find_percent(wins.count, total_games)
  end

  def count_of_games_by_season
    count = {}
    season_group.each do |season, games|
      count[season] = games.count
    end
    count
  end

  def avg_goals_by_season
    avg_goals_by_season = {}
    seasonal_game_data.each do |season, details|
      avg_goals_by_season[season] = ratio(total_goals(details), total_games(details))
    end
    avg_goals_by_season
  end

  def avg_goals_per_game
    ratio(total_goals, total_games)
  end

# ~~~ LEAGUE METHODS~~~
  def worst_offense
    worst = average_scores_by_team.min_by {|id, average| average}
    team_names_by_team_id(worst[0])
  end

  def best_offense
    best = average_scores_by_team.max_by {|id, average| average}
    team_names_by_team_id(best[0])
  end

  def count_of_teams
    @teams.count
  end

  def highest_scoring_home_team
    highest_scoring_home_team = home_games_by_team.max_by do |team_id, details|
      avg_score(details)
    end[0]
    team_id_to_team_name(highest_scoring_home_team)
  end

  def highest_scoring_visitor
    highest_scoring_visitor = away_games_by_team.max_by do |team_id, details|
      avg_score(details)
    end[0]
    team_id_to_team_name(highest_scoring_visitor)
  end

  def lowest_scoring_visitor_team
    team_id_to_team_name(lowest_scoring_team_id("away"))
  end

  def lowest_scoring_home_team
    team_id_to_team_name(lowest_scoring_team_id("home"))
  end

# ~~~ SEASON METHODS~~~

  def winningest_coach(season)
    @game_teams.find do |game_team|
      game_team.team_id == winningest_team(season)
    end.head_coach
  end

  def worst_coach(season)
    @game_teams.find do |game_team|
      game_team.team_id == worst_team(season)
    end.head_coach
  end

  def most_tackles(season)
    team_identifier(team_tackles(season).max_by do |team|
      team.last
    end.first)
  end

  def fewest_tackles(season)
    team_identifier(team_tackles(season).min_by do |team|
      team.last
    end.first)
  end

  def most_accurate_team(season)
    most_accurate = shots_per_goal_per_season(season).min_by { |team, avg| avg}
    team_names_by_team_id(most_accurate[0])
  end

  def least_accurate_team(season)
    least_accurate = shots_per_goal_per_season(season).max_by { |team, avg| avg}
    team_names_by_team_id(least_accurate[0])
  end

# ~~~ TEAM METHODS~~~

  def best_season(team_id)
    all_teams_all_seasons_win_percentages.flat_map do |team, seasons|
      if team == team_id
        seasons.max_by do |season|
          season.last
        end
      end
    end.compact.first
  end

  # This is a duplicate method as average_win_percentage(id)
  def average_win_percentage(teamid)
    find_percent(total_wins(filter_by_teamid(teamid)), total_game_teams(filter_by_teamid(teamid)))
  end

  def favorite_opponent(teamid)
    team_id_to_team_name(fave_opponent_id(teamid))
  end

  def rival(teamid)
    team_id_to_team_name(rival_id(teamid))
  end

  def worst_season(team_id)
    all_teams_all_seasons_win_percentages.flat_map do |team, seasons|
      if team == team_id
        seasons.min_by do |season|
          season.last
        end
      end
    end.compact.first
  end

  # This is a duplicate method as average_win_percentage(teamid)
  def average_win_percentage(id)
    find_percent(total_wins(filter_by_teamid(id)), total_game_teams(filter_by_teamid(id)))
  end

  def team_info(team_id)
    team_string = team_id.to_s
    team_string = {}
    @teams.each do |team|
      if team.team_id == team_id
        team_string[:team_id] = team.team_id
        team_string[:franchise_id] = team.franchise_id
        team_string[:team_name] = team.team_name
        team_string[:abbreviation] = team.abbreviation
        team_string[:stadium] = team.stadium
        team_string[:link] = team.link
      end
    end
    team_string
  end

  def most_goals_scored(team_id)
    team_goals_by_game(team_id).max
  end

  def fewest_goals_scored(team_id)
    team_goals_by_game(team_id).min
  end
end
