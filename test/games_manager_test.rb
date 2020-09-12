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

  def test_it_can_sum_game_scores
    assert_equal 211, @games_manager.total_game_scores
  end

  def test_it_can_average_scores
    assert_equal 3.98, @games_manager.average_game_scores
  end

  def test_it_can_group_games_by_away_team_id
    skip
    assert_equal 7, @games_manager.games_by_visitor
  end

  def test_it_can_average_visitor_scores
    skip
    assert_equal 3.2, @games_manager.average_visitor_score
  end

  def test_it_can_get_visitor_w_min_avg_score
    require "pry"; binding.pry
    assert_equal 24, @games_manager.min_visitor_score
  end




end
