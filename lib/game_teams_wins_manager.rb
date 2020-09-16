class GameTeamsWinsManager < GameTeamsManager
  attr_reader :game_teams, :stat_tracker

  def initialize(game_teams, stat_tracker)
    super(game_teams, stat_tracker)
  end

  def average_win_percentage_by(hash)
    hash.map do |group_value, gameteams|
      [group_value, ratio(total_wins(gameteams), total_game_teams(gameteams))]
    end.to_h
  end

  def total_wins(game_teams)
    game_teams.count do |gameteam|
      gameteam.result == "WIN"
    end
  end

  def highest_lowest_win_percentage(hash, method_arg)
    average_win_percentage_by(hash).method(method_arg).call do |group, win_perc|
      win_perc
    end[0]
  end

  def favorite_opponent(team_id)
    hash = game_teams_by_opponent(team_id)
    fave_opp_id = highest_lowest_win_percentage(hash, :max_by)
    @stat_tracker.fetch_team_identifier(fave_opp_id)
  end

  def rival(team_id)
    hash = game_teams_by_opponent(team_id)
    rival_id = highest_lowest_win_percentage(hash, :min_by)
    @stat_tracker.fetch_team_identifier(rival_id)
  end
end
