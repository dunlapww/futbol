require "./test/test_helper"

class GameTeamsGoalsManagerTest < Minitest::Test

  def setup
    @stat_tracker = StatTracker.from_csv
    @game_teams_goals_manager = @stat_tracker.game_teams_goals_manager
  end

  def test_it_can_see_highest_number_of_goals_by_team_in_a_game
    assert_equal 4, @game_teams_goals_manager.most_goals_scored("1")
  end

  def test_it_can_see_lowest_number_of_goals_by_team_in_a_game
    assert_equal 1, @game_teams_goals_manager.fewest_goals_scored("14")
  end

  def test_it_can_get_total_scores_by_team
    expected = {"1"=>43, "4"=>37, "14"=>47, "6"=>47, "26"=>37}
    assert_equal expected, @game_teams_goals_manager.total_scores_by_team
  end

  def test_it_can_get_average_scores_per_team
    expected = {"1"=>1.87, "4"=>1.682, "14"=>2.238, "6"=>2.35, "26"=>1.85}
    assert_equal expected, @game_teams_goals_manager.average_scores_by_team
  end

  def test_it_can_get_highest_lowest_away_home_teams
    #highest scoring home team
    assert_equal "DC United", @game_teams_goals_manager.highest_lowest_scoring_team("home",:max_by)
    #lowest scoring home team
    assert_equal "Atlanta United", @game_teams_goals_manager.highest_lowest_scoring_team("home",:min_by)
    #highest scoring visitor team
    assert_equal "FC Dallas", @game_teams_goals_manager.highest_lowest_scoring_team("away",:max_by)
    #lowest scoring visitor team
    assert_equal "Chicago Fire", @game_teams_goals_manager.highest_lowest_scoring_team("away",:min_by)
  end

  def test_it_can_calculate_shot_ratios
    expected = {"4"=>3.2, "14"=>2.8889, "1"=>3.8571, "6"=>2.4, "26"=>3.6364}
    assert_equal expected, @game_teams_goals_manager.team_shot_ratios("20132014")
  end

  def test_it_can_get_total_shots
    expected = 149
    actual = @game_teams_goals_manager.total_shots(@game_teams_goals_manager.game_teams_by_season("20132014"))
    assert_equal expected, actual
  end

  def test_worst_offense
    assert_equal "Chicago Fire", @game_teams_goals_manager.best_worst_offense(:min_by)
  end

  def test_best_offense
    assert_equal "FC Dallas", @game_teams_goals_manager.best_worst_offense(:max_by)
  end

  def test_it_can_get_most_accurate_team_for_season
    assert_equal "FC Dallas", @game_teams_goals_manager.most_accurate_team("20132014")
  end

  def test_it_can_get_least_accurate_team_for_season
    assert_equal "Atlanta United", @game_teams_goals_manager.least_accurate_team("20132014")
  end

end
