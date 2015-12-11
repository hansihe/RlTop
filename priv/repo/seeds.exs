# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RlTools.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

RlTools.Repo.start_link

RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :skill, request_id: "10", name: "1v1", api_id: "1v1"}
RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :skill, request_id: "11", name: "2v2", api_id: "2v2"}
RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :skill, request_id: "12", name: "3v3 Solo", api_id: "s3v3"}
RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :skill, request_id: "13", name: "3v3", api_id: "3v3"}

#RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :stats, request_id: "Wins", name: "Wins"}
#RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :stats, request_id: "Assists", name: "Assists"}
#RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :stats, request_id: "Shots", name: "Shots"}
#RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :stats, request_id: "Saves", name: "Saves"}
#RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :stats, request_id: "MVPs", name: "MVPs"}
#RlTools.Repo.insert! %RlTools.Leaderboard{request_type: :stats, request_id: "Goals", name: "Goals"}
