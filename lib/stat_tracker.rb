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
    find_percent(total_team_wins(team_id, season), count_of_games_by_season[season])
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


  def total_game_teams(filtered_game_teams = @game_teams)
    filtered_game_teams.count
  end

  def avg_score(filtered_game_teams = @game_teams)
    ratio(total_score(filtered_game_teams), total_game_teams(filtered_game_teams))
  end

  def team_id_to_team_name(id)
    team_obj = @teams.select do |team|
      team.team_id == id
    end
    team_obj[0].team_name
  end

  def total_score(filtered_game_teams = @game_teams)
    total_score = filtered_game_teams.reduce(0) do |sum, game_team|
      sum += game_team.goals
    end
  end

  def home_games
    @game_teams.select do |game|
      game.hoa == "home"
    end
  end

  def away_games
    @game_teams.select do |game_team|
      game_team.hoa == "away"
    end
  end

  def home_games_by_team
    home_games.group_by do |game_team|
      game_team.team_id
    end
  end

  def away_games_by_team
    away_games.group_by do |game_team|
      game_team.team_id
    end
  end

  def home_or_away_games(where = "home")
    @game_teams.select do |game|
      game.hoa == where
    end
  end

  def hoa_games_by_team_id(hoa)
    home_or_away_games(hoa).group_by do |game_team|
      game_team.team_id
    end
  end

  def lowest_scoring_team_id(hoa)
    hoa_games_by_team_id(hoa).min_by do |team_id, details|
      avg_score(details)
    end[0]
  end

  def team_id_to_team_name(id)
    @teams.each do |team|
      return team.team_name if team.team_id == id
    end
  end

  def total_wins(game_teams_filtered = @game_teams)
    game_teams_filtered.count do |gameteam|
      gameteam.result == "WIN"
    end
  end

  def filter_by_teamid(id)
    @game_teams.select do |game_team|
      game_team.team_id == id
    end
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

  def game_ids_by_season(season)
    filter_by_season(season).map do |game|
      game.game_id
    end.sort
  end

  def team_tackles(season)
    team_season_tackles = {}
    games = @game_teams.find_all do |game|
      game_ids_by_season(season).include?(game.game_id)
    end
    games.each do |game|
      if team_season_tackles[game.team_id]
        team_season_tackles[game.team_id] += game.tackles
      else
        team_season_tackles[game.team_id] = game.tackles
      end
    end
    team_season_tackles
  end

  def team_identifier(team_id)
    @teams.find do |team|
      team.team_id == team_id
    end.team_name
  end

  def games_by_team(team_id)
    @game_teams.select do |game|
      game.team_id == team_id
    end
  end

  def team_goals_by_game(team_id)
    games_by_team(team_id).map do |game|
      game.goals
    end
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

  def count_of_teams
    @teams.count
  end

  def highest_scoring_home_team
    highest_scoring_home_team = home_games_by_team.max_by do |team_id, details|
      avg_score(details)
    end[0]
    team_id_to_team_name(highest_scoring_home_team)
  end

  def highest_scoring_visitor
    highest_scoring_visitor = away_games_by_team.max_by do |team_id, details|
      avg_score(details)
    end[0]
    team_id_to_team_name(highest_scoring_visitor)
  end

  def lowest_scoring_visitor_team
    team_id_to_team_name(lowest_scoring_team_id("away"))
  end

  def lowest_scoring_home_team
    team_id_to_team_name(lowest_scoring_team_id("home"))
  end

# ~~~ SEASON METHODS~~~

  def winningest_coach(season)
    @game_teams.find do |game_team|
      game_team.team_id == winningest_team(season)
    end.head_coach
  end

  def worst_coach(season)
    @game_teams.find do |game_team|
      game_team.team_id == worst_team(season)
    end.head_coach
  end

  def most_tackles(season)
    team_identifier(team_tackles(season).max_by do |team|
      team.last
    end.first)
  end

  def fewest_tackles(season)
    team_identifier(team_tackles(season).min_by do |team|
      team.last
    end.first)
  end

# ~~~ TEAM METHODS~~~

  def average_win_percentage(id)
    find_percent(total_wins(filter_by_teamid(id)), total_game_teams(filter_by_teamid(id)))
  end

  def team_info(team_id)
    team_string = team_id.to_s
    team_string = {}
    @teams.each do |team|
      if team.team_id == team_id
        team_string[:team_id] = team.team_id
        team_string[:franchise_id] = team.franchise_id
        team_string[:team_name] = team.team_name
        team_string[:abbreviation] = team.abbreviation
        team_string[:stadium] = team.stadium
        team_string[:link] = team.link
      end
    end
    team_string
  end

  def most_goals_scored(team_id)
    team_goals_by_game(team_id).max
  end

  def fewest_goals_scored(team_id)
    team_goals_by_game(team_id).min
  end
end
