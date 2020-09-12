require "csv"
require_relative "./games_manager"

class Game
  attr_reader :game_id,
              :season,
              :type,
              :date_time,
              :away_team_id,
              :home_team_id,
              :away_goals,
              :home_goals
              # :venue,
              # :venue_link

  def initialize(data)
    @game_id = data[:game_id].to_i
    @season = data[:season]
    @type = data[:type]
    @date_time = data[:date_time]
    @away_team_id = data[:away_team_id].to_i
    @home_team_id = data[:home_team_id].to_i
    @away_goals = data[:away_goals].to_i
    @home_goals = data[:home_goals].to_i
    # @venue = data[:venue]
    # @venue_link = data[:venue_link]
  end

  def total_game_score
    @away_goals + @home_goals
  end

  def home_is_winner?
    @away_goals < @home_goals
  end

  def visitor_is_winner?
    @away_goals > @home_goals
  end



end
