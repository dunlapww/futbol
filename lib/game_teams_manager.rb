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

  def create_game_teams(game_teams_table)
    @game_teams = game_teams_table.map do |data|
      GameTeam.new(game_teams_table)
    end
  end
end
