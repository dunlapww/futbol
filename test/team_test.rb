require "./test/test_helper"

class TeamTest < Minitest::Test

  def setup
    @stat_tracker = StatTracker.from_csv
    @team = Team.new({
      team_id: "1",
      franchise_id: "23",
      team_name: "Atlanta United",
      abbreviation: "ATL"
    })
  end

  def test_it_exists
    assert_instance_of Team, @team
  end

end
