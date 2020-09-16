# Futbol

## Group Members
* Joshua Carey, Jake Heft, William Dunlap, Hope Gochnour

## What is this?
* A repo for a group project for The Turing School. The four of us have been tasked with making a program that can extrapolate statistics from what is currently completely made-up data about fake futbol/soccer teams.

## How is it organized?
* In the beginning, we started with only StatTracker. It worked, but was cumbersome and did too many things, so we pulled some of its responsibility out to classes that could handle the different CSV files on their own. This led to the game, team, and game_team classes, but eventually we found that we could do more with manager classes for each of those. They would handle all of the calculations relating to the base classes, and StatTracker would be left responsible for directing the file reading and reporting the math done by methods in the manager classes, which is basically as far as we can go while staying true to our instructions. Aside from that, we have a module active in Stat Tracker and the Manager classes, called "Manageable". We've also started developing subclasses for GameTeamsManager, but it's not completely clear whether we'll finish them before project turn-in.

* The file structure goes like this:

```
              StatTracker                                 >
      /            |               \                      > -> Manageable(module)
GamesManager  TeamsManager        GameTeamsManager        >
    |              |             /         \          \
   Game           Team    TacklesManager  WinsManager   GoalsManager

                                   |
                                GameTeam
```

## How did you decide how to handle what?
* Please check the DTR file. That includes our most up-to-date agreement on the process, but in summary, we agreed to meet after class during the week and to generally use Slack to handle our conversations, outside of PR-related notes (left on GitHub) and Zoom calls during check-ins.
* In choosing which methods to take or responsibilities to shoulder, that has been mostly left up to the individual members. We each took sets of methods, usually related ones, and worked on those until everything we needed to make was done. In the process, the repo underwent some restructuring, then some refactoring and test focus at the end. Our highest priority was to pass the spec harness for this project.

## Has this been challenging?
* Absolutely yes. Math is hard, first of all.
* The process required a lot of reading in to what the Spec wanted from us, plus learning how to retool the basic structure of our repo, how to create rake-related files, how to work with the gem "simplecov," and how to understand both what is required to make a spec harness work and how that should influence our code.
* We learned how to refer to methods in other classes and how calling up the class chain works.
* We've learned to put the basic pillars of OOP to use in a medium-scale project.
* We're constantly learning how GitHub/Git works.
