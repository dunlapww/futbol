require "csv"
require "./lib/team"
require "./lib/game"
require "./lib/game_team"

class StatTracker
  attr_reader :teams, :games, :game_teams

  def initialize(teams, games, game_teams)
    @teams = teams
    @games = games
    @game_teams = game_teams
  end

  def self.from_csv(locations = {games: './data/games_sample.csv', teams: './data/teams_sample.csv', game_teams: './data/game_teams_sample.csv'})
    Game.from_csv(locations[:games])
    Team.from_csv(locations[:teams])
    GameTeam.from_csv(locations[:game_teams])
    self.new(Team.all_teams, Game.all_games, GameTeam.all_game_teams)
  end

# ~~~ Helper Methods ~~~~

  def total_games(filtered_games = @games)
    filtered_games.count
  end

  def find_percent(numerator, denominator)
    (numerator / denominator.to_f * 100).round(2)
  end

  def sum_game_goals(season = nil)
    game_goals_hash = {}
    season_games = filter_by_season(season)
    season_games.each do |game|
      game_goals_hash[game.game_id] = (game.away_goals + game.home_goals)
    end
    game_goals_hash
  end

  def season_group
    @games.group_by do |row|
      row.season
    end
  end

  def total_goals(filtered_games = @games)
    filtered_games.reduce(0) do |sum, game|
      sum += (game.home_goals + game.away_goals)
    end
  end

  def ratio(numerator, denominator)
    (numerator.to_f / denominator).round(2)
  end

  def seasonal_game_data
    seasonal_game_data = @games.group_by do |game|
      game.season
    end
    seasonal_game_data
  end

  def total_scores_by_team
    base = Hash.new(0)
    @game_teams.each do |game|
      key = game.team_id.to_s
      base[key] += game.goals
    end
    base
  end

  def average_scores_by_team
    total_scores_by_team.merge(games_containing_team){|team_id, scores, games_played| (scores.to_f / games_played).round(2)}
  end

  def games_containing_team
    games_by_team = Hash.new(0)
    @game_teams.each do |game|
      games_by_team[game.team_id.to_s] += 1
    end
    games_by_team
  end

  def team_names_by_team_id(id)
    team_id_hash = {}
    @teams.each do |team|
      team_id_hash[team.team_id.to_s] = team.team_name
    end
    team_id_hash[id.to_s]
  end

  def filter_by_season(season)
    @games.find_all do |game|
      game.season == season
    end
  end

  def team_wins_as_home(team_id, season)
    @games.find_all do |game|
      game.home_team_id == team_id && game.home_goals > game.away_goals && game.season == season
    end.count
  end

  def team_wins_as_away(team_id, season)
    @games.find_all do |game|
      game.away_team_id == team_id && game.away_goals > game.home_goals
    end.count
  end

  def total_team_wins(team_id, season)
    team_wins_as_home(team_id, season) + team_wins_as_away(team_id, season)
  end

  def season_win_percentage(team_id, season)
    find_percent(total_team_wins(team_id, season), count_of_games_by_season)
  end

  def team_ids
    @teams.map do |team|
      team.team_id
    end.sort
  end

  def all_teams_win_percentage(season)
    percent_wins = {}
    team_ids.each do |team_id|
      percent_wins[team_id] = season_win_percentage(team_id, season)
    end
    percent_wins
  end

  def winningest_team(season)
    all_teams_win_percentage(season).max_by do |team_id, win_percentage|
      win_percentage
    end.first
  end

  def worst_team(season)
    all_teams_win_percentage(season).min_by do |team_id, win_percentage|
      win_percentage
    end.first
  end

# ~~~ Game Methods ~~~
  def lowest_total_score(season)
    sum_game_goals(season).min_by do |game_id, score|
      score
    end.last
  end

  def highest_total_score(season)
    sum_game_goals(season).max_by do |game_id, score|
      score
    end.last
  end

  def team_wins_as_home(team_id, season)
    @games.find_all do |game|
      game.home_team_id == team_id && game.home_goals > game.away_goals && game.season == season
    end.count
  end

  def team_wins_as_away(team_id, season)
    @games.find_all do |game|
      game.away_team_id == team_id && game.away_goals > game.home_goals
    end.count
  end

  def total_team_wins(team_id, season)
    team_wins_as_home(team_id, season) + team_wins_as_away(team_id, season)
  end

  def season_win_percentage(team_id, season)
    find_percent(total_team_wins(team_id, season), count_of_games_by_season[season])
  end

  def percentage_away_wins
    wins = @games.find_all { |game| game.away_goals > game.home_goals}
    find_percent(wins.count, total_games)
  end

  def percentage_ties
    ties = @games.find_all { |game| game.away_goals == game.home_goals}
    find_percent(ties.count, total_games)
  end

  def percentage_home_wins
    wins = @games.find_all { |game| game.away_goals < game.home_goals}
    find_percent(wins.count, total_games)
  end

  def count_of_games_by_season
    count = {}
    season_group.each do |season, games|
      count[season] = games.count
    end
    count
  end

  def avg_goals_by_season
    avg_goals_by_season = {}
    seasonal_game_data.each do |season, details|
      avg_goals_by_season[season] = ratio(total_goals(details), total_games(details))
    end
    avg_goals_by_season
  end

  def avg_goals_per_game
    ratio(total_goals, total_games)
  end

# ~~~ LEAGUE METHODS~~~
  def worst_offense
    worst = average_scores_by_team.min_by {|id, average| average}
    team_names_by_team_id(worst[0])
  end

  def best_offense
    best = average_scores_by_team.max_by {|id, average| average}
    team_names_by_team_id(best[0])
  end

  def home_games_by_team
    home_games.group_by do |game_team|
      game_team.team_id
    end
  end

  def highest_scoring_home_team
    home_games_by_team.max_by do |team_id, details|
      avg_score(details)
    end[0]
  end

  def team_id_to_team_name(id)
    return @teams.select do |team|
      team.team_id == id
    end
  end

  def avg_score(filtered_game_teams = @game_teams)
    ratio(total_score(filtered_game_teams), total_game_teams(filtered_game_teams))
  end

  def total_score(filtered_game_teams = @game_teams)
    total_score = filtered_game_teams.reduce(0) do |sum, game_team|
      sum += game_team.goals
    end
  end

  def total_game_teams(filtered_game_teams = @game_teams)
    filtered_game_teams.count
  end

  def home_games
    home_games = @game_teams.select do |game|
      game.hoa == "home"
    end
    home_games
  end

# ~~~ SEASON METHODS~~~

# ~~~ TEAM METHODS~~~
end
