require 'csv'
require_relative './manageable'
require_relative './stat_tracker'
require_relative './game'


class GamesManager
include Manageable
  attr_reader :stat_tracker, :games

  def initialize(path, stat_tracker)
    @stat_tracker = stat_tracker
    @games = []
    create_games(path)
  end

  def create_games(games_table)
    @games = games_table.map do |data|
      Game.new(data)
    end
  end

  def lowest_total_score
    @games.min_by do |game|
      game.total_game_score
    end.total_game_score
  end

  def highest_total_score
    @games.max_by do |game|
      game.total_game_score
    end.total_game_score
  end

  def percentage_home_wins
    wins = @games.count do |game|
      game.home_is_winner?
    end
    ratio(wins, total_games)
  end

  def percentage_visitor_wins
    wins = @games.count do |game|
      game.visitor_is_winner?
    end
    ratio(wins, total_games)
  end

  def total_games(filtered_games = @games)
    filtered_games.count
  end

  def total_game_scores(filtered_games = @games)
    filtered_games.reduce(0) do |sum, game|
      sum += game.total_game_score
    end
  end

  def total_away_goals(filtered_games = @games)
    filtered_games.reduce(0) do |sum, game|
      sum += game.away_goals
    end
  end

  def total_home_goals(filtered_games = @games)
    filtered_games.reduce(0) do |sum, game|
      sum += game.home_goals
    end
  end

  def average_game_scores(filtered_games = @games)
    ratio(total_game_scores(filtered_games), total_games(filtered_games))
  end

  def average_away_goals(filtered_games = @games)
    ratio(total_away_goals(filtered_games), total_games(filtered_games))
  end

  def games_by_visitor
    @games.group_by do |game|
      game.away_team_id
    end
  end

  def avg_goals_by_visitor
    avg_vis_score = {}
    games_by_visitor.each do |visitor_id, games|
      avg_vis_score[visitor_id] = average_away_goals(games)
    end
    avg_vis_score
  end

  def visitor_id_w_min_avg_score
    avg_goals_by_visitor.min_by do |visitor_id, avg_score|
      avg_score
    end[0]
  end
end
