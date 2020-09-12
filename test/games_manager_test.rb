require "./test/test_helper"
require "./lib/games_manager"

class GamesManagerTest < Minitest::Test

  def setup
    @stat_tracker = StatTracker.from_csv
    @games_manager = @stat_tracker.games_manager
  end

  def test_it_exists
    assert_instance_of GamesManager, @games_manager
  end

  def test_it_can_find_the_lowest_total_score
    assert_equal 1, @games_manager.lowest_total_score
  end

  def test_it_can_find_the_highest_total_score
    assert_equal 6, @games_manager.highest_total_score
  end

  def test_it_can_get_percentage_home_wins
    assert_equal 0.55, @games_manager.percentage_home_wins
  end

  def test_it_can_get_percentage_visitor_games_won
    assert_equal 0.30, @games_manager.percentage_visitor_wins
  end

  def test_it_can_count_games
    assert_equal 53, @games_manager.total_games
  end

  def test_it_can_sum_goals
    assert_equal 211, @games_manager.total_game_scores
    assert_equal 95, @games_manager.total_away_goals
    assert_equal 116, @games_manager.total_home_goals
  end

  def test_it_can_average_scores
    assert_equal 3.98, @games_manager.average_game_scores
  end

  def test_it_can_group_games_by_away_team_id
    assert_equal 9, @games_manager.games_by_visitor[6].size
    assert @games_manager.games_by_visitor[6].all? do |game|
      game.hoa == "away"
    end
  end

  def test_it_can_average_visitor_scores
    assert_equal 2.22, @games_manager.avg_goals_by_visitor[6]
  end

  def test_it_can_get_visitor_id_w_min_avg_score
    assert_equal 4, @games_manager.visitor_id_w_min_avg_score
  end
end
