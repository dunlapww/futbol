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



end
