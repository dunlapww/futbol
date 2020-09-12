require "./test/test_helper"
require "./lib/game_teams_manager"

class GameTeamsManagerTest < Minitest::Test
  def setup

    @stat_tracker = StatTracker.from_csv
    require "pry"; binding.pry
    @game_teams_manager = @stat_tracker.game_teams_manager
  end

  def test_it_exists

    assert_instance_of GameTeam, @game_teams_manager
  end

end
