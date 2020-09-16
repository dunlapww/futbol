# Futbol

## Group Members
* Joshua Carey, Jake Heft, William Dunlap, Hope Gochnour

## What is this?
* A repo for a group project for The Turing School. The four of us have been tasked with making a program that can extrapolate statistics from what is currently completely made-up data about fake futbol/soccer teams. It can be run by running the runner file (type "ruby runner.rb" in your command line of choice).

## How is it organized? Who did what?
* In the beginning, we started with only StatTracker. It worked, but was cumbersome and did too many things, so we pulled some of its responsibility out to classes that could handle the different CSV files on their own. This led to the game, team, and game_team classes, but eventually we found that we could do more with manager classes for each of those. They would handle all of the calculations relating to the base classes, and StatTracker would be left responsible for directing the file reading and reporting the math done by methods in the manager classes, which is basically as far as we can go while staying true to our instructions. Aside from that, we have a module active in Stat Tracker and the Manager classes, called "Manageable".

* The file structure goes like this:

```
          StatTracker                         >
  /           |             \                 > Manageable(module)
GamesManager  TeamsManager  GameTeamsManager  >
    |             |                 |
  Game          Team              GameTeam
```
