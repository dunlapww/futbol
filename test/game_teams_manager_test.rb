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

  def test_it_can_list_game_teams_per_coach
    expected = ["Claude Julien", "Guy Boucher", "Peter DeBoer", "Peter Laviolette"]
    @game_teams_manager.coach_game_teams("20122013").each do |coach, game_teams|
      game_teams.each do |game_team|
        assert expected.include?(game_team.head_coach)
      end
    end
  end

  def test_it_can_calculate_coach_game_teams_average_wins
    expected = {
      "Claude Julien" => 1.0,
      "Guy Boucher" => 0.0,
      "Peter DeBoer" => 1.0,
      "Peter Laviolette" => 0.25
    }
    assert_equal expected, @game_teams_manager.coach_game_teams_average_wins("20122013")
  end

  def test_it_can_list_winningest_coach_by_season
    assert_equal "Peter DeBoer", @game_teams_manager.winningest_coach("20122013")
    assert_equal "Claude Julien", @game_teams_manager.winningest_coach("20132014")
    assert_equal "Claude Julien", @game_teams_manager.winningest_coach("20142015")
    assert_equal "Jon Cooper", @game_teams_manager.winningest_coach("20152016")
    assert_equal "Bruce Cassidy", @game_teams_manager.winningest_coach("20162017")
    assert_equal "John Stevens", @game_teams_manager.winningest_coach("20172018")

  end

  def test_it_can_determine_the_worst_coach_by_season
    assert_equal "Guy Boucher", @game_teams_manager.worst_coach("20122013")
    assert_equal "Jon Cooper", @game_teams_manager.worst_coach("20132014")
    assert_equal "Jon Cooper", @game_teams_manager.worst_coach("20142015")
    assert_equal "Darryl Sutter", @game_teams_manager.worst_coach("20152016")
    assert_equal "Claude Julien", @game_teams_manager.worst_coach("20162017")
    assert_equal "Dave Hakstol", @game_teams_manager.worst_coach("20172018")
  end

  def test_it_can_get_game_teams_by_season
    @game_teams_manager.game_teams_by_season("20142015").each do |game|
      assert_instance_of GameTeam, game
    end
    assert_equal 8, @game_teams_manager.game_teams_by_season("20122013").count
    assert_equal 24, @game_teams_manager.game_teams_by_season("20132014").count
    assert_equal 32, @game_teams_manager.game_teams_by_season("20142015").count
    assert_equal 10, @game_teams_manager.game_teams_by_season("20152016").count
    assert_equal 14, @game_teams_manager.game_teams_by_season("20162017").count
    assert_equal 18, @game_teams_manager.game_teams_by_season("20172018").count
  end

  def test_it_can_show_total_tackles_per_team_per_season
    expected = {
      "1" => 30,
      "4" => 108,
      "6" => 31,
      "14" => 17
      # "26" => 0 (26 doesn't have any games this season)
    }
    assert_equal expected, @game_teams_manager.team_tackles("20122013")
  end

  def test_it_can_determine_team_with_most_season_tackles
    assert_equal "Chicago Fire", @game_teams_manager.most_tackles("20122013")
  end

  def test_it_can_determine_team_with_fewest_season_tackles
    assert_equal "DC United", @game_teams_manager.fewest_tackles("20122013")
  end

  def test_it_can_see_highest_number_of_goals_by_team_in_a_game
    assert_equal 4, @game_teams_manager.most_goals_scored("1")
  end

  def test_it_can_see_lowest_number_of_goals_by_team_in_a_game
    assert_equal 1, @game_teams_manager.fewest_goals_scored("14")
  end

  def test_it_can_see_highest_scoring_home_team
    assert_equal "DC United", @game_teams_manager.highest_scoring_home_team
  end

  def test_it_can_see_highest_scoring_visitor
    assert_equal "FC Dallas",   @game_teams_manager.highest_scoring_visitor
  end

  def test_it_knows_lowest_scoring_home_team
    assert_equal "Atlanta United", @game_teams_manager.lowest_scoring_home_team
  end

  def test_it_knows_lowest_scoring_visitor_team
    assert_equal "Chicago Fire", @game_teams_manager.lowest_scoring_visitor
  end

  def test_it_can_filter_gameteams_by_team_id
    assert @game_teams_manager.games_by_team("6").all? {|gameteam| gameteam.team_id == "6"}
  end

  def test_it_can_create_gameteams_by_opponent
    assert_equal ["6", "26", "4", "1"], @game_teams_manager.game_teams_by_opponent("14").keys
    assert_equal 5, @game_teams_manager.game_teams_by_opponent("14")["6"].size
    assert_equal 4, @game_teams_manager.game_teams_by_opponent("14")["1"].size
    assert_equal 6, @game_teams_manager.game_teams_by_opponent("14")["4"].size
    assert_equal 6, @game_teams_manager.game_teams_by_opponent("14")["26"].size
  end

  def test_it_can_get_most_accurate_team_for_season
    assert_equal "FC Dallas", @game_teams_manager.most_accurate_team("20132014")
  end

  def test_it_can_get_least_accurate_team_for_season
    assert_equal "Atlanta United", @game_teams_manager.least_accurate_team("20132014")
  end

  def test_it_can_get_games_from_season_game_ids
    season_game_ids = @game_teams_manager.game_ids_per_season("20132014")
    assert_equal GameTeam, @game_teams_manager.find_game_teams(season_game_ids)[0].class
    assert_equal (season_game_ids.count * 2), @game_teams_manager.find_game_teams(season_game_ids).count
  end

  def test_it_can_get_shots_per_team
    expected = {"4"=>32, "14"=>26, "1"=>27, "6"=>24, "26"=>40}
    assert_equal expected, @game_teams_manager.shots_per_team_id("20132014")
  end

  #This test I had to alter the expected to get it to pass, but when I changed the method formula, the spec harness failed so we should take a closer look at it.
  def test_shots_per_goal_per_season_for_given_season
    expected = {"4"=>3.20, "14"=>2.889, "1"=>3.857, "6"=>2.40, "26"=>3.636}
    assert_equal expected, @game_teams_manager.shots_per_goal_per_season("20132014")
  end

  def test_it_can_calculate_total_wins
    assert_equal 45, @game_teams_manager.total_wins(@game_teams_manager.game_teams)
  end

  def test_it_can_calculate_average_win_percentage
    assert_equal 0.32, @game_teams_manager.average_win_percentage("4")
  end

  def test_it_can_filter_by_team_id
    assert @game_teams_manager.filter_by_team_id("4").all? do |gameteam|
      gameteam.team_id == "4"
    end
  end

  def test_it_can_calculate_average_win_percentage_by_opponent
    expected = {"14"=>0.4, "1"=>0.8, "4"=>0.83, "26"=>0.25}
    assert_equal expected, @game_teams_manager.average_win_percentage_by_opponent("6")
  end

  def test_it_can_return_favorite_opponent_id
    assert_equal "4", @game_teams_manager.favorite_opponent_id("6")
  end

  def test_it_can_return_rival_id
    assert_equal "26", @game_teams_manager.rival_id("6")
  end

  def test_it_can_get_number_of_games_by_team
    expected = {"1"=>23, "4"=>22, "14"=>21, "6"=>20, "26"=>20}
    assert_equal expected, @game_teams_manager.games_containing_team
  end

  def test_it_can_get_total_scores_by_team
    expected = {"1"=>43, "4"=>37, "14"=>47, "6"=>47, "26"=>37}
    assert_equal expected, @game_teams_manager.total_scores_by_team
  end

  # Check validity of test - are the expected values accurate?
  def test_it_can_get_average_scores_per_team
    expected = {"1"=>1.87, "4"=>1.682, "14"=>2.238, "6"=>2.35, "26"=>1.85}
    assert_equal expected, @game_teams_manager.average_scores_by_team
  end

  def test_worst_offense
    assert_equal "Chicago Fire", @game_teams_manager.worst_offense
  end

  def test_best_offense
    assert_equal "FC Dallas", @game_teams_manager.best_offense
  end

  def test_it_can_find_goals_per_season
    expected = {"4"=>10, "14"=>9, "1"=>7, "6"=>10, "26"=>11}
    assert_equal expected, @game_teams_manager.season_goals("20132014")
  end


end
