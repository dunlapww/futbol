require "./test/test_helper"

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

  def test_it_can_get_game_teams_by_team_id
    assert_equal ["4", "14", "1", "6", "26"], @game_teams_manager.game_teams_by_team_id("20132014").keys
    assert_equal 5, @game_teams_manager.game_teams_by_team_id("20132014")["4"].size
    assert_equal 4, @game_teams_manager.game_teams_by_team_id("20132014")["14"].size
    assert_equal 5, @game_teams_manager.game_teams_by_team_id("20132014")["1"].size
    assert_equal 4, @game_teams_manager.game_teams_by_team_id("20132014")["6"].size
    assert_equal 6, @game_teams_manager.game_teams_by_team_id("20132014")["26"].size
  end

  def test_it_can_get_games_from_season_game_ids
    season_game_ids = @game_teams_manager.game_ids_per_season("20132014")
    assert_equal GameTeam, @game_teams_manager.find_game_teams(season_game_ids)[0].class
    assert_equal (season_game_ids.count * 2), @game_teams_manager.find_game_teams(season_game_ids).count
  end

  def test_it_can_filter_by_team_id
    assert @game_teams_manager.filter_by_team_id("4").all? do |gameteam|
      gameteam.team_id == "4"
    end
  end

  def test_it_can_get_number_of_games_by_team
    expected = {"1"=>23, "4"=>22, "14"=>21, "6"=>20, "26"=>20}
    assert_equal expected, @game_teams_manager.games_containing_team
  end

end
