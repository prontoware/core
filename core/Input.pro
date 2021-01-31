////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// IInputTarget
////////////////////////////////////////////////////////////////////////////////////////////////////

// Object receives input.
interface IInputTarget
{
	// Register for input from the keyboard (physical, on-screen, voice directed etc.)
	void listenToKeyboard(IKeyboardListener listener)
	{
		if(globalInputListeners.keyboardListeners.contains(listener) == false)
			globalInputListeners.keyboardListeners.add(listener);
	}

	// Unregister for input from the keyboard (physical, on-screen, voice directed etc.)
	void unlistenToKeyboard(IKeyboardListener listener)
	{
		globalInputListeners.keyboardListeners.removeElement(listener);
	}

	// Register for input from mice, touchpads, and other pointing devices.
	void listenToMouse(IMouseListener listener)
	{
		if(globalInputListeners.mouseListeners.contains(listener) == false)
			globalInputListeners.mouseListeners.add(listener);
	}

	// Unregister for input from mice, touchpads, and other pointing devices.
	void unlistenToMouse(IMouseListener listener)
	{
		globalInputListeners.mouseListeners.removeElement(listener);
	}

	// Register for input from touch screens.
	void listenToTouch(ITouchListener listener)
	{
		if(globalInputListeners.touchListeners.contains(listener) == false)
			globalInputListeners.touchListeners.add(listener);
	}

	// Unregister for input from touch screens.
	void unlistenToTouch(ITouchListener listener)
	{
		globalInputListeners.touchListeners.removeElement(listener);
	}

	// Register for input from gamepads and joysticks.
	void listenToGamepad(IGamepadListener listener)
	{
		if(globalInputListeners.gamepadListeners.contains(listener) == false)
			globalInputListeners.gamepadListeners.add(listener);
	}

	// Unregister for input from gamepads and joysticks.
	void unlistenToGamepad(IGamepadListener listener)
	{
		globalInputListeners.gamepadListeners.removeElement(listener);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// InputTarget
////////////////////////////////////////////////////////////////////////////////////////////////////

// Tracks input listeners to this target and provides utilites to dispatch events, track input
// device state etc.
class InputTarget implements IInputTarget
{
	ArrayList<IKeyboardListener> keyboardListeners = ArrayList<IKeyboardListener>();
	ArrayList<IMouseListener>    mouseListeners    = ArrayList<IMouseListener>();
	ArrayList<ITouchListener>    touchListeners    = ArrayList<ITouchListener>();
	ArrayList<IGamepadListener>  gamepadListeners  = ArrayList<IGamepadListener>();

	AllKeysState allKeys(); // for keybaord

	// Initialize key states etc.
	void constructor()
	{
	}

	// Register for input from the keyboard (physical, on-screen, voice directed etc.) to this target.
	void listenToKeyboard(IKeyboardListener listener)
	{
		if(keyboardListeners.contains(listener) == false)
			keyboardListeners.add(listener);
	}

	// Unregister for input from the keyboard (physical, on-screen, voice directed etc.) to this target.
	void unlistenToKeyboard(IKeyboardListener listener)
	{
		keyboardListeners.removeElement(listener);
	}

	// Register for input from mice, touchpads, and other pointing devices to this target.
	void listenToMouse(IMouseListener listener)
	{
		if(mouseListeners.contains(listener) == false)
			mouseListeners.add(listener);
	}

	// Unregister for input from mice, touchpads, and other pointing devices to this target.
	void unlistenToMouse(IMouseListener listener)
	{
		mouseListeners.removeElement(listener);
	}

	// Register for input from touch screens to this target.
	void listenToTouch(ITouchListener listener)
	{
		if(touchListeners.contains(listener) == false)
			touchListeners.add(listener);
	}

	// Unregister for input from touch screens to this target.
	void unlistenToTouch(ITouchListener listener)
	{
		touchListeners.removeElement(listener);
	}

	// Register for input from gamepads and joysticks to this target.
	void listenToGamepad(IGamepadListener listener)
	{
		if(gamepadListeners.contains(listener) == false)
			gamepadListeners.add(listener);
	}

	// Unregister for input from gamepads and joysticks to this target.
	void unlistenToGamepad(IGamepadListener listener)
	{
		gamepadListeners.removeElement(listener);
	}

	// Dispatch input events to all listeners.
	void dispatchKeyEvents(KeyEvent[] keyEvents)
	{
		if(keyEvents == null)
			return; // nothing to do

		for(u64 ke=0; ke<keyEvents.length(); ke++)
		{
			allKeys.track(keyEvents[ke]);
			keyEvents[ke].allKeys = allKeys.keysState; // so each KeyEvent can check all other keys for state
		}
		
		for(u64 k=0; k<keyboardListeners.size(); k++)
		{
			for(u64 e=0; e<keyEvents.length(); e++)
			{
				keyboardListeners[k].onKeyEvent(keyEvents[e]);
			}
		}

		for(u64 x=0; x<keyEvents.length(); x++)
			keyEvents[x] = null;
	}

	// Dispatch input events to all listeners.
	void dispatchMouseEvents(MouseEvent[] mouseEvents)
	{
		if(mouseEvents == null)
			return; // nothing to do
		
		for(u64 m=0; m<mouseListeners.size(); m++)
		{
			for(u64 e=0; e<mouseEvents.length(); e++)
			{
				MouseEvent mouseEvent = mouseEvents[e];
				mouseListeners[m].onMouseEvent(mouseEvent);
			}
		}

		for(u64 x=0; x<mouseEvents.length(); x++)
			mouseEvents[x] = null;
	}

	// Dispatch input events to all listeners.
	void dispatchTouchEvents(TouchEvent[] touchEvents)
	{
		if(touchEvents == null)
			return; // nothing to do

		for(u64 t=0; t<touchListeners.size(); t++)
		{
			for(u64 e=0; e<touchEvents.length(); e++)
			{
				TouchEvent touchEvent = touchEvents[e];
				touchListeners[t].onTouchEvent(touchEvent);
			}
		}

		for(u64 x=0; x<touchEvents.length(); x++)
			touchEvents[x] = null;
	}

	// Dispatch input events to all listeners.
	void dispatchGamepadEvents(GamepadEvent[] gamepadEvents)
	{
		if(gamepadEvents == null)
			return; // nothing to do

		for(u64 g=0; g<gamepadListeners.size(); g++)
		{
			for(u64 e=0; e<gamepadEvents.length(); e++)
			{
				GamepadEvent gamepadEvent = gamepadEvents[e];
				gamepadListeners[g].onGamepadEvent(gamepadEvent);
			}
		}

		for(u64 x=0; x<gamepadEvents.length(); x++)
			gamepadEvents[x] = null;
	}
}