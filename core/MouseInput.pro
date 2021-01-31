////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// MouseEvent
////////////////////////////////////////////////////////////////////////////////////////////////////

// Mouse / pointing device event. Extends built-in.
class MouseEvent
{
	// const ID_PRIMARYDOWN   = 0;
	// const ID_PRIMARYUP     = 1;
	// const ID_SECONDARYDOWN = 2;
	// const ID_SECONDARYUP   = 3;
	// const ID_X0UP          = 4;
	// const ID_X0DOWN        = 5;
	// const ID_X1DOWN        = 6;
	// const ID_X1UP          = 7;
	// const ID_X2DOWN        = 8;
	// const ID_X2UP          = 9;
	// const ID_X3DOWN        = 10;
	// const ID_X3UP          = 11;
	// const ID_X4DOWN        = 12;
	// const ID_X4UP          = 13;
	// const ID_X5DOWN        = 14;
	// const ID_X5UP          = 15;
	// const ID_WHEELDOWN     = 16;
	// const ID_WHEELUP       = 17;
	// const ID_MOUSEMOVE     = 18;

	// const BUTTON_PRIMARY   = 0;
	// const BUTTON_SECONDARY = 1;
	// const BUTTON_X0        = 2;
	// const BUTTON_X1        = 3;
	// const BUTTON_X2        = 4;
	// const BUTTON_X3        = 5;
	// const BUTTON_X4        = 6;
	// const BUTTON_X5        = 7;

	// const u8 MAX_MOUSE_BUTTONS = 8;

	// u8[8] buttons; // indexed by BUTTON_XXX, where true = down
	// i32   screenX; // pixel position
	// i32   screenY; // pixel position
	// i32   windowX; // pixel position relative to focused window origin at top-left.
	// i32   windowY; // pixel position relative to focused window origin at top-left.
	// u8    eventID; // button that changed (if any), one of ID_XXX

	// Track mouse button pressed by event ID.
	void track()
	{
		if(eventID == ID_PRIMARYDOWN)
			buttons[BUTTON_PRIMARY] = true;
		else if(eventID == ID_PRIMARYUP)
			buttons[BUTTON_PRIMARY] = false;

		if(eventID == ID_SECONDARYDOWN)
			buttons[BUTTON_SECONDARY] = true;
		else if(eventID == ID_SECONDARYUP)
			buttons[BUTTON_SECONDARY] = false;

		if(eventID == ID_X0UP)
			buttons[BUTTON_X0] = true;
		else if(eventID == ID_X0DOWN)
			buttons[BUTTON_X0] = false;

		if(eventID == ID_X1DOWN)
			buttons[BUTTON_X1] = true;
		else  if(eventID == ID_X1UP)
			buttons[BUTTON_X1] = false;

		if(eventID == ID_X2DOWN)
			buttons[BUTTON_X2] = true;
		else if(eventID == ID_X2UP)
			buttons[BUTTON_X2] = false;

		if(eventID == ID_X3DOWN)
			buttons[BUTTON_X3] = true;
		else if(eventID == ID_X3UP)
			buttons[BUTTON_X3] = false;

		if(eventID == ID_X4DOWN)
			buttons[BUTTON_X4] = true;
		else if(eventID == ID_X4UP)
			buttons[BUTTON_X4] = false;

		if(eventID == ID_X5DOWN)
			buttons[BUTTON_X5] = true;
		else if(eventID == ID_X5UP)
			buttons[BUTTON_X5] = false;
	}

	// Is a specific button currently pressed/down?
	bool isButtonDown(u8 buttonID)
	{
		return buttons[buttonID];
	}

	// Get button/event name from event id
	shared String<u8> getEventName(u8 eventID)
	{
		if(eventID == ID_MOUSEMOVE)
			return String<u8>("move"); // mouse move
		else if(eventID == ID_PRIMARYDOWN)
			return String<u8>("primary down");
		else if(eventID == ID_PRIMARYUP)
			return String<u8>("primary up");
		else if(eventID == ID_SECONDARYDOWN)
			return String<u8>("secondary down");
		else if(eventID == ID_SECONDARYUP)
			return String<u8>("secondary up");
		else if(eventID == ID_X0DOWN)
			return String<u8>("x0 down");
		else if(eventID == ID_X0UP)
			return String<u8>("x0 up");
		else if(eventID == ID_X1DOWN)
			return String<u8>("x1 down");
		else if(eventID == ID_X1UP)
			return String<u8>("x1 up");
		else if(eventID == ID_X2DOWN)
			return String<u8>("x2 down");
		else if(eventID == ID_X2UP)
			return String<u8>("x2 up");
		else if(eventID == ID_X3DOWN)
			return String<u8>("x3 down");
		else if(eventID == ID_X3UP)
			return String<u8>("x3 up");
		else if(eventID == ID_X4DOWN)
			return String<u8>("x4 down");
		else if(eventID == ID_X4UP)
			return String<u8>("x4 up");
		else if(eventID == ID_X5DOWN)
			return String<u8>("x5 down");
		else if(eventID == ID_X5UP)
			return String<u8>("x5 up");
		else if(eventID == ID_WHEELDOWN)
			return String<u8>("wheel down");
		else if(eventID == ID_WHEELUP)
			return String<u8>("wheel up");

		return String<u8>("unknown");
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// IMouseListener
////////////////////////////////////////////////////////////////////////////////////////////////////

// Something that wishes to recieve mouse input events.
interface IMouseListener
{
	// Event object is available only for the duration of this call and owned by the event dispatcher.
	void onMouseEvent(MouseEvent event);
}