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

  def total_games
    @games.count
  end

  def total_game_scores
    @games.reduce(0) do |sum, game|
      sum += game.total_game_score
    end
  end








end
