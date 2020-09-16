class GameTeamsGoalsManager < GameTeamsManager
  attr_reader :game_teams, :stat_tracker

  def initialize(game_teams, stat_tracker)
    super(game_teams, stat_tracker)
  end

  def most_goals_scored(team_id)
    most_fewest_goals_scored(team_id, :max)
  end

  def fewest_goals_scored(team_id)
    most_fewest_goals_scored(team_id, :min)
  end

  def most_fewest_goals_scored(team_id, method_arg)
    team_goals_by_game(team_id).method(method_arg).call.to_i
  end

  def total_score(filtered_game_teams = @game_teams)
    filtered_game_teams.reduce(0) do |sum, game_team|
      sum += game_team.goals
    end
  end

  def avg_score(game_teams = @game_teams)
    ratio(total_score(game_teams), total_game_teams(game_teams))
  end

  def average_scores_by_team
    total_scores_by_team.merge(games_containing_team){|team_id, scores, games_played| ratio(scores, games_played, 3)}
  end

  def team_goals_by_game(team_id)
    games_by_team(team_id).map do |game|
      game.goals
    end
  end

  def total_scores_by_team
    @game_teams.reduce(Hash.new(0)) do |base, game|
      base[game.team_id] += game.goals
      base
    end
  end

  def highest_scoring_home_team
    highest_lowest_scoring_team("home",:max_by)
  end

  def highest_scoring_visitor
    highest_lowest_scoring_team("away",:max_by)
  end

  def lowest_scoring_visitor
    highest_lowest_scoring_team("away",:min_by)
  end

  def lowest_scoring_home_team
    highest_lowest_scoring_team("home",:min_by)
  end

  def highest_lowest_scoring_team(hoa,method_arg)
    hoa_team_id = hoa_games_by_team_id(hoa).method(method_arg).call do |team_id, details|
      avg_score(details)
    end[0]
    @stat_tracker.fetch_team_identifier(hoa_team_id)
  end

  def team_shot_ratios(season)
    game_teams_by_team_id(season).map do |team_id,game_teams|
      [team_id, (total_shots(game_teams).to_f / total_score(game_teams)).round(4)]
    end.to_h
  end

  def total_shots(game_teams = @game_teams)
    game_teams.reduce(0) do |sum, game_team|
      sum += game_team.shots
    end
  end

  def most_accurate_team(season)
    most_least_accurate_team(season, :min_by)
  end

  def least_accurate_team(season)
    most_least_accurate_team(season, :max_by)
  end

  def most_least_accurate_team(season, method_arg)
    team_id = team_shot_ratios(season).method(method_arg).call do |team_id, shot_ratio|
      shot_ratio
    end[0]
    @stat_tracker.fetch_team_identifier(team_id)
  end

  def worst_offense
    best_worst_offense(:min_by)
  end

  def best_offense
    best_worst_offense(:max_by)
  end

  def best_worst_offense(method_arg1)
    team = average_scores_by_team.method(method_arg1).call {|id, average| average}
    @stat_tracker.fetch_team_identifier(team[0])
  end

end
