require "./test/test_helper"

class GameTeamTest < Minitest::Test

  def setup
    @game_team_1 = GameTeam.new({
      game_id: "2014020006",
      team_id: "1",
      hoa: "away",
      result: "WIN",
      settled_in: "REG",
      head_coach: "Peter DeBoer",
      goals: 4,
      shots: 6,
      pim: 10,
      ppg: 0,
      ppo: 3,
      fowp: 42.9,
      tackles: 36,
      giveaways: 4,
      takeaways: 5,
    })
  end

  def test_it_exists
    assert_instance_of GameTeam, @game_team_1
  end
end
