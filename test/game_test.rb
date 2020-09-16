require "./test/test_helper"
require "./lib/game"
require "mocha/minitest"

class GameTest < Minitest::Test

  def setup
    data = {
      game_id: 2014020006,
      season: "20142015",
      type: "Regular Season",
      date_time: "10/9/14",
      away_team_id: "1",
      home_team_id: "4",
      away_goals: 4,
      home_goals: 2
    }
    @game_1 = Game.new(data)
  end

  def test_it_can_sum_a_game_total_score
    assert_equal 6, @game_1.total_game_score
  end

  def test_it_can_see_who_is_winner
    assert_equal false, @game_1.home_is_winner?
    assert @game_1.visitor_is_winner?
  end

  def test_it_can_determine_winner_id
    @game_1.stubs(:home_is_winner?).returns(true)
    @game_1.stubs(:visitor_is_winner?).returns(false)
    assert_equal "4", @game_1.winner_id


    @game_1.stubs(:home_is_winner?).returns(false)
    @game_1.stubs(:visitor_is_winner?).returns(true)
    assert_equal "1", @game_1.winner_id

    @game_1.stubs(:home_is_winner?).returns(false)
    @game_1.stubs(:visitor_is_winner?).returns(false)
    assert_equal "tie", @game_1.winner_id
  end

  def test_it_can_get_opponent_id
    assert_equal "1", @game_1.get_opponent_id("4")
    assert_equal "4", @game_1.get_opponent_id("1")
  end

end
