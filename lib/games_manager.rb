require 'csv'
require_relative './stat_tracker'
require_relative './game'
require_relative './manageable'

class GamesManager
  include Manageable

  attr_reader :stat_tracker, :games

  def initialize(path, stat_tracker)
    @stat_tracker = stat_tracker
    @games = create_games(path)
  end

  def create_games(games_table)
    @games = games_table.map do |data|
      Game.new(data)
    end
  end

  def total_score(method_arg)
    @games.method(method_arg).call do |game|
      game.total_game_score
    end.total_game_score
  end

  def percentage_ties
    ties = @games.count do |game|
      !game.home_is_winner? && !game.visitor_is_winner?
    end
    ratio(ties, total_games)
  end

  def percentage_wins(method_arg)
    wins = @games.count do |game|
      game.method(method_arg).call
    end
    ratio(wins, total_games)
  end

  def total_games(games = @games)
    games.count
  end

  def total_goals(games = @games)
    games.sum do |game|
      (game.home_goals + game.away_goals)
    end
  end

  def average_goals_per_game
    ratio(total_goals, total_games)
  end

  def average_goals_by_season
    avg_goals_by_season = {}
    season_group.each do |season, details|
      avg_goals_by_season[season] = ratio(total_goals(details), total_games(details))
    end
    avg_goals_by_season
  end

  def season_group
    @games.group_by do |row|
      row.season
    end
  end

  def game_ids_by_season(season)
    season_group[season].map do |game|
      game.game_id
    end.sort
  end

  def count_of_games_by_season
    count = {}
    season_group.each do |season, games|
      count[season] = games.count
    end
    count
  end

  def team_wins_as(team_id, season, method_arg1, method_arg2)
    season_group[season].find_all do |game|
      (game.method(method_arg1).call == team_id) && (game.method(method_arg2).call)
    end.count
  end

  def total_team_wins(team_id, season)
    team_wins_as(team_id, season, :home_team_id, :home_is_winner?) +
    team_wins_as(team_id, season, :away_team_id, :visitor_is_winner?)
  end

  def season_win_percentage(team_id, season)
    find_percent(total_team_wins(team_id, season), total_team_games_per_season(team_id, season))
  end

  def all_seasons
    season_group.keys.sort
  end

  def total_team_games_per_season(team_id, season)
    season_group[season].find_all do |game|
      game.away_team_id == team_id || game.home_team_id == team_id
    end.count
  end

  def seasons_win_percentages_by_team(team_id)
    all_seasons.reduce({}) do |collector, season|
      collector[season] = season_win_percentage(team_id, season)
      collector
    end
  end

  def worst_or_best_season(team_id, method_arg)
    seasons_win_percentages_by_team(team_id).method(method_arg).call do |season, percent|
      percent
    end[0]
  end

  def get_game(game_id)
    @games.find do |game|
      game.game_id == game_id
    end
  end

  def get_opponent_id(game_id, team_id)
    get_game(game_id).get_opponent_id(team_id)
  end

end
