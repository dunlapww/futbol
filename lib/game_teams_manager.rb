require 'csv'
require_relative './stat_tracker'
require_relative './game_team'
require_relative './manageable'

class GameTeamsManager
  include Manageable
  attr_reader :stat_tracker, :game_teams

  def initialize(path, stat_tracker)
    @stat_tracker = stat_tracker
    @game_teams = create_game_teams(path)
  end

  def create_game_teams(game_teams_table)
    @game_teams = game_teams_table.map do |row|
      GameTeam.new(row)
    end
  end

  def total_game_teams(filtered_game_teams = @game_teams)
    filtered_game_teams.count
  end

  def game_teams_by_season(season)
    game_ids = @stat_tracker.fetch_game_ids_by_season(season)
    @game_teams.find_all do |game|
      game_ids.include?(game.game_id)
    end
  end

  def team_tackles(season)
    game_teams_by_season(season).reduce(Hash.new(0)) do |team_season_tackles, game|
      team_season_tackles[game.team_id] += game.tackles
      team_season_tackles
    end
  end

  def most_fewest_tackles(season, method_arg)
    @stat_tracker.fetch_team_identifier(team_tackles(season).method(method_arg).call do |team|
      team.last
    end.first)
  end

  def games_by_team(team_id)
    @game_teams.select do |game|
      game.team_id == team_id
    end
  end

  def team_goals_by_game(team_id)
    games_by_team(team_id).map do |game|
      game.goals
    end
  end

  def most_fewest_goals_scored(team_id, method_arg)
    team_goals_by_game(team_id).method(method_arg).call.to_i
  end

  def home_or_away_games(hoa)
    @game_teams.select do |game|
      game.hoa == hoa
    end
  end

  def hoa_games_by_team_id(hoa)
    home_or_away_games(hoa).group_by do |game_team|
      game_team.team_id
    end
  end

  def total_score(filtered_game_teams = @game_teams)
    filtered_game_teams.reduce(0) do |sum, game_team|
      sum += game_team.goals
    end
  end

  def highest_lowest_scoring_team(hoa,method_arg)
    hoa_team_id = hoa_games_by_team_id(hoa).method(method_arg).call do |team_id, details|
      avg_score(details)
    end[0]
    @stat_tracker.fetch_team_identifier(hoa_team_id)
  end

  def coach_game_teams(season)
    game_teams_by_season(season).group_by do |game_team|
      game_team.head_coach
    end
  end

  def game_teams_by_opponent(team_id)
    filter_by_team_id(team_id).group_by do |gameteam|
      @stat_tracker.get_opponent_id(gameteam.game_id,team_id)
    end
  end

  def average_win_percentage_by(hash)
    hash.map do |group_value, gameteams|
      [group_value, ratio(total_wins(gameteams), total_game_teams(gameteams))]
    end.to_h
  end

  def highest_lowest_win_percentage(hash, method_arg)
    average_win_percentage_by(hash).method(method_arg).call do |group, win_perc|
      win_perc
    end[0]
  end

  def favorite_opponent(team_id)
    hash = game_teams_by_opponent(team_id)
    fave_opp_id = highest_lowest_win_percentage(hash, :max_by)
    @stat_tracker.fetch_team_identifier(fave_opp_id)
  end

  def rival(team_id)
    hash = game_teams_by_opponent(team_id)
    rival_id = highest_lowest_win_percentage(hash, :min_by)
    @stat_tracker.fetch_team_identifier(rival_id)
  end

  def game_ids_per_season(season)
    @stat_tracker.season_group[season].map do |games|
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
      results[game.team_id] += game.shots
      results
    end
  end

  def season_goals(season)
    specific_season = @stat_tracker.season_group[season]
    specific_season.reduce(Hash.new(0)) do |season_goals, game|
      season_goals[game.away_team_id.to_s] += game.away_goals
      season_goals[game.home_team_id.to_s] += game.home_goals
      season_goals
    end
  end

  def shots_per_goal_per_season(season)
    season_goals(season).merge(shots_per_team_id(season)) do |team_id, goals, shots|
      ratio(shots, goals, 3)
    end
  end

  def most_least_accurate_team(season, method_arg)
    most_accurate = shots_per_goal_per_season(season).method(method_arg).call { |team, avg| avg}
    @stat_tracker.fetch_team_identifier(most_accurate[0])
  end

  def total_wins(game_teams)
    game_teams.count do |gameteam|
      gameteam.result == "WIN"
    end
  end

  def filter_by_team_id(team_id)
    @game_teams.select do |gameteam|
      team_id == gameteam.team_id
    end
  end

  def games_containing_team
    @game_teams.reduce(Hash.new(0)) do |games_by_team, game|
      games_by_team[game.team_id] += 1
      games_by_team
    end
  end

  def total_scores_by_team
    @game_teams.reduce(Hash.new(0)) do |base, game|
      base[game.team_id] += game.goals
      base
    end
  end

  def average_scores_by_team
    total_scores_by_team.merge(games_containing_team){|team_id, scores, games_played| ratio(scores, games_played, 3)}
  end

  def best_worst_offense(method_arg1)
    team = average_scores_by_team.method(method_arg1).call {|id, average| average}
    @stat_tracker.fetch_team_identifier(team[0])
  end

  def avg_score(filtered_game_teams = @game_teams)
    ratio(total_score(filtered_game_teams), total_game_teams(filtered_game_teams))
  end

end
