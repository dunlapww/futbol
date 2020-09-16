require 'csv'
require_relative './stat_tracker'
require_relative './game_teams_manager'
require_relative './game_teams_tackles_manager'
require_relative './manageable'

class GameTeamsTacklesManager < GameTeamsManager
  attr_reader :game_teams_manager

  def initialize(game_teams_manager)
    @game_teams_manager = game_teams_manager
  end

  def team_tackles(season)
    require "pry"; binding.pry
    game_teams_by_season(season).reduce(Hash.new(0)) do |team_season_tackles, game|
      team_season_tackles[game.team_id] += game.tackles
      team_season_tackles
    end
  end

  def most_fewest_tackles(season, method_arg)
    require "pry"; binding.pry
    @stat_tracker.fetch_team_identifier(team_tackles(season).method(method_arg).call do |team|
      team.last
    end.first)
  end

end
