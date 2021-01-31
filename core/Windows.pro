////////////////////////////////////////////////////////////////////////////////////////////////////
// Project:       Pronto Core
// Author(s):     Michael Sikora
//
// Copyright 2019 by Prontoware Inc., All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// ImageRenderTarget2D
////////////////////////////////////////////////////////////////////////////////////////////////////

// Use a image as a render target backing a native render target (i.e. software 2D rendering).
class NativeImageRenderTarget2D implements IRenderTarget2D
{
	u64 winHandle = 0; // native window handle
	u64 rtHandle  = 0; // native render target handle
	ImageRGBA backBuffer = null; // implements IRenderTarget2D

	// Basic rendering
	void constructor(u64 winHandle, u64 rtHandle)
	{
		this.winHandle = winHandle;
		this.rtHandle  = rtHandle;

		resizeToMatchWindow();
	}

	// Resize to match - if the image already matches the dimensions of the window, nothing changes.
	void resizeToMatchWindow()
	{
		i32[4] rectVec = getWindowRect_native(winHandle, false);
		i32 winWidth  = rectVec[2];
		i32 winHeight = rectVec[3];

		if(backBuffer == null)
		{
			this.backBuffer = ImageRGBA(winWidth, winHeight);
		}
		else
		{
			if(backBuffer.width != winWidth || backBuffer.height != winHeight)
			{
				this.backBuffer = ImageRGBA(winWidth, winHeight);
			}
		}
	}

	// Call to indicate the start of rendering a new frame.
	void beginFrame()
	{
		// check if we need to resize to start
		resizeToMatchWindow();
	}

	// Call to indicate the end of rendering of a frame. Will swap backbuffer to frontbuffer etc. as needed.
	void endFrame()
	{
		// Upload to display device
		u8[] pixelsBytes = backBuffer.pixels.reinterpret(Type:U8, 0);
		writePixelsRT_native(rtHandle, pixelsBytes);
		backBuffer.pixels = pixelsBytes.reinterpret(Type:U32, 0); // revert
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// INativeWindow
////////////////////////////////////////////////////////////////////////////////////////////////////

// An OS independent window. Windows can be resized, hidden or shown by the OS at any time.
interface INativeWindow
{
	// Screen relative coordinates of the entire window area.
	Rectangle2D<i32> getExternalRect();

	// Screen relative coordinates of the inner window area, i.e. minus OS-defined title bar.
	Rectangle2D<i32> getInternalRect();

	// Show/hide
	void setVisible(bool visibleFlag);

	// Visible to user?
	bool isVisible();

	// Has user-input focus etc. Active windows are always visible.
	bool isActive();

	// Attempt to move/resize the window by external dimensions.
	bool move(i32 x, i32 y);

	// Attempt to resize the window by external dimensions.
	bool resize(u32 newWidth, u32 newHeight);

	// Maximize the window to fill the screen
	bool maximize();

	// Get a reference to a 2D/3D drawing API for the internal window area.
	IRenderTarget2D getRenderTarget();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// NativeWindow
////////////////////////////////////////////////////////////////////////////////////////////////////

// Default implementation of INativeWindow.
class NativeWindow implements INativeWindow, IInputTarget, ITask
{
	const u8 WINDOW_STATE_INVISIBLE        = 1;
	const u8 WINDOW_STATE_VISIBLE_INACTIVE = 2;
	const u8 WINDOW_STATE_VISIBLE_ACTIVE   = 3;

	shared INativeWindow globalDefaultNativeWindow = null; // created via NativeWindow:getDefaultWindow() once per thread as needed.

	u64 winHandle = 0; // native window "handle". Do not assume this means anything specific like a WIN32 API HWND.
	InputTarget inputTarget = InputTarget(); // implements IInputTarget interface
	IRenderTarget2D rt = null;

	// Create from existing native window.
	void constructor(u64 winHandle)
	{
		this.winHandle = winHandle;

		GlobalTasks:addProcessTask(this);
	}

	// Destroys native window. Set this.winHandle to 0 if you want to just delete this container object.
	void destroy()
	{
		if(winHandle != 0)
			destroyWindow_native(winHandle);
		winHandle = 0;

		GlobalTasks:removeProcessTask(this);
	}

	// Screen relative coordinates of the entire window area.
	Rectangle2D<i32> getExternalRect()
	{
		i32[4] rectVec = getWindowRect_native(winHandle, true);
		return Rectangle2D<i32>(rectVec[0], rectVec[1], rectVec[2], rectVec[3]);
	}

	// Screen relative coordinates of the inner window area, i.e. minus OS-defined title bar.
	Rectangle2D<i32> getInternalRect()
	{
		i32[4] rectVec = getWindowRect_native(winHandle, false);
		return Rectangle2D<i32>(rectVec[0], rectVec[1], rectVec[2], rectVec[3]);
	}

	// Implements ITask, called to pump input etc. events
	void run()
	{
		dispatchInputEvents();
	}

	// Show/hide
	void setVisible(bool visibleFlag)
	{
		showWindow_native(winHandle, visibleFlag);
	}

	// Visible to user?
	bool isVisible()
	{
		u8 winState = getWindowState_native(winHandle);
		if(winState == WINDOW_STATE_INVISIBLE)
			return false;

		return true;
	}

	// Has user-input focus etc. Active windows are always visible.
	bool isActive()
	{
		u8 winState = getWindowState_native(winHandle);
		if(winState == WINDOW_STATE_VISIBLE_ACTIVE)
			return true;

		return false;
	}

	// Attempt to move the window.
	bool move(i32 x, i32 y)
	{
		i32[4] extRect = getWindowRect_native(winHandle, true);
		i32[4] newRect = i32(x, y, extRect[2], extRect[3]);
		return moveWindow_native(winHandle, newRect);
	}

	// Attempt to resize the window by internal dimensions.
	bool resize(u32 newWidth, u32 newHeight)
	{
		i32[4] extRect = getWindowRect_native(winHandle, true);
		i32[4] newRect = i32(extRect[0], extRect[1], newWidth, newHeight);
		return moveWindow_native(winHandle, newRect);
	}

	// Maximize the window to fill the screen
	bool maximize()
	{
		return maximizeWindow_native(winHandle);
	}

	// Set title of window
	void setTitle(String<u8> newTitle)
	{
		setWindowTitle_native(winHandle, newTitle);
	}

	// Dispath all input events directed at this window
	void dispatchInputEvents()
	{
		KeyEvent[] keyEvents = getKeyEvents_native(winHandle);
		inputTarget.dispatchKeyEvents(keyEvents);

		MouseEvent[] mouseEvents = getMouseEvents_native(winHandle);
		inputTarget.dispatchMouseEvents(mouseEvents);

		TouchEvent[] touchEvents = getTouchEvents_native(winHandle);
		inputTarget.dispatchTouchEvents(touchEvents);

		GamepadEvent[] gamepadEvents = getGamepadEvents_native(winHandle);
		inputTarget.dispatchGamepadEvents(gamepadEvents);
	}

	// Get a reference to a 2D/3D drawing object API for the internal window area. The render target will normally be resized automatically to match the native window.
	IRenderTarget2D getRenderTarget()
	{
		if(rt != null)
			return rt;

		if(rt == null)
		{
			// get handle
			u64 rtHandle = getRTForWindow_native(winHandle);
			if(rtHandle == 0)
				return null;
			
			// supports 3D?
			Rectangle2D<i32> internalRect = getInternalRect();
			if(isRT3D_native(rtHandle) == true)
			{
				rt = RenderTarget3D(rtHandle, RenderTarget3D:RT_SCREEN, 1);
			}
			else
			{
				// 2D only software rendering
				rt = NativeImageRenderTarget2D(winHandle, rtHandle);
			}
		}

		return rt;
	}

	// Some operating systems (like mobile platforms) provide a window at application creation based 
	// on properties before the application is run. i.e.
	// - Mobile platforms will generally support a single quasi-fullscreen window.
	// - Console platforms generally support a single fullscreen "window". 
	// - Desktop OSs generally support creation of multiple windows.
	// Returns null if no default window available.
	shared NativeWindow getDefaultWindow(bool want3DRenderTarget, u8 colorFormat)
	{
		if(globalDefaultNativeWindow != null)
			return globalDefaultNativeWindow;

		u64 newWinHandle = getDefaultWindowHandle_native(want3DRenderTarget, colorFormat);
		if(newWinHandle == 0)
			return null;

		globalDefaultNativeWindow = NativeWindow(newWinHandle);
		return globalDefaultNativeWindow;
	}

	// Create a primary or secondary application window. Some OS do not support custom windows sizes.
	// winRect is internal drawable area of window by default. Window may be different size than
	// requested.
	shared INativeWindow createWindow(bool want3DRenderTarget, u8 colorFormat, Rectangle2D<i32> winRect, bool winRectIsExternal, bool wantOSTitleBar)
	{
		NativeWindow newWindow = null;

		i32[4] winRectVec = i32(winRect.getMinX(), winRect.getMinY(), winRect.getWidth(), winRect.getHeight());
		u64 newWinHandle = createWindow_native(want3DRenderTarget, colorFormat, winRectVec, winRectIsExternal, wantOSTitleBar);
		if(newWinHandle == 0)
			return null;

		newWindow = NativeWindow(newWinHandle);

		return newWindow;
	}

	// Create a primary application window. Some OS do not support custom windows sizes.
	// Mobile OSs will generally return a full screen window you can work within.
	shared INativeWindow createFullScreenWindow(bool want3DRenderTarget, u8 colorFormat)
	{
		NativeWindow newWindow = null;

		i32[4] winRectVec = i32(0, 0, 0, 0); // all zero's means full screen / maximized
		u64 newWinHandle = createWindow_native(want3DRenderTarget, colorFormat, winRectVec, false, false);
		if(newWinHandle == 0)
			return null;

		newWindow = NativeWindow(newWinHandle);

		return newWindow;
	}
}