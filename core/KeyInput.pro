////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Keys
////////////////////////////////////////////////////////////////////////////////////////////////////

// Keyboard keys.
class Keys
{
	const u16 INPUT_NUM_KEYS = 256;

	const u8 KEY_NULL = 0; // not an event

	// Numbers 0 - 9 ASCII compatible
	const u8 KEY_0 = 48;
	const u8 KEY_1 = 49;
	const u8 KEY_2 = 50;
	const u8 KEY_3 = 51;
	const u8 KEY_4 = 52;
	const u8 KEY_5 = 53;
	const u8 KEY_6 = 54;
	const u8 KEY_7 = 55;
	const u8 KEY_8 = 56;
	const u8 KEY_9 = 57;

	// Letters A - Z ASCII compatible
	const u8 KEY_A = 65;
	const u8 KEY_B = 66;
	const u8 KEY_C = 67;
	const u8 KEY_D = 68;
	const u8 KEY_E = 69;
	const u8 KEY_F = 70;
	const u8 KEY_G = 71;
	const u8 KEY_H = 72;
	const u8 KEY_I = 73;
	const u8 KEY_J = 74;
	const u8 KEY_K = 75;
	const u8 KEY_L = 76;
	const u8 KEY_M = 77;
	const u8 KEY_N = 78;
	const u8 KEY_O = 79;
	const u8 KEY_P = 80;
	const u8 KEY_Q = 81;
	const u8 KEY_R = 82;
	const u8 KEY_S = 83;
	const u8 KEY_T = 84;
	const u8 KEY_U = 85;
	const u8 KEY_V = 86;
	const u8 KEY_W = 87;
	const u8 KEY_X = 88;
	const u8 KEY_Y = 89;
	const u8 KEY_Z = 90;

	// Punctuation ASCII compatible
	const u8 KEY_GRAVE         = 96;
	const u8 KEY_MINUS         = 45;
	const u8 KEY_PLUS          = 43;
	const u8 KEY_LEFT_BRACKET  = 123;
	const u8 KEY_RIGHT_BRACKET = 125;
	const u8 KEY_BACKSLASH     = 92;
	const u8 KEY_TAB           = 9;
	const u8 KEY_SPACE         = 32;
	const u8 KEY_ENTER         = 10;
	const u8 KEY_SEMI_COLON    = 59;
	const u8 KEY_QUOTE         = 39;
	const u8 KEY_COMMA         = 44;
	const u8 KEY_PERIOD        = 46;
	const u8 KEY_FORWARD_SLASH = 47;

	// Numbers (numpad) 0 - 9 ASCII compatible as -128
	const u8 KEY_NUMPAD_0 = 176;
	const u8 KEY_NUMPAD_1 = 177;
	const u8 KEY_NUMPAD_2 = 178;
	const u8 KEY_NUMPAD_3 = 179;
	const u8 KEY_NUMPAD_4 = 180;
	const u8 KEY_NUMPAD_5 = 181;
	const u8 KEY_NUMPAD_6 = 182;
	const u8 KEY_NUMPAD_7 = 183;
	const u8 KEY_NUMPAD_8 = 184;
	const u8 KEY_NUMPAD_9 = 185;

	// Other numpad (not ascii compatible)
	const u8 KEY_NUMPAD_ENTER    = 10;
	const u8 KEY_NUMPAD_PLUS     = 43;
	const u8 KEY_NUMPAD_MINUS    = 45;
	const u8 KEY_NUMPAD_DIVIDE   = 92; // back slash
	const u8 KEY_NUMPAD_MULTIPLY = 42; // asterick

	// Non-ASCII equivalent keys all over 200;

	// Other numpad
	const u8 KEY_NUMPAD_DECIMAL = 201;
	const u8 KEY_NUMPAD_NUMLOCK = 202;

	// Control keys
	const u8 KEY_BACKSPACE   = 203;
	const u8 KEY_LEFT_SHIFT  = 204;
	const u8 KEY_RIGHT_SHIFT = 205;
	const u8 KEY_CAPS_LOCK   = 206;
	const u8 KEY_LEFT_CTRL   = 207;
	const u8 KEY_RIGHT_CTRL  = 208;
	const u8 KEY_WINDOWS     = 209;
	const u8 KEY_ARROW_UP    = 210;
	const u8 KEY_ARROW_DOWN  = 211;
	const u8 KEY_ARROW_RIGHT = 212;
	const u8 KEY_ARROW_LEFT  = 213;
	const u8 KEY_DELETE      = 214;
	const u8 KEY_INSERT      = 215;
	const u8 KEY_HOME        = 216;
	const u8 KEY_END         = 217;
	const u8 KEY_PAGE_UP     = 218;
	const u8 KEY_PAGE_DOWN   = 219;
	const u8 KEY_ESCAPE      = 220;
	const u8 KEY_RIGHT_ALT   = 221;
	const u8 KEY_LEFT_ALT    = 222;

	// Function keys
	const u8 KEY_F1  = 221;
	const u8 KEY_F2  = 222;
	const u8 KEY_F3  = 223;
	const u8 KEY_F4  = 224;
	const u8 KEY_F5  = 225;
	const u8 KEY_F6  = 226;
	const u8 KEY_F7  = 227;
	const u8 KEY_F8  = 228;
	const u8 KEY_F9  = 229;
	const u8 KEY_F10 = 230;
	const u8 KEY_F11 = 231;
	const u8 KEY_F12 = 232;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// KeyEvent
////////////////////////////////////////////////////////////////////////////////////////////////////

// Keyboard event. Extends built-in type.
class KeyEvent
{
	const u8 KEY_STATE_REST     = 0;
	const u8 KEY_STATE_PRESSED  = 1;
	const u8 KEY_STATE_RELEASED = 2; // up, back to rest
	const u8 KEY_STATE_REPEAT   = 3; // still pressed, long enough for repeat

	//u8  keyState; // one of KEY_STATE_
	//u8  keyID;    // one of Keys:KEY_XXX
	//u32 charID;   // UTF32, if not zero should count this as character input
	//u8[] allKeys; // one of KEY_STATE_, indexed by Keys:KEY_XXX

	// Start of key press? Doesn't include repeats.
	bool isKeyDown()
	{
		if(keyState == KEY_STATE_PRESSED)
			return true;

		return false;
	}

	// Is the specified key down (i.e. held)
	bool isKeyDown(u8 key)
	{
		if(allKeys == null)
			return false;

		if(allKeys[key] == KeyEvent:KEY_STATE_PRESSED)
			return true;

		return false;
	}

	// Is left/right CTRL key down?
	bool isCTRLDown()
	{
		if(allKeys[Keys:KEY_LEFT_CTRL] == KeyEvent:KEY_STATE_PRESSED || allKeys[Keys:KEY_RIGHT_CTRL] == KeyEvent:KEY_STATE_PRESSED)
			return true;

		return false;
	}

	// Is left/right CTRL key down?
	bool isShiftDown()
	{
		if(allKeys[Keys:KEY_LEFT_SHIFT] == KeyEvent:KEY_STATE_PRESSED || allKeys[Keys:KEY_RIGHT_SHIFT] == KeyEvent:KEY_STATE_PRESSED)
			return true;

		return false;
	}

	// Is left/right Alt key down?
	bool isAltDown()
	{
		if(allKeys[Keys:KEY_LEFT_ALT] == KeyEvent:KEY_STATE_PRESSED || allKeys[Keys:KEY_RIGHT_ALT] == KeyEvent:KEY_STATE_PRESSED)
			return true;

		return false;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// AllKeysState
////////////////////////////////////////////////////////////////////////////////////////////////////

// Use this to track key state, like shift/ctrl/alt up/down.
class AllKeysState
{
	u8[] keysState(256); // one of Keys:KEY_STATE_REST or Keys:KEY_STATE_PRESSED

	// Keys start at rest.
	void constructor()
	{
		for(u32 k=0; k<keysState.length(); k++)
			keysState[k] = KeyEvent:KEY_STATE_REST;
	}

	// Track key event
	void track(KeyEvent event)
	{
		if(event.keyState == KeyEvent:KEY_STATE_RELEASED || event.keyState == KeyEvent:KEY_STATE_REST)
			keysState[event.keyID] = KeyEvent:KEY_STATE_REST;
		else
			keysState[event.keyID] = KeyEvent:KEY_STATE_PRESSED;
	}

	// Is the specified key down (i.e. held)
	bool isKeyDown(u8 key)
	{
		if(keysState[key] == KeyEvent:KEY_STATE_PRESSED)
			return true;

		return false;
	}

	// Is left/right CTRL key down?
	bool isCTRLDown()
	{
		if(keysState[Keys:KEY_LEFT_CTRL] == KeyEvent:KEY_STATE_PRESSED || keysState[Keys:KEY_RIGHT_CTRL] == KeyEvent:KEY_STATE_PRESSED)
			return true;

		return false;
	}

	// Is left/right CTRL key down?
	bool isShiftDown()
	{
		if(keysState[Keys:KEY_LEFT_SHIFT] == KeyEvent:KEY_STATE_PRESSED || keysState[Keys:KEY_RIGHT_SHIFT] == KeyEvent:KEY_STATE_PRESSED)
			return true;

		return false;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IKeyboardListener
////////////////////////////////////////////////////////////////////////////////////////////////////

// Something that wishes to recieve key input events.
interface IKeyboardListener
{
	// Event object is available only for the duration of this call and owned by the event dispatcher.
	void onKeyEvent(KeyEvent event);
}