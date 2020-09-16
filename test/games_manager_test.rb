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
    assert_equal 1, @games_manager.total_score(:min_by)
  end

  def test_it_can_find_the_highest_total_score
    assert_equal 6, @games_manager.total_score(:max_by)
  end

  def test_it_can_get_percentage_ties
    assert_equal 0.15, @games_manager.percentage_ties
  end

  def test_it_can_get_percentage_home_wins
    assert_equal 0.55, @games_manager.percentage_wins(:home_is_winner?)
  end

  def test_it_can_get_percentage_visitor_games_won
    assert_equal 0.30, @games_manager.percentage_wins(:visitor_is_winner?)
  end

  def test_it_can_count_total_games
    assert_equal 53, @games_manager.total_games
  end

  def test_it_can_group_games_by_season
    assert_equal ["20142015", "20172018", "20152016", "20132014", "20122013", "20162017"], @games_manager.season_group.keys

    @games_manager.season_group.values.each do |games|
      games.each do |game|
        assert_instance_of Game, game
      end
    end
  end

  def test_it_can_sum_game_goals
    assert_equal 211, @games_manager.total_goals
    season_1415 = @games_manager.season_group["20142015"]
    assert_equal 67, @games_manager.total_goals(season_1415)
  end

  def test_it_can_get_avg_goals_per_game
    assert_equal 3.98, @games_manager.average_goals_per_game
  end

  def test_it_can_get_average_goals_by_season
    expected = {
      "20142015"=>4.19,
      "20172018"=>3.78,
      "20152016"=>3.8,
      "20132014"=>3.92,
      "20122013"=>3.5,
      "20162017"=>4.29
    }
    assert_equal expected, @games_manager.average_goals_by_season
  end

  def test_it_can_show_count_of_games_by_season
    expected = {"20142015"=>16, "20172018"=>9, "20152016"=>5, "20132014"=>12, "20122013"=>4, "20162017"=>7}
    assert_equal expected, @games_manager.count_of_games_by_season
  end

  def test_it_can_return_all_game_ids_for_season
    expected = ["2012020030", "2012020133", "2012020355", "2012020389"]
    assert_equal expected, @games_manager.game_ids_by_season("20122013")
  end

  def test_it_can_count_total_home_wins_aaa
    assert_equal 1, @games_manager.team_wins_as("1", "20142015", :home_team_id, :home_is_winner?)
    assert_equal 1, @games_manager.team_wins_as("4", "20142015", :home_team_id, :home_is_winner?)
    assert_equal 3, @games_manager.team_wins_as("6", "20142015", :home_team_id, :home_is_winner?)
    assert_equal 0, @games_manager.team_wins_as("14", "20142015", :home_team_id, :home_is_winner?)
    assert_equal 2, @games_manager.team_wins_as("26", "20142015", :home_team_id, :home_is_winner?)
  end

  def test_it_can_count_total_away_wins_bbb
    assert_equal 1, @games_manager.team_wins_as("1", "20142015", :away_team_id, :visitor_is_winner?)
    assert_equal 2, @games_manager.team_wins_as("4", "20142015", :away_team_id, :visitor_is_winner?)
    assert_equal 1, @games_manager.team_wins_as("6", "20142015", :away_team_id, :visitor_is_winner?)
    assert_equal 1, @games_manager.team_wins_as("26", "20142015", :away_team_id, :visitor_is_winner?)
  end

  def test_it_can_count_total_number_of_wins_per_season
    assert_equal 2, @games_manager.total_team_wins("1", "20142015")
    assert_equal 3, @games_manager.total_team_wins("4", "20142015")
    assert_equal 4, @games_manager.total_team_wins("6", "20142015")
    assert_equal 3, @games_manager.total_team_wins("26", "20142015")
  end

  def test_it_can_count_total_games_for_team_in_season
    assert_equal 7, @games_manager.total_team_games_per_season("1", "20142015")
    assert_equal 7, @games_manager.total_team_games_per_season("4", "20142015")
    assert_equal 6, @games_manager.total_team_games_per_season("6", "20142015")
    assert_equal 5, @games_manager.total_team_games_per_season("14", "20142015")
    assert_equal 7, @games_manager.total_team_games_per_season("26", "20142015")
  end

  def test_it_can_determine_season_win_percentage
    assert_equal 0.29, @games_manager.season_win_percentage("1", "20142015")
    assert_equal 0.43, @games_manager.season_win_percentage("4", "20142015")
    assert_equal 0.67, @games_manager.season_win_percentage("6", "20142015")
    assert_equal 0.43, @games_manager.season_win_percentage("26", "20142015")
  end

  def test_it_can_return_array_of_seasons
    expected = ["20122013", "20132014", "20142015", "20152016", "20162017", "20172018"]
    assert_equal expected, @games_manager.all_seasons
  end

  def test_it_can_return_a_hash_with_teams_season_win_percentages
    expected1 = {
        "20122013" => 1.0,
        "20132014" => 0.4,
        "20142015" => 0.29,
        "20152016" => 0.5,
        "20162017" => 0.25,
        "20172018" => 0.33
      }
    expected2 = {
        "20122013" => 0.25,
        "20132014" => 0.4,
        "20142015" => 0.43,
        "20152016" => 0.33,
        "20162017" => 0.0,
        "20172018" => 0.0
      }
    expected3 = {
        "20122013" => 1.0,
        "20132014" => 0.5,
        "20142015" => 0.67,
        "20152016" => 0.67,
        "20162017" => 0.5,
        "20172018" => 0.5
      }
    expected4 = {
        "20122013" => 0.0,
        "20132014" => 0.25,
        "20142015" => 0.0,
        "20152016" => 1.0,
        "20162017" => 0.6,
        "20172018" => 0.6
      }
    expected5 = {
        "20122013" => 0.0,
        "20132014" => 0.33,
        "20142015" => 0.43,
        "20152016" => 0.0,
        "20162017" => 0.5,
        "20172018" => 0.75
      }
    assert_equal expected1, @games_manager.seasons_win_percentages_by_team("1")
    assert_equal expected2, @games_manager.seasons_win_percentages_by_team("4")
    assert_equal expected3, @games_manager.seasons_win_percentages_by_team("6")
    assert_equal expected4, @games_manager.seasons_win_percentages_by_team("14")
    assert_equal expected5, @games_manager.seasons_win_percentages_by_team("26")

  end

  def test_it_can_return_a_teams_best_season
    assert_equal "20122013", @games_manager.worst_or_best_season("1", :max_by)
    assert_equal "20142015", @games_manager.worst_or_best_season("4", :max_by)
    assert_equal "20122013", @games_manager.worst_or_best_season("6", :max_by)
    assert_equal "20152016", @games_manager.worst_or_best_season("14", :max_by)
    assert_equal "20172018", @games_manager.worst_or_best_season("26", :max_by)
  end

  def test_it_can_return_a_teams_worst_season
    assert_equal "20162017", @games_manager.worst_or_best_season("1", :min_by)
    assert_equal "20162017", @games_manager.worst_or_best_season("4", :min_by)
    assert_equal "20132014", @games_manager.worst_or_best_season("6", :min_by)
    assert_equal "20122013", @games_manager.worst_or_best_season("14", :min_by)
    assert_equal "20122013", @games_manager.worst_or_best_season("26", :min_by)
  end

  def test_it_can_get_game
    assert_equal "2014021002", @games_manager.get_game("2014021002").game_id
  end

  def test_it_can_get_opponent_id
    assert_equal "14", @games_manager.get_opponent_id("2014021002","6")
  end

end
