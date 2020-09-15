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
    assert_instance_of Game, @stats.games_manager.games[0]
    assert_equal 53, @stats.games_manager.total_games
    assert_instance_of Team, @stats.teams_manager.teams[0]
    assert_equal 5, @stats.teams_manager.teams.count
    assert_instance_of GameTeam, @stats.game_teams_manager.game_teams[0]
    assert_equal 106, @stats.game_teams_manager.game_teams.count
  end

  # ~~~ HELPER METHOD TESTS~~~

  # def test_it_can_sum_goals_per_game ###
  #   expected = {
  #     2014020006=>6, 2014021002=>4, 2014020598=>3, 2014020917=>5, 2014020774=>4, 2014020142=>5, 2014020981=>5, 2014020970=>5, 2014020002=>3, 2014020391=>3, 2014020423=>3, 2014020643=>6, 2014020371=>2, 2014020845=>5, 2014021083=>4, 2014020775=>4}
  #   assert_equal expected, @stats.sum_game_goals("20142015")
  # end

  def test_it_can_find_total_games ###
    assert_equal 53, @stats.total_games
  end

  def test_it_can_fetch_season_win_percentage
    assert_equal 28.57, @stats.fetch_season_win_percentage("1", "20142015")
    assert_equal 42.86, @stats.fetch_season_win_percentage("4", "20142015")
    assert_equal 66.67, @stats.fetch_season_win_percentage("6", "20142015")
    assert_equal 42.86, @stats.fetch_season_win_percentage("26", "20142015")
  end

  def test_it_can_filter_games_by_season
    expected_games_1 = @stats.filter_by_season("20122013")
    expected_games_2 = @stats.filter_by_season("20152016")
    expected_games_3 = @stats.filter_by_season("20142015")
    result_1 = expected_games_1.none? do |game|
      game.season == "20132014" && game.season == "20142015" && game.season == "20162017"
    end
    assert result_1
    assert_equal 4, expected_games_1.count
    result_2 = expected_games_2.any? do |game|
      game.season == "20122013" && game.season == "20132014" && game.season == "20162017"
    end
    assert_equal false, result_2
    assert_equal 5, expected_games_2.count
    result_3 = expected_games_3.any? do |game|
      game.season == "20142015"
    end
    assert result_3
    assert_equal 16, expected_games_3.count
  end

  def test_it_can_create_array_of_all_team_ids
    expected = ["1", "4", "6", "14", "26"]
    assert_equal expected, @stats.team_ids
  end

  def test_it_can_get_team_name_from_team_id
    assert_equal "Chicago Fire", @stats.team_names_by_team_id("4")
  end

  def test_it_can_get_total_scores_by_team
    expected = {"1"=>43, "4"=>37, "14"=>47, "6"=>47, "26"=>37}
    assert_equal expected, @stats.total_scores_by_team
  end

  def test_it_can_get_number_of_games_by_team
    expected = {"1"=>23, "4"=>22, "14"=>21, "6"=>20, "26"=>20}
    assert_equal expected, @stats.games_containing_team
  end

  # Check validity of test - are the expected values accurate?
  def test_it_can_get_average_scores_per_team
    expected = {"1"=>1.87, "4"=>1.682, "14"=>2.238, "6"=>2.35, "26"=>1.85}
    assert_equal expected, @stats.average_scores_by_team
  end

  def test_it_can_sum_game_goals
    assert_equal 211, @stats.total_goals
    season_1415 = @stats.seasonal_game_data["20142015"]
    assert_equal 67, @stats.total_goals(season_1415)
  end

  def test_it_can_calc_a_ratio
    expected = 0.67
    assert_equal expected, @stats.ratio(2,3)
  end

  def test_it_can_return_array_of_game_ids_per_season
    expected = ["2012020030", "2012020133", "2012020355", "2012020389"]
    assert_equal expected, @stats.game_ids_by_season("20122013")
  end

  # def test_it_can_show_total_tackles_per_team_per_season ###
  #   expected = {
  #     "1" => 30,
  #     "4" => 108,
  #     "6" => 31,
  #     "14" => 17
  #     # 26 => 0
  #   }
  #   assert_equal expected, @stats.team_tackles("20122013")
  # end

  def test_it_can_get_average_scores_per_team
    expected = {"1"=>1.87, "4"=>1.68, "14"=>2.24, "6"=>2.35, "26"=>1.85}
    assert_equal expected, @stats.average_scores_by_team
  end

  def test_it_can_group_games_by_season
    assert_equal ["20142015", "20172018", "20152016", "20132014", "20122013", "20162017"], @stats.seasonal_game_data.keys

    @stats.seasonal_game_data.values.each do |games|
      games.each do |game|
        assert_instance_of Game, game
      end
    end
  end

  def test_it_can_count_wins
    assert_equal 45, @stats.total_wins
  end

  # def test_it_can_filter_gameteams_by_team_id
  #   assert @stats.games_by_team("6").all? {|gameteam| gameteam.team_id == "6"}
  # end

  def test_it_can_get_a_game
    assert_equal "2014021002", @stats.get_game("2014021002").game_id
  end

  def test_it_can_get_opponent_id
    game = @stats.get_game("2014021002")
    assert_equal "14", @stats.get_opponent_id(game,"6")

    game = @stats.get_game("2014020371")
    assert_equal "26", @stats.get_opponent_id(game,"6")
  end

  def test_it_can_create_gameteams_by_opponent
    assert_equal ["14", "1", "4", "26"], @stats.game_teams_by_opponent("6").keys
    assert_equal 5, @stats.game_teams_by_opponent("6")["14"].size
    assert_equal 5, @stats.game_teams_by_opponent("6")["1"].size
    assert_equal 6, @stats.game_teams_by_opponent("6")["4"].size
    assert_equal 4, @stats.game_teams_by_opponent("6")["26"].size
  end

  def test_it_can_get_game_ids_in_season
    expected = ["2013021198", "2013020371", "2013020203", "2013020649", "2013021160", "2013020334", "2013021221", "2013020667", "2013020321", "2013020285", "2013020739", "2013020088"]
    assert_equal expected, @stats.game_ids_per_season("20132014")
  end

  def test_it_can_get_games_from_season_game_ids
    season_game_ids = @stats.game_ids_per_season("20132014")
    assert_equal GameTeam, @stats.find_game_teams(season_game_ids)[0].class
    assert_equal (season_game_ids.count * 2), @stats.find_game_teams(season_game_ids).count
  end

  def test_it_can_get_shots_per_team
    expected = {"4"=>32, "14"=>26, "1"=>27, "6"=>24, "26"=>40}
    assert_equal expected, @stats.shots_per_team_id("20132014")
  end

  # def test_it_can_find_goals_per_season
  #   expected = {"4"=>10, "14"=>9, "1"=>7, "6"=>10, "26"=>11}
  #   assert_equal expected, @stats.season_goals("20132014")
  # end

  def test_shots_per_goal_per_season_for_given_season
    expected = {"4"=>3.20, "14"=>2.89, "1"=>3.86, "6"=>2.40, "26"=>3.64}
    assert_equal expected, @stats.shots_per_goal_per_season("20132014")
  end

# ~~~ GAME METHOD TESTS~~~
  def test_it_can_get_percentage_away_games_won ###
    assert_equal 30.19, @stats.percentage_away_wins
  end

  def test_it_can_get_percentage_ties ###
    assert_equal 15.09, @stats.percentage_ties
  end

  def test_it_can_get_percentage_home_wins ###
    assert_equal 54.72, @stats.percentage_home_wins
  end

  def test_it_can_see_count_of_games_by_season ###
    expected = {"20142015"=>16, "20172018"=>9, "20152016"=>5, "20132014"=>12, "20122013"=>4, "20162017"=>7}
    assert_equal expected, @stats.count_of_games_by_season
  end

  def test_it_can_get_average_goals_by_season
    expected = {"20142015"=>4.19, "20172018"=>3.78, "20152016"=>3.8, "20132014"=>3.92, "20122013"=>3.5, "20162017"=>4.29}
    assert_equal expected , @stats.average_goals_by_season
  end

  def test_it_can_get_avg_goals_per_game
    assert_equal 3.98, @stats.avg_goals_per_game
  end

  def test_it_can_determine_highest_and_lowest_game_score
    assert_equal 2, @stats.lowest_total_score("20142015")
    assert_equal 6, @stats.highest_total_score("20142015")
  end

# ~~~ LEAGUE METHOD TESTS~~~
  def test_worst_offense
    assert_equal "Chicago Fire", @stats.worst_offense
  end

  def test_best_offense
    assert_equal "FC Dallas", @stats.best_offense
  end

  def test_it_can_count_teams
    assert_equal 5, @stats.count_of_teams
  end

  def test_it_can_see_highest_scoring_home_team
    assert_equal "DC United", @stats.highest_scoring_home_team
  end

  def test_it_can_see_highest_scoring_visitor
    assert_equal "FC Dallas",   @stats.highest_scoring_visitor
  end

  def test_it_knows_lowest_scoring_home_team
    assert_equal "Atlanta United", @stats.lowest_scoring_home_team
  end

  def test_it_knows_lowest_scoring_visitor_team
    assert_equal "Chicago Fire", @stats.lowest_scoring_visitor_team
  end

# ~~~ SEASON METHOD TESTS~~~

  def test_it_can_list_winningest_coach_by_season
    assert_equal "Claude Julien", @stats.winningest_coach("20142015")
  end

  def test_it_can_determine_the_worst_coach_by_season
    assert_equal "Jon Cooper", @stats.worst_coach("20142015")
  end

  def test_it_can_determine_team_with_most_season_tackles
    assert_equal "Chicago Fire", @stats.most_tackles("20122013")
  end

  def test_it_can_determine_team_with_fewest_season_tackles
    assert_equal "DC United", @stats.fewest_tackles("20122013")
  end
# ~~~ SEASON METHOD TESTS~~~

  def test_it_can_get_most_accurate_team_for_season
    assert_equal "FC Dallas", @stats.most_accurate_team("20132014")
  end

  def
     test_it_can_get_least_accurate_team_for_season
    assert_equal "Atlanta United", @stats.least_accurate_team("20132014")
  end

# ~~~ TEAM METHOD TESTS~~~

  def test_it_can_calc_average_win_percentage
    assert_equal 0.32, @stats.average_win_percentage("4")
  end

  # def test_it_can_return_array_of_seasons
  #   expected = ["20122013", "20132014", "20142015", "20152016", "20162017", "20172018"]
  #   assert_equal expected, @stats.all_seasons
  # end

  def test_it_can_return_a_nested_hash_with_all_teams_season_win_percentages
    expected = {
      "1" => {
        "20122013" => 100.0,
        "20132014" => 40.0,
        "20142015" => 28.57,
        "20152016" => 50.0,
        "20162017" => 25.0,
        "20172018" => 33.33
      },
      "4" => {
        "20122013" => 25.0,
        "20132014" => 40.0,
        "20142015" => 42.86,
        "20152016" => 33.33,
        "20162017" => 0.0,
        "20172018" => 0.0
      },
      "6" => {
        "20122013" => 100.0,
        "20132014" => 50.0,
        "20142015" => 66.67,
        "20152016" => 66.67,
        "20162017" => 50.0,
        "20172018" => 50.0
      },
      "14" => {
        "20122013" => 0.0,
        "20132014" => 25.0,
        "20142015" => 0.0,
        "20152016" => 100.0,
        "20162017" => 60.0,
        "20172018" => 60.0
      },
      "26" => {
        "20122013" => 0.0,
        "20132014" => 33.33,
        "20142015" => 42.86,
        "20152016" => 0.0,
        "20162017" => 50.0,
        "20172018" => 75.0
      },
    }
    assert_equal expected, @stats.all_teams_all_seasons_win_percentages
  end

  def test_it_can_return_a_teams_best_season
    assert_equal "20122013", @stats.best_season("1")
    assert_equal "20142015", @stats.best_season("4")
    assert_equal "20122013", @stats.best_season("6")
    assert_equal "20152016", @stats.best_season("14")
    assert_equal "20172018", @stats.best_season("26")
  end

  #Took the first season in examples were there were multiple options
  def test_it_can_return_a_teams_worst_season
    assert_equal "20162017", @stats.worst_season("1")
    assert_equal "20162017", @stats.worst_season("4")
    assert_equal "20132014", @stats.worst_season("6")
    assert_equal "20122013", @stats.worst_season("14")
    assert_equal "20122013", @stats.worst_season("26")
  end

  def test_it_can_see_team_info
    expected1 = {
      "team_id"=>"1",
      "franchise_id"=>"23",
      "team_name"=>"Atlanta United",
      "abbreviation"=>"ATL",
      "link"=>"/api/v1/teams/1"
    }
    expected2 = {
      "team_id"=>"14",
      "franchise_id"=>"31",
      "team_name"=>"DC United",
      "abbreviation"=>"DC",
      "link"=>"/api/v1/teams/14"
    }

    assert_equal expected1, @stats.team_info("1")
    assert_equal expected2, @stats.team_info("14")
  end

  def test_it_can_see_highest_number_of_goals_by_team_in_a_game
    assert_equal 4, @stats.most_goals_scored("1")
  end

  def test_it_can_see_lowest_number_of_goals_by_team_in_a_game
    assert_equal 1, @stats.fewest_goals_scored("14")
  end

  def test_it_can_calc_favorite_opponent
    assert_equal "Chicago Fire", @stats.favorite_opponent("6")
  end

  def test_it_can_calc_rival
    assert_equal "FC Cincinnati", @stats.rival("6")
  end

end
