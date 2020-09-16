require "./test/test_helper"

class GameTeamsTacklesManagerTest < Minitest::Test

  def setup
    @stat_tracker = StatTracker.from_csv
    @game_teams_tackles_manager = @stat_tracker.game_teams_tackles_manager
  end

  def test_it_can_show_total_tackles_per_team_per_season
    expected = {
      "1" => 30,
      "4" => 108,
      "6" => 31,
      "14" => 17
      # "26" => 0 (26 doesn't have any games this season)
    }
    assert_equal expected, @game_teams_tackles_manager.team_tackles("20122013")
  end

  def test_it_can_determine_team_with_most_season_tackles
    assert_equal "Chicago Fire", @game_teams_tackles_manager.most_tackles("20122013")
  end

  def test_it_can_determine_team_with_fewest_season_tackles
    assert_equal "DC United", @game_teams_tackles_manager.fewest_tackles("20122013")
  end

end
