require "csv"
require_relative "./teams_manager"
require_relative "./games_manager"
require_relative "./game_teams_manager"
require_relative './manageable'

class StatTracker
  include Manageable
  attr_reader :teams_manager, :games_manager, :game_teams_manager

  def initialize(locations)
    @teams_manager = TeamsManager.new(load_csv(locations[:teams]), self)
    @games_manager = GamesManager.new(load_csv(locations[:games]), self)
    @game_teams_manager = GameTeamsManager.new(load_csv(locations[:game_teams]), self)
  end

  def self.from_csv(locations = {games: './data/games_sample.csv', teams: './data/teams_sample.csv', game_teams: './data/game_teams_sample.csv'})
    StatTracker.new(locations)
  end

  def load_csv(path)
    CSV.read(path, headers: true, header_converters: :symbol)
  end

  def fetch_team_identifier(team_id)
    @teams_manager.team_identifier(team_id)
  end

  def fetch_game_ids_by_season(season)
    @games_manager.game_ids_by_season(season)
  end

  def season_group
    @games_manager.season_group
  end

  def get_opponent_id(game_id, team_id)
    @games_manager.get_opponent_id(game_id, team_id)
  end

  def lowest_total_score
    @games_manager.total_score(:min_by)
  end

  def highest_total_score
    @games_manager.total_score(:max_by)
  end

  def percentage_visitor_wins
    @games_manager.percentage_wins(:visitor_is_winner?)
  end

  def percentage_ties
   @games_manager.percentage_ties
  end

  def percentage_home_wins
    @games_manager.percentage_wins(:home_is_winner?)
  end

  def count_of_games_by_season
    @games_manager.count_of_games_by_season
  end

  def average_goals_by_season
    @games_manager.average_goals_by_season
  end

  def average_goals_per_game
    @games_manager.average_goals_per_game
  end

  def worst_offense
    @game_teams_manager.best_worst_offense(:min_by)
  end

  def best_offense
    @game_teams_manager.best_worst_offense(:max_by)
  end

  def count_of_teams
    @teams_manager.count_of_teams
  end

  def highest_scoring_home_team
    @game_teams_manager.highest_lowest_scoring_team("home",:max_by)
  end

  def highest_scoring_visitor
    @game_teams_manager.highest_lowest_scoring_team("away",:max_by)
  end

  def lowest_scoring_visitor
    @game_teams_manager.highest_lowest_scoring_team("away",:min_by)
  end

  def lowest_scoring_home_team
    @game_teams_manager.highest_lowest_scoring_team("home",:min_by)
  end

  def winningest_coach(season)
    coach_hash = @game_teams_manager.coach_game_teams(season)
    @game_teams_manager.highest_lowest_win_percentage(coach_hash,:max_by)
  end

  def worst_coach(season)
    coach_hash = @game_teams_manager.coach_game_teams(season)
    @game_teams_manager.highest_lowest_win_percentage(coach_hash,:min_by)
  end

  def most_tackles(season)
    @game_teams_manager.most_fewest_tackles(season, :max_by)
  end

  def fewest_tackles(season)
    @game_teams_manager.most_fewest_tackles(season, :min_by)
  end

  def most_accurate_team(season)
    @game_teams_manager.most_least_accurate_team(season, :min_by)
  end

  def least_accurate_team(season)
    @game_teams_manager.most_least_accurate_team(season, :max_by)
  end

  def best_season(team_id)
    @games_manager.worst_or_best_season(team_id, :max_by)
  end

  def average_win_percentage(team_id)
    ratio(@game_teams_manager.total_wins(@game_teams_manager.filter_by_team_id(team_id)), @game_teams_manager.total_game_teams(@game_teams_manager.filter_by_team_id(team_id)))
  end

  def worst_season(team_id)
    @games_manager.worst_or_best_season(team_id, :min_by)
  end

  def team_info(team_id)
    @teams_manager.team_info(team_id)
  end

  def most_goals_scored(team_id)
    @game_teams_manager.most_fewest_goals_scored(team_id, :max)
  end

  def fewest_goals_scored(team_id)
    @game_teams_manager.most_fewest_goals_scored(team_id, :min)
  end

  def favorite_opponent(team_id)
    @game_teams_manager.favorite_opponent(team_id)
  end

  def rival(team_id)
    @game_teams_manager.rival(team_id)
  end

end
