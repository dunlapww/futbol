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

  def fetch_all_team_ids
    @teams_manager.all_team_ids
  end

  def fetch_season_win_percentage(team_id, season)
    @games_manager.season_win_percentage(team_id, season)
  end

  def fetch_team_identifier(team_id)
    @teams_manager.team_identifier(team_id)
  end

  def fetch_game_ids_by_season(season)
    @games_manager.game_ids_by_season(season)
  end

  def total_games(filtered_games = @games_manager.games)
    @games_manager.total_games
  end

  def total_goals(filtered_games = @games_manager.games)
    @games_manager.total_goals(filtered_games)
  end

  def season_group
    @games_manager.season_group
  end

  def total_scores_by_team
    @game_teams_manager.total_scores_by_team
  end

  def average_scores_by_team
    @game_teams_manager.average_scores_by_team
  end

  def games_containing_team
    @game_teams_manager.games_containing_team
  end

  def avg_score(filtered_game_teams = @game_teams)
    @game_teams_manager.avg_score(filtered_game_teams)
  end

  def team_id_to_team_name(team_id)
    @teams_manager.team_identifier(team_id)
  end

  def filter_by_team_id(team_id)
    @game_teams_manager.filter_by_team_id(team_id)
  end

  def game_teams_by_opponent(team_id)
    @game_teams_manager.game_teams_by_opponent(team_id)
  end

  def get_game(game_id)
    @games_manager.get_game(game_id)
  end

  def get_opponent_id(game_id, team_id)
    @games_manager.get_opponent_id(game_id, team_id)
  end

  def game_ids_per_season(season)
    @game_teams_manager.game_ids_per_season(season)
  end

  def find_game_teams(game_ids)
    @game_teams_manager.find_game_teams(game_ids)
  end

  def shots_per_team_id(season)
    @game_teams_manager.shots_per_team_id(season)
  end

  def shots_per_goal_per_season(season)
    @game_teams_manager.shots_per_goal_per_season(season)
  end

  def lowest_total_score
    @games_manager.lowest_total_score
  end

  def highest_total_score
    @games_manager.highest_total_score
  end

  def percentage_visitor_wins
    @games_manager.percentage_visitor_wins
  end

  def percentage_ties
   @games_manager.percentage_ties
  end

  def percentage_home_wins
    @games_manager.percentage_home_wins
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
    @game_teams_manager.worst_offense
  end

  def best_offense
    @game_teams_manager.best_offense
  end

  def count_of_teams
    @teams_manager.count_of_teams
  end

  def highest_scoring_home_team
    @game_teams_manager.highest_scoring_home_team
  end

  def highest_scoring_visitor
    @game_teams_manager.highest_scoring_visitor
  end

  def lowest_scoring_visitor
    @game_teams_manager.lowest_scoring_visitor
  end

  def lowest_scoring_home_team
    @game_teams_manager.lowest_scoring_home_team
  end

  def winningest_coach(season)
    @game_teams_manager.winningest_coach(season)
  end

  def worst_coach(season)
    @game_teams_manager.worst_coach(season)
  end

  def most_tackles(season)
    @game_teams_manager.most_tackles(season)
  end

  def fewest_tackles(season)
    @game_teams_manager.fewest_tackles(season)
  end

  def most_accurate_team(season)
    @game_teams_manager.most_accurate_team(season)
  end

  def least_accurate_team(season)
    @game_teams_manager.least_accurate_team(season)
  end

  def best_season(team_id)
    @games_manager.best_season(team_id)
  end

  def average_win_percentage(team_id)
    ratio(@game_teams_manager.total_wins(@game_teams_manager.filter_by_team_id(team_id)), @game_teams_manager.total_game_teams(@game_teams_manager.filter_by_team_id(team_id)))
  end

  def worst_season(team_id)
    @games_manager.worst_season(team_id)
  end

  def team_info(team_id)
    @teams_manager.team_info(team_id)
  end

  def most_goals_scored(team_id)
    @game_teams_manager.most_goals_scored(team_id)
  end

  def fewest_goals_scored(team_id)
    @game_teams_manager.fewest_goals_scored(team_id)
  end

  def favorite_opponent(team_id)
    fetch_team_identifier(@game_teams_manager.highest_win_percentage(@game_teams_manager.game_teams_by_opponent(team_id)))
  end

  def rival(team_id)
    fetch_team_identifier(@game_teams_manager.lowest_win_percentage(@game_teams_manager.game_teams_by_opponent(team_id)))
  end
end
