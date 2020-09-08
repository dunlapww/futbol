require "./test/test_helper"
require "./lib/stat_tracker"

class StatTrackerTest < Minitest::Test
  def setup
    @stats = StatTracker.from_csv
  end

  def test_it_is_a_stat_tracker
    assert_instance_of StatTracker, @stats
  end

  def test_it_has_access_to_other_classes
    assert_instance_of Game, @stats.games[0]
    assert_equal 6, @stats.games.count
    assert_instance_of Team, @stats.teams[0]
    assert_equal 5, @stats.teams.count
    assert_instance_of GameTeam, @stats.game_teams[0]
    assert_equal 12, @stats.game_teams.count
  end

  # ~~~ HELPER METHOD TESTS~~~

  def test_it_can_sum_goals_per_game
    expected = {
      2014020006 => 6,
      2014021002 => 4,
      2014020598 => 3,
      2014020917 => 5,
      2014020774 => 4,
      2017020012 => 2
    }
    assert_equal expected, @stats.sum_game_goals
  end

  def test_it_can_determine_highest_and_lowest_game_score
    assert_equal 2, @stats.lowest_total_score
    assert_equal 6, @stats.highest_total_score
  end

  def test_it_can_find_total_games
    assert_equal 6, @stats.total_games
  end

  def test_it_can_find_percentage
    wins = ["game1", "game2", "game3"]
    assert_equal 50.00, @stats.find_percent(wins, 6)
  end

  def test_it_can_group_games_by_season
    assert_equal ["20142015", "20172018"], @stats.seasonal_game_data.keys

    @stats.seasonal_game_data.values.each do |games|
      games.each do |game|
        assert_instance_of Game, game
      end
    end
  end

  def test_it_can_sum_game_goals
    assert_equal 24, @stats.wd_total_goals
    season_1415 = @stats.seasonal_game_data["20142015"]
    assert_equal 22, @stats.wd_total_goals(season_1415)
  end


  def test_it_can_calc_a_ratio
    expected = 0.67
    assert_equal expected, @stats.ratio(2,3)
  end

# ~~~ GAME METHOD TESTS~~~
  def test_it_can_get_percentage_away_games_won
    assert_equal 33.33, @stats.percentage_away_wins
  end

  def test_it_can_get_percentage_ties
    assert_equal 33.33, @stats.percentage_ties
  end

  def test_it_can_get_percentage_home_wins
    assert_equal 33.33, @stats.percentage_home_wins
  end

  def test_it_can_get_average_goals_by_season
    expected = {"20142015"=>4.4, "20172018"=>2.0}
    assert_equal expected , @stats.avg_goals_by_season
  end

  def test_it_can_get_avg_goals_per_game
    assert_equal 4.0, @stats.avg_goals_per_game
  end



# ~~~ LEAGUE METHOD TESTS~~~


# ~~~ SEASON METHOD TESTS~~~


# ~~~ TEAM METHOD TESTS~~~
end
