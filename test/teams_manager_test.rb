require "./test/test_helper"

class TeamsManagerTest < Minitest::Test
  def setup
    @stat_tracker = StatTracker.from_csv
    @teams_manager = @stat_tracker.teams_manager
  end

  def test_it_exists
    assert_instance_of TeamsManager, @teams_manager
  end

  def test_it_can_count_teams
    assert_equal 5, @teams_manager.count_of_teams
  end

  def test_it_can_return_array_of_all_team_ids
    expected = ["1", "4", "26", "14", "6"]
    assert_equal expected, @teams_manager.all_team_ids
  end

  def test_team_identifier_can_return_team_string
    assert_equal "Atlanta United", @teams_manager.team_identifier("1")
    assert_equal "Chicago Fire", @teams_manager.team_identifier("4")
    assert_equal "FC Cincinnati", @teams_manager.team_identifier("26")
    assert_equal "DC United", @teams_manager.team_identifier("14")
    assert_equal "FC Dallas", @teams_manager.team_identifier("6")
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
    expected3 = {
      "team_id"=>"6",
      "franchise_id"=>"6",
      "team_name"=>"FC Dallas",
      "abbreviation"=>"DAL",
      "link"=>"/api/v1/teams/6"
    }

    assert_equal expected1, @teams_manager.team_info("1")
    assert_equal expected2, @teams_manager.team_info("14")
    assert_equal expected3, @teams_manager.team_info("6")
  end

end
