require "./test/test_helper"
require "./lib/stat_tracker"

class StatTrackerTest < Minitest::Test
  def setup
    @team_path = './data/teams_sample.csv'
    @game_path = './data/games_sample.csv'
    @game_teams_path = './data/game_teams_sample.csv'
    @stats = StatTracker.new(@team_path, @game_path, @game_teams_path)
  end

  def test_it_is_a_stat_tracker
    assert_instance_of StatTracker, @stats
  end

  def test_it_stores_correct_csv_files
    expected = CSV.parse(File.read('./data/teams_sample.csv'), {headers: true, header_converters: :symbol})
    assert_equal expected, @stats.teams
    expected = CSV.parse(File.read('./data/games_sample.csv'), {headers: true, header_converters: :symbol})
    assert_equal expected, @stats.games
    expected = CSV.parse(File.read('./data/game_teams_sample.csv'), {headers: true, header_converters: :symbol})
    assert_equal expected, @stats.game_teams
  end

  def test_it_can_count_number_of_rows
    assert_equal 5, @stats.teams.size
    assert_equal 6, @stats.games.size
    assert_equal 12, @stats.game_teams.size
  end

  def test_it_has_the_correct_columns
    expected = [:team_id, :franchiseid, :teamname, :abbreviation, :stadium, :link]
    assert_equal expected, @stats.teams.headers
    expected = [:game_id, :season, :type, :date_time, :away_team_id, :home_team_id,
      :away_goals, :home_goals, :venue, :venue_link]
    assert_equal expected, @stats.games.headers
    expected = [:game_id, :team_id, :hoa, :result, :settled_in, :head_coach,
      :goals, :shots, :tackles, :pim, :powerplayopportunities, :powerplaygoals,
      :faceoffwinpercentage, :giveaways, :takeaways]
    assert_equal expected, @stats.game_teams.headers
  end

  def test_it_can_group_games_by_season
    




end
