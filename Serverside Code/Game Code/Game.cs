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

        // -- MOVEMENT HANDLING --

        public double movementSpeed = 4;

        // ---------------------------------------

        // -- DASH HANDLING --

        public Boolean isDashing = false;

        public Boolean dashOnCooldown = false;
        public int dashCooldownRemainingTime = 60;
        public int dashCooldownOriginalTime = 60;

        public double dashAngle;
        public double dashAmount = 30;
        public double dashAmountOriginal = 30;
        public double dashDecrement = 2;

        // ---------------------------------------
    }

    public class Skeleton
    {

        // ---------------------------------------

        // -- COORDINATES --

        public double x = 0;
        public double y = 0;

        // ---------------------------------------

        // -- MOVEMENT HANDLING --

        public double movementSpeed = 2;
        public double movementAngle;

        // ---------------------------------------
    }

    [RoomType("Multiplayer")]
    public class GameCode : Game<Player>
    {

        private int maxPlayers = 2;
        private Skeleton skeleton = new Skeleton();

        // GameStarted triggers when first player enters the room.
        public override void GameStarted()
        {
            
            // ---------------------------------------

            // -- GAME LOOP --

            AddTimer(delegate
            {

                Broadcast("gameLoop");

                dashController();
                skeletonController();

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

            player.Send("addSkeleton", skeleton.x, skeleton.y);
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

                    // If player is dashing, we don't want her to move.
                    if (player.isDashing) return;

                    double angle = message.GetFloat(0);

                    player.x -= Math.Cos(angle) * player.movementSpeed;
                    player.y -= Math.Sin(angle) * player.movementSpeed;

                    Broadcast("move", player.Id, angle, player.movementSpeed);

                    break;

                // ---------------------------------------

                case "dash":

                    // If player is dashing or on cooldown, we don't want her to dash yet.
                    if (player.isDashing || player.dashOnCooldown) return;

                    player.isDashing = true;
                    player.dashAngle = message.GetFloat(0);

                    break;

                    // ---------------------------------------
            }
        }

        // ---------------------------------------
        
        // -- DASH CONTROLLER --

        private void dashController()
        {
            // Check if a player is dashing.
            foreach (Player p in Players)
            {
                // ---------------------------------------

                //  -- DASH COOLDOWN --

                // If dash is on cooldown, we run DASH COOLDOWN code but not DASH MOVEMENT code.
                if (p.dashOnCooldown)
                {

                    // Inform to player its current cooldown time.
                    p.Send("dashCooldown", p.dashCooldownRemainingTime);

                    // Reduce cooldown current time.
                    p.dashCooldownRemainingTime--;

                    // Check cooldown remaining time.
                    if (p.dashCooldownRemainingTime <= 0)
                    {
                        // Enable dash again.
                        // Reset cooldown time when it reachs 0.
                        p.dashCooldownRemainingTime = p.dashCooldownOriginalTime;
                        p.dashOnCooldown = false;

                        p.dashAmount = p.dashAmountOriginal;
                    }

                    return;
                }

                // ---------------------------------------

                // -- DASH MOVEMENT --

                // If a player is dashing, this code will run.
                if (p.isDashing)
                {

                    // Move her position towards dash angle.
                    p.x -= Math.Cos(p.dashAngle) * p.dashAmount;
                    p.y -= Math.Sin(p.dashAngle) * p.dashAmount;

                    // Update position to all players.
                    Broadcast("dash", p.Id, p.dashAngle, p.dashAmount);

                    // Reduce dashAmount value.
                    p.dashAmount -= p.dashDecrement;

                    // If dashAmount value equals 0, dash has finished.
                    if (p.dashAmount <= 0)
                    {
                        p.isDashing = false;
                        p.dashOnCooldown = true;
                    }
                }

                // ---------------------------------------
            }
        }

        // ---------------------------------------

        // -- SKELETON CONTROLLER --

        private void skeletonController()
        {

            // Move skeleton coordinates to first player.

            foreach (Player p in Players)
            {

                double angle = Math.Atan2(p.y - skeleton.y, p.x - skeleton.x);

                skeleton.x += Math.Cos(angle) * skeleton.movementSpeed;
                skeleton.y += Math.Sin(angle) * skeleton.movementSpeed;

                Broadcast("moveSkeleton", angle, skeleton.movementSpeed);
            }
        }

        // ---------------------------------------

        // 

        // ---------------------------------------
    }
}
