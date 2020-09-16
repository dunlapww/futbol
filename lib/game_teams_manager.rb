require 'csv'
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
    @game_teams.select do |gameteam|
      gameteam.game_id[0..3] == season[0..3]
    end
  end

  def games_by_team(team_id)
    @game_teams.select do |game|
      game.team_id == team_id
    end
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

  def game_teams_by_team_id(season)
    game_teams_by_season(season).group_by do |gameteam|
      gameteam.team_id
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

end
