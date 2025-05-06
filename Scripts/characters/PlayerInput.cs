using Game.Core;
using Godot;
// using System;

namespace Game.Gameplay{
public partial class PlayerInput : Node
{
	// Called when the node enters the scene tree for the first time.
	[ExportCategory("Player Input")]
	[Export] public double HoldThreshold = 0.1f; // Time in seconds to consider a button as "held"
	[Export] public double HoldTime = 0.0f; // Time in seconds the button has been held
	public override void _Ready()
	{
		Logger.Info("Loading PlayerInput...");
	}

	// // Called every frame. 'delta' is the elapsed time since the previous frame.
	// public override void _Process(double delta)
	// {
	}
}
