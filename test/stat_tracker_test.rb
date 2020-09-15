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

  def test_it_can_find_total_games ###
    assert_equal 53, @stats.total_games
  end

  def test_it_can_fetch_season_win_percentage
    assert_equal 28.57, @stats.fetch_season_win_percentage("1", "20142015")
    assert_equal 42.86, @stats.fetch_season_win_percentage("4", "20142015")
    assert_equal 66.67, @stats.fetch_season_win_percentage("6", "20142015")
    assert_equal 42.86, @stats.fetch_season_win_percentage("26", "20142015")
  end

  def test_it_can_create_array_of_all_team_ids
    expected = ["1", "4", "26", "14", "6"]
    assert_equal expected, @stats.fetch_all_team_ids
  end

  def test_it_can_get_team_name_from_team_id
    assert_equal "Chicago Fire", @stats.fetch_team_identifier("4")
  end

  def test_it_can_sum_game_goals
    assert_equal 211, @stats.total_goals
    season_1415 = @stats.season_group["20142015"]
    assert_equal 67, @stats.total_goals(season_1415)
  end

  def test_it_can_return_array_of_game_ids_per_season
    expected = ["2012020030", "2012020133", "2012020355", "2012020389"]
    assert_equal expected, @stats.fetch_game_ids_by_season("20122013")
  end

  def test_it_can_group_games_by_season
    assert_equal ["20142015", "20172018", "20152016", "20132014", "20122013", "20162017"], @stats.season_group.keys

    @stats.season_group.values.each do |games|
      games.each do |game|
        assert_instance_of Game, game
      end
    end
  end

  def test_it_can_get_a_game
    assert_equal "2014021002", @stats.get_game("2014021002").game_id
  end

  def test_it_can_get_opponent_id
    assert_equal "14", @stats.get_opponent_id("2014021002","6")

    game = @stats.get_game("2014020371")
    assert_equal "26", @stats.get_opponent_id("2014020371","6")
  end

  def test_it_can_create_gameteams_by_opponent
    assert_equal ["14", "1", "4", "26"], @stats.game_teams_by_opponent("6").keys
    assert_equal 5, @stats.game_teams_by_opponent("6")["14"].size
    assert_equal 5, @stats.game_teams_by_opponent("6")["1"].size
    assert_equal 6, @stats.game_teams_by_opponent("6")["4"].size
    assert_equal 4, @stats.game_teams_by_opponent("6")["26"].size
  end

  def test_it_can_get_game_ids_in_season
    expected = ["2013020088", "2013020203", "2013020285", "2013020321", "2013020334", "2013020371", "2013020649", "2013020667", "2013020739", "2013021160", "2013021198", "2013021221"]
    assert_equal expected, @stats.fetch_game_ids_by_season("20132014")
  end

  def test_it_can_get_games_from_season_game_ids
    season_game_ids = @stats.game_ids_per_season("20132014")
    assert_equal GameTeam, @stats.find_game_teams(season_game_ids)[0].class
    assert_equal (season_game_ids.count * 2), @stats.find_game_teams(season_game_ids).count
  end

# ~~~ GAME METHOD TESTS~~~
  def test_it_can_get_percentage_away_games_won
    assert_equal 0.3, @stats.percentage_visitor_wins
  end

  def test_it_can_get_percentage_ties
    assert_equal 0.15, @stats.percentage_ties
  end

  def test_it_can_get_percentage_home_wins
    assert_equal 0.55, @stats.percentage_home_wins
  end

  def test_it_can_see_count_of_games_by_season
    expected = {"20142015"=>16, "20172018"=>9, "20152016"=>5, "20132014"=>12, "20122013"=>4, "20162017"=>7}
    assert_equal expected, @stats.count_of_games_by_season
  end
  # DUPLICATE - In other test class - keep in both?
  def test_it_can_get_average_goals_by_season
    expected = {"20142015"=>4.19, "20172018"=>3.78, "20152016"=>3.8, "20132014"=>3.92, "20122013"=>3.5, "20162017"=>4.29}
    assert_equal expected , @stats.average_goals_by_season
  end

  def test_it_can_get_avg_goals_per_game
    assert_equal 3.98, @stats.average_goals_per_game
  end

  def test_it_can_determine_highest_and_lowest_game_score
    assert_equal 1, @stats.lowest_total_score
    assert_equal 6, @stats.highest_total_score
  end

# ~~~ LEAGUE METHOD TESTS~~~
  # DUPLICATE - In other test class - keep in both?
  def test_worst_offense
    assert_equal "Chicago Fire", @stats.worst_offense
  end
  # DUPLICATE - In other test class - keep in both?
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
    assert_equal "Chicago Fire", @stats.lowest_scoring_visitor
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
