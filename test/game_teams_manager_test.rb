require "./test/test_helper"
require "./lib/game_teams_manager"

class GameTeamsManagerTest < Minitest::Test
  def setup

    @stat_tracker = StatTracker.from_csv
    @game_teams_manager = @stat_tracker.game_teams_manager
  end

  def test_it_exists
    assert_instance_of GameTeamsManager, @game_teams_manager
  end

  def test_it_can_create_a_table_of_games
    @game_teams_manager.game_teams.all? do |game|
      assert_instance_of GameTeam, game
    end
  end
end
