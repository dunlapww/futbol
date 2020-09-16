class GameTeamsTacklesManager < GameTeamsManager
  attr_reader :game_teams, :stat_tracker

  def initialize(game_teams, stat_tracker)
    super(game_teams, stat_tracker)
  end

  def team_tackles(season)
    game_teams_by_season(season).reduce(Hash.new(0)) do |team_season_tackles, game|
      team_season_tackles[game.team_id] += game.tackles
      team_season_tackles
    end
  end

  def most_tackles(season)
    most_fewest_tackles(season, :max_by)
  end

  def fewest_tackles(season)
    most_fewest_tackles(season, :min_by)
  end

  def most_fewest_tackles(season, method_arg)
    @stat_tracker.fetch_team_identifier(team_tackles(season).method(method_arg).call do |team|
      team.last
    end.first)
  end

end
