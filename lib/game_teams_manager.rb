require 'csv'
require_relative './stat_tracker'
require_relative './game_team'
require './lib/manageable'

class GameTeamsManager
  attr_reader :stat_tracker, :game_teams

  def initialize(path, stat_tracker)
    @stat_tracker = stat_tracker
    @game_teams = []
    create_game_teams(path)
  end

  def create_game_teams(path)
    @game_teams = path.map do |data|
      GameTeam.new(data, self)
    end
  end

  def home_or_away_games(where = "home")
    @game_teams.select do |game|
      game.hoa == where
    end
  end


end
