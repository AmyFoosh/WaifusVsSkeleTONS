using System;
using PlayerIO.GameLibrary;

namespace MyGame
{
    public class Player : BasePlayer
    {

        // ---------------------------------------

        // -- COORDINATES --

        public double x = 0;
        public double y = 0;

        // ---------------------------------------

        // -- DASH HANDLING --

        public Boolean canDash = true;
        public double dashAngle;
        public double dashAmount = 30;
        public double dashAmountOriginal = 30;
        public double dashDecrement = 2;

        // ---------------------------------------
    }

    [RoomType("Multiplayer")]
    public class GameCode : Game<Player>
    {

        private int maxPlayers = 2;

        // GameStarted triggers when first player enters the room.
        public override void GameStarted()
        {
            // ---------------------------------------
         
            AddTimer(delegate
            {

                Broadcast("gameLoop");

                foreach (Player p in Players)
                {

                    if (!p.canDash)
                    {

                        p.x -= Math.Cos(p.dashAngle) * p.dashAmount;
                        p.y -= Math.Sin(p.dashAngle) * p.dashAmount;

                        Broadcast("dash", p.Id, p.dashAngle, p.dashAmount);

                        p.dashAmount -= p.dashDecrement;

                        if (p.dashAmount <= 0)
                        {
                            p.dashAmount = p.dashAmountOriginal;
                            p.canDash = true;
                        }
                    }
                }

            }, 25);

            // ---------------------------------------
        }

        // GameClosed triggers when last player leaves the room.
        public override void GameClosed()
        {

        }

        // UserJoined triggers when a player enters the room.
        public override void UserJoined(Player player)
        {
            Broadcast("connected", player.Id, player.x, player.y);
            player.Send("myID", player.Id);

            foreach (Player p in Players)
            {
                if (player.Id != p.Id)
                {
                    player.Send("connected", p.Id, p.x, p.y);
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

                    if (!player.canDash) return;

                    double angle = message.GetFloat(0);

                    player.x -= Math.Cos(angle) * 4;
                    player.y -= Math.Sin(angle) * 4;

                    Broadcast("move", player.Id, angle);

                    break;

                // ---------------------------------------

                case "dash":

                    if (!player.canDash) return;

                    player.canDash = false;
                    player.dashAngle = message.GetFloat(0);

                    break;


                    // ---------------------------------------
            }
        }
    }
}
