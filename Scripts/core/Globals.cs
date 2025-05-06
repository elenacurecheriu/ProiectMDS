using Godot;
using System;

namespace Game.Core{

// This class is used to store global variables and functions that can be accessed from anywhere in the game.
// It is a singleton, meaning that there will only be one instance of this class in the game.
// It is also a Node, meaning that it can be added to the scene tree and can be used to store references to other nodes.

	public partial class Globals : Node
	{
		public static Globals Instance { get; private set; }

		[ExportCategory("Gameplay")]
		[Export] public int GRID_SIZE = 32; //cred ca putem orice vrem noi aici care sa fie constant


		// Called when the node enters the scene tree for the first time.
		public override void _Ready()
		{
			Instance = this;
			Logger.Info("Loading Globals...");
		}

	}
}
