require "csv"

class StatTracker
  attr_reader :teams, :games, :game_teams

  def initialize(team_path, game_path, game_teams_path)
    @teams = read_csv(team_path)
    @games = read_csv(game_path)
    @game_teams = read_csv(game_teams_path)
  end

  def self.from_csv(locations)
    self.new(locations[:teams], locations[:games], locations[:game_teams])
  end

  CSV::Converters[:symbol] = ->(value) {value.to_sym rescue value}

  def read_csv(path)
    CSV.parse(File.read(path), {headers: true, header_converters: :symbol})
  end

  def season_group
    @games.group_by do |row|
      row[:season]
    end
  end

  def goals_by_season
    goals_by_season = {}
    season_group.each do |season,rows|
      goals_by_season[season] = rows.reduce(0) do |sum, row|
        sum += (row[:away_goals].to_i + row[:home_goals].to_i)
      end
    end
    goals_by_season
  end

  def games_by_season
    games_by_season = {}
    season_group.each do |season, rows|
      games_by_season[season] = rows.size
    end
    games_by_season
  end

  def average_goals_by_season
    avg_season_goals = {}
    goals_by_season.each do |season, goals|
      avg_season_goals[season] = (goals / games_by_season[season].to_f).round(2)
    end
    avg_season_goals
  end

  def total_goals
    goals_by_season.values.sum
  end

  def total_games
    games_by_season.values.sum
  end

  def total_avg_goals
    (total_goals / total_games.to_f).round(2)
  end







end
