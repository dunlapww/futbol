require "./test/test_helper"
require "./lib/game_teams_wins_manager"

class GameTeamsWinsManagerTest < Minitest::Test

  def setup
    @stat_tracker = StatTracker.from_csv
    @game_teams_wins_manager = @stat_tracker.game_teams_wins_manager
  end

  def test_it_can_calculate_average_win_percentage_by_a_group
    expected = {"14"=>0.4, "1"=>0.8, "4"=>0.83, "26"=>0.25}
    assert_equal expected, @game_teams_wins_manager.average_win_percentage_by(@game_teams_wins_manager.game_teams_by_opponent("6"))
  end

  def test_it_can_calculate_total_wins
    assert_equal 45, @game_teams_wins_manager.total_wins(@game_teams_wins_manager.game_teams)
  end

  # def test_it_can_see_highest_number_of_goals_by_team_in_a_game
  #   assert_equal 4, @game_teams_wins_manager.most_fewest_goals_scored("1", :max)
  # end
  #
  # def test_it_can_see_lowest_number_of_goals_by_team_in_a_game
  #   assert_equal 1, @game_teams_wins_manager.most_fewest_goals_scored("14", :min)
  # end

  def test_it_can_return_win_percentage_for_a_group
    hash = @game_teams_wins_manager.game_teams_by_opponent("6")
    assert_equal "4", @game_teams_wins_manager.highest_lowest_win_percentage(hash,:max_by)

    hash = @game_teams_wins_manager.game_teams_by_opponent("6")
    assert_equal "26", @game_teams_wins_manager.highest_lowest_win_percentage(hash,:min_by)
  end

end
