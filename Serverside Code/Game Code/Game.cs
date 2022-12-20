using System;
using PlayerIO.GameLibrary;

namespace MyGame
{
    public class Player : BasePlayer
    {
        public double x = 0;
        public double y = 0;
    }

    [RoomType("Multiplayer")]
    public class GameCode : Game<Player>
    {

        private int maxPlayers = 2;

        // GameStarted triggers when first player enters the room.
        public override void GameStarted()
        {

        }

        // GameClosed triggers when last player leaves the room.
        public override void GameClosed()
        {

        }

        // UserJoined triggers when a player enters the room.
        public override void UserJoined(Player player)
        {
            Broadcast("connected", player.Id);
            player.Send("myID", player.Id);

            foreach (Player p in Players)
            {
                if (player.Id != p.Id)
                {
                    player.Send("playersPositions", p.Id, p.x, p.y);
                }
            }
        }

        // UserLeft triggers when a player leaves the room.
        public override void UserLeft(Player player)
        {
            Broadcast("disconnected", player.Id);
        }

        // AllowUserJoins allows a user to join the room when it returns true.
        public override bool AllowUserJoin(Player player)
        {

            if (PlayerCount == maxPlayers) return false;
            return true;
        }

        public override void GotMessage(Player player, Message message)
        {

            switch (message.Type)
            {
                // ---------------------------------------

                case "move":

                    double angle = message.GetFloat(0);

                    player.x -= Math.Cos(angle) * 4;
                    player.y -= Math.Sin(angle) * 4;

                    Broadcast("move", player.Id, angle);

                    break;

                // ---------------------------------------
            }
        }
    }
}
